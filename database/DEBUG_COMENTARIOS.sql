-- DEBUG: VERIFICAR COMENTARIOS EN TODO EL FLUJO

-- 1. ¿Existe la columna comentarios en ventas_pendientes?
SELECT 
    'PASO 1: Verificar columna' as paso,
    column_name,
    data_type,
    is_nullable
FROM information_schema.columns
WHERE table_name = 'ventas_pendientes'
AND column_name = 'comentarios';

-- 2. ¿Hay ventas pendientes con comentarios?
SELECT 
    'PASO 2: Ventas con comentarios' as paso,
    vp.id,
    p.marca,
    p.modelo,
    vp.cantidad,
    vp.fecha,
    vp.procesada,
    vp.comentarios,
    LENGTH(vp.comentarios) as longitud_comentario
FROM ventas_pendientes vp
JOIN productos p ON vp.producto_id = p.id
WHERE vp.fecha = '2026-06-03'
ORDER BY vp.created_at DESC;

-- 3. ¿Las transacciones CIERRE_DIA tienen los comentarios en observaciones?
SELECT 
    'PASO 3: Transacciones CIERRE_DIA' as paso,
    t.id,
    p.marca,
    p.modelo,
    t.cantidad,
    t.observaciones,
    LENGTH(t.observaciones) as longitud_observaciones,
    t.fecha_transaccion
FROM transacciones t
JOIN productos p ON t.producto_id = p.id
WHERE t.tipo_transaccion = 'CIERRE_DIA'
AND t.fecha_transaccion::date = '2026-06-03'
ORDER BY t.created_at DESC;

-- 4. ¿Cuántas ventas procesadas vs no procesadas?
SELECT 
    'PASO 4: Estado de ventas' as paso,
    procesada,
    COUNT(*) as cantidad,
    SUM(cantidad) as total_unidades
FROM ventas_pendientes
WHERE fecha = '2026-06-03'
GROUP BY procesada;
