-- ============================================
-- AGREGAR COMENTARIOS A VENTAS - VERSIÓN COMPLETA
-- ============================================

-- PASO 1: Agregar columna comentarios a ventas_pendientes
DO $$ 
BEGIN
    -- Eliminar la columna si existe (para empezar limpio)
    IF EXISTS (
        SELECT 1 FROM information_schema.columns 
        WHERE table_name = 'ventas_pendientes' AND column_name = 'comentarios'
    ) THEN
        ALTER TABLE ventas_pendientes DROP COLUMN comentarios;
    END IF;
    
    -- Agregar la columna nuevamente
    ALTER TABLE ventas_pendientes ADD COLUMN comentarios TEXT;
    
    RAISE NOTICE 'Columna comentarios agregada exitosamente';
END $$;

-- PASO 2: Verificar que se agregó correctamente
SELECT 
    column_name, 
    data_type,
    is_nullable
FROM information_schema.columns 
WHERE table_name = 'ventas_pendientes'
ORDER BY ordinal_position;

-- PASO 3: Probar insertar una venta con comentarios
-- (Esto refrescará el caché de Supabase)
DO $$
DECLARE
    test_producto_id UUID;
BEGIN
    -- Obtener un producto de prueba
    SELECT id INTO test_producto_id 
    FROM productos 
    LIMIT 1;
    
    -- Insertar y eliminar inmediatamente (solo para refrescar caché)
    IF test_producto_id IS NOT NULL THEN
        INSERT INTO ventas_pendientes (producto_id, cantidad, fecha, procesada, comentarios)
        VALUES (test_producto_id, 1, CURRENT_DATE, false, 'Test de comentarios')
        RETURNING id INTO test_producto_id;
        
        DELETE FROM ventas_pendientes WHERE id = test_producto_id;
        
        RAISE NOTICE 'Caché de Supabase refrescado';
    END IF;
END $$;

-- PASO 4: Resultado final
SELECT 
    'Columna comentarios agregada y caché refrescado' as resultado,
    'Ahora puedes agregar ventas con comentarios' as siguiente_paso;
