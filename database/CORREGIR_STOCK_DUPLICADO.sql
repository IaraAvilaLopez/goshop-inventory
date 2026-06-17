-- ============================================
-- CORREGIR STOCK DUPLICADO - LIMPIEZA COMPLETA
-- ============================================
-- Este script elimina transacciones duplicadas de CIERRE_DIA
-- y recalcula el stock correcto desde cero

-- ADVERTENCIA: Este script modificará datos. Asegúrate de tener backup.

-- PASO 1: Identificar producto
DO $$
DECLARE
    v_producto_id UUID;
    v_stock_actual_res INTEGER;
    v_stock_actual_cor INTEGER;
BEGIN
    SELECT id INTO v_producto_id
    FROM productos
    WHERE marca = 'JBL' AND modelo = 'FLIP' AND color = 'Negro';
    
    IF v_producto_id IS NULL THEN
        RAISE EXCEPTION 'Producto JBL FLIP Negro no encontrado';
    END IF;
    
    RAISE NOTICE 'Producto encontrado: %', v_producto_id;
    
    -- Ver stock actual antes de limpiar
    SELECT cantidad_actual INTO v_stock_actual_res
    FROM inventario
    WHERE producto_id = v_producto_id AND ubicacion = 'RESISTENCIA';
    
    SELECT cantidad_actual INTO v_stock_actual_cor
    FROM inventario
    WHERE producto_id = v_producto_id AND ubicacion = 'CORRIENTES';
    
    RAISE NOTICE 'Stock ANTES de limpieza:';
    RAISE NOTICE '  RESISTENCIA: %', COALESCE(v_stock_actual_res, 0);
    RAISE NOTICE '  CORRIENTES: %', COALESCE(v_stock_actual_cor, 0);
END $$;

-- PASO 2: Eliminar transacciones CIERRE_DIA duplicadas
-- Mantener solo la primera transacción de cada día/ubicación
DO $$
DECLARE
    v_producto_id UUID;
    v_deleted INTEGER;
BEGIN
    SELECT id INTO v_producto_id
    FROM productos
    WHERE marca = 'JBL' AND modelo = 'FLIP' AND color = 'Negro';
    
    -- Eliminar duplicados (mantener solo el ID más antiguo de cada día/ubicación)
    WITH duplicados AS (
        SELECT 
            id,
            ROW_NUMBER() OVER (
                PARTITION BY DATE(fecha_transaccion), ubicacion 
                ORDER BY fecha_transaccion ASC, id ASC
            ) as rn
        FROM transacciones
        WHERE producto_id = v_producto_id
        AND tipo_transaccion = 'CIERRE_DIA'
    )
    DELETE FROM transacciones
    WHERE id IN (
        SELECT id FROM duplicados WHERE rn > 1
    );
    
    GET DIAGNOSTICS v_deleted = ROW_COUNT;
    
    RAISE NOTICE '';
    RAISE NOTICE 'Transacciones CIERRE_DIA duplicadas eliminadas: %', v_deleted;
END $$;

-- PASO 3: Recalcular stock desde cero
DO $$
DECLARE
    v_producto_id UUID;
    v_stock_calculado_res INTEGER := 0;
    v_stock_calculado_cor INTEGER := 0;
    rec RECORD;
