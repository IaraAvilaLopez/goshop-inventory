-- VERIFICAR SI LOS COMENTARIOS ESTÁN GUARDADOS

-- 1. Ver todas las ventas pendientes con comentarios
SELECT 
    vp.id,
    p.marca,
    p.modelo,
    vp.cantidad,
    vp.fecha,
    vp.procesada,
    vp.comentarios,
    vp.created_at
FROM ventas_pendientes vp
JOIN productos p ON vp.producto_id = p.id
ORDER BY vp.created_at DESC
LIMIT 10;

-- 2. Ver transacciones CIERRE_DIA con observaciones
SELECT 
    t.id,
    p.marca,
    p.modelo,
    t.cantidad,
    t.fecha_transaccion,
    t.observaciones,
    t.created_at
FROM transacciones t
JOIN productos p ON t.producto_id = p.id
WHERE t.tipo_transaccion = 'CIERRE_DIA'
ORDER BY t.created_at DESC
LIMIT 10;

-- 3. Verificar si la columna comentarios existe
SELECT 
    column_name,
    data_type,
    is_nullable
FROM information_schema.columns
WHERE table_name = 'ventas_pendientes'
AND column_name = 'comentarios';
