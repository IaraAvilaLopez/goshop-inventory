-- Migración de datos desde Google Sheets a GoShop
-- Basado en tu stock actual de RESISTENCIA

-- IMPORTANTE: Ejecutar este script en Supabase SQL Editor DESPUÉS de ejecutar schema.sql

-- ============================================
-- PRODUCTOS IPHONE
-- ============================================

-- iPhone 11 PRO MAX
INSERT INTO productos (modelo, marca, color, capacidad_gb) VALUES
('11 PRO MAX', 'IPHONE', NULL, '256');

INSERT INTO inventario (producto_id, cantidad_actual, cantidad_minima, ubicacion, estado)
SELECT id, 4, 1, 'RESISTENCIA', 'DISPONIBLE'
FROM productos WHERE modelo = '11 PRO MAX' AND marca = 'IPHONE' AND capacidad_gb = '256';

-- iPhone 13
INSERT INTO productos (modelo, marca, color, capacidad_gb) VALUES
('13', 'IPHONE', NULL, '128');

INSERT INTO inventario (producto_id, cantidad_actual, cantidad_minima, ubicacion, estado)
SELECT id, 11, 1, 'RESISTENCIA', 'DISPONIBLE'
FROM productos WHERE modelo = '13' AND marca = 'IPHONE' AND capacidad_gb = '128';

-- iPhone 12 PRO
INSERT INTO productos (modelo, marca, color, capacidad_gb) VALUES
('12 PRO', 'IPHONE', NULL, '128');

INSERT INTO inventario (producto_id, cantidad_actual, cantidad_minima, ubicacion, estado)
SELECT id, 11, 1, 'RESISTENCIA', 'DISPONIBLE'
FROM productos WHERE modelo = '12 PRO' AND marca = 'IPHONE' AND capacidad_gb = '128';

-- iPhone 13 PRO
INSERT INTO productos (modelo, marca, color, capacidad_gb) VALUES
('13 PRO', 'IPHONE', NULL, '256');

INSERT INTO inventario (producto_id, cantidad_actual, cantidad_minima, ubicacion, estado)
SELECT id, 6, 1, 'RESISTENCIA', 'DISPONIBLE'
FROM productos WHERE modelo = '13 PRO' AND marca = 'IPHONE' AND capacidad_gb = '256';

-- iPhone 15 PRO
INSERT INTO productos (modelo, marca, color, capacidad_gb) VALUES
('15 PRO', 'IPHONE', NULL, '256');

INSERT INTO inventario (producto_id, cantidad_actual, cantidad_minima, ubicacion, estado)
SELECT id, 6, 1, 'RESISTENCIA', 'DISPONIBLE'
FROM productos WHERE modelo = '15 PRO' AND marca = 'IPHONE' AND capacidad_gb = '256';

-- iPhone 13 PRO MAX (256)
INSERT INTO productos (modelo, marca, color, capacidad_gb) VALUES
('13 PRO MAX', 'IPHONE', NULL, '256');

INSERT INTO inventario (producto_id, cantidad_actual, cantidad_minima, ubicacion, estado)
SELECT id, 3, 1, 'RESISTENCIA', 'DISPONIBLE'
FROM productos WHERE modelo = '13 PRO MAX' AND marca = 'IPHONE' AND capacidad_gb = '256';

-- iPhone 13 PRO MAX (128)
INSERT INTO productos (modelo, marca, color, capacidad_gb) VALUES
('13 PRO MAX', 'IPHONE', NULL, '128');

INSERT INTO inventario (producto_id, cantidad_actual, cantidad_minima, ubicacion, estado)
SELECT id, 2, 1, 'RESISTENCIA', 'DISPONIBLE'
FROM productos WHERE modelo = '13 PRO MAX' AND marca = 'IPHONE' AND capacidad_gb = '128';

-- iPhone 14 PRO (512)
INSERT INTO productos (modelo, marca, color, capacidad_gb) VALUES
('14 PRO', 'IPHONE', NULL, '512');

INSERT INTO inventario (producto_id, cantidad_actual, cantidad_minima, ubicacion, estado)
SELECT id, 2, 1, 'RESISTENCIA', 'DISPONIBLE'
FROM productos WHERE modelo = '14 PRO' AND marca = 'IPHONE' AND capacidad_gb = '512';

-- iPhone 14 PRO (1T)
INSERT INTO productos (modelo, marca, color, capacidad_gb) VALUES
('14 PRO', 'IPHONE', NULL, '1T');