BEGIN
    SELECT id INTO v_producto_id
    FROM productos
    WHERE marca = 'JBL' AND modelo = 'FLIP' AND color = 'Negro';
    
    RAISE NOTICE '';
    RAISE NOTICE 'Recalculando stock desde transacciones...';
    
    -- Recorrer todas las transacciones en orden cronológico
    FOR rec IN 
        SELECT tipo_transaccion, cantidad, ubicacion
        FROM transacciones
        WHERE producto_id = v_producto_id
        ORDER BY fecha_transaccion ASC
    LOOP
        IF rec.tipo_transaccion IN ('COMPRA', 'CANJE_ENTRADA') THEN
            -- Agregar al stock de la ubicación
            IF rec.ubicacion = 'RESISTENCIA' THEN
                v_stock_calculado_res := v_stock_calculado_res + rec.cantidad;
            ELSE
                v_stock_calculado_cor := v_stock_calculado_cor + rec.cantidad;
            END IF;
            
        ELSIF rec.tipo_transaccion IN ('VENTA', 'CANJE_SALIDA', 'CIERRE_DIA') THEN
            -- Restar del stock de la ubicación
            IF rec.ubicacion = 'RESISTENCIA' THEN
                v_stock_calculado_res := v_stock_calculado_res - rec.cantidad;
            ELSE
                v_stock_calculado_cor := v_stock_calculado_cor - rec.cantidad;
            END IF;
            
        ELSIF rec.tipo_transaccion = 'TRANSFERENCIA' THEN
            -- Transferencia: destino = rec.ubicacion, origen = la otra
            IF rec.ubicacion = 'RESISTENCIA' THEN
                -- De CORRIENTES a RESISTENCIA
                v_stock_calculado_cor := v_stock_calculado_cor - rec.cantidad;
                v_stock_calculado_res := v_stock_calculado_res + rec.cantidad;
            ELSE
                -- De RESISTENCIA a CORRIENTES
                v_stock_calculado_res := v_stock_calculado_res - rec.cantidad;
                v_stock_calculado_cor := v_stock_calculado_cor + rec.cantidad;
            END IF;
        END IF;
    END LOOP;
    
    RAISE NOTICE 'Stock calculado desde transacciones:';
    RAISE NOTICE '  RESISTENCIA: %', v_stock_calculado_res;
    RAISE NOTICE '  CORRIENTES: %', v_stock_calculado_cor;
    
    -- Actualizar inventario con valores correctos
    UPDATE inventario
    SET cantidad_actual = v_stock_calculado_res
    WHERE producto_id = v_producto_id AND ubicacion = 'RESISTENCIA';
    
    UPDATE inventario
    SET cantidad_actual = v_stock_calculado_cor
    WHERE producto_id = v_producto_id AND ubicacion = 'CORRIENTES';
    
    RAISE NOTICE '';
    RAISE NOTICE 'Inventario actualizado correctamente';
END $$;

-- PASO 4: Eliminar cierres duplicados (mantener solo el más reciente de cada día/ubicación)
DO $$
DECLARE
    v_deleted INTEGER;
BEGIN
    WITH duplicados AS (
        SELECT 
            id,
            ROW_NUMBER() OVER (
                PARTITION BY fecha_cierre, ubicacion 
                ORDER BY created_at DESC
            ) as rn
        FROM cierres_dia
    )
    DELETE FROM cierres_dia
    WHERE id IN (
        SELECT id FROM duplicados WHERE rn > 1
    );
    
    GET DIAGNOSTICS v_deleted = ROW_COUNT;
    
    RAISE NOTICE 'Registros de cierres_dia duplicados eliminados: %', v_deleted;
END $$;

-- PASO 5: Verificar resultado final
DO $$
DECLARE
    v_producto_id UUID;
    v_stock_final_res INTEGER;
    v_stock_final_cor INTEGER;
BEGIN
    SELECT id INTO v_producto_id
    FROM productos
    WHERE marca = 'JBL' AND modelo = 'FLIP' AND color = 'Negro';
    
    SELECT cantidad_actual INTO v_stock_final_res
    FROM inventario
    WHERE producto_id = v_producto_id AND ubicacion = 'RESISTENCIA';
    
    SELECT cantidad_actual INTO v_stock_final_cor
    FROM inventario
    WHERE producto_id = v_producto_id AND ubicacion = 'CORRIENTES';
    
    RAISE NOTICE '';
    RAISE NOTICE '================================================';
    RAISE NOTICE 'LIMPIEZA COMPLETADA';
    RAISE NOTICE '================================================';
    RAISE NOTICE '';
    RAISE NOTICE 'Stock FINAL:';
    RAISE NOTICE '  RESISTENCIA: %', COALESCE(v_stock_final_res, 0);
    RAISE NOTICE '  CORRIENTES: %', COALESCE(v_stock_final_cor, 0);
    RAISE NOTICE '  TOTAL: %', COALESCE(v_stock_final_res, 0) + COALESCE(v_stock_final_cor, 0);
    RAISE NOTICE '';
    RAISE NOTICE '================================================';
END $$;
