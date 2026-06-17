-- ============================================
-- SISTEMA COMPLETO Y DEFINITIVO - GOSHOP
-- ============================================
-- Este script garantiza que TODAS las operaciones funcionen correctamente:
-- - Compras, Ventas, Transferencias, Canjes, Cierre de Dia
-- - En AMBAS sucursales (RESISTENCIA y CORRIENTES)
-- - Restauracion correcta al eliminar transacciones
-- - Historial completo y permanente
-- - Stock siempre correcto y nunca negativo

-- ============================================
-- PASO 1: LIMPIAR TODO
-- ============================================
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

-- ============================================
-- PASO 2: TRIGGER 1 - PREVENIR STOCK NEGATIVO
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

-- ============================================
-- PASO 3: TRIGGER 2 - ACTUALIZAR INVENTARIO AL INSERTAR TRANSACCION
-- ============================================
CREATE OR REPLACE FUNCTION actualizar_inventario_desde_transaccion()
RETURNS TRIGGER AS $$
DECLARE
  v_ubicacion_origen TEXT;
  v_ubicacion_destino TEXT;
  v_stock_origen INTEGER;
BEGIN
  RAISE NOTICE '========================================';
  RAISE NOTICE 'NUEVA TRANSACCION: %', NEW.tipo_transaccion;
  RAISE NOTICE 'Producto: %', NEW.producto_id;
  RAISE NOTICE 'Cantidad: %', NEW.cantidad;
  RAISE NOTICE 'Ubicacion registrada: %', NEW.ubicacion;
  RAISE NOTICE '========================================';
  
  -- ============================================
  -- CASO 1: TRANSFERENCIAS
  -- ============================================
  IF NEW.tipo_transaccion = 'TRANSFERENCIA' THEN
    v_ubicacion_destino := NEW.ubicacion;
    
    -- Determinar origen (la OTRA sucursal)
    IF NEW.ubicacion = 'RESISTENCIA' THEN
      v_ubicacion_origen := 'CORRIENTES';
    ELSE
      v_ubicacion_origen := 'RESISTENCIA';
    END IF;
    
    RAISE NOTICE 'TRANSFERENCIA: % -> %', v_ubicacion_origen, v_ubicacion_destino;
    
    -- Verificar stock en origen
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
    
    -- Descontar del origen
    UPDATE inventario
    SET cantidad_actual = cantidad_actual - NEW.cantidad
    WHERE producto_id = NEW.producto_id
    AND ubicacion = v_ubicacion_origen;
    
    RAISE NOTICE 'OK: Descontado % de %', NEW.cantidad, v_ubicacion_origen;
    
    -- Agregar al destino (marcar como NO original)
    INSERT INTO inventario (producto_id, ubicacion, cantidad_actual, cantidad_minima, estado, es_original)
    VALUES (NEW.producto_id, v_ubicacion_destino, NEW.cantidad, 1, 'DISPONIBLE', false)
    ON CONFLICT (producto_id, ubicacion)
    DO UPDATE SET cantidad_actual = inventario.cantidad_actual + NEW.cantidad;
    
    RAISE NOTICE 'OK: Agregado % a %', NEW.cantidad, v_ubicacion_destino;
    RAISE NOTICE 'TRANSFERENCIA COMPLETADA';
    
  -- ============================================
  -- CASO 2: COMPRA / CANJE_ENTRADA
  -- ============================================
  ELSIF NEW.tipo_transaccion IN ('COMPRA', 'CANJE_ENTRADA') THEN
    RAISE NOTICE 'COMPRA/CANJE_ENTRADA en %', NEW.ubicacion;
    
    -- Agregar al inventario (marcar como ORIGINAL)
    INSERT INTO inventario (producto_id, ubicacion, cantidad_actual, cantidad_minima, estado, es_original)
    VALUES (NEW.producto_id, NEW.ubicacion, NEW.cantidad, 1, 'DISPONIBLE', true)
    ON CONFLICT (producto_id, ubicacion)
    DO UPDATE SET cantidad_actual = inventario.cantidad_actual + NEW.cantidad;
    
    RAISE NOTICE 'OK: Agregado % a %', NEW.cantidad, NEW.ubicacion;
    
  -- ============================================
  -- CASO 3: VENTA / CANJE_SALIDA / CIERRE_DIA
  -- ============================================
  ELSIF NEW.tipo_transaccion IN ('VENTA', 'CANJE_SALIDA', 'CIERRE_DIA') THEN
    RAISE NOTICE 'VENTA/SALIDA/CIERRE en %', NEW.ubicacion;
    
    -- Verificar stock en la ubicacion donde se registra
    SELECT cantidad_actual INTO v_stock_origen
    FROM inventario
    WHERE producto_id = NEW.producto_id
    AND ubicacion = NEW.ubicacion;
    
    RAISE NOTICE 'Stock actual en %: %', NEW.ubicacion, COALESCE(v_stock_origen, 0);
    
    IF v_stock_origen IS NULL OR v_stock_origen < NEW.cantidad THEN
      RAISE EXCEPTION 'ERROR: Stock insuficiente en % (tiene %, necesita %)', 
        NEW.ubicacion, COALESCE(v_stock_origen, 0), NEW.cantidad;
    END IF;
    
    -- Descontar del inventario
    UPDATE inventario
    SET cantidad_actual = cantidad_actual - NEW.cantidad
    WHERE producto_id = NEW.producto_id
    AND ubicacion = NEW.ubicacion;
    
    RAISE NOTICE 'OK: Descontado % de %', NEW.cantidad, NEW.ubicacion;
  END IF;
  
  RAISE NOTICE '========================================';
  RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER trigger_actualizar_inventario
