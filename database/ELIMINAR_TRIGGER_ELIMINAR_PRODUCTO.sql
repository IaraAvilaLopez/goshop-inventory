-- Eliminar trigger y función que está causando el error
-- "eliminar_producto is not a function"

-- 1. Buscar triggers relacionados con eliminar_producto
SELECT 
    trigger_name,
    event_object_table,
    action_statement
FROM information_schema.triggers
WHERE trigger_name LIKE '%eliminar%'
   OR action_statement LIKE '%eliminar_producto%';

-- 2. Eliminar triggers en productos
DROP TRIGGER IF EXISTS eliminar_producto ON productos;
DROP TRIGGER IF EXISTS trigger_eliminar_producto ON productos;
DROP TRIGGER IF EXISTS before_delete_producto ON productos;
DROP TRIGGER IF EXISTS after_delete_producto ON productos;

-- 3. Eliminar triggers en inventario
DROP TRIGGER IF EXISTS eliminar_producto ON inventario;
DROP TRIGGER IF EXISTS trigger_eliminar_producto ON inventario;
DROP TRIGGER IF EXISTS before_delete_inventario ON inventario;
DROP TRIGGER IF EXISTS after_delete_inventario ON inventario;

-- 4. Eliminar la función si existe
DROP FUNCTION IF EXISTS eliminar_producto() CASCADE;
DROP FUNCTION IF EXISTS eliminar_producto(uuid) CASCADE;
DROP FUNCTION IF EXISTS eliminar_producto(text) CASCADE;

-- 5. Verificar que se eliminaron
SELECT 
    trigger_name,
    event_object_table
FROM information_schema.triggers
WHERE event_object_table IN ('productos', 'inventario');
