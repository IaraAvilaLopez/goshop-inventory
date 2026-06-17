-- ============================================
-- CORREGIR STOCK ACTUAL
-- ============================================

-- PASO 1: Ver estado actual problemático
SELECT 
    'PROBLEMAS ACTUALES' as info,
    p.marca,
    p.modelo,
    p.capacidad_gb,
    p.color,
    i.ubicacion,
    i.cantidad_actual
FROM inventario i
JOIN productos p ON i.producto_id = p.id
WHERE (p.marca = 'IPHONE' AND p.modelo = '13 PRO' AND p.color = 'BLANCO')
   OR (p.marca = 'SAMSUNG' AND p.modelo = 'S24 ULTRA')
ORDER BY p.marca, i.ubicacion;

-- PASO 2: RESTAURAR iPhone 13 Pro Blanco en CORRIENTES
-- Debería tener 1 unidad (se perdió al eliminar la transferencia)
UPDATE inventario
SET cantidad_actual = 1
WHERE producto_id = (
    SELECT id FROM productos 
    WHERE marca = 'IPHONE' 
    AND modelo = '13 PRO' 
    AND capacidad_gb = '128'
    AND color = 'BLANCO'
)
AND ubicacion = 'CORRIENTES';

-- PASO 3: ELIMINAR Samsung S24 Ultra con stock negativo en CORRIENTES
-- No debería existir este registro con -3
DELETE FROM inventario
WHERE producto_id = (
    SELECT id FROM productos 
    WHERE marca = 'SAMSUNG' 
    AND modelo = 'S24 ULTRA' 
    AND capacidad_gb = '256'
)
AND ubicacion = 'CORRIENTES'
AND cantidad_actual < 0;

-- PASO 4: Verificar resultado
SELECT 
    'DESPUÉS DE CORRECCIÓN' as info,
    p.marca,
    p.modelo,
    p.capacidad_gb,
    p.color,
    i.ubicacion,
    i.cantidad_actual
FROM inventario i
JOIN productos p ON i.producto_id = p.id
WHERE (p.marca = 'IPHONE' AND p.modelo = '13 PRO' AND p.color = 'BLANCO')
   OR (p.marca = 'SAMSUNG' AND p.modelo = 'S24 ULTRA')
ORDER BY p.marca, i.ubicacion;

-- CONFIRMACIÓN
DO $$
BEGIN
  RAISE NOTICE '✅ CORRECCIONES APLICADAS:';
  RAISE NOTICE '';
  RAISE NOTICE '1. iPhone 13 Pro Blanco 128:';
  RAISE NOTICE '   ✅ Restaurado en CORRIENTES: 1 unidad';
  RAISE NOTICE '';
  RAISE NOTICE '2. Samsung S24 Ultra 256:';
  RAISE NOTICE '   ✅ Eliminado registro con -3 en CORRIENTES';
  RAISE NOTICE '   ✅ Mantiene 3 unidades en RESISTENCIA';
END $$;