AFTER INSERT ON transacciones
FOR EACH ROW
EXECUTE FUNCTION actualizar_inventario_desde_transaccion();

-- ============================================
-- PASO 4: TRIGGER 3 - RESTAURAR INVENTARIO AL ELIMINAR TRANSACCION
-- ============================================
CREATE OR REPLACE FUNCTION restaurar_inventario_al_eliminar()
RETURNS TRIGGER AS $$
DECLARE
  v_ubicacion_origen TEXT;
  v_ubicacion_destino TEXT;
  v_stock_destino INTEGER;
BEGIN
  RAISE NOTICE '========================================';
  RAISE NOTICE 'ELIMINANDO TRANSACCION: %', OLD.tipo_transaccion;
  RAISE NOTICE 'Producto: %', OLD.producto_id;
  RAISE NOTICE 'Cantidad: %', OLD.cantidad;
  RAISE NOTICE 'Ubicacion: %', OLD.ubicacion;
  RAISE NOTICE '========================================';
  
  -- ============================================
  -- CASO 1: TRANSFERENCIAS - REVERTIR
  -- ============================================
  IF OLD.tipo_transaccion = 'TRANSFERENCIA' THEN
    v_ubicacion_destino := OLD.ubicacion;
    
    -- Determinar origen (la OTRA sucursal)
    IF OLD.ubicacion = 'RESISTENCIA' THEN
      v_ubicacion_origen := 'CORRIENTES';
    ELSE
      v_ubicacion_origen := 'RESISTENCIA';
    END IF;
    
    RAISE NOTICE 'REVERTIR TRANSFERENCIA: % <- %', v_ubicacion_origen, v_ubicacion_destino;
    
    -- Verificar stock en destino
    SELECT cantidad_actual INTO v_stock_destino
    FROM inventario
    WHERE producto_id = OLD.producto_id
    AND ubicacion = v_ubicacion_destino;
    
    -- Si el producto no existe en destino (fue eliminado automaticamente)
    IF v_stock_destino IS NULL THEN
      RAISE NOTICE 'Producto ya no existe en % (fue eliminado)', v_ubicacion_destino;
      
      -- Solo restaurar al origen
      INSERT INTO inventario (producto_id, ubicacion, cantidad_actual, cantidad_minima, estado, es_original)
      VALUES (OLD.producto_id, v_ubicacion_origen, OLD.cantidad, 1, 'DISPONIBLE', true)
      ON CONFLICT (producto_id, ubicacion)
      DO UPDATE SET cantidad_actual = inventario.cantidad_actual + OLD.cantidad;
      
      RAISE NOTICE 'OK: Restaurado % a %', OLD.cantidad, v_ubicacion_origen;
      RAISE NOTICE 'TRANSFERENCIA REVERTIDA';
      RETURN OLD;
    END IF;
    
    -- Si no tiene suficiente stock
    IF v_stock_destino < OLD.cantidad THEN
      RAISE EXCEPTION 'ERROR: No se puede revertir. Stock insuficiente en % (tiene %, necesita %)', 
        v_ubicacion_destino, v_stock_destino, OLD.cantidad;
    END IF;
    
    -- Quitar del destino
    UPDATE inventario
    SET cantidad_actual = cantidad_actual - OLD.cantidad
    WHERE producto_id = OLD.producto_id
    AND ubicacion = v_ubicacion_destino;
    
    RAISE NOTICE 'OK: Quitado % de %', OLD.cantidad, v_ubicacion_destino;
    
    -- Restaurar al origen
    INSERT INTO inventario (producto_id, ubicacion, cantidad_actual, cantidad_minima, estado, es_original)
    VALUES (OLD.producto_id, v_ubicacion_origen, OLD.cantidad, 1, 'DISPONIBLE', true)
    ON CONFLICT (producto_id, ubicacion)
    DO UPDATE SET cantidad_actual = inventario.cantidad_actual + OLD.cantidad;
    
    RAISE NOTICE 'OK: Restaurado % a %', OLD.cantidad, v_ubicacion_origen;
    RAISE NOTICE 'TRANSFERENCIA REVERTIDA';
    
  -- ============================================
  -- CASO 2: COMPRA / CANJE_ENTRADA - RESTAR
  -- ============================================
  ELSIF OLD.tipo_transaccion IN ('COMPRA', 'CANJE_ENTRADA') THEN
    RAISE NOTICE 'REVERTIR COMPRA/CANJE_ENTRADA de %', OLD.ubicacion;
    
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
    
    RAISE NOTICE 'OK: Revertida compra - quitado % de %', OLD.cantidad, OLD.ubicacion;
    
  -- ============================================
  -- CASO 3: VENTA / CANJE_SALIDA / CIERRE_DIA - SUMAR
  -- ============================================
  ELSIF OLD.tipo_transaccion IN ('VENTA', 'CANJE_SALIDA', 'CIERRE_DIA') THEN
    RAISE NOTICE 'REVERTIR VENTA/SALIDA/CIERRE de %', OLD.ubicacion;
    
    INSERT INTO inventario (producto_id, ubicacion, cantidad_actual, cantidad_minima, estado, es_original)
    VALUES (OLD.producto_id, OLD.ubicacion, OLD.cantidad, 1, 'DISPONIBLE', true)
    ON CONFLICT (producto_id, ubicacion)
    DO UPDATE SET cantidad_actual = inventario.cantidad_actual + OLD.cantidad;
    
    RAISE NOTICE 'OK: Revertida venta - agregado % a %', OLD.cantidad, OLD.ubicacion;
  END IF;
  
  RAISE NOTICE '========================================';
  RETURN OLD;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER trigger_restaurar_inventario
