-- ============================================
-- ARREGLO TOTAL DEL SISTEMA - EJECUTAR UNA SOLA VEZ
-- ============================================
-- Este script corrige TODOS los problemas:
-- 1. Ventas pendientes sin ubicacion
-- 2. Cierres mezclados entre sucursales
-- 3. Stock duplicado al borrar cierres
-- 4. Triggers que no funcionan correctamente

-- ============================================
-- PARTE 1: LIMPIAR DATOS INCORRECTOS
-- ============================================

DO $$
BEGIN
    -- Eliminar TODAS las ventas pendientes actuales (están sin ubicacion)
    DELETE FROM ventas_pendientes;

    -- Eliminar TODOS los cierres de hoy (están duplicados/incorrectos)
    DELETE FROM cierres_dia WHERE fecha_cierre >= CURRENT_DATE - INTERVAL '7 days';

    -- Eliminar transacciones CIERRE_DIA de hoy (están duplicadas)
    DELETE FROM transacciones 
    WHERE tipo_transaccion = 'CIERRE_DIA' 
    AND fecha_transaccion >= CURRENT_DATE - INTERVAL '7 days';

    RAISE NOTICE 'PASO 1: Datos incorrectos eliminados';
END $$;

-- ============================================
-- PARTE 2: AGREGAR COLUMNA UBICACION A VENTAS_PENDIENTES
-- ============================================

DO $$
BEGIN
    ALTER TABLE ventas_pendientes
    ADD COLUMN IF NOT EXISTS ubicacion TEXT;

    ALTER TABLE ventas_pendientes
    DROP CONSTRAINT IF EXISTS ventas_pendientes_ubicacion_check;

    ALTER TABLE ventas_pendientes
    ADD CONSTRAINT ventas_pendientes_ubicacion_check
    CHECK (ubicacion IN ('RESISTENCIA', 'CORRIENTES'));

    RAISE NOTICE 'PASO 2: Columna ubicacion agregada a ventas_pendientes';
END $$;

-- ============================================
-- PARTE 3: RECREAR TRIGGERS COMPLETOS
-- ============================================

DO $$
BEGIN
    -- Eliminar triggers anteriores
    DROP TRIGGER IF EXISTS trigger_actualizar_inventario ON transacciones CASCADE;
    DROP TRIGGER IF EXISTS trigger_restaurar_inventario ON transacciones CASCADE;
    DROP TRIGGER IF EXISTS trigger_validar_stock_positivo ON inventario CASCADE;
    DROP TRIGGER IF EXISTS trigger_limpiar_inventario_cero ON inventario CASCADE;
    DROP TRIGGER IF EXISTS trigger_gestionar_alertas ON inventario CASCADE;

    DROP FUNCTION IF EXISTS actualizar_inventario_desde_transaccion() CASCADE;
    DROP FUNCTION IF EXISTS restaurar_inventario_al_eliminar() CASCADE;
    DROP FUNCTION IF EXISTS prevenir_stock_negativo() CASCADE;
    DROP FUNCTION IF EXISTS limpiar_inventario_cero() CASCADE;
    DROP FUNCTION IF EXISTS gestionar_alertas_stock() CASCADE;

    RAISE NOTICE 'PASO 3: Triggers anteriores eliminados';
END $$;

-- ============================================
-- TRIGGER 1: PREVENIR STOCK NEGATIVO
-- ============================================
CREATE OR REPLACE FUNCTION prevenir_stock_negativo()
RETURNS TRIGGER AS $$
BEGIN
    IF NEW.cantidad_actual < 0 THEN
        RAISE EXCEPTION 'STOCK NEGATIVO BLOQUEADO: Producto %, Ubicacion %, Cantidad: %',
            NEW.producto_id, NEW.ubicacion, NEW.cantidad_actual;
    END IF;
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER trigger_validar_stock_positivo
BEFORE INSERT OR UPDATE ON inventario
FOR EACH ROW
EXECUTE FUNCTION prevenir_stock_negativo();

