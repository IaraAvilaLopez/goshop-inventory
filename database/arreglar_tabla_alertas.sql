-- ARREGLAR ESTRUCTURA DE LA TABLA alertas_stock

-- 1. Agregar columnas faltantes si no existen
DO $$ 
BEGIN
    -- Agregar tipo_alerta
    IF NOT EXISTS (
        SELECT 1 FROM information_schema.columns 
        WHERE table_name = 'alertas_stock' AND column_name = 'tipo_alerta'
    ) THEN
        ALTER TABLE alertas_stock ADD COLUMN tipo_alerta VARCHAR(50);
    END IF;
    
    -- Agregar mensaje
    IF NOT EXISTS (
        SELECT 1 FROM information_schema.columns 
        WHERE table_name = 'alertas_stock' AND column_name = 'mensaje'
    ) THEN
        ALTER TABLE alertas_stock ADD COLUMN mensaje TEXT;
    END IF;
    
    -- Agregar cantidad_actual
    IF NOT EXISTS (
        SELECT 1 FROM information_schema.columns 
        WHERE table_name = 'alertas_stock' AND column_name = 'cantidad_actual'
    ) THEN
        ALTER TABLE alertas_stock ADD COLUMN cantidad_actual INTEGER DEFAULT 0;
    END IF;
END $$;

-- 2. Eliminar trigger y función vieja
DROP TRIGGER IF EXISTS trigger_alerta_stock_bajo ON inventario CASCADE;
DROP FUNCTION IF EXISTS generar_alerta_stock_bajo() CASCADE;

-- 3. Crear nueva función simplificada
CREATE FUNCTION generar_alerta_stock_bajo()
RETURNS TRIGGER AS $$
BEGIN
    -- Solo procesar si el stock cambió
    IF OLD.cantidad_actual IS DISTINCT FROM NEW.cantidad_actual THEN
        
        -- Si stock <= 1, crear alerta
        IF NEW.cantidad_actual <= 1 AND NEW.estado = 'DISPONIBLE' THEN
            -- Eliminar alertas anteriores
            DELETE FROM alertas_stock 
            WHERE producto_id = NEW.producto_id 
            AND ubicacion = NEW.ubicacion;
            
            -- Crear nueva alerta
            INSERT INTO alertas_stock (
                producto_id,
                ubicacion,
                cantidad_actual,
                cantidad_minima,
                tipo_alerta,
                mensaje
            ) VALUES (
                NEW.producto_id,
                NEW.ubicacion,
                NEW.cantidad_actual,
                1,  -- Cantidad mínima por defecto
                CASE 
                    WHEN NEW.cantidad_actual = 0 THEN 'SIN_STOCK'
                    ELSE 'STOCK_BAJO'
                END,
                CASE 
                    WHEN NEW.cantidad_actual = 0 THEN 'Producto sin stock'
                    ELSE 'Stock bajo - Solo queda ' || NEW.cantidad_actual || ' unidad(es)'
                END
            );
        
        -- Si stock > 1, eliminar alertas
        ELSIF NEW.cantidad_actual > 1 THEN
            DELETE FROM alertas_stock
            WHERE producto_id = NEW.producto_id
            AND ubicacion = NEW.ubicacion;
        END IF;
    END IF;
    
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

-- 4. Crear trigger
CREATE TRIGGER trigger_alerta_stock_bajo
    AFTER UPDATE OF cantidad_actual ON inventario
    FOR EACH ROW
    EXECUTE FUNCTION generar_alerta_stock_bajo();

-- 5. Verificar estructura
SELECT column_name, data_type 
FROM information_schema.columns 
WHERE table_name = 'alertas_stock'
ORDER BY ordinal_position;
