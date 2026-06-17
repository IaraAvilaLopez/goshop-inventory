-- ============================================
-- MEJORAR LÓGICA DE STOCK EN 0
-- ============================================

-- PROBLEMA: Cuando un producto llega a 0, se elimina del inventario
-- SOLUCIÓN: Mantener el registro con 0 para que no se pierda el historial

-- PASO 1: Crear función para prevenir stock negativo
CREATE OR REPLACE FUNCTION prevenir_stock_negativo()
RETURNS TRIGGER AS $$
BEGIN
    IF NEW.cantidad_actual < 0 THEN
        RAISE EXCEPTION 'No se puede tener stock negativo. Producto: %, Ubicación: %, Cantidad: %',
            NEW.producto_id, NEW.ubicacion, NEW.cantidad_actual;
    END IF;
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

-- Crear trigger para validar antes de INSERT/UPDATE
DROP TRIGGER IF EXISTS trigger_validar_stock_positivo ON inventario;
CREATE TRIGGER trigger_validar_stock_positivo
BEFORE INSERT OR UPDATE ON inventario
FOR EACH ROW
EXECUTE FUNCTION prevenir_stock_negativo();

-- PASO 2: Modificar trigger de DELETE en transacciones
DROP TRIGGER IF EXISTS trigger_restaurar_inventario ON transacciones;
DROP FUNCTION IF EXISTS restaurar_inventario_al_eliminar();

CREATE OR REPLACE FUNCTION restaurar_inventario_al_eliminar()
RETURNS TRIGGER AS $$
DECLARE
  v_ubicacion_origen TEXT;
  v_ubicacion_destino TEXT;
  v_stock_destino INTEGER;
BEGIN
  -- TRANSFERENCIAS: Revertir
  IF OLD.tipo_transaccion = 'TRANSFERENCIA' THEN
    v_ubicacion_destino := OLD.ubicacion;
    
    IF OLD.ubicacion = 'RESISTENCIA' THEN
      v_ubicacion_origen := 'CORRIENTES';
    ELSE
      v_ubicacion_origen := 'RESISTENCIA';
    END IF;
    
    -- RESTAURAR AL ORIGEN (crear si no existe)
    INSERT INTO inventario (producto_id, ubicacion, cantidad_actual, cantidad_minima, estado)
    VALUES (OLD.producto_id, v_ubicacion_origen, OLD.cantidad, 1, 'DISPONIBLE')
    ON CONFLICT (producto_id, ubicacion)
    DO UPDATE SET cantidad_actual = inventario.cantidad_actual + OLD.cantidad;
    
    -- QUITAR DEL DESTINO
    UPDATE inventario
    SET cantidad_actual = cantidad_actual - OLD.cantidad
    WHERE producto_id = OLD.producto_id
    AND ubicacion = v_ubicacion_destino;
    
    -- NO ELIMINAR, solo dejar en 0
    -- Esto mantiene el historial de que el producto existió en esa sucursal
    
    RAISE NOTICE 'REVERTIR TRANSFERENCIA: +% a %, -% de %', 
      OLD.cantidad, v_ubicacion_origen, OLD.cantidad, v_ubicacion_destino;
    RETURN OLD;
  END IF;
  
  -- COMPRA, CANJE_ENTRADA: Restar
  IF OLD.tipo_transaccion IN ('COMPRA', 'CANJE_ENTRADA') THEN
    UPDATE inventario
    SET cantidad_actual = cantidad_actual - OLD.cantidad
    WHERE producto_id = OLD.producto_id
    AND ubicacion = OLD.ubicacion;
    
    -- NO ELIMINAR registros con 0
    
    RAISE NOTICE 'REVERTIR COMPRA: -% de %', OLD.cantidad, OLD.ubicacion;
    RETURN OLD;
  END IF;
  
  -- VENTA, CANJE_SALIDA, CIERRE_DIA: Sumar
  IF OLD.tipo_transaccion IN ('VENTA', 'CANJE_SALIDA', 'CIERRE_DIA') THEN
    INSERT INTO inventario (producto_id, ubicacion, cantidad_actual, cantidad_minima, estado)
    VALUES (OLD.producto_id, OLD.ubicacion, OLD.cantidad, 1, 'DISPONIBLE')
    ON CONFLICT (producto_id, ubicacion)
    DO UPDATE SET cantidad_actual = inventario.cantidad_actual + OLD.cantidad;
    
    RAISE NOTICE 'REVERTIR SALIDA: +% a %', OLD.cantidad, OLD.ubicacion;
    RETURN OLD;
  END IF;
  
  RETURN OLD;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER trigger_restaurar_inventario
BEFORE DELETE ON transacciones
FOR EACH ROW
EXECUTE FUNCTION restaurar_inventario_al_eliminar();

-- PASO 2: Verificar productos con stock 0
SELECT 
    'PRODUCTOS CON STOCK 0' as info,
    i.ubicacion,
    p.marca,
    p.modelo,
    i.cantidad_actual,
    i.estado
FROM inventario i
JOIN productos p ON i.producto_id = p.id
WHERE i.cantidad_actual = 0
ORDER BY i.ubicacion, p.marca;

-- CONFIRMACIÓN
DO $$
BEGIN
    RAISE NOTICE '';
    RAISE NOTICE '═══════════════════════════════════════';
    RAISE NOTICE '✅ LÓGICA DE STOCK EN 0 MEJORADA';
    RAISE NOTICE '═══════════════════════════════════════';
    RAISE NOTICE '';
    RAISE NOTICE '📋 COMPORTAMIENTO NUEVO:';
    RAISE NOTICE '   ✅ Productos con 0 stock SE MANTIENEN en inventario';
    RAISE NOTICE '   ✅ Se conserva el historial de productos';
    RAISE NOTICE '   ✅ Al transferir de vuelta, el stock se restaura correctamente';
    RAISE NOTICE '';
    RAISE NOTICE '🔄 EJEMPLO:';
    RAISE NOTICE '   1. Resistencia: 5 → Corrientes: 0';
    RAISE NOTICE '   2. Transferir 5 a Corrientes';
    RAISE NOTICE '   3. Resistencia: 0 (MANTIENE registro)';
    RAISE NOTICE '   4. Corrientes: 5';
    RAISE NOTICE '   5. Transferir 5 de vuelta';
    RAISE NOTICE '   6. Resistencia: 5 (RESTAURA correctamente)';
    RAISE NOTICE '   7. Corrientes: 0 (MANTIENE registro)';
    RAISE NOTICE '';
    RAISE NOTICE '═══════════════════════════════════════';
END $$;