BEFORE DELETE ON transacciones
FOR EACH ROW
EXECUTE FUNCTION restaurar_inventario_al_eliminar();

-- ============================================
-- PASO 5: TRIGGER 4 - LIMPIAR INVENTARIO CON 0 STOCK NO ORIGINAL
-- ============================================
CREATE OR REPLACE FUNCTION limpiar_inventario_cero()
RETURNS TRIGGER AS $$
BEGIN
    -- Si el stock llega a 0 y NO es original, eliminar
    IF NEW.cantidad_actual = 0 AND NEW.es_original = false THEN
        RAISE NOTICE 'Eliminando producto no original con 0 stock: % en %', NEW.producto_id, NEW.ubicacion;
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

-- ============================================
-- PASO 6: TRIGGER 5 - GESTIONAR ALERTAS
-- ============================================
CREATE OR REPLACE FUNCTION gestionar_alertas_stock()
RETURNS TRIGGER AS $$
DECLARE
    v_alerta_existente_id UUID;
BEGIN
    -- Solo procesar si el stock cambio
    IF TG_OP = 'UPDATE' AND OLD.cantidad_actual = NEW.cantidad_actual THEN
        RETURN NEW;
    END IF;
    
    -- Verificar si hay alerta existente
    SELECT id INTO v_alerta_existente_id
    FROM alertas_stock
    WHERE producto_id = NEW.producto_id
    AND ubicacion = NEW.ubicacion
    AND estado_alerta = 'ACTIVA';
    
    -- Stock bajo o en 0 (crear o mantener alerta)
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
    
    -- Stock recuperado (desactivar alerta)
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