INSERT INTO inventario (producto_id, cantidad_actual, cantidad_minima, ubicacion, estado)
SELECT id, 2, 1, 'RESISTENCIA', 'DISPONIBLE'
FROM productos WHERE modelo = '14 PRO' AND marca = 'IPHONE' AND capacidad_gb = '1T';

-- iPhone 14 PRO (128)
INSERT INTO productos (modelo, marca, color, capacidad_gb) VALUES
('14 PRO', 'IPHONE', NULL, '128');

INSERT INTO inventario (producto_id, cantidad_actual, cantidad_minima, ubicacion, estado)
SELECT id, 4, 1, 'RESISTENCIA', 'DISPONIBLE'
FROM productos WHERE modelo = '14 PRO' AND marca = 'IPHONE' AND capacidad_gb = '128';

-- iPhone 15 (128)
INSERT INTO productos (modelo, marca, color, capacidad_gb) VALUES
('15', 'IPHONE', NULL, '128');

INSERT INTO inventario (producto_id, cantidad_actual, cantidad_minima, ubicacion, estado)
SELECT id, 4, 1, 'RESISTENCIA', 'DISPONIBLE'
FROM productos WHERE modelo = '15' AND marca = 'IPHONE' AND capacidad_gb = '128';

-- iPhone 15 PRO (128)
INSERT INTO productos (modelo, marca, color, capacidad_gb) VALUES
('15 PRO', 'IPHONE', NULL, '128');

INSERT INTO inventario (producto_id, cantidad_actual, cantidad_minima, ubicacion, estado)
SELECT id, 4, 1, 'RESISTENCIA', 'DISPONIBLE'
FROM productos WHERE modelo = '15 PRO' AND marca = 'IPHONE' AND capacidad_gb = '128';

-- iPhone 16 PRO (256)
INSERT INTO productos (modelo, marca, color, capacidad_gb) VALUES
('16 PRO', 'IPHONE', NULL, '256');

INSERT INTO inventario (producto_id, cantidad_actual, cantidad_minima, ubicacion, estado)
SELECT id, 4, 1, 'RESISTENCIA', 'DISPONIBLE'
FROM productos WHERE modelo = '16 PRO' AND marca = 'IPHONE' AND capacidad_gb = '256';

-- iPhone 16 PRO MAX (256)
INSERT INTO productos (modelo, marca, color, capacidad_gb) VALUES
('16 PRO MAX', 'IPHONE', NULL, '256');

INSERT INTO inventario (producto_id, cantidad_actual, cantidad_minima, ubicacion, estado)
SELECT id, 2, 1, 'RESISTENCIA', 'DISPONIBLE'
FROM productos WHERE modelo = '16 PRO MAX' AND marca = 'IPHONE' AND capacidad_gb = '256';

-- iPhone 16 PRO MAX (256) - segunda entrada
INSERT INTO inventario (producto_id, cantidad_actual, cantidad_minima, ubicacion, estado)
SELECT id, 1, 1, 'RESISTENCIA', 'DISPONIBLE'
FROM productos WHERE modelo = '16 PRO MAX' AND marca = 'IPHONE' AND capacidad_gb = '256'
ON CONFLICT (producto_id, ubicacion, estado) DO UPDATE SET cantidad_actual = inventario.cantidad_actual + 1;

-- iPhone 17 (256)
INSERT INTO productos (modelo, marca, color, capacidad_gb) VALUES
('17', 'IPHONE', NULL, '256');

INSERT INTO inventario (producto_id, cantidad_actual, cantidad_minima, ubicacion, estado)
SELECT id, 1, 1, 'RESISTENCIA', 'DISPONIBLE'
FROM productos WHERE modelo = '17' AND marca = 'IPHONE' AND capacidad_gb = '256';

-- iPhone 17 BLANCO C/ caja (256)
INSERT INTO productos (modelo, marca, color, capacidad_gb) VALUES
('17 BLANCO C/ caja', 'IPHONE', 'BLANCO', '256');

INSERT INTO inventario (producto_id, cantidad_actual, cantidad_minima, ubicacion, estado)
SELECT id, 1, 1, 'RESISTENCIA', 'DISPONIBLE'
FROM productos WHERE modelo = '17 BLANCO C/ caja' AND marca = 'IPHONE' AND capacidad_gb = '256';

-- iPhone 17 PRO (256)
INSERT INTO productos (modelo, marca, color, capacidad_gb) VALUES
('17 PRO', 'IPHONE', NULL, '256');

