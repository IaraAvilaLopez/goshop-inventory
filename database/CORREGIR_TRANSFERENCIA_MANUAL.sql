-- ============================================
-- CORREGIR TRANSFERENCIA MANUAL
-- ============================================
-- Este script corrige la transferencia de SAMSUNG S24 ULTRA que ya hiciste

-- Ver la transferencia actual
SELECT * FROM transacciones 
WHERE tipo_transaccion = 'TRANSFERENCIA' 
AND fecha_transaccion::date = CURRENT_DATE
ORDER BY created_at DESC;

-- Corregir el stock manualmente
-- SAMSUNG S24 ULTRA 256: Descontar 3 de Resistencia, Agregar 3 a Corrientes

-- 1. Descontar de Resistencia
UPDATE inventario
SET cantidad_actual = cantidad_actual - 3
WHERE producto_id = (
  SELECT id FROM productos 
  WHERE marca = 'SAMSUNG' 
  AND modelo = 'S24 ULTRA' 
  AND capacidad_gb = '256'
)
AND ubicacion = 'RESISTENCIA';

-- 2. Agregar a Corrientes (o crear si no existe)
INSERT INTO inventario (producto_id, ubicacion, cantidad_actual, cantidad_minima, estado)
SELECT 
  id,
  'CORRIENTES',
  3,
  1,
  'DISPONIBLE'
FROM productos
WHERE marca = 'SAMSUNG' 
AND modelo = 'S24 ULTRA' 
AND capacidad_gb = '256'
ON CONFLICT (producto_id, ubicacion) 
DO UPDATE SET cantidad_actual = inventario.cantidad_actual + 3;

-- Verificar resultado
SELECT 
  p.marca,
  p.modelo,
  p.capacidad_gb,
  i.ubicacion,
  i.cantidad_actual
FROM inventario i
JOIN productos p ON i.producto_id = p.id
WHERE p.marca = 'SAMSUNG' 
AND p.modelo = 'S24 ULTRA'
ORDER BY i.ubicacion;

-- Confirmación
DO $$
BEGIN
  RAISE NOTICE '✅ Transferencia corregida manualmente';
  RAISE NOTICE '📍 SAMSUNG S24 ULTRA 256:';
  RAISE NOTICE '   Resistencia: -3 unidades';
  RAISE NOTICE '   Corrientes: +3 unidades';
END $$;
