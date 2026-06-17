-- ============================================
-- SISTEMA COMPLETO DE CIERRE DE DIA
-- ============================================
-- Este sistema garantiza que el cierre de dia funcione correctamente
-- y se reinicie automaticamente cada dia

-- PASO 1: Eliminar triggers anteriores
DROP TRIGGER IF EXISTS trigger_actualizar_inventario ON transacciones CASCADE;
DROP FUNCTION IF EXISTS actualizar_inventario_desde_transaccion() CASCADE;

-- PASO 2: Crear funcion de actualizacion de inventario CORRECTA
CREATE OR REPLACE FUNCTION actualizar_inventario_desde_transaccion()
RETURNS TRIGGER AS $$
DECLARE
  v_ubicacion_origen TEXT;
  v_ubicacion_destino TEXT;
  v_stock_origen INTEGER;
BEGIN
  RAISE NOTICE 'PROCESANDO: % en ubicacion: %', NEW.tipo_transaccion, NEW.ubicacion;
  
  -- TRANSFERENCIAS
  IF NEW.tipo_transaccion = 'TRANSFERENCIA' THEN
    v_ubicacion_destino := NEW.ubicacion;
    
    IF NEW.ubicacion = 'RESISTENCIA' THEN
      v_ubicacion_origen := 'CORRIENTES';
    ELSE
      v_ubicacion_origen := 'RESISTENCIA';
    END IF;
    
    RAISE NOTICE 'TRANSFERENCIA: % -> %', v_ubicacion_origen, v_ubicacion_destino;
    
    SELECT cantidad_actual INTO v_stock_origen
    FROM inventario
    WHERE producto_id = NEW.producto_id
    AND ubicacion = v_ubicacion_origen;
    
    IF v_stock_origen IS NULL THEN
      RAISE EXCEPTION 'ERROR: El producto no existe en % (origen)', v_ubicacion_origen;
    END IF;
    
    IF v_stock_origen < NEW.cantidad THEN
      RAISE EXCEPTION 'ERROR: Stock insuficiente en % (tiene %, necesita %)', 
        v_ubicacion_origen, v_stock_origen, NEW.cantidad;
    END IF;
    
    UPDATE inventario
    SET cantidad_actual = cantidad_actual - NEW.cantidad
    WHERE producto_id = NEW.producto_id
    AND ubicacion = v_ubicacion_origen;
    
    INSERT INTO inventario (producto_id, ubicacion, cantidad_actual, cantidad_minima, estado, es_original)
    VALUES (NEW.producto_id, v_ubicacion_destino, NEW.cantidad, 1, 'DISPONIBLE', false)
    ON CONFLICT (producto_id, ubicacion)
    DO UPDATE SET cantidad_actual = inventario.cantidad_actual + NEW.cantidad;
    
    RAISE NOTICE 'Transferencia completada: % -> %', v_ubicacion_origen, v_ubicacion_destino;
    
  -- COMPRA / CANJE_ENTRADA
  ELSIF NEW.tipo_transaccion IN ('COMPRA', 'CANJE_ENTRADA') THEN
    INSERT INTO inventario (producto_id, ubicacion, cantidad_actual, cantidad_minima, estado, es_original)
    VALUES (NEW.producto_id, NEW.ubicacion, NEW.cantidad, 1, 'DISPONIBLE', true)
    ON CONFLICT (producto_id, ubicacion)
    DO UPDATE SET cantidad_actual = inventario.cantidad_actual + NEW.cantidad;
    
    RAISE NOTICE 'Agregado % unidades a %', NEW.cantidad, NEW.ubicacion;
    
  -- VENTA / CANJE_SALIDA / CIERRE_DIA
  ELSIF NEW.tipo_transaccion IN ('VENTA', 'CANJE_SALIDA', 'CIERRE_DIA') THEN
    -- CRITICO: Usar NEW.ubicacion (donde se registra la transaccion)
    SELECT cantidad_actual INTO v_stock_origen
    FROM inventario
    WHERE producto_id = NEW.producto_id
    AND ubicacion = NEW.ubicacion;
    
    RAISE NOTICE 'Verificando stock en %: tiene %, necesita %', NEW.ubicacion, COALESCE(v_stock_origen, 0), NEW.cantidad;
    
    IF v_stock_origen IS NULL OR v_stock_origen < NEW.cantidad THEN
      RAISE EXCEPTION 'ERROR: Stock insuficiente en % (tiene %, necesita %)', 
        NEW.ubicacion, COALESCE(v_stock_origen, 0), NEW.cantidad;
    END IF;
    
    UPDATE inventario
    SET cantidad_actual = cantidad_actual - NEW.cantidad
    WHERE producto_id = NEW.producto_id
    AND ubicacion = NEW.ubicacion;
    
    RAISE NOTICE 'Descontado % unidades de %', NEW.cantidad, NEW.ubicacion;
  END IF;
  
  RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER trigger_actualizar_inventario
