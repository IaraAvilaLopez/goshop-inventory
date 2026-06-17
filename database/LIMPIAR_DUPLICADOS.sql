-- ============================================
-- LIMPIAR PRODUCTOS DUPLICADOS
-- ============================================
-- Este script elimina productos duplicados y mantiene solo uno

-- Ver productos duplicados
SELECT 
    marca, 
    modelo, 
    capacidad_gb, 
    color,
    COUNT(*) as cantidad
FROM productos
GROUP BY marca, modelo, capacidad_gb, color
HAVING COUNT(*) > 1
ORDER BY marca, modelo;

-- Eliminar duplicados (mantiene el más antiguo)
DELETE FROM productos a USING productos b
WHERE a.id > b.id 
AND a.marca = b.marca 
AND a.modelo = b.modelo 
AND COALESCE(a.capacidad_gb, '') = COALESCE(b.capacidad_gb, '')
AND COALESCE(a.color, '') = COALESCE(b.color, '');

-- Verificar que no haya duplicados
SELECT 
    marca, 
    modelo, 
    capacidad_gb, 
    color,
    COUNT(*) as cantidad
FROM productos
GROUP BY marca, modelo, capacidad_gb, color
HAVING COUNT(*) > 1;

-- Confirmación
DO $$
BEGIN
  RAISE NOTICE '✅ Productos duplicados eliminados';
  RAISE NOTICE '📦 Ahora cada producto es único';
END $$;
