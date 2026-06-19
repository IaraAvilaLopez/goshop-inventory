-- Buscar todas las funciones que contengan "eliminar" en el nombre o código

-- 1. Buscar funciones por nombre
SELECT 
    n.nspname as schema,
    p.proname as function_name,
    pg_get_function_arguments(p.oid) as arguments,
    pg_get_functiondef(p.oid) as definition
FROM pg_proc p
LEFT JOIN pg_namespace n ON p.pronamespace = n.oid
WHERE n.nspname NOT IN ('pg_catalog', 'information_schema')
  AND (p.proname LIKE '%eliminar%' OR p.proname LIKE '%delete%')
ORDER BY p.proname;

-- 2. Buscar todos los triggers activos
SELECT 
    t.tgname as trigger_name,
    c.relname as table_name,
    p.proname as function_name,
    pg_get_triggerdef(t.oid) as trigger_definition
FROM pg_trigger t
JOIN pg_class c ON t.tgrelid = c.oid
JOIN pg_proc p ON t.tgfoid = p.oid
WHERE NOT t.tgisinternal
  AND c.relname IN ('productos', 'inventario')
ORDER BY c.relname, t.tgname;
