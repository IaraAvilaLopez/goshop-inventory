-- CORREGIR FECHAS DE VENTAS PENDIENTES
-- Las ventas que muestran 2/6/2026 deberían ser 3/6/2026

-- Ver las fechas actuales
SELECT id, producto_id, cantidad, fecha, procesada, created_at
FROM ventas_pendientes
WHERE procesada = false
ORDER BY created_at DESC;

-- Corregir ventas del 2/6 al 3/6
UPDATE ventas_pendientes
SET fecha = '2026-06-03'
WHERE fecha = '2026-06-02'
AND procesada = false;

-- Verificar que se corrigieron
SELECT 
    fecha,
    COUNT(*) as cantidad_ventas,
    SUM(cantidad) as total_unidades
FROM ventas_pendientes
WHERE procesada = false
GROUP BY fecha
ORDER BY fecha DESC;
