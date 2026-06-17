-- LIMPIAR VENTAS PENDIENTES Y PERMITIR REPROCESAR CIERRE

-- 1. Eliminar ventas pendientes de productos que ya no existen
DELETE FROM ventas_pendientes 
WHERE producto_id NOT IN (SELECT id FROM productos);

-- 2. Corregir la fecha de las ventas pendientes (31/5 -> 01/6)
UPDATE ventas_pendientes 
SET fecha = '2026-06-01' 
WHERE fecha = '2026-05-31';

-- 3. Eliminar el registro de cierre del día de hoy para poder reprocesar
DELETE FROM cierres_dia 
WHERE fecha_cierre = '2026-06-01';

-- 4. Marcar todas las ventas pendientes de hoy como NO procesadas
UPDATE ventas_pendientes 
SET procesada = false 
WHERE fecha = '2026-06-01';

-- Verificar ventas pendientes
SELECT vp.*, p.marca, p.modelo 
FROM ventas_pendientes vp
LEFT JOIN productos p ON vp.producto_id = p.id
WHERE vp.fecha = '2026-06-01'
ORDER BY vp.created_at;
