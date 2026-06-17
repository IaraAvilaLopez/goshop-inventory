-- ============================================
-- RESETEAR DÍA COMPLETO (PARA PRUEBAS)
-- ============================================
-- Este script reinicia el cierre Y restaura el stock
-- SOLO USAR PARA PRUEBAS, NO EN PRODUCCIÓN

-- PASO 1: Obtener las ventas que se procesaron en el cierre
-- y sumar el stock de vuelta

-- Primero, restaurar el stock de las ventas procesadas
DO $$
DECLARE
    venta RECORD;
BEGIN
    -- Por cada venta procesada del día, sumar el stock de vuelta
    FOR venta IN 
        SELECT vp.producto_id, vp.cantidad, 'RESISTENCIA' as ubicacion
        FROM ventas_pendientes vp
        WHERE vp.fecha = '2026-06-03' 
        AND vp.procesada = true
    LOOP
        -- Sumar el stock de vuelta
        UPDATE inventario
        SET cantidad_actual = cantidad_actual + venta.cantidad,
            updated_at = NOW()
        WHERE producto_id = venta.producto_id
        AND ubicacion = venta.ubicacion
        AND estado = 'DISPONIBLE';
        
        RAISE NOTICE 'Stock restaurado: producto %, cantidad %', venta.producto_id, venta.cantidad;
    END LOOP;
END $$;

-- PASO 2: Eliminar el cierre del día
DELETE FROM cierres_dia 
WHERE fecha_cierre = '2026-06-03';

-- PASO 3: Marcar ventas como NO procesadas
UPDATE ventas_pendientes 
SET procesada = false 
WHERE fecha = '2026-06-03';

-- PASO 4: Eliminar transacciones de tipo CIERRE_DIA
DELETE FROM transacciones 
WHERE tipo_transaccion = 'CIERRE_DIA' 
AND fecha_transaccion::date = '2026-06-03';

-- PASO 5: Verificar
SELECT 
    'Stock actual del Samsung S24 ULTRA' as info,
    i.cantidad_actual,
    i.ubicacion
FROM inventario i
JOIN productos p ON i.producto_id = p.id
WHERE p.modelo LIKE '%S24 ULTRA%'
AND i.estado = 'DISPONIBLE';

SELECT 
    'Ventas pendientes no procesadas' as info,
    COUNT(*) as cantidad,
    SUM(cantidad) as total_unidades
FROM ventas_pendientes
WHERE fecha = '2026-06-03' 
AND procesada = false;

-- ✅ LISTO! Ahora puedes volver a procesar el cierre del día
