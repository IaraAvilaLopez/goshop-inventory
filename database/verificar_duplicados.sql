-- Verificar duplicados en inventario
SELECT 
    p.marca,
    p.modelo,
    i.ubicacion,
    i.estado,
    i.cantidad_actual,
    i.id as inventario_id,
    p.id as producto_id
FROM inventario i
JOIN productos p ON i.producto_id = p.id
WHERE p.marca = 'JBL' AND p.modelo = 'Flip 6'
ORDER BY i.created_at;

-- Ver si hay productos duplicados
SELECT 
    marca,
    modelo,
    COUNT(*) as cantidad,
    array_agg(id) as ids
FROM productos
WHERE marca = 'JBL' AND modelo = 'Flip 6'
GROUP BY marca, modelo
HAVING COUNT(*) > 1;