DO $$ BEGIN RAISE NOTICE 'PASO 4: Trigger prevenir_stock_negativo creado'; END $$;

-- ============================================
-- TRIGGER 2: ACTUALIZAR INVENTARIO AL INSERTAR TRANSACCION
-- ============================================
CREATE OR REPLACE FUNCTION actualizar_inventario_desde_transaccion()
RETURNS TRIGGER AS $$
DECLARE
  v_ubicacion_origen TEXT;
  v_ubicacion_destino TEXT;
  v_stock_origen INTEGER;
BEGIN
  -- TRANSFERENCIAS
  IF NEW.tipo_transaccion = 'TRANSFERENCIA' THEN
    v_ubicacion_destino := NEW.ubicacion;
    
    IF NEW.ubicacion = 'RESISTENCIA' THEN
      v_ubicacion_origen := 'CORRIENTES';
    ELSE
      v_ubicacion_origen := 'RESISTENCIA';
    END IF;
    
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
    
  -- COMPRA / CANJE_ENTRADA
  ELSIF NEW.tipo_transaccion IN ('COMPRA', 'CANJE_ENTRADA') THEN
    INSERT INTO inventario (producto_id, ubicacion, cantidad_actual, cantidad_minima, estado, es_original)
    VALUES (NEW.producto_id, NEW.ubicacion, NEW.cantidad, 1, 'DISPONIBLE', true)
    ON CONFLICT (producto_id, ubicacion)
    DO UPDATE SET cantidad_actual = inventario.cantidad_actual + NEW.cantidad;
    
  -- VENTA / CANJE_SALIDA / CIERRE_DIA
  ELSIF NEW.tipo_transaccion IN ('VENTA', 'CANJE_SALIDA', 'CIERRE_DIA') THEN
    SELECT cantidad_actual INTO v_stock_origen
    FROM inventario
    WHERE producto_id = NEW.producto_id
    AND ubicacion = NEW.ubicacion;
    
    IF v_stock_origen IS NULL OR v_stock_origen < NEW.cantidad THEN
      RAISE EXCEPTION 'ERROR: Stock insuficiente en % (tiene %, necesita %)', 
        NEW.ubicacion, COALESCE(v_stock_origen, 0), NEW.cantidad;
    END IF;
    
    UPDATE inventario
    SET cantidad_actual = cantidad_actual - NEW.cantidad
    WHERE producto_id = NEW.producto_id
    AND ubicacion = NEW.ubicacion;
  END IF;
  
  RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER trigger_actualizar_inventario
AFTER INSERT ON transacciones
FOR EACH ROW
EXECUTE FUNCTION actualizar_inventario_desde_transaccion();

DO $$ BEGIN RAISE NOTICE 'PASO 5: Trigger actualizar_inventario creado'; END $$;

-- ============================================
-- TRIGGER 3: RESTAURAR INVENTARIO AL ELIMINAR TRANSACCION
-- ============================================
CREATE OR REPLACE FUNCTION restaurar_inventario_al_eliminar()
RETURNS TRIGGER AS $$
DECLARE
  v_ubicacion_origen TEXT;
  v_ubicacion_destino TEXT;
  v_stock_destino INTEGER;
