-- CREAR TRIGGER PARA GENERAR ALERTAS AUTOMÁTICAS DE STOCK BAJO
-- Este trigger se ejecuta cada vez que se actualiza el inventario

CREATE OR REPLACE FUNCTION generar_alerta_stock_bajo()
RETURNS TRIGGER AS $$
BEGIN
    -- Si el stock nuevo es 1 o menos, crear alerta
    IF NEW.cantidad_actual <= 1 AND NEW.estado = 'DISPONIBLE' THEN
        -- Verificar si ya existe una alerta activa para este producto
        IF NOT EXISTS (
            SELECT 1 FROM alertas_stock 
            WHERE producto_id = NEW.producto_id 
            AND ubicacion = NEW.ubicacion
            AND resuelta = false
        ) THEN
            -- Crear nueva alerta
            INSERT INTO alertas_stock (
                producto_id,
                ubicacion,
                cantidad_actual,
                tipo_alerta,
                mensaje,
                resuelta
            ) VALUES (
                NEW.producto_id,
                NEW.ubicacion,
                NEW.cantidad_actual,
                CASE 
                    WHEN NEW.cantidad_actual = 0 THEN 'SIN_STOCK'
                    ELSE 'STOCK_BAJO'
                END,
                CASE 
                    WHEN NEW.cantidad_actual = 0 THEN 'Producto sin stock'
                    ELSE 'Stock bajo - Solo queda ' || NEW.cantidad_actual || ' unidad(es)'
                END,
                false
            );
        END IF;
    -- Si el stock sube por encima de 1, resolver alertas existentes
    ELSIF NEW.cantidad_actual > 1 THEN
        UPDATE alertas_stock
        SET resuelta = true,
            fecha_resolucion = NOW()
        WHERE producto_id = NEW.producto_id
        AND ubicacion = NEW.ubicacion
        AND resuelta = false;
    END IF;
    
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

-- Eliminar trigger anterior si existe
DROP TRIGGER IF EXISTS trigger_alerta_stock_bajo ON inventario;

-- Crear el trigger
CREATE TRIGGER trigger_alerta_stock_bajo
    AFTER UPDATE OF cantidad_actual ON inventario
    FOR EACH ROW
    EXECUTE FUNCTION generar_alerta_stock_bajo();

-- Verificar que funciona
SELECT * FROM alertas_stock ORDER BY created_at DESC LIMIT 5;
