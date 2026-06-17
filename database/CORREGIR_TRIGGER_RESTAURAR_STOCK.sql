-- ============================================
-- CORREGIR TRIGGER DE RESTAURACIÓN DE STOCK
-- ============================================
-- Este script corrige el trigger para que use UPSERT
-- y no falle cuando el producto ya existe en inventario

-- Eliminar trigger y función anterior (CASCADE elimina dependencias)
DROP TRIGGER IF EXISTS restaurar_inventario_al_eliminar ON transacciones;
DROP FUNCTION IF EXISTS restaurar_inventario_al_eliminar() CASCADE;

-- Crear función mejorada con UPSERT
CREATE OR REPLACE FUNCTION restaurar_inventario_al_eliminar()
RETURNS TRIGGER AS $$
DECLARE
    v_ubicacion_origen TEXT;
    v_ubicacion_destino TEXT;
    v_stock_actual INTEGER;
BEGIN
    -- IMPORTANTE: NO restaurar stock para CIERRE_DIA
    -- El stock se restaura automáticamente al eliminar las ventas pendientes
    IF OLD.tipo_transaccion IN ('VENTA', 'CANJE_SALIDA') THEN
        -- Restaurar stock en la ubicación de origen (sumar)
        INSERT INTO inventario (producto_id, ubicacion, cantidad_actual, cantidad_minima)
        VALUES (OLD.producto_id, OLD.ubicacion, OLD.cantidad, 1)
        ON CONFLICT (producto_id, ubicacion) 
        DO UPDATE SET 
            cantidad_actual = inventario.cantidad_actual + EXCLUDED.cantidad_actual;
            
        RAISE NOTICE 'Stock restaurado: % unidades de producto % en %', 
            OLD.cantidad, OLD.producto_id, OLD.ubicacion;
    
    ELSIF OLD.tipo_transaccion = 'TRANSFERENCIA' THEN
        -- Determinar origen y destino
        IF OLD.observaciones LIKE '%Origen:%' THEN
            v_ubicacion_origen := TRIM(SPLIT_PART(SPLIT_PART(OLD.observaciones, 'Origen:', 2), 'Destino:', 1));
            v_ubicacion_destino := TRIM(SPLIT_PART(OLD.observaciones, 'Destino:', 2));
        ELSE
            v_ubicacion_origen := OLD.ubicacion;
            v_ubicacion_destino := CASE 
                WHEN OLD.ubicacion = 'RESISTENCIA' THEN 'CORRIENTES'
                ELSE 'RESISTENCIA'
            END;
        END IF;

        -- Restaurar en origen (sumar)
        INSERT INTO inventario (producto_id, ubicacion, cantidad_actual, cantidad_minima)
        VALUES (OLD.producto_id, v_ubicacion_origen, OLD.cantidad, 1)
        ON CONFLICT (producto_id, ubicacion) 
        DO UPDATE SET 
            cantidad_actual = inventario.cantidad_actual + EXCLUDED.cantidad_actual;

        -- Restar en destino
        INSERT INTO inventario (producto_id, ubicacion, cantidad_actual, cantidad_minima)
        VALUES (OLD.producto_id, v_ubicacion_destino, -OLD.cantidad, 1)
        ON CONFLICT (producto_id, ubicacion) 
        DO UPDATE SET 
            cantidad_actual = inventario.cantidad_actual + EXCLUDED.cantidad_actual;

        RAISE NOTICE 'Transferencia revertida: % unidades de % a %', 
            OLD.cantidad, v_ubicacion_origen, v_ubicacion_destino;
    
    ELSIF OLD.tipo_transaccion = 'COMPRA' THEN
        -- Restar stock en la ubicación (eliminar compra)
        UPDATE inventario
        SET cantidad_actual = cantidad_actual - OLD.cantidad
        WHERE producto_id = OLD.producto_id
        AND ubicacion = OLD.ubicacion;

        RAISE NOTICE 'Compra eliminada: % unidades de producto % en %', 
            OLD.cantidad, OLD.producto_id, OLD.ubicacion;
    
    ELSIF OLD.tipo_transaccion = 'CANJE_ENTRADA' THEN
        -- Verificar si el producto existe en inventario
        SELECT cantidad_actual INTO v_stock_actual
        FROM inventario
        WHERE producto_id = OLD.producto_id
        AND ubicacion = OLD.ubicacion;

        -- Si no se encontró el producto, v_stock_actual será NULL
        IF v_stock_actual IS NULL THEN
            RAISE NOTICE 'Canje entrada eliminado: producto no existe en inventario (ya fue eliminado)';
        ELSIF v_stock_actual >= OLD.cantidad THEN
            -- Stock suficiente, restar normalmente
            UPDATE inventario
            SET cantidad_actual = cantidad_actual - OLD.cantidad
            WHERE producto_id = OLD.producto_id
            AND ubicacion = OLD.ubicacion;

            RAISE NOTICE 'Canje entrada eliminado: % unidades de producto % en %', 
                OLD.cantidad, OLD.producto_id, OLD.ubicacion;
        ELSE
            -- Stock insuficiente (0 o menor que cantidad del canje)
            -- Poner el stock en 0 y permitir eliminar la transacción
            UPDATE inventario
            SET cantidad_actual = 0
            WHERE producto_id = OLD.producto_id
            AND ubicacion = OLD.ubicacion;
            
            RAISE WARNING 'CANJE ENTRADA eliminado con stock insuficiente. Stock actual era %, se ajustó a 0. Parte del stock ya fue vendido o transferido.',
                v_stock_actual;
        END IF;
    END IF;

    RETURN OLD;