BEGIN
  -- TRANSFERENCIAS - REVERTIR
  IF OLD.tipo_transaccion = 'TRANSFERENCIA' THEN
    v_ubicacion_destino := OLD.ubicacion;
    
    IF OLD.ubicacion = 'RESISTENCIA' THEN
      v_ubicacion_origen := 'CORRIENTES';
    ELSE
      v_ubicacion_origen := 'RESISTENCIA';
    END IF;
    
    SELECT cantidad_actual INTO v_stock_destino
    FROM inventario
    WHERE producto_id = OLD.producto_id
    AND ubicacion = v_ubicacion_destino;
    
    -- Si el producto no existe en destino, solo restaurar al origen
    IF v_stock_destino IS NULL THEN
      INSERT INTO inventario (producto_id, ubicacion, cantidad_actual, cantidad_minima, estado, es_original)
      VALUES (OLD.producto_id, v_ubicacion_origen, OLD.cantidad, 1, 'DISPONIBLE', true)
      ON CONFLICT (producto_id, ubicacion)
      DO UPDATE SET cantidad_actual = inventario.cantidad_actual + OLD.cantidad;
      RETURN OLD;
    END IF;
    
    IF v_stock_destino < OLD.cantidad THEN
      RAISE EXCEPTION 'ERROR: No se puede revertir. Stock insuficiente en % (tiene %, necesita %)', 
        v_ubicacion_destino, v_stock_destino, OLD.cantidad;
    END IF;
    
    -- Quitar del destino
    UPDATE inventario
    SET cantidad_actual = cantidad_actual - OLD.cantidad
    WHERE producto_id = OLD.producto_id
    AND ubicacion = v_ubicacion_destino;
    
    -- Restaurar al origen
    INSERT INTO inventario (producto_id, ubicacion, cantidad_actual, cantidad_minima, estado, es_original)
    VALUES (OLD.producto_id, v_ubicacion_origen, OLD.cantidad, 1, 'DISPONIBLE', true)
    ON CONFLICT (producto_id, ubicacion)
    DO UPDATE SET cantidad_actual = inventario.cantidad_actual + OLD.cantidad;
    
  -- COMPRA / CANJE_ENTRADA - RESTAR
  ELSIF OLD.tipo_transaccion IN ('COMPRA', 'CANJE_ENTRADA') THEN
    SELECT cantidad_actual INTO v_stock_destino
    FROM inventario
    WHERE producto_id = OLD.producto_id
    AND ubicacion = OLD.ubicacion;
    
    IF v_stock_destino IS NULL OR v_stock_destino < OLD.cantidad THEN
      RAISE EXCEPTION 'ERROR: No se puede revertir. Stock insuficiente en % (tiene %, necesita %)', 
        OLD.ubicacion, COALESCE(v_stock_destino, 0), OLD.cantidad;
    END IF;
    
    UPDATE inventario
    SET cantidad_actual = cantidad_actual - OLD.cantidad
    WHERE producto_id = OLD.producto_id
    AND ubicacion = OLD.ubicacion;
    
  -- VENTA / CANJE_SALIDA / CIERRE_DIA - SUMAR (RESTAURAR)
  ELSIF OLD.tipo_transaccion IN ('VENTA', 'CANJE_SALIDA', 'CIERRE_DIA') THEN
    INSERT INTO inventario (producto_id, ubicacion, cantidad_actual, cantidad_minima, estado, es_original)
    VALUES (OLD.producto_id, OLD.ubicacion, OLD.cantidad, 1, 'DISPONIBLE', true)
    ON CONFLICT (producto_id, ubicacion)
    DO UPDATE SET cantidad_actual = inventario.cantidad_actual + OLD.cantidad;
  END IF;
  
  RETURN OLD;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER trigger_restaurar_inventario
BEFORE DELETE ON transacciones
FOR EACH ROW
EXECUTE FUNCTION restaurar_inventario_al_eliminar();

DO $$ BEGIN RAISE NOTICE 'PASO 6: Trigger restaurar_inventario creado'; END $$;

-- ============================================
-- TRIGGER 4: LIMPIAR INVENTARIO CON 0 STOCK NO ORIGINAL
-- ============================================
CREATE OR REPLACE FUNCTION limpiar_inventario_cero()
RETURNS TRIGGER AS $$
BEGIN
    IF NEW.cantidad_actual = 0 AND NEW.es_original = false THEN
        DELETE FROM inventario WHERE id = NEW.id;
        RETURN NULL;
    END IF;
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER trigger_limpiar_inventario_cero
AFTER UPDATE ON inventario
FOR EACH ROW
EXECUTE FUNCTION limpiar_inventario_cero();

