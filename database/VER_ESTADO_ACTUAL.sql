-- ============================================
-- VER ESTADO ACTUAL DEL STOCK (SOLO CONSULTA)
-- ============================================
-- Este script NO modifica nada, solo muestra información

-- 1. Ver TODO el stock de CORRIENTES
SELECT 
    '=== STOCK CORRIENTES ===' as seccion,
    p.marca,
    p.modelo,
    p.capacidad_gb,
    p.color,
    i.cantidad_actual
FROM inventario i
JOIN productos p ON i.producto_id = p.id
WHERE i.ubicacion = 'CORRIENTES'
ORDER BY p.marca, p.modelo;

-- 2. Ver TODO el stock de RESISTENCIA
SELECT 
    '=== STOCK RESISTENCIA ===' as seccion,
    p.marca,
    p.modelo,
    p.capacidad_gb,
    p.color,
    i.cantidad_actual
FROM inventario i
JOIN productos p ON i.producto_id = p.id
WHERE i.ubicacion = 'RESISTENCIA'
ORDER BY p.marca, p.modelo;

-- 3. Buscar específicamente IPHONE 13 PRO en ambas sucursales
SELECT 
    '=== IPHONE 13 PRO (todos) ===' as seccion,
    p.marca,
    p.modelo,
    p.capacidad_gb,
    p.color,
    i.ubicacion,
    i.cantidad_actual
FROM inventario i
JOIN productos p ON i.producto_id = p.id
WHERE p.marca = 'IPHONE' 
AND p.modelo LIKE '%13 PRO%'
ORDER BY p.modelo, i.ubicacion;

-- 4. Buscar SAMSUNG S24 ULTRA en ambas sucursales
SELECT 
    '=== SAMSUNG S24 ULTRA ===' as seccion,
    p.id as producto_id,
    p.marca,
    p.modelo,
    p.capacidad_gb,
    p.color,
    i.ubicacion,
    i.cantidad_actual
FROM inventario i
JOIN productos p ON i.producto_id = p.id
WHERE p.marca = 'SAMSUNG' 
AND p.modelo = 'S24 ULTRA'
ORDER BY p.id, i.ubicacion;

-- 5. Ver las últimas transacciones de TRANSFERENCIA
SELECT 
    '=== ÚLTIMAS TRANSFERENCIAS ===' as seccion,
    t.id,
    t.fecha_transaccion,
    p.marca,
    p.modelo,
    p.capacidad_gb,
    p.color,
    t.cantidad,
    t.ubicacion as destino,
    t.observaciones
FROM transacciones t
JOIN productos p ON t.producto_id = p.id
WHERE t.tipo_transaccion = 'TRANSFERENCIA'
ORDER BY t.fecha_transaccion DESC
LIMIT 10;

-- 6. Contar productos duplicados
SELECT 
    '=== PRODUCTOS DUPLICADOS ===' as seccion,
    p.marca,
    p.modelo,
    p.capacidad_gb,
    p.color,
    COUNT(*) as cantidad_registros
FROM productos p
GROUP BY p.marca, p.modelo, p.capacidad_gb, p.color
HAVING COUNT(*) > 1
ORDER BY p.marca, p.modelo;

-- RESUMEN
DO $$
BEGIN
  RAISE NOTICE '📊 ESTE SCRIPT SOLO MUESTRA INFORMACIÓN';
  RAISE NOTICE '❌ NO MODIFICA NADA';
  RAISE NOTICE '';
  RAISE NOTICE 'Por favor revisa los resultados y dime:';
  RAISE NOTICE '1. ¿Qué productos tiene Corrientes actualmente?';
  RAISE NOTICE '2. ¿Qué productos tiene Resistencia actualmente?';
  RAISE NOTICE '3. ¿Cuál es el estado correcto que debería tener?';
END $$;
