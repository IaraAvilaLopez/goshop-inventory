-- CREAR O REEMPLAZAR LA FUNCIÓN ajustar_stock
-- Esta función permite ajustar el stock manualmente (sumar o restar)

CREATE OR REPLACE FUNCTION ajustar_stock(
    p_producto_id UUID,
    p_ubicacion VARCHAR,
    p_cantidad INTEGER
)
RETURNS void AS $$
BEGIN
    -- Actualizar el stock del producto
    UPDATE inventario
    SET cantidad_actual = cantidad_actual + p_cantidad,
        updated_at = NOW()
    WHERE producto_id = p_producto_id
    AND ubicacion = p_ubicacion
    AND estado = 'DISPONIBLE';
    
    -- Si no existe el registro, crearlo (solo si la cantidad es positiva)
    IF NOT FOUND AND p_cantidad > 0 THEN
        INSERT INTO inventario (producto_id, cantidad_actual, ubicacion, estado)
        VALUES (p_producto_id, p_cantidad, p_ubicacion, 'DISPONIBLE');
    END IF;
END;
$$ LANGUAGE plpgsql;

-- Probar la función
-- SELECT ajustar_stock('id-del-producto', 'RESISTENCIA', -1);  -- Resta 1
-- SELECT ajustar_stock('id-del-producto', 'RESISTENCIA', 5);   -- Suma 5
