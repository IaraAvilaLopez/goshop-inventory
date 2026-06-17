-- ============================================
-- MEJORAR TRIGGERS CON VALIDACIÓN DE STOCK
-- ============================================

-- ELIMINAR TRIGGERS ACTUALES
DROP TRIGGER IF EXISTS trigger_actualizar_inventario ON transacciones;
DROP TRIGGER IF EXISTS trigger_restaurar_inventario ON transacciones;
DROP FUNCTION IF EXISTS actualizar_inventario();
DROP FUNCTION IF EXISTS restaurar_inventario_al_eliminar();

-- ============================================
-- FUNCIÓN PARA INSERT (con validación)
-- ============================================
CREATE OR REPLACE FUNCTION actualizar_inventario()
RETURNS TRIGGER AS $$
DECLARE
  v_ubicacion_origen TEXT;
  v_ubicacion_destino TEXT;
  v_stock_actual INTEGER;
BEGIN
  -- TRANSFERENCIAS
  IF NEW.tipo_transaccion = 'TRANSFERENCIA' THEN
    v_ubicacion_destino := NEW.ubicacion;
    
    -- Determinar origen
    IF NEW.ubicacion = 'RESISTENCIA' THEN
      v_ubicacion_origen := 'CORRIENTES';
    ELSE
      v_ubicacion_origen := 'RESISTENCIA';
    END IF;
    
    -- VALIDAR que hay stock suficiente en origen
    SELECT cantidad_actual INTO v_stock_actual
    FROM inventario
    WHERE producto_id = NEW.producto_id
    AND ubicacion = v_ubicacion_origen;
    
    IF v_stock_actual IS NULL OR v_stock_actual < NEW.cantidad THEN
      RAISE EXCEPTION 'Stock insuficiente en % para transferir % unidades', v_ubicacion_origen, NEW.cantidad;
    END IF;
    
    -- DESCONTAR DEL ORIGEN
    UPDATE inventario
    SET cantidad_actual = cantidad_actual - NEW.cantidad
    WHERE producto_id = NEW.producto_id
    AND ubicacion = v_ubicacion_origen;
    
    -- AGREGAR AL DESTINO (o crear si no existe)
    INSERT INTO inventario (producto_id, ubicacion, cantidad_actual, cantidad_minima, estado)
    VALUES (NEW.producto_id, v_ubicacion_destino, NEW.cantidad, 1, 'DISPONIBLE')
    ON CONFLICT (producto_id, ubicacion)
    DO UPDATE SET cantidad_actual = inventario.cantidad_actual + NEW.cantidad;
    
    RETURN NEW;
  END IF;
  
  -- COMPRA, CANJE_ENTRADA
  IF NEW.tipo_transaccion IN ('COMPRA', 'CANJE_ENTRADA') THEN
    INSERT INTO inventario (producto_id, ubicacion, cantidad_actual, cantidad_minima, estado)
    VALUES (NEW.producto_id, NEW.ubicacion, NEW.cantidad, 1, 'DISPONIBLE')
    ON CONFLICT (producto_id, ubicacion)
    DO UPDATE SET cantidad_actual = inventario.cantidad_actual + NEW.cantidad;
    
    RETURN NEW;
  END IF;
  
  -- VENTA, CANJE_SALIDA, CIERRE_DIA
  IF NEW.tipo_transaccion IN ('VENTA', 'CANJE_SALIDA', 'CIERRE_DIA') THEN
    -- VALIDAR stock suficiente
    SELECT cantidad_actual INTO v_stock_actual
    FROM inventario
    WHERE producto_id = NEW.producto_id
    AND ubicacion = NEW.ubicacion;
    
    IF v_stock_actual IS NULL OR v_stock_actual < NEW.cantidad THEN
      RAISE EXCEPTION 'Stock insuficiente en % para % de % unidades', NEW.ubicacion, NEW.tipo_transaccion, NEW.cantidad;
    END IF;
    
    UPDATE inventario
    SET cantidad_actual = cantidad_actual - NEW.cantidad
    WHERE producto_id = NEW.producto_id
    AND ubicacion = NEW.ubicacion;
    
    RETURN NEW;
  END IF;
  
  RETURN NEW;
