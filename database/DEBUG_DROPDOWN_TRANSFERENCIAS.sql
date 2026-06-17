-- ============================================
-- DEBUG: ¿Por qué no aparecen todos los productos?
-- ============================================

-- 1. Ver TODOS los productos de Resistencia (sin filtros)
SELECT 
    'RESISTENCIA - TODOS' as tipo,
    p.marca,
    p.modelo,
    p.capacidad_gb,
    i.cantidad_actual,
    i.estado
FROM inventario i
JOIN productos p ON i.producto_id = p.id
WHERE i.ubicacion = 'RESISTENCIA'
ORDER BY p.marca, p.modelo;

-- 2. Ver productos de Resistencia CON STOCK (como debería aparecer en dropdown)
SELECT 
    'RESISTENCIA - CON STOCK' as tipo,
    p.marca,
    p.modelo,
    p.capacidad_gb,
    i.cantidad_actual,
    i.estado
FROM inventario i
JOIN productos p ON i.producto_id = p.id
WHERE i.ubicacion = 'RESISTENCIA'
AND i.cantidad_actual > 0
AND i.estado = 'DISPONIBLE'
ORDER BY p.marca, p.modelo;

-- 3. Ver lo que devuelve vista_stock_actual
SELECT 
    'VISTA_STOCK_ACTUAL' as tipo,
    marca,
    modelo,
    capacidad_gb,
    cantidad_actual,
    estado
FROM vista_stock_actual
WHERE ubicacion = 'RESISTENCIA'
AND cantidad_actual > 0
AND estado = 'DISPONIBLE'
ORDER BY marca, modelo;

-- 4. Comparar: ¿Qué productos están en inventario pero NO en vista?
SELECT 
    'FALTA EN VISTA' as tipo,
    p.marca,
    p.modelo,
    p.capacidad_gb,
    i.cantidad_actual
FROM inventario i
JOIN productos p ON i.producto_id = p.id
WHERE i.ubicacion = 'RESISTENCIA'
AND i.cantidad_actual > 0
AND i.estado = 'DISPONIBLE'
AND NOT EXISTS (
    SELECT 1 FROM vista_stock_actual v
    WHERE v.producto_id = p.id
    AND v.ubicacion = 'RESISTENCIA'
);

-- 5. Contar productos
SELECT 
    'INVENTARIO' as fuente,
    COUNT(*) as total
FROM inventario
WHERE ubicacion = 'RESISTENCIA'
AND cantidad_actual > 0
AND estado = 'DISPONIBLE'
UNION ALL
SELECT 
    'VISTA' as fuente,
    COUNT(*) as total
FROM vista_stock_actual
WHERE ubicacion = 'RESISTENCIA'
AND cantidad_actual > 0
AND estado = 'DISPONIBLE';
