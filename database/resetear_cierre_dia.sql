-- RESETEAR CIERRE DEL DÍA PARA REPROCESAR

-- 1. Eliminar el cierre del día de hoy
DELETE FROM cierres_dia 
WHERE fecha_cierre = '2026-06-03';

-- 2. Marcar todas las ventas como NO procesadas
UPDATE ventas_pendientes 
SET procesada = false 
WHERE fecha = '2026-06-03';

-- 3. Eliminar transacciones de tipo CIERRE_DIA de hoy
DELETE FROM transacciones 
WHERE tipo_transaccion = 'CIERRE_DIA' 
AND DATE(fecha) = '2026-06-03';

-- 4. Verificar
SELECT 'Cierres eliminados:' as info, COUNT(*) as cantidad 
FROM cierres_dia 
WHERE fecha_cierre = '2026-06-03'

UNION ALL

SELECT 'Ventas pendientes:', COUNT(*) 
FROM ventas_pendientes 
WHERE fecha = '2026-06-03' AND procesada = false;