END;
$$ LANGUAGE plpgsql;

-- ============================================
-- FUNCIÓN PARA DELETE (con validación)
-- ============================================
CREATE OR REPLACE FUNCTION restaurar_inventario_al_eliminar()
RETURNS TRIGGER AS $$
DECLARE
  v_ubicacion_origen TEXT;
  v_ubicacion_destino TEXT;
  v_stock_actual INTEGER;
BEGIN
  -- TRANSFERENCIAS: Revertir movimiento
  IF OLD.tipo_transaccion = 'TRANSFERENCIA' THEN
    v_ubicacion_destino := OLD.ubicacion;
    
    IF OLD.ubicacion = 'RESISTENCIA' THEN
      v_ubicacion_origen := 'CORRIENTES';
    ELSE
      v_ubicacion_origen := 'RESISTENCIA';
    END IF;
    
    -- VALIDAR que hay stock en destino para restar
    SELECT cantidad_actual INTO v_stock_actual
    FROM inventario
    WHERE producto_id = OLD.producto_id
    AND ubicacion = v_ubicacion_destino;
    
    -- RESTAURAR AL ORIGEN (sumar)
    UPDATE inventario
    SET cantidad_actual = cantidad_actual + OLD.cantidad
    WHERE producto_id = OLD.producto_id
    AND ubicacion = v_ubicacion_origen;
    
    -- QUITAR DEL DESTINO (restar)
    IF v_stock_actual IS NOT NULL AND v_stock_actual >= OLD.cantidad THEN
      UPDATE inventario
      SET cantidad_actual = cantidad_actual - OLD.cantidad
      WHERE producto_id = OLD.producto_id
      AND ubicacion = v_ubicacion_destino;
      
      -- Si queda en 0, eliminar el registro
      DELETE FROM inventario
      WHERE producto_id = OLD.producto_id
      AND ubicacion = v_ubicacion_destino
      AND cantidad_actual <= 0;
    ELSE
      -- Si no hay stock suficiente, eliminar el registro negativo
      DELETE FROM inventario
      WHERE producto_id = OLD.producto_id
      AND ubicacion = v_ubicacion_destino;
    END IF;
    
    RETURN OLD;
  END IF;
  
  -- COMPRA, CANJE_ENTRADA: Restar al eliminar
  IF OLD.tipo_transaccion IN ('COMPRA', 'CANJE_ENTRADA') THEN
    UPDATE inventario
    SET cantidad_actual = cantidad_actual - OLD.cantidad
    WHERE producto_id = OLD.producto_id
    AND ubicacion = OLD.ubicacion;
    
    -- Eliminar si queda en 0 o negativo
    DELETE FROM inventario
    WHERE producto_id = OLD.producto_id
    AND ubicacion = OLD.ubicacion
    AND cantidad_actual <= 0;
    
    RETURN OLD;
  END IF;
  
  -- VENTA, CANJE_SALIDA, CIERRE_DIA: Sumar al eliminar
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

-- ============================================
-- CREAR TRIGGERS
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
-- CONFIRMACIÓN
-- ============================================
DO $$
BEGIN
  RAISE NOTICE '✅ TRIGGERS MEJORADOS CON VALIDACIONES:';
  RAISE NOTICE '';
  RAISE NOTICE '🔒 Validaciones agregadas:';
  RAISE NOTICE '   1. No permite transferir si no hay stock suficiente';
  RAISE NOTICE '   2. No permite ventas sin stock';
  RAISE NOTICE '   3. Elimina registros con stock <= 0';
  RAISE NOTICE '   4. Evita stock negativo';
  RAISE NOTICE '';
  RAISE NOTICE '🔄 Al eliminar transferencias:';
  RAISE NOTICE '   1. Restaura stock en origen';
  RAISE NOTICE '   2. Quita stock de destino';
  RAISE NOTICE '   3. Elimina registros negativos automáticamente';
END $$;
