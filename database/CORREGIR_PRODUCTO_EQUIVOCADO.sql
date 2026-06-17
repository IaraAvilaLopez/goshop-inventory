-- ============================================
-- CORREGIR: Se modificó el producto equivocado
-- ============================================

-- PASO 1: Ver el estado actual de ambos productos
SELECT 
    'ESTADO ACTUAL' as paso,
    p.marca,
    p.modelo,
    p.capacidad_gb,
    p.color,
    i.ubicacion,
    i.cantidad_actual
FROM inventario i
JOIN productos p ON i.producto_id = p.id
WHERE p.marca = 'IPHONE' 
AND (
    (p.modelo = '13 PRO MAX' AND p.capacidad_gb = '128')
    OR (p.modelo = '13 PRO' AND p.capacidad_gb = '128' AND p.color = 'BLANCO')
)
ORDER BY p.modelo, i.ubicacion;

-- PASO 2: REVERTIR el cambio en IPHONE 13 PRO MAX
-- (Se le sumó 1 por error, hay que restarlo)
UPDATE inventario
SET cantidad_actual = cantidad_actual - 1
WHERE producto_id = (
    SELECT id FROM productos 
    WHERE marca = 'IPHONE' 
    AND modelo = '13 PRO MAX' 
    AND capacidad_gb = '128'
    AND color IS NULL
)
AND ubicacion = 'CORRIENTES';

-- PASO 3: AGREGAR 1 al producto CORRECTO (IPHONE 13 PRO BLANCO)
UPDATE inventario
SET cantidad_actual = cantidad_actual + 1
WHERE producto_id = (
    SELECT id FROM productos 
    WHERE marca = 'IPHONE' 
    AND modelo = '13 PRO' 
    AND capacidad_gb = '128'
    AND color = 'BLANCO'
)
AND ubicacion = 'CORRIENTES';

-- PASO 4: Verificar el resultado
SELECT 
    'DESPUÉS DE CORRECCIÓN' as paso,
    p.marca,
    p.modelo,
    p.capacidad_gb,
    p.color,
    i.ubicacion,
    i.cantidad_actual
FROM inventario i
JOIN productos p ON i.producto_id = p.id
WHERE p.marca = 'IPHONE' 
AND (
    (p.modelo = '13 PRO MAX' AND p.capacidad_gb = '128')
    OR (p.modelo = '13 PRO' AND p.capacidad_gb = '128' AND p.color = 'BLANCO')
)
ORDER BY p.modelo, i.ubicacion;

-- CONFIRMACIÓN
DO $$
BEGIN
  RAISE NOTICE '✅ Producto corregido:';
  RAISE NOTICE '   ❌ IPHONE 13 PRO MAX 128: -1 (se había modificado por error)';
  RAISE NOTICE '   ✅ IPHONE 13 PRO BLANCO 128: +1 (producto correcto)';
END $$;
