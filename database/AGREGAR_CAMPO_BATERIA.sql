-- Script para agregar campo de porcentaje de batería a productos
-- Ejecutar en Supabase SQL Editor

-- 1. Agregar columna bateria_porcentaje a la tabla productos
ALTER TABLE productos 
ADD COLUMN IF NOT EXISTS bateria_porcentaje INTEGER;

-- 2. Agregar comentario a la columna
COMMENT ON COLUMN productos.bateria_porcentaje IS 'Porcentaje de batería del celular (0-100)';

-- 3. Agregar constraint para validar que el porcentaje esté entre 0 y 100
ALTER TABLE productos
ADD CONSTRAINT check_bateria_porcentaje 
CHECK (bateria_porcentaje IS NULL OR (bateria_porcentaje >= 0 AND bateria_porcentaje <= 100));

-- 4. Verificar que se agregó correctamente
SELECT column_name, data_type, is_nullable
FROM information_schema.columns
WHERE table_name = 'productos' AND column_name = 'bateria_porcentaje';
