-- Función para ajustar stock manualmente (para revertir transacciones eliminadas)
CREATE OR REPLACE FUNCTION ajustar_stock(
    p_producto_id UUID,
    p_ubicacion VARCHAR,
    p_cantidad INTEGER
)
RETURNS VOID AS $$
BEGIN
    -- Actualizar el stock sumando o restando la cantidad
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
    
    -- Asegurar que el stock no sea negativo
    UPDATE inventario 
    SET cantidad_actual = GREATEST(cantidad_actual, 0)
    WHERE producto_id = p_producto_id 
    AND ubicacion = p_ubicacion
    AND estado = 'DISPONIBLE';
END;
$$ LANGUAGE plpgsql;

-- Comentario
COMMENT ON FUNCTION ajustar_stock(UUID, VARCHAR, INTEGER) IS 
'Ajusta el stock de un producto sumando o restando la cantidad especificada. 
Usado para revertir transacciones eliminadas.';
