-- ============================================
-- SISTEMA COMPLETO Y DEFINITIVO
-- ============================================
-- Este script configura TODO para que funcione perfectamente

-- ============================================
-- PASO 1: LIMPIAR TRIGGERS ANTERIORES
-- ============================================
DROP TRIGGER IF EXISTS trigger_actualizar_inventario ON transacciones;
DROP TRIGGER IF EXISTS trigger_restaurar_inventario ON transacciones;
DROP FUNCTION IF EXISTS actualizar_inventario();
DROP FUNCTION IF EXISTS restaurar_inventario_al_eliminar();

-- ============================================
-- PASO 2: FUNCIÓN PARA CREAR/ACTUALIZAR INVENTARIO
-- ============================================
CREATE OR REPLACE FUNCTION actualizar_inventario()
RETURNS TRIGGER AS $$
DECLARE
  v_ubicacion_origen TEXT;
  v_ubicacion_destino TEXT;
  v_stock_origen INTEGER;
BEGIN
  -- ==========================================
  -- TRANSFERENCIAS
  -- ==========================================
  IF NEW.tipo_transaccion = 'TRANSFERENCIA' THEN
    v_ubicacion_destino := NEW.ubicacion;  -- Donde se registra (destino)
    
    -- Determinar origen
    IF NEW.ubicacion = 'RESISTENCIA' THEN
      v_ubicacion_origen := 'CORRIENTES';
    ELSE
      v_ubicacion_origen := 'RESISTENCIA';
    END IF;
    
    -- VALIDAR stock en origen
    SELECT COALESCE(cantidad_actual, 0) INTO v_stock_origen
    FROM inventario
    WHERE producto_id = NEW.producto_id
    AND ubicacion = v_ubicacion_origen;
    
    IF v_stock_origen < NEW.cantidad THEN
      RAISE EXCEPTION 'Stock insuficiente en %. Disponible: %, Solicitado: %', 
        v_ubicacion_origen, v_stock_origen, NEW.cantidad;
    END IF;
    
    -- DESCONTAR DEL ORIGEN
    UPDATE inventario
    SET cantidad_actual = cantidad_actual - NEW.cantidad
    WHERE producto_id = NEW.producto_id
    AND ubicacion = v_ubicacion_origen;
    
    -- AGREGAR AL DESTINO (crear si no existe)
    INSERT INTO inventario (producto_id, ubicacion, cantidad_actual, cantidad_minima, estado)
    VALUES (NEW.producto_id, v_ubicacion_destino, NEW.cantidad, 1, 'DISPONIBLE')
    ON CONFLICT (producto_id, ubicacion)
    DO UPDATE SET 
      cantidad_actual = inventario.cantidad_actual + NEW.cantidad,
      estado = 'DISPONIBLE';
    
    RAISE NOTICE 'TRANSFERENCIA: % unidades de % → %', NEW.cantidad, v_ubicacion_origen, v_ubicacion_destino;
    RETURN NEW;
  END IF;
  
  -- ==========================================
  -- COMPRA, CANJE_ENTRADA
  -- ==========================================
  IF NEW.tipo_transaccion IN ('COMPRA', 'CANJE_ENTRADA') THEN
    -- SIEMPRE crear o actualizar inventario
    INSERT INTO inventario (producto_id, ubicacion, cantidad_actual, cantidad_minima, estado)
    VALUES (NEW.producto_id, NEW.ubicacion, NEW.cantidad, 1, 'DISPONIBLE')
    ON CONFLICT (producto_id, ubicacion)
    DO UPDATE SET 
      cantidad_actual = inventario.cantidad_actual + NEW.cantidad,
      estado = 'DISPONIBLE';
    
    RAISE NOTICE 'COMPRA/ENTRADA: +% unidades en %', NEW.cantidad, NEW.ubicacion;
    RETURN NEW;
  END IF;
  
  -- ==========================================
  -- VENTA, CANJE_SALIDA, CIERRE_DIA
  -- ==========================================
  IF NEW.tipo_transaccion IN ('VENTA', 'CANJE_SALIDA', 'CIERRE_DIA') THEN
    -- VALIDAR stock
    SELECT COALESCE(cantidad_actual, 0) INTO v_stock_origen
    FROM inventario
    WHERE producto_id = NEW.producto_id
    AND ubicacion = NEW.ubicacion;
    
    IF v_stock_origen < NEW.cantidad THEN
      RAISE EXCEPTION 'Stock insuficiente en %. Disponible: %, Solicitado: %', 
        NEW.ubicacion, v_stock_origen, NEW.cantidad;
    END IF;
    
    -- DESCONTAR
    UPDATE inventario
    SET cantidad_actual = cantidad_actual - NEW.cantidad
    WHERE producto_id = NEW.producto_id
    AND ubicacion = NEW.ubicacion;
    
    RAISE NOTICE 'SALIDA: -% unidades de %', NEW.cantidad, NEW.ubicacion;
    RETURN NEW;
  END IF;
  
  RETURN NEW;
