-- ============================================
-- CONFIGURACIÓN MULTI-SUCURSAL - SCRIPT COMPLETO
-- ============================================
-- Copia y pega TODO este script en Supabase SQL Editor
-- y presiona RUN (Ctrl + Enter)

-- ============================================
-- PASO 1: Crear inventario vacío para Corrientes
-- ============================================

INSERT INTO inventario (producto_id, ubicacion, cantidad_actual, cantidad_minima)
SELECT 
    producto_id,
    'CORRIENTES' as ubicacion,
    0 as cantidad_actual,
    cantidad_minima
FROM inventario
WHERE ubicacion = 'RESISTENCIA'
ON CONFLICT (producto_id, ubicacion) DO NOTHING;

-- ============================================
-- PASO 2: Verificar resultado
-- ============================================

SELECT 
    ubicacion,
    COUNT(*) as total_productos,
    SUM(cantidad_actual) as total_unidades,
    SUM(CASE WHEN cantidad_actual < cantidad_minima THEN 1 ELSE 0 END) as productos_bajo_stock
FROM inventario
GROUP BY ubicacion
ORDER BY ubicacion;

-- ============================================
-- PASO 3: Confirmación
-- ============================================

DO $$
BEGIN
  RAISE NOTICE '✅ Base de datos configurada correctamente';
  RAISE NOTICE '📍 Resistencia: Stock completo';
  RAISE NOTICE '📍 Corrientes: Stock vacío, listo para cargar';
  RAISE NOTICE '🚀 Puedes empezar a usar ambas sucursales';
END $$;
