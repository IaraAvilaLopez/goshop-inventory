-- Script para corregir las políticas de eliminación de productos e inventario
-- Permite eliminar productos desde cualquier sucursal

-- 1. Eliminar políticas antiguas de DELETE en productos
DROP POLICY IF EXISTS "delete_productos" ON productos;
DROP POLICY IF EXISTS "productos_delete_policy" ON productos;

-- 2. Crear nueva política de DELETE para productos (sin restricción de sucursal)
-- Los productos son compartidos entre sucursales, cualquiera puede eliminarlos
CREATE POLICY "productos_delete_all" ON productos
  FOR DELETE
  USING (true);

-- 3. Eliminar políticas antiguas de DELETE en inventario
DROP POLICY IF EXISTS "delete_inventario" ON inventario;
DROP POLICY IF EXISTS "inventario_delete_policy" ON inventario;

-- 4. Crear nueva política de DELETE para inventario (sin restricción de sucursal)
-- Permitir eliminar inventario de cualquier sucursal
CREATE POLICY "inventario_delete_all" ON inventario
  FOR DELETE
  USING (true);

-- Verificar las políticas actuales
SELECT schemaname, tablename, policyname, permissive, roles, cmd, qual
FROM pg_policies
WHERE tablename IN ('productos', 'inventario')
ORDER BY tablename, policyname;