INSERT INTO inventario (producto_id, cantidad_actual, cantidad_minima, ubicacion, estado)
SELECT id, 1, 1, 'RESISTENCIA', 'DISPONIBLE'
FROM productos WHERE modelo = '17 PRO' AND marca = 'IPHONE' AND capacidad_gb = '256';

-- iPhone 17 PRO MAX (256)
INSERT INTO productos (modelo, marca, color, capacidad_gb) VALUES
('17 PRO MAX', 'IPHONE', NULL, '256');

INSERT INTO inventario (producto_id, cantidad_actual, cantidad_minima, ubicacion, estado)
SELECT id, 1, 1, 'RESISTENCIA', 'DISPONIBLE'
FROM productos WHERE modelo = '17 PRO MAX' AND marca = 'IPHONE' AND capacidad_gb = '256';

-- ============================================
-- PRODUCTOS SAMSUNG
-- ============================================

-- Samsung S24 ULTRA (256)
INSERT INTO productos (modelo, marca, color, capacidad_gb) VALUES
('S24 ULTRA', 'SAMSUNG', NULL, '256');

INSERT INTO inventario (producto_id, cantidad_actual, cantidad_minima, ubicacion, estado)
SELECT id, 2, 1, 'RESISTENCIA', 'DISPONIBLE'
FROM productos WHERE modelo = 'S24 ULTRA' AND marca = 'SAMSUNG' AND capacidad_gb = '256';

-- Samsung S24 ULTRA (256) - segunda entrada
INSERT INTO inventario (producto_id, cantidad_actual, cantidad_minima, ubicacion, estado)
SELECT id, 1, 1, 'RESISTENCIA', 'DISPONIBLE'
FROM productos WHERE modelo = 'S24 ULTRA' AND marca = 'SAMSUNG' AND capacidad_gb = '256'
ON CONFLICT (producto_id, ubicacion, estado) DO UPDATE SET cantidad_actual = inventario.cantidad_actual + 1;

-- Samsung S25 ULTRA (256)
INSERT INTO productos (modelo, marca, color, capacidad_gb) VALUES
('S25 ULTRA', 'SAMSUNG', NULL, '256');

INSERT INTO inventario (producto_id, cantidad_actual, cantidad_minima, ubicacion, estado)
SELECT id, 2, 1, 'RESISTENCIA', 'DISPONIBLE'
FROM productos WHERE modelo = 'S25 ULTRA' AND marca = 'SAMSUNG' AND capacidad_gb = '256';

-- ============================================
-- PRODUCTOS SELLADOS
-- ============================================

-- iPhone 13 (128) SELLADO
INSERT INTO productos (modelo, marca, color, capacidad_gb) VALUES
('13', 'IPHONE', NULL, '128');

INSERT INTO inventario (producto_id, cantidad_actual, cantidad_minima, ubicacion, estado)
SELECT id, 4, 1, 'RESISTENCIA', 'SELLADO'
FROM productos WHERE modelo = '13' AND marca = 'IPHONE' AND capacidad_gb = '128';

-- iPhone 14 (128) SELLADO
INSERT INTO productos (modelo, marca, color, capacidad_gb) VALUES
('14', 'IPHONE', NULL, '128');

INSERT INTO inventario (producto_id, cantidad_actual, cantidad_minima, ubicacion, estado)
SELECT id, 2, 1, 'RESISTENCIA', 'SELLADO'
FROM productos WHERE modelo = '14' AND marca = 'IPHONE' AND capacidad_gb = '128';

-- iPhone 15 (128) SELLADO
INSERT INTO productos (modelo, marca, color, capacidad_gb) VALUES
('15', 'IPHONE', NULL, '128');

INSERT INTO inventario (producto_id, cantidad_actual, cantidad_minima, ubicacion, estado)
SELECT id, 1, 1, 'RESISTENCIA', 'SELLADO'
FROM productos WHERE modelo = '15' AND marca = 'IPHONE' AND capacidad_gb = '128'
ON CONFLICT (producto_id, ubicacion, estado) DO UPDATE SET cantidad_actual = inventario.cantidad_actual + 1;

-- iPhone 16 (128) SELLADO
INSERT INTO productos (modelo, marca, color, capacidad_gb) VALUES
('16', 'IPHONE', NULL, '128');

INSERT INTO inventario (producto_id, cantidad_actual, cantidad_minima, ubicacion, estado)
SELECT id, 3, 1, 'RESISTENCIA', 'SELLADO'
FROM productos WHERE modelo = '16' AND marca = 'IPHONE' AND capacidad_gb = '128';

