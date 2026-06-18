-- Deshabilitar RLS para productos e inventario
-- La aplicación ya maneja la seguridad por sucursal correctamente

-- 1. Deshabilitar RLS en productos
ALTER TABLE productos DISABLE ROW LEVEL SECURITY;

-- 2. Deshabilitar RLS en inventario  
ALTER TABLE inventario DISABLE ROW LEVEL SECURITY;

-- 3. Verificar que RLS esté deshabilitado
SELECT 
    schemaname,
    tablename,
    rowsecurity as "RLS Habilitado"
FROM pg_tables
WHERE tablename IN ('productos', 'inventario');

-- Resultado esperado: rowsecurity = false para ambas tablas
