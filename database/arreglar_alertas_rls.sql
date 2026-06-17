-- ARREGLAR ERROR DE SEGURIDAD EN ALERTAS_STOCK
-- Este error impide que se creen alertas automáticamente

-- Desactivar RLS (Row Level Security) en la tabla alertas_stock
ALTER TABLE alertas_stock DISABLE ROW LEVEL SECURITY;

-- O si prefieres mantener RLS, crear una política permisiva:
-- DROP POLICY IF EXISTS "Permitir todo en alertas_stock" ON alertas_stock;
-- CREATE POLICY "Permitir todo en alertas_stock" ON alertas_stock FOR ALL USING (true);

-- Verificar que funciona
SELECT * FROM alertas_stock LIMIT 5;
