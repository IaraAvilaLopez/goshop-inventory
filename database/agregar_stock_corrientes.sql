-- Agregar stock de CORRIENTES (Casa Madre)
-- Estos son productos que están en Corrientes y se pueden pedir a Resistencia

-- Ejemplo: iPhone 13 128GB en CORRIENTES
INSERT INTO inventario (producto_id, cantidad_actual, cantidad_minima, ubicacion, estado)
SELECT id, 25, 5, 'CORRIENTES', 'DISPONIBLE'
FROM productos WHERE modelo = '13' AND marca = 'IPHONE' AND capacidad_gb = '128'
ON CONFLICT (producto_id, ubicacion, estado) DO UPDATE SET cantidad_actual = inventario.cantidad_actual + 25;

-- iPhone 13 PRO 256GB en CORRIENTES
INSERT INTO inventario (producto_id, cantidad_actual, cantidad_minima, ubicacion, estado)
SELECT id, 15, 5, 'CORRIENTES', 'DISPONIBLE'
FROM productos WHERE modelo = '13 PRO' AND marca = 'IPHONE' AND capacidad_gb = '256'
ON CONFLICT (producto_id, ubicacion, estado) DO UPDATE SET cantidad_actual = inventario.cantidad_actual + 15;

-- iPhone 14 PRO 128GB en CORRIENTES
INSERT INTO inventario (producto_id, cantidad_actual, cantidad_minima, ubicacion, estado)
SELECT id, 20, 5, 'CORRIENTES', 'DISPONIBLE'
FROM productos WHERE modelo = '14 PRO' AND marca = 'IPHONE' AND capacidad_gb = '128'
ON CONFLICT (producto_id, ubicacion, estado) DO UPDATE SET cantidad_actual = inventario.cantidad_actual + 20;

-- iPhone 15 128GB en CORRIENTES
INSERT INTO inventario (producto_id, cantidad_actual, cantidad_minima, ubicacion, estado)
SELECT id, 30, 5, 'CORRIENTES', 'DISPONIBLE'
FROM productos WHERE modelo = '15' AND marca = 'IPHONE' AND capacidad_gb = '128'
ON CONFLICT (producto_id, ubicacion, estado) DO UPDATE SET cantidad_actual = inventario.cantidad_actual + 30;

-- iPhone 15 PRO 256GB en CORRIENTES
INSERT INTO inventario (producto_id, cantidad_actual, cantidad_minima, ubicacion, estado)
SELECT id, 18, 5, 'CORRIENTES', 'DISPONIBLE'
FROM productos WHERE modelo = '15 PRO' AND marca = 'IPHONE' AND capacidad_gb = '256'
ON CONFLICT (producto_id, ubicacion, estado) DO UPDATE SET cantidad_actual = inventario.cantidad_actual + 18;

-- Samsung S24 ULTRA 256GB en CORRIENTES
INSERT INTO inventario (producto_id, cantidad_actual, cantidad_minima, ubicacion, estado)
SELECT id, 12, 5, 'CORRIENTES', 'DISPONIBLE'
FROM productos WHERE modelo = 'S24 ULTRA' AND marca = 'SAMSUNG' AND capacidad_gb = '256'
ON CONFLICT (producto_id, ubicacion, estado) DO UPDATE SET cantidad_actual = inventario.cantidad_actual + 12;

-- Samsung S25 ULTRA 256GB en CORRIENTES
INSERT INTO inventario (producto_id, cantidad_actual, cantidad_minima, ubicacion, estado)
SELECT id, 10, 5, 'CORRIENTES', 'DISPONIBLE'
FROM productos WHERE modelo = 'S25 ULTRA' AND marca = 'SAMSUNG' AND capacidad_gb = '256'
ON CONFLICT (producto_id, ubicacion, estado) DO UPDATE SET cantidad_actual = inventario.cantidad_actual + 10;

-- Verificar stock por ubicación
SELECT 
    i.ubicacion,
    p.marca,
    p.modelo,
    p.capacidad_gb,
    i.cantidad_actual,
    i.estado
FROM inventario i
JOIN productos p ON i.producto_id = p.id
ORDER BY i.ubicacion, p.marca, p.modelo;

-- Resumen por ubicación
SELECT 
    ubicacion,
    COUNT(*) as total_productos,
    SUM(cantidad_actual) as total_unidades
FROM inventario
GROUP BY ubicacion
ORDER BY ubicacion;
