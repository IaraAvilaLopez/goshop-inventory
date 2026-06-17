-- ============================================
-- RESTAURAR STOCK PERDIDO POR TRANSFERENCIA ELIMINADA
-- ============================================

-- PASO 1: Ver el stock actual de ambas sucursales
SELECT 
    'STOCK ACTUAL' as info,
    p.marca,
    p.modelo,
    p.capacidad_gb,
    i.ubicacion,
    i.cantidad_actual
FROM inventario i
JOIN productos p ON i.producto_id = p.id
ORDER BY p.marca, p.modelo, i.ubicacion;

-- PASO 2: Identificar qué producto perdió stock
-- (Necesitas decirme cuál fue para restaurarlo)

-- EJEMPLO: Si fue SAMSUNG S24 ULTRA 256 que perdió 3 unidades en Corrientes
-- Descomenta y ajusta según tu caso:

/*
UPDATE inventario
SET cantidad_actual = cantidad_actual + 3  -- Cantidad que se perdió
WHERE producto_id = (
    SELECT id FROM productos 
    WHERE marca = 'SAMSUNG' 
    AND modelo = 'S24 ULTRA' 
    AND capacidad_gb = '256'
)
AND ubicacion = 'CORRIENTES';  -- Sucursal que perdió el stock
*/

-- PASO 3: Verificar el resultado
SELECT 
    'STOCK DESPUÉS DE RESTAURAR' as info,
    p.marca,
    p.modelo,
    p.capacidad_gb,
    i.ubicacion,
    i.cantidad_actual
FROM inventario i
JOIN productos p ON i.producto_id = p.id
ORDER BY p.marca, p.modelo, i.ubicacion;

-- ============================================
-- INSTRUCCIONES
-- ============================================
-- 1. Ejecuta PASO 1 para ver el stock actual
-- 2. Identifica qué producto perdió stock
-- 3. Descomenta y ajusta el UPDATE del PASO 2
-- 4. Ejecuta el UPDATE
-- 5. Ejecuta PASO 3 para verificar
