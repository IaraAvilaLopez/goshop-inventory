-- LIMPIAR TRANSACCIONES DUPLICADAS Y RESTAURAR STOCK
-- Ejecuta este script para eliminar las transacciones de prueba

-- Ver las transacciones actuales antes de eliminar
SELECT id, tipo_transaccion, cantidad, fecha_transaccion, observaciones 
FROM transacciones 
WHERE producto_id IN (
  SELECT producto_id FROM productos WHERE modelo LIKE '%S24 ULTRA%'
)
ORDER BY fecha_transaccion DESC;

-- IMPORTANTE: Antes de eliminar, anota el stock actual del Samsung S24 ULTRA 256
-- Luego ejecuta esto para eliminar las transacciones duplicadas:

-- Eliminar las transacciones de VENTA manuales (las que hiciste desde Transacciones)
DELETE FROM transacciones 
WHERE tipo_transaccion = 'VENTA' 
AND observaciones IS NULL OR observaciones = '-';

-- Opcional: Si quieres eliminar TODAS las transacciones de prueba de CIERRE_DIA también:
-- DELETE FROM transacciones WHERE tipo_transaccion = 'CIERRE_DIA';

-- Después de eliminar, ajusta manualmente el stock si es necesario:
-- UPDATE inventario 
-- SET cantidad_actual = 3  -- El valor original que tenías
-- WHERE producto_id IN (SELECT id FROM productos WHERE modelo LIKE '%S24 ULTRA%')
-- AND ubicacion = 'RESISTENCIA';
