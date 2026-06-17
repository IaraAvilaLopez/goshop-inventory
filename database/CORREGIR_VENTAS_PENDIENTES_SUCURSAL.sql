-- ============================================
-- CORREGIR VENTAS PENDIENTES POR SUCURSAL
-- ============================================
-- Agregar columna ubicacion a ventas_pendientes para separar por sucursal

-- PASO 1: Agregar columna ubicacion
ALTER TABLE ventas_pendientes
ADD COLUMN IF NOT EXISTS ubicacion TEXT;

-- PASO 2: Actualizar ventas existentes (asignar a RESISTENCIA por defecto)
UPDATE ventas_pendientes
SET ubicacion = 'RESISTENCIA'
WHERE ubicacion IS NULL;

-- PASO 3: Hacer la columna NOT NULL
ALTER TABLE ventas_pendientes
ALTER COLUMN ubicacion SET NOT NULL;

-- PASO 4: Agregar constraint para validar ubicacion
ALTER TABLE ventas_pendientes
DROP CONSTRAINT IF EXISTS ventas_pendientes_ubicacion_check;

ALTER TABLE ventas_pendientes
ADD CONSTRAINT ventas_pendientes_ubicacion_check
CHECK (ubicacion IN ('RESISTENCIA', 'CORRIENTES'));

-- PASO 5: Ver estructura actualizada
SELECT 
    column_name,
    data_type,
    is_nullable,
    column_default
FROM information_schema.columns
WHERE table_name = 'ventas_pendientes'
ORDER BY ordinal_position;

-- CONFIRMACION
DO $$
BEGIN
    RAISE NOTICE '';
    RAISE NOTICE '================================================';
    RAISE NOTICE 'VENTAS PENDIENTES CORREGIDAS';
    RAISE NOTICE '================================================';
    RAISE NOTICE '';
    RAISE NOTICE 'Ahora cada sucursal tiene sus propias ventas pendientes';
    RAISE NOTICE 'Columna ubicacion agregada y validada';
    RAISE NOTICE '';
    RAISE NOTICE '================================================';
END $$;