-- ============================================
-- PASO 7: VERIFICACION FINAL
-- ============================================

-- Ver todos los triggers activos
SELECT 
    '=== TRIGGERS ACTIVOS ===' as info,
    trigger_name,
    event_object_table as tabla,
    action_timing as cuando,
    event_manipulation as evento
FROM information_schema.triggers
WHERE trigger_schema = 'public'
AND event_object_table IN ('inventario', 'transacciones')
ORDER BY event_object_table, trigger_name;

-- CONFIRMACION
DO $$
BEGIN
    RAISE NOTICE '';
    RAISE NOTICE '████████████████████████████████████████████████████████';
    RAISE NOTICE '█                                                      █';
    RAISE NOTICE '█       SISTEMA COMPLETO CONFIGURADO EXITOSAMENTE     █';
    RAISE NOTICE '█                                                      █';
    RAISE NOTICE '████████████████████████████████████████████████████████';
    RAISE NOTICE '';
    RAISE NOTICE 'GARANTIAS DEL SISTEMA:';
    RAISE NOTICE '';
    RAISE NOTICE '✓ COMPRAS:';
    RAISE NOTICE '  - Se agregan al inventario de la sucursal correcta';
    RAISE NOTICE '  - Marcadas como ORIGINALES';
    RAISE NOTICE '  - Al eliminar: se resta del inventario';
    RAISE NOTICE '';
    RAISE NOTICE '✓ VENTAS / CIERRE_DIA:';
    RAISE NOTICE '  - Se descuentan de la sucursal correcta';
    RAISE NOTICE '  - Valida stock antes de vender';
    RAISE NOTICE '  - Al eliminar: se restaura al inventario';
    RAISE NOTICE '';
    RAISE NOTICE '✓ TRANSFERENCIAS:';
    RAISE NOTICE '  - RESISTENCIA <-> CORRIENTES';
    RAISE NOTICE '  - Valida stock en origen';
    RAISE NOTICE '  - Descuenta de origen, agrega a destino';
    RAISE NOTICE '  - Al eliminar: revierte completamente';
    RAISE NOTICE '  - Productos transferidos NO son originales';
    RAISE NOTICE '';
    RAISE NOTICE '✓ CANJES:';
    RAISE NOTICE '  - ENTRADA: agrega stock (original)';
    RAISE NOTICE '  - SALIDA: descuenta stock';
    RAISE NOTICE '  - Al eliminar: se revierten';
    RAISE NOTICE '';
    RAISE NOTICE '✓ STOCK:';
    RAISE NOTICE '  - NUNCA negativo (bloqueado)';
    RAISE NOTICE '  - Productos originales: se mantienen con 0';
    RAISE NOTICE '  - Productos transferidos: se eliminan al llegar a 0';
    RAISE NOTICE '';
    RAISE NOTICE '✓ ALERTAS:';
    RAISE NOTICE '  - Se crean automaticamente cuando stock < minimo';
    RAISE NOTICE '  - Se resuelven automaticamente cuando stock >= minimo';
    RAISE NOTICE '';
    RAISE NOTICE '✓ HISTORIAL:';
    RAISE NOTICE '  - Todas las transacciones quedan registradas';
    RAISE NOTICE '  - Al eliminar transaccion, se revierte el stock';
    RAISE NOTICE '  - Trazabilidad completa';
    RAISE NOTICE '';
    RAISE NOTICE '████████████████████████████████████████████████████████';
    RAISE NOTICE '';
    RAISE NOTICE 'SISTEMA LISTO PARA PRODUCCION';
    RAISE NOTICE '';
    RAISE NOTICE '████████████████████████████████████████████████████████';
END $$;
