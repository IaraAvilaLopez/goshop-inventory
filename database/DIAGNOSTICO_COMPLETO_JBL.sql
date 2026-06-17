-- ============================================
-- DIAGNOSTICO COMPLETO AUTOMATICO - JBL FLIP NEGRO
-- ============================================

-- PASO 1: Ver producto y su inventario actual
DO $$
DECLARE
    v_producto_id UUID;
    v_stock_resistencia INTEGER;
    v_stock_corrientes INTEGER;
BEGIN
    -- Obtener ID del producto
    SELECT id INTO v_producto_id
    FROM productos
    WHERE marca = 'JBL' AND modelo = 'FLIP' AND color = 'Negro';
    
    IF v_producto_id IS NULL THEN
        RAISE NOTICE 'ERROR: Producto JBL FLIP Negro no encontrado';
        RETURN;
    END IF;
    
    RAISE NOTICE '';
    RAISE NOTICE '================================================';
    RAISE NOTICE 'PRODUCTO: JBL FLIP Negro';
    RAISE NOTICE 'ID: %', v_producto_id;
    RAISE NOTICE '================================================';
    RAISE NOTICE '';
    
    -- Ver stock en cada sucursal
    SELECT cantidad_actual INTO v_stock_resistencia
    FROM inventario
    WHERE producto_id = v_producto_id AND ubicacion = 'RESISTENCIA';
    
    SELECT cantidad_actual INTO v_stock_corrientes
    FROM inventario
    WHERE producto_id = v_producto_id AND ubicacion = 'CORRIENTES';
    
    RAISE NOTICE '=== STOCK ACTUAL ===';
    RAISE NOTICE 'RESISTENCIA: % unidades', COALESCE(v_stock_resistencia, 0);
    RAISE NOTICE 'CORRIENTES: % unidades', COALESCE(v_stock_corrientes, 0);
    RAISE NOTICE 'TOTAL: % unidades', COALESCE(v_stock_resistencia, 0) + COALESCE(v_stock_corrientes, 0);
    RAISE NOTICE '';
END $$;

-- PASO 2: Ver todas las transacciones
SELECT 
    '=== HISTORIAL COMPLETO DE TRANSACCIONES ===' as seccion,
    t.fecha_transaccion,
    t.tipo_transaccion,
    t.cantidad,
    t.ubicacion,
    t.observaciones
FROM transacciones t
JOIN productos p ON t.producto_id = p.id
WHERE p.marca = 'JBL' AND p.modelo = 'FLIP' AND p.color = 'Negro'
ORDER BY t.fecha_transaccion DESC;

-- PASO 3: Ver cierres de dia de hoy
SELECT 
    '=== CIERRES DE HOY ===' as seccion,
    fecha_cierre,
    ubicacion,
    total_ventas,
    observaciones,
    created_at
FROM cierres_dia
WHERE fecha_cierre = CURRENT_DATE
ORDER BY ubicacion;

-- PASO 4: Contar transacciones de CIERRE_DIA por dia
SELECT 
    '=== TRANSACCIONES CIERRE_DIA POR DIA ===' as seccion,
    DATE(t.fecha_transaccion) as fecha,
    t.ubicacion,
    COUNT(*) as num_transacciones,
    SUM(t.cantidad) as total_unidades
FROM transacciones t
JOIN productos p ON t.producto_id = p.id
WHERE p.marca = 'JBL' 
AND p.modelo = 'FLIP' 
AND p.color = 'Negro'
AND t.tipo_transaccion = 'CIERRE_DIA'
GROUP BY DATE(t.fecha_transaccion), t.ubicacion
ORDER BY fecha DESC, ubicacion;

-- PASO 5: Detectar duplicados
DO $$
DECLARE
    v_duplicados INTEGER;
BEGIN
    SELECT COUNT(*) INTO v_duplicados
    FROM (
        SELECT DATE(t.fecha_transaccion) as fecha, t.ubicacion, COUNT(*) as cnt
        FROM transacciones t
        JOIN productos p ON t.producto_id = p.id
        WHERE p.marca = 'JBL' 
        AND p.modelo = 'FLIP' 
        AND p.color = 'Negro'
        AND t.tipo_transaccion = 'CIERRE_DIA'
        GROUP BY DATE(t.fecha_transaccion), t.ubicacion
        HAVING COUNT(*) > 1
    ) duplicados;
    
    RAISE NOTICE '';
    RAISE NOTICE '================================================';
    IF v_duplicados > 0 THEN
        RAISE NOTICE 'ALERTA: Se encontraron % dias con transacciones CIERRE_DIA duplicadas', v_duplicados;
        RAISE NOTICE 'Esto causa que el stock se descuente multiples veces';
        RAISE NOTICE '';
        RAISE NOTICE 'SOLUCION: Ejecuta el script de limpieza';
    ELSE
        RAISE NOTICE 'OK: No hay transacciones CIERRE_DIA duplicadas';
    END IF;
    RAISE NOTICE '================================================';
    RAISE NOTICE '';
END $$;
