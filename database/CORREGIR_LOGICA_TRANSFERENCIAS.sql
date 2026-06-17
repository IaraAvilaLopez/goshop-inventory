-- ============================================
-- CORREGIR LÓGICA DE TRANSFERENCIAS
-- ============================================

-- ELIMINAR TRIGGER Y FUNCIÓN ACTUALES
DROP TRIGGER IF EXISTS trigger_actualizar_inventario ON transacciones;
DROP FUNCTION IF EXISTS actualizar_inventario();

-- CREAR NUEVA FUNCIÓN CON LÓGICA CORRECTA
CREATE OR REPLACE FUNCTION actualizar_inventario()
RETURNS TRIGGER AS $$
DECLARE
  v_ubicacion_origen TEXT;
  v_ubicacion_destino TEXT;
BEGIN
  -- ============================================
  -- TRANSFERENCIAS
  -- ============================================
  IF NEW.tipo_transaccion = 'TRANSFERENCIA' THEN
    -- La transacción se registra en la sucursal DESTINO
    -- Necesitamos descontar de ORIGEN (la otra sucursal)
    
    v_ubicacion_destino := NEW.ubicacion;  -- Donde se registra la transacción
    
    -- Determinar origen (la otra sucursal)
    IF NEW.ubicacion = 'RESISTENCIA' THEN
      v_ubicacion_origen := 'CORRIENTES';
    ELSE
      v_ubicacion_origen := 'RESISTENCIA';
    END IF;
    
    RAISE NOTICE 'TRANSFERENCIA: Origen=%, Destino=%, Producto=%, Cantidad=%', 
      v_ubicacion_origen, v_ubicacion_destino, NEW.producto_id, NEW.cantidad;
    
    -- 1. DESCONTAR DEL ORIGEN
    UPDATE inventario
    SET cantidad_actual = cantidad_actual - NEW.cantidad
    WHERE producto_id = NEW.producto_id
    AND ubicacion = v_ubicacion_origen;
    
    -- 2. AGREGAR AL DESTINO (o crear si no existe)
    INSERT INTO inventario (producto_id, ubicacion, cantidad_actual, cantidad_minima, estado)
    VALUES (NEW.producto_id, v_ubicacion_destino, NEW.cantidad, 1, 'DISPONIBLE')
    ON CONFLICT (producto_id, ubicacion)
    DO UPDATE SET cantidad_actual = inventario.cantidad_actual + NEW.cantidad;
    
    RETURN NEW;
  END IF;
  
  -- ============================================
  -- COMPRA, CANJE_ENTRADA: Aumentar stock
  -- ============================================
  IF NEW.tipo_transaccion IN ('COMPRA', 'CANJE_ENTRADA') THEN
    INSERT INTO inventario (producto_id, ubicacion, cantidad_actual, cantidad_minima, estado)
    VALUES (NEW.producto_id, NEW.ubicacion, NEW.cantidad, 1, 'DISPONIBLE')
    ON CONFLICT (producto_id, ubicacion)
    DO UPDATE SET cantidad_actual = inventario.cantidad_actual + NEW.cantidad;
    
    RETURN NEW;
  END IF;
  
  -- ============================================
  -- VENTA, CANJE_SALIDA, CIERRE_DIA: Disminuir stock
  -- ============================================
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

-- CREAR TRIGGER PARA INSERT
CREATE TRIGGER trigger_actualizar_inventario
AFTER INSERT ON transacciones
FOR EACH ROW
EXECUTE FUNCTION actualizar_inventario();

-- ============================================
-- CREAR FUNCIÓN PARA RESTAURAR AL ELIMINAR
-- ============================================
CREATE OR REPLACE FUNCTION restaurar_inventario_al_eliminar()
RETURNS TRIGGER AS $$
DECLARE
  v_ubicacion_origen TEXT;
  v_ubicacion_destino TEXT;
BEGIN
  -- ============================================
  -- TRANSFERENCIAS: Revertir movimiento
  -- ============================================
  IF OLD.tipo_transaccion = 'TRANSFERENCIA' THEN
    v_ubicacion_destino := OLD.ubicacion;
    
    IF OLD.ubicacion = 'RESISTENCIA' THEN
      v_ubicacion_origen := 'CORRIENTES';
    ELSE
      v_ubicacion_origen := 'RESISTENCIA';
    END IF;
    
    RAISE NOTICE 'ELIMINAR TRANSFERENCIA: Restaurar % a %, Quitar % de %', 
      OLD.cantidad, v_ubicacion_origen, OLD.cantidad, v_ubicacion_destino;
    
    -- 1. RESTAURAR AL ORIGEN (sumar)
    UPDATE inventario
    SET cantidad_actual = cantidad_actual + OLD.cantidad
    WHERE producto_id = OLD.producto_id
    AND ubicacion = v_ubicacion_origen;
    
    -- 2. QUITAR DEL DESTINO (restar)
    UPDATE inventario
    SET cantidad_actual = cantidad_actual - OLD.cantidad
    WHERE producto_id = OLD.producto_id
    AND ubicacion = v_ubicacion_destino;
    
    RETURN OLD;
  END IF;
  
  -- ============================================
  -- COMPRA, CANJE_ENTRADA: Restar al eliminar
  -- ============================================
  IF OLD.tipo_transaccion IN ('COMPRA', 'CANJE_ENTRADA') THEN
    UPDATE inventario
    SET cantidad_actual = cantidad_actual - OLD.cantidad
    WHERE producto_id = OLD.producto_id
    AND ubicacion = OLD.ubicacion;
    
    RETURN OLD;
  END IF;
  
  -- ============================================
  -- VENTA, CANJE_SALIDA, CIERRE_DIA: Sumar al eliminar
  -- ============================================
  IF OLD.tipo_transaccion IN ('VENTA', 'CANJE_SALIDA', 'CIERRE_DIA') THEN
    UPDATE inventario
    SET cantidad_actual = cantidad_actual + OLD.cantidad
    WHERE producto_id = OLD.producto_id
    AND ubicacion = OLD.ubicacion;
    
    RETURN OLD;
  END IF;
  
  RETURN OLD;
END;
$$ LANGUAGE plpgsql;

-- CREAR TRIGGER PARA DELETE
CREATE TRIGGER trigger_restaurar_inventario
BEFORE DELETE ON transacciones
FOR EACH ROW
EXECUTE FUNCTION restaurar_inventario_al_eliminar();

-- ============================================
-- CONFIRMACIÓN
-- ============================================
DO $$
BEGIN
  RAISE NOTICE '✅ Triggers corregidos:';
  RAISE NOTICE '   1. INSERT: Actualiza stock correctamente';
  RAISE NOTICE '   2. DELETE: Restaura stock al eliminar';
  RAISE NOTICE '';
  RAISE NOTICE '🔄 TRANSFERENCIAS:';
  RAISE NOTICE '   - Descuenta de ORIGEN (otra sucursal)';
  RAISE NOTICE '   - Agrega a DESTINO (sucursal actual)';
  RAISE NOTICE '   - Al eliminar: REVIERTE el movimiento';
END $$;
