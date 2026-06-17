-- ============================================
-- SOLUCIÓN FINAL COMENTARIOS - TODO EN UNO
-- ============================================
-- Este script hace TODO lo necesario para que los comentarios funcionen

-- PASO 1: Agregar columna comentarios (si no existe)
DO $$ 
BEGIN
    IF NOT EXISTS (
        SELECT 1 FROM information_schema.columns 
        WHERE table_name = 'ventas_pendientes' AND column_name = 'comentarios'
    ) THEN
        ALTER TABLE ventas_pendientes ADD COLUMN comentarios TEXT;
        RAISE NOTICE '✅ Columna comentarios agregada';
    ELSE
        RAISE NOTICE '✅ Columna comentarios ya existe';
    END IF;
END $$;

-- PASO 2: Resetear el día completo (restaurar stock y cierre)
DO $$
DECLARE
    venta RECORD;
BEGIN
    -- Restaurar stock de ventas procesadas
    FOR venta IN 
        SELECT vp.producto_id, vp.cantidad, 'RESISTENCIA' as ubicacion
        FROM ventas_pendientes vp
        WHERE vp.fecha = '2026-06-03' 
        AND vp.procesada = true
    LOOP
        UPDATE inventario
        SET cantidad_actual = cantidad_actual + venta.cantidad,
            updated_at = NOW()
        WHERE producto_id = venta.producto_id
        AND ubicacion = venta.ubicacion
        AND estado = 'DISPONIBLE';
        
        RAISE NOTICE '✅ Stock restaurado: producto %, cantidad %', venta.producto_id, venta.cantidad;
    END LOOP;
END $$;

-- PASO 3: Eliminar el cierre del día
DELETE FROM cierres_dia WHERE fecha_cierre = '2026-06-03';

-- PASO 4: Marcar ventas como NO procesadas
UPDATE ventas_pendientes SET procesada = false WHERE fecha = '2026-06-03';

-- PASO 5: Eliminar transacciones CIERRE_DIA
DELETE FROM transacciones 
WHERE tipo_transaccion = 'CIERRE_DIA' 
AND fecha_transaccion::date = '2026-06-03';

-- PASO 6: Eliminar todas las ventas pendientes del día (para empezar limpio)
DELETE FROM ventas_pendientes WHERE fecha = '2026-06-03';

-- PASO 7: Verificar que todo está listo
SELECT 
    '✅ PASO 1: Columna comentarios' as verificacion,
    CASE 
        WHEN EXISTS (
            SELECT 1 FROM information_schema.columns 
            WHERE table_name = 'ventas_pendientes' AND column_name = 'comentarios'
        ) THEN 'OK - Existe'
        ELSE 'ERROR - No existe'
    END as estado;

SELECT 
    '✅ PASO 2: Stock restaurado' as verificacion,
    p.marca,
    p.modelo,
    i.cantidad_actual
FROM inventario i
JOIN productos p ON i.producto_id = p.id
WHERE p.modelo LIKE '%S24 ULTRA%'
AND i.estado = 'DISPONIBLE';

SELECT 
    '✅ PASO 3: Día reseteado' as verificacion,
    CASE 
        WHEN NOT EXISTS (SELECT 1 FROM cierres_dia WHERE fecha_cierre = '2026-06-03')
        THEN 'OK - No hay cierre'
        ELSE 'ERROR - Todavía hay cierre'
    END as estado;

SELECT 
    '✅ PASO 4: Ventas eliminadas' as verificacion,
    COUNT(*) as cantidad_ventas
FROM ventas_pendientes
WHERE fecha = '2026-06-03';

-- ============================================
-- RESULTADO FINAL
-- ============================================
SELECT 
    '🎉 SISTEMA LISTO PARA USAR' as mensaje,
    'Ahora puedes:' as instrucciones,
    '1. Recargar la app (F5)' as paso_1,
    '2. Ir a Ventas y agregar ventas CON comentarios' as paso_2,
    '3. Procesar el cierre' as paso_3,
    '4. Ver en Historial y hacer click en "Ver detalles"' as paso_4;