-- iPhone 17 (256) SELLADO
INSERT INTO productos (modelo, marca, color, capacidad_gb) VALUES
('17', 'IPHONE', NULL, '256');

INSERT INTO inventario (producto_id, cantidad_actual, cantidad_minima, ubicacion, estado)
SELECT id, 4, 1, 'RESISTENCIA', 'SELLADO'
FROM productos WHERE modelo = '17' AND marca = 'IPHONE' AND capacidad_gb = '256'
ON CONFLICT (producto_id, ubicacion, estado) DO UPDATE SET cantidad_actual = inventario.cantidad_actual + 4;

-- iPhone 17 PRO (256) SELLADO
INSERT INTO productos (modelo, marca, color, capacidad_gb) VALUES
('17 PRO', 'IPHONE', NULL, '256');

INSERT INTO inventario (producto_id, cantidad_actual, cantidad_minima, ubicacion, estado)
SELECT id, 3, 1, 'RESISTENCIA', 'SELLADO'
FROM productos WHERE modelo = '17 PRO' AND marca = 'IPHONE' AND capacidad_gb = '256'
ON CONFLICT (producto_id, ubicacion, estado) DO UPDATE SET cantidad_actual = inventario.cantidad_actual + 3;

-- iPhone 17 PRO MAX (256) SELLADO
INSERT INTO productos (modelo, marca, color, capacidad_gb) VALUES
('17 PRO MAX', 'IPHONE', NULL, '256');

INSERT INTO inventario (producto_id, cantidad_actual, cantidad_minima, ubicacion, estado)
SELECT id, 3, 1, 'RESISTENCIA', 'SELLADO'
FROM productos WHERE modelo = '17 PRO MAX' AND marca = 'IPHONE' AND capacidad_gb = '256'
ON CONFLICT (producto_id, ubicacion, estado) DO UPDATE SET cantidad_actual = inventario.cantidad_actual + 3;

-- Samsung A07 (128) SELLADO
INSERT INTO productos (modelo, marca, color, capacidad_gb) VALUES
('A07', 'SAMSUNG', NULL, '128');

INSERT INTO inventario (producto_id, cantidad_actual, cantidad_minima, ubicacion, estado)
SELECT id, 5, 1, 'RESISTENCIA', 'SELLADO'
FROM productos WHERE modelo = 'A07' AND marca = 'SAMSUNG' AND capacidad_gb = '128';

-- Samsung A17 (128) SELLADO
INSERT INTO productos (modelo, marca, color, capacidad_gb) VALUES
('A17', 'SAMSUNG', NULL, '128');

INSERT INTO inventario (producto_id, cantidad_actual, cantidad_minima, ubicacion, estado)
SELECT id, 5, 1, 'RESISTENCIA', 'SELLADO'
FROM productos WHERE modelo = 'A17' AND marca = 'SAMSUNG' AND capacidad_gb = '128';

-- Samsung A26 (128) SELLADO
INSERT INTO productos (modelo, marca, color, capacidad_gb) VALUES
('A26', 'SAMSUNG', NULL, '128');

INSERT INTO inventario (producto_id, cantidad_actual, cantidad_minima, ubicacion, estado)
SELECT id, 5, 1, 'RESISTENCIA', 'SELLADO'
FROM productos WHERE modelo = 'A26' AND marca = 'SAMSUNG' AND capacidad_gb = '128';

-- Samsung S26 ULTRA (256) SELLADO
INSERT INTO productos (modelo, marca, color, capacidad_gb) VALUES
('S26 ULTRA', 'SAMSUNG', NULL, '256');

INSERT INTO inventario (producto_id, cantidad_actual, cantidad_minima, ubicacion, estado)
SELECT id, 2, 1, 'RESISTENCIA', 'SELLADO'
FROM productos WHERE modelo = 'S26 ULTRA' AND marca = 'SAMSUNG' AND capacidad_gb = '256';

-- ============================================
-- VERIFICACIÓN
-- ============================================

-- Ver todos los productos insertados
SELECT 
    p.marca,
    p.modelo,
    p.color,
    p.capacidad_gb,
    i.cantidad_actual,
    i.estado,
    i.ubicacion
FROM productos p
LEFT JOIN inventario i ON p.id = i.producto_id
ORDER BY p.marca, p.modelo, i.estado;

-- Ver total de unidades
SELECT 
    SUM(cantidad_actual) as total_unidades,
    COUNT(DISTINCT producto_id) as total_productos
FROM inventario;