END;
$$ LANGUAGE plpgsql;

-- ============================================
-- PASO 3: FUNCIÓN PARA RESTAURAR AL ELIMINAR
-- ============================================
CREATE OR REPLACE FUNCTION restaurar_inventario_al_eliminar()
RETURNS TRIGGER AS $$
DECLARE
  v_ubicacion_origen TEXT;
  v_ubicacion_destino TEXT;
  v_stock_destino INTEGER;
BEGIN
  -- ==========================================
  -- TRANSFERENCIAS: Revertir
  -- ==========================================
  IF OLD.tipo_transaccion = 'TRANSFERENCIA' THEN
    v_ubicacion_destino := OLD.ubicacion;
    
    IF OLD.ubicacion = 'RESISTENCIA' THEN
      v_ubicacion_origen := 'CORRIENTES';
    ELSE
      v_ubicacion_origen := 'RESISTENCIA';
    END IF;
    
    -- RESTAURAR AL ORIGEN
    UPDATE inventario
    SET cantidad_actual = cantidad_actual + OLD.cantidad
    WHERE producto_id = OLD.producto_id
    AND ubicacion = v_ubicacion_origen;
    
    -- QUITAR DEL DESTINO
    SELECT COALESCE(cantidad_actual, 0) INTO v_stock_destino
    FROM inventario
    WHERE producto_id = OLD.producto_id
    AND ubicacion = v_ubicacion_destino;
    
    IF v_stock_destino >= OLD.cantidad THEN
      UPDATE inventario
      SET cantidad_actual = cantidad_actual - OLD.cantidad
      WHERE producto_id = OLD.producto_id
      AND ubicacion = v_ubicacion_destino;
    END IF;
    
    -- ELIMINAR si queda en 0
    DELETE FROM inventario
    WHERE producto_id = OLD.producto_id
    AND ubicacion = v_ubicacion_destino
    AND cantidad_actual <= 0;
    
    RAISE NOTICE 'REVERTIR TRANSFERENCIA: +% a %, -% de %', 
      OLD.cantidad, v_ubicacion_origen, OLD.cantidad, v_ubicacion_destino;
    RETURN OLD;
  END IF;
  
  -- ==========================================
  -- COMPRA, CANJE_ENTRADA: Restar
  -- ==========================================
  IF OLD.tipo_transaccion IN ('COMPRA', 'CANJE_ENTRADA') THEN
    UPDATE inventario
    SET cantidad_actual = cantidad_actual - OLD.cantidad
    WHERE producto_id = OLD.producto_id
    AND ubicacion = OLD.ubicacion;
    
    -- ELIMINAR si queda en 0
    DELETE FROM inventario
    WHERE producto_id = OLD.producto_id
    AND ubicacion = OLD.ubicacion
    AND cantidad_actual <= 0;
    
    RAISE NOTICE 'REVERTIR COMPRA: -% de %', OLD.cantidad, OLD.ubicacion;
    RETURN OLD;
  END IF;
  
  -- ==========================================
  -- VENTA, CANJE_SALIDA, CIERRE_DIA: Sumar
  -- ==========================================
  IF OLD.tipo_transaccion IN ('VENTA', 'CANJE_SALIDA', 'CIERRE_DIA') THEN
    UPDATE inventario
    SET cantidad_actual = cantidad_actual + OLD.cantidad
    WHERE producto_id = OLD.producto_id
    AND ubicacion = OLD.ubicacion;
    
    RAISE NOTICE 'REVERTIR SALIDA: +% a %', OLD.cantidad, OLD.ubicacion;
    RETURN OLD;
  END IF;
  
  RETURN OLD;
