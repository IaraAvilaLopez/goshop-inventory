-- ============================================
-- DIAGNOSTICO Y LIMPIEZA - JBL FLIP NEGRO
-- ============================================

-- PASO 1: Ver estado actual del producto
SELECT 
    '=== INVENTARIO ACTUAL ===' as info,
    i.ubicacion,
    i.cantidad_actual,
    i.cantidad_minima,
    i.es_original,
    p.marca,
    p.modelo,
    p.color
FROM inventario i
JOIN productos p ON i.producto_id = p.id
WHERE p.marca = 'JBL' 
AND p.modelo = 'FLIP'
AND p.color = 'Negro';

-- PASO 2: Ver todas las transacciones de este producto
SELECT 
    '=== HISTORIAL DE TRANSACCIONES ===' as info,
    t.fecha_transaccion,
    t.tipo_transaccion,
    t.cantidad,
    t.ubicacion,
    t.observaciones
FROM transacciones t
JOIN productos p ON t.producto_id = p.id
WHERE p.marca = 'JBL' 
AND p.modelo = 'FLIP'
AND p.color = 'Negro'
ORDER BY t.fecha_transaccion DESC;

-- PASO 3: Ver cierres de dia
SELECT 
    '=== CIERRES DE DIA ===' as info,
    fecha_cierre,
    ubicacion,
    total_ventas,
    created_at
FROM cierres_dia
WHERE fecha_cierre >= CURRENT_DATE - INTERVAL '7 days'
ORDER BY fecha_cierre DESC, ubicacion;

-- PASO 4: Contar transacciones de CIERRE_DIA duplicadas
SELECT 
    '=== TRANSACCIONES CIERRE_DIA ===' as info,
    DATE(fecha_transaccion) as fecha,
    ubicacion,
    COUNT(*) as cantidad_transacciones,
    SUM(cantidad) as total_unidades
FROM transacciones t
JOIN productos p ON t.producto_id = p.id
WHERE p.marca = 'JBL' 
AND p.modelo = 'FLIP'
AND p.color = 'Negro'
AND t.tipo_transaccion = 'CIERRE_DIA'
GROUP BY DATE(fecha_transaccion), ubicacion
ORDER BY fecha DESC;

-- CONFIRMACION
DO $$
BEGIN
    RAISE NOTICE '';
    RAISE NOTICE '================================================';
    RAISE NOTICE 'DIAGNOSTICO COMPLETADO';
    RAISE NOTICE '================================================';
    RAISE NOTICE '';
    RAISE NOTICE 'Revisa los resultados arriba para ver:';
    RAISE NOTICE '1. Stock actual en inventario';
    RAISE NOTICE '2. Historial completo de transacciones';
    RAISE NOTICE '3. Cierres registrados';
    RAISE NOTICE '4. Transacciones duplicadas de CIERRE_DIA';
    RAISE NOTICE '';
    RAISE NOTICE 'Si hay duplicados, ejecuta el siguiente script de limpieza';
    RAISE NOTICE '';
    RAISE NOTICE '================================================';
END $$;
