-- AGREGAR CAMPO DE COMENTARIOS A VENTAS PENDIENTES

-- 1. Agregar columna comentarios si no existe
DO $$ 
BEGIN
    IF NOT EXISTS (
        SELECT 1 FROM information_schema.columns 
        WHERE table_name = 'ventas_pendientes' AND column_name = 'comentarios'
    ) THEN
        ALTER TABLE ventas_pendientes ADD COLUMN comentarios TEXT;
    END IF;
END $$;

-- 2. Verificar que se agregó
SELECT column_name, data_type 
FROM information_schema.columns 
WHERE table_name = 'ventas_pendientes'
ORDER BY ordinal_position;