END;
$$ LANGUAGE plpgsql;

-- Crear trigger para eliminación de transacciones
CREATE TRIGGER restaurar_inventario_al_eliminar
AFTER DELETE ON transacciones
FOR EACH ROW
EXECUTE FUNCTION restaurar_inventario_al_eliminar();

-- ============================================
-- TRIGGER PARA RESTAURAR STOCK AL DESPROCESAR VENTAS
-- ============================================

-- Función para restaurar stock cuando una venta se marca como NO procesada
CREATE OR REPLACE FUNCTION restaurar_stock_venta_desprocesada()
RETURNS TRIGGER AS $$
BEGIN
    -- Solo actuar cuando una venta procesada se marca como NO procesada
    IF OLD.procesada = true AND NEW.procesada = false THEN
        -- Restaurar el stock (sumar la cantidad)
        INSERT INTO inventario (producto_id, ubicacion, cantidad_actual, cantidad_minima)
        VALUES (NEW.producto_id, NEW.ubicacion, NEW.cantidad, 1)
        ON CONFLICT (producto_id, ubicacion) 
        DO UPDATE SET 
            cantidad_actual = inventario.cantidad_actual + EXCLUDED.cantidad_actual;
            
        RAISE NOTICE 'Stock restaurado por desprocesar venta: % unidades de producto % en %', 
            NEW.cantidad, NEW.producto_id, NEW.ubicacion;
    END IF;
    
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

-- Crear trigger en ventas_pendientes
DROP TRIGGER IF EXISTS restaurar_stock_al_desprocesar ON ventas_pendientes;
CREATE TRIGGER restaurar_stock_al_desprocesar
AFTER UPDATE ON ventas_pendientes
FOR EACH ROW
EXECUTE FUNCTION restaurar_stock_venta_desprocesada();

-- ============================================
-- CONFIRMACIÓN
-- ============================================
DO $$
BEGIN
    RAISE NOTICE '';
    RAISE NOTICE '████████████████████████████████████████████████████████';
    RAISE NOTICE '█                                                      █';
    RAISE NOTICE '█   TRIGGERS DE RESTAURACIÓN CORREGIDOS               █';
    RAISE NOTICE '█                                                      █';
    RAISE NOTICE '████████████████████████████████████████████████████████';
    RAISE NOTICE '';
    RAISE NOTICE '✓ Trigger 1: Restaurar stock al eliminar transacciones';
    RAISE NOTICE '  - NO restaura stock para CIERRE_DIA (evita duplicación)';
    RAISE NOTICE '  - Usa UPSERT (INSERT ON CONFLICT DO UPDATE)';
    RAISE NOTICE '  - No falla si el producto ya existe en inventario';
    RAISE NOTICE '';
    RAISE NOTICE '✓ Trigger 2: Restaurar stock al desprocesar ventas';
    RAISE NOTICE '  - Restaura stock cuando venta pasa de procesada=true a false';
    RAISE NOTICE '  - Se activa al reiniciar un cierre de día';
    RAISE NOTICE '';
    RAISE NOTICE 'FLUJO CORRECTO AL REINICIAR CIERRE:';
    RAISE NOTICE '1. Ventas procesadas → NO procesadas (restaura stock)';
    RAISE NOTICE '2. Eliminar transacciones CIERRE_DIA (NO restaura stock)';
    RAISE NOTICE '3. Eliminar registro de cierre';
    RAISE NOTICE '4. Stock restaurado UNA SOLA VEZ ✓';
    RAISE NOTICE '';
    RAISE NOTICE '████████████████████████████████████████████████████████';
END $$;
