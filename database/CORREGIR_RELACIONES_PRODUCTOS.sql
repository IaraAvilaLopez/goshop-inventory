-- ============================================
-- CORREGIR RELACIONES ENTRE INVENTARIO Y PRODUCTOS
-- ============================================

-- PASO 1: Ver productos huérfanos (inventario sin producto válido)
SELECT 
    'INVENTARIO SIN PRODUCTO VÁLIDO' as problema,
    i.id as inventario_id,
    i.producto_id,
    i.ubicacion,
    i.cantidad_actual,
    p.id as producto_existe
FROM inventario i
LEFT JOIN productos p ON i.producto_id = p.id
WHERE p.id IS NULL;

-- PASO 2: Ver todos los productos que SÍ existen
SELECT 
    'PRODUCTOS EXISTENTES' as info,
    id,
    marca,
    modelo,
    capacidad_gb,
    color
FROM productos
ORDER BY marca, modelo;

-- PASO 3: Ver inventario con productos válidos
SELECT 
    'INVENTARIO CON PRODUCTO VÁLIDO' as info,
    i.ubicacion,
    p.marca,
    p.modelo,
    p.capacidad_gb,
    p.color,
    i.cantidad_actual
FROM inventario i
INNER JOIN productos p ON i.producto_id = p.id
WHERE i.cantidad_actual > 0
ORDER BY i.ubicacion, p.marca, p.modelo;

-- PASO 4: Contar discrepancias
SELECT 
    'RESUMEN' as info,
    (SELECT COUNT(*) FROM productos) as total_productos,
    (SELECT COUNT(*) FROM inventario WHERE cantidad_actual > 0) as total_inventario,
    (SELECT COUNT(*) FROM inventario i 
     INNER JOIN productos p ON i.producto_id = p.id 
     WHERE i.cantidad_actual > 0) as inventario_valido,
    (SELECT COUNT(*) FROM inventario i 
     LEFT JOIN productos p ON i.producto_id = p.id 
     WHERE p.id IS NULL AND i.cantidad_actual > 0) as inventario_huerfano;

-- PASO 5: LIMPIAR inventario huérfano (registros sin producto válido)
DELETE FROM inventario
WHERE id IN (
    SELECT i.id
    FROM inventario i
    LEFT JOIN productos p ON i.producto_id = p.id
    WHERE p.id IS NULL
);

-- PASO 6: Verificar resultado final
SELECT 
    'DESPUÉS DE LIMPIEZA' as info,
    i.ubicacion,
    COUNT(*) as total_productos,
    SUM(i.cantidad_actual) as total_unidades
FROM inventario i
INNER JOIN productos p ON i.producto_id = p.id
WHERE i.cantidad_actual > 0
GROUP BY i.ubicacion;

-- CONFIRMACIÓN
DO $$
DECLARE
    v_huerfanos INTEGER;
BEGIN
    SELECT COUNT(*) INTO v_huerfanos
    FROM inventario i
    LEFT JOIN productos p ON i.producto_id = p.id
    WHERE p.id IS NULL;
    
    IF v_huerfanos > 0 THEN
        RAISE NOTICE '⚠️ AÚN HAY % REGISTROS HUÉRFANOS', v_huerfanos;
    ELSE
        RAISE NOTICE '✅ TODAS LAS RELACIONES ESTÁN CORRECTAS';
        RAISE NOTICE '✅ Todos los productos deberían aparecer ahora';
    END IF;
END $$;
