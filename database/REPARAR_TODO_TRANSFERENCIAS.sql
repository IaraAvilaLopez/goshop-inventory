-- ============================================
-- REPARAR TODO EL SISTEMA DE TRANSFERENCIAS
-- ============================================

-- PASO 1: Ver el estado actual del stock
SELECT 
    'ESTADO ACTUAL' as paso,
    p.marca,
    p.modelo,
    p.capacidad_gb,
    p.color,
    i.ubicacion,
    i.cantidad_actual
FROM inventario i
JOIN productos p ON i.producto_id = p.id
WHERE (p.marca = 'IPHONE' AND p.modelo LIKE '%13 PRO%' AND p.capacidad_gb = '128')
   OR (p.marca = 'SAMSUNG' AND p.modelo = 'S24 ULTRA' AND p.capacidad_gb = '256')
ORDER BY p.marca, p.modelo, i.ubicacion;

-- PASO 2: RESTAURAR IPHONE 13 PRO BLANCO 128
-- Restaurar 1 unidad a Corrientes (se perdió al eliminar la transferencia)
UPDATE inventario
SET cantidad_actual = cantidad_actual + 1
WHERE producto_id = (
    SELECT id FROM productos 
    WHERE marca = 'IPHONE' 
    AND modelo = '13 PRO' 
    AND capacidad_gb = '128'
    AND color = 'BLANCO'
)
AND ubicacion = 'CORRIENTES';

-- PASO 3: CORREGIR SAMSUNG S24 ULTRA 256
-- Si tiene 6 en lugar de 3, restar 3
UPDATE inventario
SET cantidad_actual = cantidad_actual - 3
WHERE producto_id = (
    SELECT id FROM productos 
    WHERE marca = 'SAMSUNG' 
    AND modelo = 'S24 ULTRA' 
    AND capacidad_gb = '256'
)
AND ubicacion = 'CORRIENTES'
AND cantidad_actual > 3;

-- PASO 4: Ver el estado después de las correcciones
SELECT 
    'DESPUÉS DE CORRECCIONES' as paso,
    p.marca,
    p.modelo,
    p.capacidad_gb,
    p.color,
    i.ubicacion,
    i.cantidad_actual
FROM inventario i
JOIN productos p ON i.producto_id = p.id
WHERE (p.marca = 'IPHONE' AND p.modelo LIKE '%13 PRO%' AND p.capacidad_gb = '128')
   OR (p.marca = 'SAMSUNG' AND p.modelo = 'S24 ULTRA' AND p.capacidad_gb = '256')
ORDER BY p.marca, p.modelo, i.ubicacion;

-- ============================================
-- PASO 5: ELIMINAR TRIGGERS ACTUALES
-- ============================================
DROP TRIGGER IF EXISTS trigger_actualizar_inventario ON transacciones;
DROP TRIGGER IF EXISTS trigger_restaurar_inventario ON transacciones;
DROP FUNCTION IF EXISTS actualizar_inventario();
DROP FUNCTION IF EXISTS restaurar_inventario_al_eliminar();

-- ============================================
-- PASO 6: CREAR FUNCIÓN CORRECTA PARA INSERT
-- ============================================
CREATE OR REPLACE FUNCTION actualizar_inventario()
RETURNS TRIGGER AS $$
DECLARE
  v_ubicacion_origen TEXT;
  v_ubicacion_destino TEXT;
BEGIN
  -- TRANSFERENCIAS
  IF NEW.tipo_transaccion = 'TRANSFERENCIA' THEN
    -- La transacción se registra en la sucursal DESTINO
    v_ubicacion_destino := NEW.ubicacion;
    
    -- Determinar origen (la otra sucursal)
    IF NEW.ubicacion = 'RESISTENCIA' THEN
      v_ubicacion_origen := 'CORRIENTES';
    ELSE
      v_ubicacion_origen := 'RESISTENCIA';
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
-- PASO 7: CREAR FUNCIÓN CORRECTA PARA DELETE
-- ============================================
CREATE OR REPLACE FUNCTION restaurar_inventario_al_eliminar()
RETURNS TRIGGER AS $$
DECLARE
  v_ubicacion_origen TEXT;
  v_ubicacion_destino TEXT;
BEGIN
  -- TRANSFERENCIAS: Revertir movimiento
  IF OLD.tipo_transaccion = 'TRANSFERENCIA' THEN
    v_ubicacion_destino := OLD.ubicacion;
    
    IF OLD.ubicacion = 'RESISTENCIA' THEN
      v_ubicacion_origen := 'CORRIENTES';
    ELSE
      v_ubicacion_origen := 'RESISTENCIA';
    END IF;
    
    -- RESTAURAR AL ORIGEN (sumar)
    UPDATE inventario
    SET cantidad_actual = cantidad_actual + OLD.cantidad
    WHERE producto_id = OLD.producto_id
    AND ubicacion = v_ubicacion_origen;
    
    -- QUITAR DEL DESTINO (restar)
    UPDATE inventario
    SET cantidad_actual = cantidad_actual - OLD.cantidad
    WHERE producto_id = OLD.producto_id
    AND ubicacion = v_ubicacion_destino;
    
    RETURN OLD;
  END IF;
  
  -- COMPRA, CANJE_ENTRADA: Restar al eliminar
  IF OLD.tipo_transaccion IN ('COMPRA', 'CANJE_ENTRADA') THEN
    UPDATE inventario
    SET cantidad_actual = cantidad_actual - OLD.cantidad
    WHERE producto_id = OLD.producto_id
    AND ubicacion = OLD.ubicacion;
    
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
-- PASO 8: CREAR TRIGGERS
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
  RAISE NOTICE '✅ SISTEMA DE TRANSFERENCIAS REPARADO';
  RAISE NOTICE '';
  RAISE NOTICE '📦 Stock restaurado:';
  RAISE NOTICE '   - iPhone 13 Pro Blanco 128: +1 a Corrientes';
  RAISE NOTICE '   - Samsung S24 Ultra 256: -3 de Corrientes (corregir duplicado)';
  RAISE NOTICE '';
  RAISE NOTICE '🔧 Triggers corregidos:';
  RAISE NOTICE '   - INSERT: Actualiza stock correctamente';
  RAISE NOTICE '   - DELETE: Restaura stock al eliminar';
  RAISE NOTICE '';
  RAISE NOTICE '🔄 Transferencias ahora funcionan:';
  RAISE NOTICE '   - Descuenta de ORIGEN';
  RAISE NOTICE '   - Agrega a DESTINO';
  RAISE NOTICE '   - Al eliminar: REVIERTE correctamente';
END $$;
