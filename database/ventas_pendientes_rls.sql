-- Habilitar RLS en la tabla ventas_pendientes
ALTER TABLE ventas_pendientes ENABLE ROW LEVEL SECURITY;

-- Política para permitir SELECT (leer)
CREATE POLICY "Permitir lectura de ventas pendientes"
ON ventas_pendientes
FOR SELECT
USING (true);

-- Política para permitir INSERT (crear)
CREATE POLICY "Permitir crear ventas pendientes"
ON ventas_pendientes
FOR INSERT
WITH CHECK (true);

-- Política para permitir UPDATE (actualizar)
CREATE POLICY "Permitir actualizar ventas pendientes"
ON ventas_pendientes
FOR UPDATE
USING (true)
WITH CHECK (true);

-- Política para permitir DELETE (eliminar)
CREATE POLICY "Permitir eliminar ventas pendientes"
ON ventas_pendientes
FOR DELETE
USING (true);
