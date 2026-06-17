-- Agregar categoría a productos (CELULAR u OTRO)
ALTER TABLE productos 
ADD COLUMN IF NOT EXISTS categoria VARCHAR(50) DEFAULT 'CELULAR'
CHECK (categoria IN ('CELULAR', 'OTRO'));

-- Hacer que capacidad_gb sea opcional (no todos los productos tienen GB)
ALTER TABLE productos 
ALTER COLUMN capacidad_gb DROP NOT NULL;

-- Agregar descripción para productos que no son celulares
ALTER TABLE productos 
ADD COLUMN IF NOT EXISTS descripcion TEXT;

-- Actualizar productos existentes como CELULAR
UPDATE productos SET categoria = 'CELULAR' WHERE categoria IS NULL;

-- Comentarios
COMMENT ON COLUMN productos.categoria IS 'CELULAR para celulares, OTRO para consolas, parlantes, auriculares, etc.';
COMMENT ON COLUMN productos.descripcion IS 'Descripción adicional (principalmente para productos OTRO)';
