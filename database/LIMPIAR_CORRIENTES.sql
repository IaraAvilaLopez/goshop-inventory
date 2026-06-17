-- ============================================
-- LIMPIAR INVENTARIO DE CORRIENTES
-- ============================================
-- Este script elimina TODOS los productos del inventario de Corrientes
-- para que la sucursal empiece completamente vacía

-- Eliminar todos los productos de Corrientes
DELETE FROM inventario 
WHERE ubicacion = 'CORRIENTES';

-- Verificar resultado
SELECT 
    ubicacion,
    COUNT(*) as total_productos,
    SUM(cantidad_actual) as total_unidades
FROM inventario
GROUP BY ubicacion
ORDER BY ubicacion;

-- Confirmación
DO $$
BEGIN
  RAISE NOTICE '✅ Inventario de Corrientes eliminado completamente';
  RAISE NOTICE '📍 Resistencia: Stock completo';
  RAISE NOTICE '📍 Corrientes: Vacío (sin productos)';
  RAISE NOTICE '🚀 Los chicos de Corrientes pueden cargar manualmente';
END $$;