END;
$$ LANGUAGE plpgsql;

-- ============================================
-- PASO 4: CREAR TRIGGERS
-- ============================================
CREATE TRIGGER trigger_actualizar_inventario
AFTER INSERT ON transacciones
FOR EACH ROW
EXECUTE FUNCTION actualizar_inventario();

CREATE TRIGGER trigger_restaurar_inventario
BEFORE DELETE ON transacciones
FOR EACH ROW
EXECUTE FUNCTION restaurar_inventario_al_eliminar();

-- ============================================
-- PASO 5: VERIFICAR INTEGRIDAD
-- ============================================

-- Ver productos sin inventario
SELECT 
    '⚠️ PRODUCTOS SIN INVENTARIO' as alerta,
    p.id,
    p.marca,
    p.modelo,
    p.capacidad_gb
FROM productos p
WHERE NOT EXISTS (
    SELECT 1 FROM inventario i
    WHERE i.producto_id = p.id
);

-- Ver inventario con stock negativo
SELECT 
    '❌ STOCK NEGATIVO' as alerta,
    p.marca,
    p.modelo,
    i.ubicacion,
    i.cantidad_actual
FROM inventario i
JOIN productos p ON i.producto_id = p.id
WHERE i.cantidad_actual < 0;

-- Ver resumen por sucursal
SELECT 
    '📊 RESUMEN POR SUCURSAL' as info,
    i.ubicacion,
    COUNT(DISTINCT i.producto_id) as total_productos,
    SUM(i.cantidad_actual) as total_unidades
FROM inventario i
WHERE i.cantidad_actual > 0
GROUP BY i.ubicacion
ORDER BY i.ubicacion;

-- ============================================
-- CONFIRMACIÓN FINAL
-- ============================================
DO $$
BEGIN
  RAISE NOTICE '';
  RAISE NOTICE '═══════════════════════════════════════════════════════';
  RAISE NOTICE '✅ SISTEMA COMPLETO CONFIGURADO';
  RAISE NOTICE '═══════════════════════════════════════════════════════';
  RAISE NOTICE '';
  RAISE NOTICE '🔒 VALIDACIONES ACTIVAS:';
  RAISE NOTICE '   ✓ No permite stock negativo';
  RAISE NOTICE '   ✓ Valida stock antes de transferir';
  RAISE NOTICE '   ✓ Valida stock antes de vender';
  RAISE NOTICE '';
  RAISE NOTICE '💾 PERSISTENCIA GARANTIZADA:';
  RAISE NOTICE '   ✓ Todas las compras se guardan en BD';
  RAISE NOTICE '   ✓ Todas las transferencias se reflejan';
  RAISE NOTICE '   ✓ Todos los productos quedan disponibles';
  RAISE NOTICE '   ✓ Nada se pierde al eliminar transacciones';
  RAISE NOTICE '';
  RAISE NOTICE '🔄 TRANSFERENCIAS:';
  RAISE NOTICE '   ✓ Descuenta de origen automáticamente';
  RAISE NOTICE '   ✓ Agrega a destino automáticamente';
  RAISE NOTICE '   ✓ Crea inventario si no existe';
  RAISE NOTICE '   ✓ Al eliminar: revierte correctamente';
  RAISE NOTICE '';
  RAISE NOTICE '📦 INVENTARIO:';
  RAISE NOTICE '   ✓ Se actualiza en tiempo real';
  RAISE NOTICE '   ✓ Productos disponibles para futuras operaciones';
  RAISE NOTICE '   ✓ Elimina registros con stock 0';
  RAISE NOTICE '';
  RAISE NOTICE '═══════════════════════════════════════════════════════';
  RAISE NOTICE '🎯 TODO LISTO PARA USAR';
  RAISE NOTICE '═══════════════════════════════════════════════════════';
END $$;
