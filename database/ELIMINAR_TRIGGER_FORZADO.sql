-- ELIMINAR COMPLETAMENTE EL TRIGGER Y FUNCIÓN VIEJA

-- 1. Eliminar el trigger de TODAS las formas posibles
DROP TRIGGER IF EXISTS trigger_alerta_stock_bajo ON inventario CASCADE;
DROP TRIGGER IF EXISTS trigger_alerta_stock_bajo ON public.inventario CASCADE;

-- 2. Eliminar TODAS las versiones de la función
DROP FUNCTION IF EXISTS generar_alerta_stock_bajo() CASCADE;
DROP FUNCTION IF EXISTS generar_alerta_stock_bajo(text) CASCADE;
DROP FUNCTION IF EXISTS generar_alerta_stock_bajo(uuid) CASCADE;
DROP FUNCTION IF EXISTS public.generar_alerta_stock_bajo() CASCADE;

-- 3. Verificar que no quede ninguna función
SELECT routine_name, routine_type
FROM information_schema.routines
WHERE routine_name LIKE '%alerta%'
AND routine_schema = 'public';

-- 4. Verificar que no quede ningún trigger
SELECT trigger_name, event_object_table
FROM information_schema.triggers
WHERE trigger_name LIKE '%alerta%';

-- Si aparece algo en los resultados, ejecuta esto:
-- DROP TRIGGER [nombre_del_trigger] ON [nombre_tabla] CASCADE;
-- DROP FUNCTION [nombre_funcion]() CASCADE;
