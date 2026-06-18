-- Eliminar TODOS los triggers relacionados con DELETE en productos e inventario
-- para que la eliminación funcione de forma nativa con CASCADE

-- 1. Listar TODOS los triggers en productos e inventario
SELECT 
    trigger_name,
    event_object_table,
    action_timing,
    event_manipulation,
    action_statement
FROM information_schema.triggers
WHERE event_object_table IN ('productos', 'inventario')
  AND event_manipulation = 'DELETE'
ORDER BY event_object_table, trigger_name;

-- 2. Eliminar TODOS los triggers de DELETE en productos
DO $$ 
DECLARE
    r RECORD;
BEGIN
    FOR r IN 
        SELECT trigger_name
        FROM information_schema.triggers
        WHERE event_object_table = 'productos'
          AND event_manipulation = 'DELETE'
    LOOP
        EXECUTE 'DROP TRIGGER IF EXISTS ' || r.trigger_name || ' ON productos CASCADE';
        RAISE NOTICE 'Eliminado trigger: % en productos', r.trigger_name;
    END LOOP;
END $$;

-- 3. Eliminar TODOS los triggers de DELETE en inventario
DO $$ 
DECLARE
    r RECORD;
BEGIN
    FOR r IN 
        SELECT trigger_name
        FROM information_schema.triggers
        WHERE event_object_table = 'inventario'
          AND event_manipulation = 'DELETE'
    LOOP
        EXECUTE 'DROP TRIGGER IF EXISTS ' || r.trigger_name || ' ON inventario CASCADE';
        RAISE NOTICE 'Eliminado trigger: % en inventario', r.trigger_name;
    END LOOP;
END $$;

-- 4. Verificar que no quedan triggers de DELETE
SELECT 
    trigger_name,
    event_object_table
FROM information_schema.triggers
WHERE event_object_table IN ('productos', 'inventario')
  AND event_manipulation = 'DELETE';

-- Resultado esperado: 0 filas (no triggers de DELETE)