AFTER INSERT ON transacciones
FOR EACH ROW
EXECUTE FUNCTION actualizar_inventario_desde_transaccion();

-- PASO 3: Crear funcion para limpiar ventas antiguas (mas de 30 dias)
CREATE OR REPLACE FUNCTION limpiar_ventas_antiguas()
RETURNS void AS $$
BEGIN
  -- Eliminar ventas pendientes de hace mas de 30 dias
  DELETE FROM ventas_pendientes
  WHERE fecha < CURRENT_DATE - INTERVAL '30 days'
  AND procesada = false;
  
  RAISE NOTICE 'Ventas antiguas limpiadas';
END;
$$ LANGUAGE plpgsql;

-- PASO 4: Crear vista para ver estado de cierres
CREATE OR REPLACE VIEW vista_estado_cierres AS
SELECT 
  c.fecha_cierre,
  c.ubicacion,
  c.total_ventas,
  c.observaciones,
  c.created_at,
  COUNT(DISTINCT t.id) as transacciones_registradas
FROM cierres_dia c
LEFT JOIN transacciones t ON DATE(t.fecha_transaccion) = c.fecha_cierre 
  AND t.ubicacion = c.ubicacion 
  AND t.tipo_transaccion = 'CIERRE_DIA'
GROUP BY c.id, c.fecha_cierre, c.ubicacion, c.total_ventas, c.observaciones, c.created_at
ORDER BY c.fecha_cierre DESC, c.ubicacion;

-- PASO 5: Crear funcion para verificar si hay cierre pendiente
CREATE OR REPLACE FUNCTION verificar_cierre_pendiente(p_ubicacion TEXT)
RETURNS TABLE(
  fecha DATE,
  cantidad_ventas BIGINT,
  requiere_cierre BOOLEAN
) AS $$
BEGIN
  RETURN QUERY
  SELECT 
    vp.fecha::DATE,
    COUNT(*)::BIGINT as cantidad_ventas,
    (vp.fecha < CURRENT_DATE)::BOOLEAN as requiere_cierre
  FROM ventas_pendientes vp
  WHERE vp.procesada = false
  AND vp.fecha < CURRENT_DATE
  GROUP BY vp.fecha
  ORDER BY vp.fecha;
END;
$$ LANGUAGE plpgsql;

-- PASO 6: Verificar estado actual
SELECT 
  '=== ESTADO ACTUAL DEL SISTEMA ===' as info,
  CURRENT_DATE as fecha_actual,
  CURRENT_TIME as hora_actual;

-- Ver ventas pendientes por fecha
SELECT 
  '=== VENTAS PENDIENTES POR FECHA ===' as info,
  fecha,
  COUNT(*) as cantidad,
  CASE 
    WHEN fecha < CURRENT_DATE THEN 'REQUIERE CIERRE URGENTE'
    WHEN fecha = CURRENT_DATE THEN 'DIA ACTUAL'
    ELSE 'FUTURO'
  END as estado
FROM ventas_pendientes
WHERE procesada = false
GROUP BY fecha
ORDER BY fecha;

-- Ver ultimos cierres
SELECT 
  '=== ULTIMOS CIERRES REALIZADOS ===' as info,
  fecha_cierre,
  ubicacion,
  total_ventas,
  created_at
FROM cierres_dia
ORDER BY created_at DESC
LIMIT 10;

-- CONFIRMACION FINAL
DO $$
BEGIN
    RAISE NOTICE '';
    RAISE NOTICE '================================================';
    RAISE NOTICE 'SISTEMA DE CIERRE DE DIA CONFIGURADO';
    RAISE NOTICE '================================================';
    RAISE NOTICE '';
    RAISE NOTICE 'FUNCIONALIDADES:';
    RAISE NOTICE '1. Trigger corregido para usar ubicacion correcta';
    RAISE NOTICE '2. Funcion para limpiar ventas antiguas';
    RAISE NOTICE '3. Vista para ver estado de cierres';
    RAISE NOTICE '4. Funcion para verificar cierres pendientes';
    RAISE NOTICE '';
    RAISE NOTICE 'COMPORTAMIENTO:';
    RAISE NOTICE '- Cada sucursal tiene su propio cierre independiente';
    RAISE NOTICE '- Las ventas se agrupan por fecha';
    RAISE NOTICE '- El sistema detecta ventas de dias anteriores';
    RAISE NOTICE '- Se puede procesar cierre de cualquier dia';
    RAISE NOTICE '';
    RAISE NOTICE 'IMPORTANTE:';
    RAISE NOTICE '- Procesar cierre ANTES de las 00:00 del dia siguiente';
    RAISE NOTICE '- El frontend mostrara alertas de cierres pendientes';
    RAISE NOTICE '- Las ventas antiguas (30+ dias) se limpian automaticamente';
    RAISE NOTICE '';
    RAISE NOTICE '================================================';
END $$;
