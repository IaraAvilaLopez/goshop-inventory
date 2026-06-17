-- ============================================
-- ASEGURAR QUE APAREZCAN TODOS LOS PRODUCTOS EN TRANSFERENCIAS
-- ============================================

-- PASO 1: Ver cuántos productos hay en cada sucursal
SELECT 
    ubicacion,
    COUNT(*) as total_productos,
    COUNT(CASE WHEN cantidad_actual > 0 THEN 1 END) as con_stock
FROM inventario
GROUP BY ubicacion
ORDER BY ubicacion;

-- PASO 2: Ver productos de Resistencia que deberían aparecer en Corrientes
SELECT 
    'RESISTENCIA (para transferir a Corrientes)' as origen,
    p.marca,
    p.modelo,
    p.capacidad_gb,
    p.color,
    i.cantidad_actual
FROM inventario i
JOIN productos p ON i.producto_id = p.id
WHERE i.ubicacion = 'RESISTENCIA'
AND i.cantidad_actual > 0
AND i.estado = 'DISPONIBLE'
ORDER BY p.marca, p.modelo;

-- PASO 3: Ver productos de Corrientes que deberían aparecer en Resistencia
SELECT 
    'CORRIENTES (para transferir a Resistencia)' as origen,
    p.marca,
    p.modelo,
    p.capacidad_gb,
    p.color,
    i.cantidad_actual
FROM inventario i
JOIN productos p ON i.producto_id = p.id
WHERE i.ubicacion = 'CORRIENTES'
AND i.cantidad_actual > 0
AND i.estado = 'DISPONIBLE'
ORDER BY p.marca, p.modelo;

-- PASO 4: Verificar que vista_stock_actual tenga todos los productos
-- Comparar inventario vs vista
WITH inventario_count AS (
    SELECT ubicacion, COUNT(*) as total
    FROM inventario
    WHERE cantidad_actual > 0 AND estado = 'DISPONIBLE'
    GROUP BY ubicacion
),
vista_count AS (
    SELECT ubicacion, COUNT(*) as total
    FROM vista_stock_actual
    WHERE cantidad_actual > 0 AND estado = 'DISPONIBLE'
    GROUP BY ubicacion
)
SELECT 
    COALESCE(i.ubicacion, v.ubicacion) as ubicacion,
    COALESCE(i.total, 0) as en_inventario,
    COALESCE(v.total, 0) as en_vista,
    CASE 
        WHEN COALESCE(i.total, 0) = COALESCE(v.total, 0) THEN '✅ OK'
        ELSE '❌ FALTA EN VISTA'
    END as estado
FROM inventario_count i
FULL OUTER JOIN vista_count v ON i.ubicacion = v.ubicacion;

-- PASO 5: Encontrar productos que están en inventario pero NO en vista
SELECT 
    'FALTA EN VISTA' as problema,
    i.ubicacion,
    p.marca,
    p.modelo,
    p.capacidad_gb,
    i.cantidad_actual
FROM inventario i
JOIN productos p ON i.producto_id = p.id
WHERE i.cantidad_actual > 0
AND i.estado = 'DISPONIBLE'
AND NOT EXISTS (
    SELECT 1 FROM vista_stock_actual v
    WHERE v.producto_id = i.producto_id
    AND v.ubicacion = i.ubicacion
)
ORDER BY i.ubicacion, p.marca, p.modelo;

-- CONFIRMACIÓN
DO $$
DECLARE
    resistencia_inv INTEGER;
    resistencia_vista INTEGER;
    corrientes_inv INTEGER;
    corrientes_vista INTEGER;
BEGIN
    -- Contar en inventario
    SELECT COUNT(*) INTO resistencia_inv
    FROM inventario
    WHERE ubicacion = 'RESISTENCIA' AND cantidad_actual > 0 AND estado = 'DISPONIBLE';
    
    SELECT COUNT(*) INTO corrientes_inv
    FROM inventario
    WHERE ubicacion = 'CORRIENTES' AND cantidad_actual > 0 AND estado = 'DISPONIBLE';
    
    -- Contar en vista
    SELECT COUNT(*) INTO resistencia_vista
    FROM vista_stock_actual
    WHERE ubicacion = 'RESISTENCIA' AND cantidad_actual > 0 AND estado = 'DISPONIBLE';
    
    SELECT COUNT(*) INTO corrientes_vista
    FROM vista_stock_actual
    WHERE ubicacion = 'CORRIENTES' AND cantidad_actual > 0 AND estado = 'DISPONIBLE';
    
    RAISE NOTICE '📊 RESUMEN:';
    RAISE NOTICE '📍 RESISTENCIA:';
    RAISE NOTICE '   Inventario: % productos', resistencia_inv;
    RAISE NOTICE '   Vista: % productos', resistencia_vista;
    IF resistencia_inv = resistencia_vista THEN
        RAISE NOTICE '   ✅ OK - Todos los productos aparecen';
    ELSE
        RAISE NOTICE '   ❌ PROBLEMA - Faltan % productos en vista', (resistencia_inv - resistencia_vista);
    END IF;
    
    RAISE NOTICE '📍 CORRIENTES:';
    RAISE NOTICE '   Inventario: % productos', corrientes_inv;
    RAISE NOTICE '   Vista: % productos', corrientes_vista;
    IF corrientes_inv = corrientes_vista THEN
        RAISE NOTICE '   ✅ OK - Todos los productos aparecen';
    ELSE
        RAISE NOTICE '   ❌ PROBLEMA - Faltan % productos en vista', (corrientes_inv - corrientes_vista);
    END IF;
END $$;