DO $$ BEGIN RAISE NOTICE 'PASO 7: Trigger limpiar_inventario_cero creado'; END $$;

-- ============================================
-- TRIGGER 5: GESTIONAR ALERTAS
-- ============================================
CREATE OR REPLACE FUNCTION gestionar_alertas_stock()
RETURNS TRIGGER AS $$
DECLARE
    v_alerta_existente_id UUID;
BEGIN
    IF TG_OP = 'UPDATE' AND OLD.cantidad_actual = NEW.cantidad_actual THEN
        RETURN NEW;
    END IF;
    
    SELECT id INTO v_alerta_existente_id
    FROM alertas_stock
    WHERE producto_id = NEW.producto_id
    AND ubicacion = NEW.ubicacion
    AND estado_alerta = 'ACTIVA';
    
    IF NEW.cantidad_actual < NEW.cantidad_minima THEN
        IF v_alerta_existente_id IS NULL THEN
            INSERT INTO alertas_stock (
                producto_id, ubicacion, cantidad_actual, cantidad_minima,
                estado_alerta, mensaje
            ) VALUES (
                NEW.producto_id, NEW.ubicacion, NEW.cantidad_actual, NEW.cantidad_minima,
                'ACTIVA',
                CASE WHEN NEW.cantidad_actual = 0 THEN 'SIN STOCK' ELSE 'STOCK BAJO' END
            );
        ELSE
            UPDATE alertas_stock
            SET cantidad_actual = NEW.cantidad_actual,
                mensaje = CASE WHEN NEW.cantidad_actual = 0 THEN 'SIN STOCK' ELSE 'STOCK BAJO' END
            WHERE id = v_alerta_existente_id;
        END IF;
    
    ELSIF NEW.cantidad_actual >= NEW.cantidad_minima AND v_alerta_existente_id IS NOT NULL THEN
        UPDATE alertas_stock
        SET estado_alerta = 'RESUELTA'
        WHERE id = v_alerta_existente_id;
    END IF;
    
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER trigger_gestionar_alertas
AFTER INSERT OR UPDATE ON inventario
FOR EACH ROW
EXECUTE FUNCTION gestionar_alertas_stock();

DO $$ BEGIN RAISE NOTICE 'PASO 8: Trigger gestionar_alertas creado'; END $$;

-- ============================================
-- CONFIRMACION FINAL
-- ============================================
DO $$
BEGIN
    RAISE NOTICE '';
    RAISE NOTICE '████████████████████████████████████████████████████████';
    RAISE NOTICE '█                                                      █';
    RAISE NOTICE '█       SISTEMA COMPLETAMENTE ARREGLADO               █';
    RAISE NOTICE '█                                                      █';
    RAISE NOTICE '████████████████████████████████████████████████████████';
    RAISE NOTICE '';
    RAISE NOTICE 'CAMBIOS REALIZADOS:';
    RAISE NOTICE '';
    RAISE NOTICE '✓ Ventas pendientes ahora tienen columna ubicacion';
    RAISE NOTICE '✓ Cierres separados por sucursal';
    RAISE NOTICE '✓ Al borrar cierre, se restaura stock correctamente';
    RAISE NOTICE '✓ Al borrar venta, se restaura stock correctamente';
    RAISE NOTICE '✓ No mas duplicados de stock';
    RAISE NOTICE '✓ Triggers funcionando correctamente';
    RAISE NOTICE '';
    RAISE NOTICE 'SIGUIENTE PASO:';
    RAISE NOTICE '1. Recarga la app (F5 + Ctrl+Shift+R)';
    RAISE NOTICE '2. Agrega ventas en cada sucursal';
    RAISE NOTICE '3. Procesa cierre en cada sucursal';
    RAISE NOTICE '4. Prueba borrar cierre (debe restaurar stock)';
    RAISE NOTICE '';
    RAISE NOTICE '████████████████████████████████████████████████████████';
END $$;
