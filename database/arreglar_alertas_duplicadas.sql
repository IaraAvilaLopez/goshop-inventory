-- LIMPIAR ALERTAS DUPLICADAS Y ARREGLAR TRIGGER

-- 1. Eliminar alertas duplicadas (dejar solo la más reciente de cada producto)
DELETE FROM alertas_stock a
WHERE id NOT IN (
    SELECT MAX(id)
    FROM alertas_stock
    GROUP BY producto_id, ubicacion, resuelta
);

-- 2. Mejorar el trigger para evitar duplicados
CREATE OR REPLACE FUNCTION generar_alerta_stock_bajo()
RETURNS TRIGGER AS $$
BEGIN
    -- Solo procesar si el stock cambió
    IF OLD.cantidad_actual IS DISTINCT FROM NEW.cantidad_actual THEN
        
        -- Si el stock es 1 o menos, crear alerta
        IF NEW.cantidad_actual <= 1 AND NEW.estado = 'DISPONIBLE' THEN
            -- Verificar si ya existe una alerta activa
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
            ELSE
                -- Actualizar la alerta existente con el nuevo stock
                UPDATE alertas_stock
                SET cantidad_actual = NEW.cantidad_actual,
                    tipo_alerta = CASE 
                        WHEN NEW.cantidad_actual = 0 THEN 'SIN_STOCK'
                        ELSE 'STOCK_BAJO'
                    END,
                    mensaje = CASE 
                        WHEN NEW.cantidad_actual = 0 THEN 'Producto sin stock'
                        ELSE 'Stock bajo - Solo queda ' || NEW.cantidad_actual || ' unidad(es)'
                    END,
                    updated_at = NOW()
                WHERE producto_id = NEW.producto_id
                AND ubicacion = NEW.ubicacion
                AND resuelta = false;
            END IF;
        
        -- Si el stock sube por encima de 1, resolver alertas
        ELSIF NEW.cantidad_actual > 1 THEN
            UPDATE alertas_stock
            SET resuelta = true,
                fecha_resolucion = NOW()
            WHERE producto_id = NEW.producto_id
            AND ubicacion = NEW.ubicacion
            AND resuelta = false;
        END IF;
    END IF;
    
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

-- Recrear el trigger
DROP TRIGGER IF EXISTS trigger_alerta_stock_bajo ON inventario;

CREATE TRIGGER trigger_alerta_stock_bajo
    AFTER UPDATE OF cantidad_actual ON inventario
    FOR EACH ROW
    EXECUTE FUNCTION generar_alerta_stock_bajo();

-- Verificar
SELECT * FROM alertas_stock WHERE resuelta = false;
