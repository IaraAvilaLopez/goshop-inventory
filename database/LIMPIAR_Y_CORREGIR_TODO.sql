-- ============================================
-- LIMPIAR Y CORREGIR TODO EL STOCK
-- ============================================

-- PASO 1: Ver TODO el stock actual de Corrientes
SELECT 
    'STOCK ACTUAL CORRIENTES' as info,
    p.id as producto_id,
    p.marca,
    p.modelo,
    p.capacidad_gb,
    p.color,
    i.cantidad_actual
FROM inventario i
JOIN productos p ON i.producto_id = p.id
WHERE i.ubicacion = 'CORRIENTES'
ORDER BY p.marca, p.modelo;

-- PASO 2: Identificar duplicados de SAMSUNG S24 ULTRA
SELECT 
    'DUPLICADOS S24 ULTRA' as info,
    p.id,
    p.marca,
    p.modelo,
    p.capacidad_gb,
    p.color,
    i.cantidad_actual
FROM inventario i
JOIN productos p ON i.producto_id = p.id
WHERE p.marca = 'SAMSUNG'
AND p.modelo = 'S24 ULTRA'
AND i.ubicacion = 'CORRIENTES'
ORDER BY p.id;

-- PASO 3: ELIMINAR duplicados de S24 ULTRA (dejar solo 1)
-- Primero, identificar cuál es el producto correcto (el primero)
WITH productos_s24 AS (
    SELECT 
        p.id,
        ROW_NUMBER() OVER (ORDER BY p.id) as rn
    FROM productos p
    WHERE p.marca = 'SAMSUNG'
    AND p.modelo = 'S24 ULTRA'
    AND p.capacidad_gb = '256'
)
DELETE FROM inventario
WHERE producto_id IN (
    SELECT id FROM productos_s24 WHERE rn > 1
)
AND ubicacion = 'CORRIENTES';

-- PASO 4: CORREGIR IPHONE 13 PRO
-- Revertir cambio en IPHONE 13 PRO MAX (producto equivocado)
UPDATE inventario
SET cantidad_actual = GREATEST(cantidad_actual - 1, 0)
WHERE producto_id = (
    SELECT id FROM productos 
    WHERE marca = 'IPHONE' 
    AND modelo = '13 PRO MAX' 
    AND capacidad_gb = '128'
    LIMIT 1
)
AND ubicacion = 'CORRIENTES';

-- PASO 5: AGREGAR al producto correcto (IPHONE 13 PRO BLANCO)
INSERT INTO inventario (producto_id, ubicacion, cantidad_actual, cantidad_minima, estado)
SELECT 
    id,
    'CORRIENTES',
    1,
    1,
    'DISPONIBLE'
FROM productos
WHERE marca = 'IPHONE' 
AND modelo = '13 PRO' 
AND capacidad_gb = '128'
AND color = 'BLANCO'
ON CONFLICT (producto_id, ubicacion) 
DO UPDATE SET cantidad_actual = inventario.cantidad_actual + 1;

-- PASO 6: ESTABLECER stock correcto de S24 ULTRA en Corrientes
-- Debería tener 3 unidades (transferidas desde Resistencia)
UPDATE inventario
SET cantidad_actual = 3
WHERE producto_id = (
    SELECT id FROM productos 
    WHERE marca = 'SAMSUNG' 
    AND modelo = 'S24 ULTRA' 
    AND capacidad_gb = '256'
    ORDER BY id
    LIMIT 1
)
AND ubicacion = 'CORRIENTES';

-- PASO 7: Ver el resultado final
SELECT 
    'STOCK FINAL CORRIENTES' as info,
    p.marca,
    p.modelo,
    p.capacidad_gb,
    p.color,
    i.cantidad_actual
FROM inventario i
JOIN productos p ON i.producto_id = p.id
WHERE i.ubicacion = 'CORRIENTES'
ORDER BY p.marca, p.modelo;

-- PASO 8: Ver stock de Resistencia para comparar
SELECT 
    'STOCK RESISTENCIA' as info,
    p.marca,
    p.modelo,
    p.capacidad_gb,
    p.color,
    i.cantidad_actual
FROM inventario i
JOIN productos p ON i.producto_id = p.id
WHERE i.ubicacion = 'RESISTENCIA'
AND i.cantidad_actual > 0
ORDER BY p.marca, p.modelo;

-- CONFIRMACIÓN
DO $$
BEGIN
  RAISE NOTICE '✅ CORRECCIONES APLICADAS:';
  RAISE NOTICE '';
  RAISE NOTICE '1. IPHONE 13 PRO MAX 128:';
  RAISE NOTICE '   - Revertido cambio incorrecto (-1)';
  RAISE NOTICE '';
  RAISE NOTICE '2. IPHONE 13 PRO BLANCO 128:';
  RAISE NOTICE '   - Restaurado correctamente (+1 en Corrientes)';
  RAISE NOTICE '';
  RAISE NOTICE '3. SAMSUNG S24 ULTRA 256:';
  RAISE NOTICE '   - Eliminados duplicados';
  RAISE NOTICE '   - Stock correcto: 3 unidades en Corrientes';
END $$;
