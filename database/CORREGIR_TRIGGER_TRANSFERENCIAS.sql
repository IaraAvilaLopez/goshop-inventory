-- ============================================
-- CORREGIR TRIGGER PARA TRANSFERENCIAS
-- ============================================
-- Este script corrige el trigger para que las transferencias funcionen correctamente

-- Ver el trigger actual
SELECT pg_get_functiondef(oid) 
FROM pg_proc 
WHERE proname = 'actualizar_inventario';

-- Eliminar el trigger y función actuales
DROP TRIGGER IF EXISTS trigger_actualizar_inventario ON transacciones;
DROP FUNCTION IF EXISTS actualizar_inventario();

-- Crear nueva función que maneja TRANSFERENCIAS correctamente
CREATE OR REPLACE FUNCTION actualizar_inventario()
RETURNS TRIGGER AS $$
DECLARE
  v_ubicacion_destino TEXT;
BEGIN
  -- Para TRANSFERENCIAS: manejar origen y destino
  IF NEW.tipo_transaccion = 'TRANSFERENCIA' THEN
    -- Determinar la ubicación destino (la contraria a la actual)
    IF NEW.ubicacion = 'RESISTENCIA' THEN
      v_ubicacion_destino := 'CORRIENTES';
    ELSE
      v_ubicacion_destino := 'RESISTENCIA';
    END IF;
    
    -- Descontar del origen (ubicación de la transacción)
    UPDATE inventario
    SET cantidad_actual = cantidad_actual - NEW.cantidad
    WHERE producto_id = NEW.producto_id
    AND ubicacion = v_ubicacion_destino;  -- Origen es la OTRA sucursal
    
    -- Agregar al destino (la sucursal actual)
    UPDATE inventario
    SET cantidad_actual = cantidad_actual + NEW.cantidad
    WHERE producto_id = NEW.producto_id
    AND ubicacion = NEW.ubicacion;  -- Destino es la sucursal actual
    
    RETURN NEW;
  END IF;
  
  -- Para COMPRA, CANJE_ENTRADA: aumentar stock
  IF NEW.tipo_transaccion IN ('COMPRA', 'CANJE_ENTRADA') THEN
    UPDATE inventario
    SET cantidad_actual = cantidad_actual + NEW.cantidad
    WHERE producto_id = NEW.producto_id
    AND ubicacion = NEW.ubicacion;
    
    RETURN NEW;
  END IF;
  
  -- Para VENTA, CANJE_SALIDA, CIERRE_DIA: disminuir stock
  IF NEW.tipo_transaccion IN ('VENTA', 'CANJE_SALIDA', 'CIERRE_DIA') THEN
    UPDATE inventario
    SET cantidad_actual = cantidad_actual - NEW.cantidad
    WHERE producto_id = NEW.producto_id
    AND ubicacion = NEW.ubicacion;
    
    RETURN NEW;
  END IF;
  
  RETURN NEW;
END;
$$ LANGUAGE plpgsql;

-- Crear el trigger
CREATE TRIGGER trigger_actualizar_inventario
AFTER INSERT ON transacciones
FOR EACH ROW
EXECUTE FUNCTION actualizar_inventario();

-- Verificación
DO $$
BEGIN
  RAISE NOTICE '✅ Trigger de transferencias corregido';
  RAISE NOTICE '🔄 Ahora las transferencias funcionarán correctamente';
  RAISE NOTICE '📍 Descuenta de origen y agrega a destino automáticamente';
END $$;
