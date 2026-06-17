-- ============================================
-- RECONSTRUIR INVENTARIO COMPLETO
-- ============================================
-- Este script asegura que TODOS los productos aparezcan

-- PASO 1: Ver estado actual
SELECT 
    'ESTADO ACTUAL' as info,
    (SELECT COUNT(*) FROM productos) as total_productos_tabla,
    (SELECT COUNT(DISTINCT producto_id) FROM inventario WHERE cantidad_actual > 0) as productos_en_inventario,
    (SELECT COUNT(*) FROM inventario i 
     INNER JOIN productos p ON i.producto_id = p.id 
     WHERE i.cantidad_actual > 0) as inventario_valido;

-- PASO 2: Crear vista temporal de productos que deberían estar
CREATE TEMP TABLE productos_esperados AS
SELECT 
    p.id as producto_id,
    p.marca,
    p.modelo,
    p.capacidad_gb,
    p.color,
    COALESCE(
        (SELECT ubicacion FROM inventario WHERE producto_id = p.id AND cantidad_actual > 0 LIMIT 1),
        'RESISTENCIA'
    ) as ubicacion_esperada,
    COALESCE(
        (SELECT SUM(cantidad_actual) FROM inventario WHERE producto_id = p.id),
        0
    ) as cantidad_total
FROM productos p;

-- PASO 3: Ver productos que NO están en inventario
SELECT 
    'PRODUCTOS FALTANTES EN INVENTARIO' as problema,
    pe.marca,
    pe.modelo,
    pe.capacidad_gb,
    pe.color,
    pe.cantidad_total
FROM productos_esperados pe
WHERE pe.cantidad_total = 0
ORDER BY pe.marca, pe.modelo;

-- PASO 4: Ver distribución actual por sucursal
SELECT 
    'DISTRIBUCIÓN ACTUAL' as info,
    i.ubicacion,
    p.marca,
    p.modelo,
    p.capacidad_gb,
    i.cantidad_actual
FROM inventario i
INNER JOIN productos p ON i.producto_id = p.id
WHERE i.cantidad_actual > 0
ORDER BY i.ubicacion, p.marca, p.modelo;

-- PASO 5: OPCIÓN A - Solo mostrar qué falta (NO ejecuta cambios)
SELECT 
    'LO QUE FALTA AGREGAR' as accion,
    p.marca,
    p.modelo,
    p.capacidad_gb,
    p.color,
    'Necesita agregarse al inventario' as estado
FROM productos p
WHERE NOT EXISTS (
    SELECT 1 FROM inventario i 
    WHERE i.producto_id = p.id 
    AND i.cantidad_actual > 0
)
ORDER BY p.marca, p.modelo;

-- CONFIRMACIÓN
DO $$
DECLARE
    v_total_productos INTEGER;
    v_productos_inventario INTEGER;
    v_faltantes INTEGER;
BEGIN
    SELECT COUNT(*) INTO v_total_productos FROM productos;
    SELECT COUNT(DISTINCT i.producto_id) INTO v_productos_inventario 
    FROM inventario i 
    INNER JOIN productos p ON i.producto_id = p.id
    WHERE i.cantidad_actual > 0;
    
    v_faltantes := v_total_productos - v_productos_inventario;
    
    RAISE NOTICE '';
    RAISE NOTICE '═══════════════════════════════════════';
    RAISE NOTICE '📊 DIAGNÓSTICO COMPLETO';
    RAISE NOTICE '═══════════════════════════════════════';
    RAISE NOTICE 'Total productos en BD: %', v_total_productos;
    RAISE NOTICE 'Productos en inventario: %', v_productos_inventario;
    RAISE NOTICE 'Productos FALTANTES: %', v_faltantes;
    RAISE NOTICE '';
    
    IF v_faltantes > 0 THEN
        RAISE NOTICE '⚠️ HAY % PRODUCTOS QUE NO APARECEN EN INVENTARIO', v_faltantes;
        RAISE NOTICE '💡 Estos productos fueron creados pero nunca se agregó stock';
        RAISE NOTICE '💡 Necesitas hacer una COMPRA de estos productos para que aparezcan';
    ELSE
        RAISE NOTICE '✅ TODOS LOS PRODUCTOS ESTÁN EN INVENTARIO';
    END IF;
    RAISE NOTICE '═══════════════════════════════════════';
END $$;
