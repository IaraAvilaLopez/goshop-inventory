-- ============================================
-- BUSCAR SAMSUNG S26 ULTRA
-- ============================================

-- 1. Buscar en tabla productos
SELECT 
    'PRODUCTOS' as tabla,
    id,
    marca,
    modelo,
    capacidad_gb,
    color,
    categoria
FROM productos
WHERE marca LIKE '%SAMSUNG%'
AND modelo LIKE '%S26%'
ORDER BY modelo;

-- 2. Buscar en inventario
SELECT 
    'INVENTARIO' as tabla,
    p.marca,
    p.modelo,
    p.capacidad_gb,
    i.ubicacion,
    i.cantidad_actual,
    i.estado
FROM inventario i
JOIN productos p ON i.producto_id = p.id
WHERE p.marca LIKE '%SAMSUNG%'
AND p.modelo LIKE '%S26%'
ORDER BY i.ubicacion;

-- 3. Buscar en vista_stock_actual
SELECT 
    'VISTA_STOCK_ACTUAL' as tabla,
    marca,
    modelo,
    capacidad_gb,
    ubicacion,
    cantidad_actual,
    estado
FROM vista_stock_actual
WHERE marca LIKE '%SAMSUNG%'
AND modelo LIKE '%S26%'
ORDER BY ubicacion;

-- 4. Ver TODOS los SAMSUNG en Resistencia
SELECT 
    'TODOS LOS SAMSUNG EN RESISTENCIA' as info,
    p.marca,
    p.modelo,
    p.capacidad_gb,
    i.cantidad_actual,
    i.estado
FROM inventario i
JOIN productos p ON i.producto_id = p.id
WHERE p.marca LIKE '%SAMSUNG%'
AND i.ubicacion = 'RESISTENCIA'
ORDER BY p.modelo;

-- 5. Verificar si S26 existe pero con otro nombre
SELECT 
    'PRODUCTOS SIMILARES' as info,
    marca,
    modelo,
    capacidad_gb
FROM productos
WHERE marca LIKE '%SAMSUNG%'
AND (
    modelo LIKE '%26%'
    OR modelo LIKE '%S26%'
)
ORDER BY modelo;
