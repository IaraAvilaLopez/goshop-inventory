-- ============================================
-- CORREGIR STOCK DE IPHONE 11 PRO MAX
-- ============================================

-- Corregir stock a 4 unidades (valor original antes del problema)
UPDATE inventario
SET cantidad_actual = 4
WHERE producto_id = (
    SELECT id FROM productos 
    WHERE marca = 'IPHONE' 
    AND modelo = '11 PRO MAX' 
    AND capacidad_gb = '256'
)
AND ubicacion = 'RESISTENCIA';

-- Verificar corrección
SELECT 
    p.marca,
    p.modelo,
    p.capacidad_gb,
    i.ubicacion,
    i.cantidad_actual as stock_corregido
FROM inventario i
JOIN productos p ON i.producto_id = p.id
WHERE p.marca = 'IPHONE' 
AND p.modelo = '11 PRO MAX'
AND i.ubicacion = 'RESISTENCIA';
