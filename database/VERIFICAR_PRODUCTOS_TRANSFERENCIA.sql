-- ============================================
-- VERIFICAR PRODUCTOS PARA TRANSFERENCIA
-- ============================================

-- Ver todos los productos de Resistencia con stock
SELECT 
    p.marca,
    p.modelo,
    p.capacidad_gb,
    p.color,
    i.cantidad_actual,
    i.estado,
    i.ubicacion
FROM inventario i
JOIN productos p ON i.producto_id = p.id
WHERE i.ubicacion = 'RESISTENCIA'
AND i.cantidad_actual > 0
ORDER BY p.marca, p.modelo;

-- Ver todos los productos de Corrientes con stock
SELECT 
    p.marca,
    p.modelo,
    p.capacidad_gb,
    p.color,
    i.cantidad_actual,
    i.estado,
    i.ubicacion
FROM inventario i
JOIN productos p ON i.producto_id = p.id
WHERE i.ubicacion = 'CORRIENTES'
AND i.cantidad_actual > 0
ORDER BY p.marca, p.modelo;

-- Ver productos que están en vista_stock_actual de Resistencia
SELECT 
    marca,
    modelo,
    capacidad_gb,
    color,
    cantidad_actual,
    estado,
    ubicacion
FROM vista_stock_actual
WHERE ubicacion = 'RESISTENCIA'
AND cantidad_actual > 0
ORDER BY marca, modelo;

-- Buscar específicamente SAMSUNG S26
SELECT 
    p.id,
    p.marca,
    p.modelo,
    p.capacidad_gb,
    i.ubicacion,
    i.cantidad_actual,
    i.estado
FROM productos p
LEFT JOIN inventario i ON p.id = i.producto_id
WHERE p.marca = 'SAMSUNG'
AND p.modelo LIKE '%S26%'
ORDER BY i.ubicacion;
