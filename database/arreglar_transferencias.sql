-- Arreglar el trigger para que TRANSFERENCIA también afecte el stock
-- TRANSFERENCIA resta del stock (como una salida)

DROP TRIGGER IF EXISTS trigger_actualizar_inventario ON transacciones;
DROP FUNCTION IF EXISTS actualizar_inventario();

-- Función mejorada para actualizar inventario
CREATE OR REPLACE FUNCTION actualizar_inventario()
RETURNS TRIGGER AS $$
BEGIN
    -- Operaciones que SUMAN al stock (entradas)
    IF NEW.tipo_transaccion IN ('COMPRA', 'CANJE_ENTRADA') THEN
        UPDATE inventario 
        SET cantidad_actual = cantidad_actual + NEW.cantidad,
            updated_at = NOW()
        WHERE producto_id = NEW.producto_id 
        AND ubicacion = NEW.ubicacion
        AND estado = 'DISPONIBLE';
        
        IF NOT FOUND THEN
            INSERT INTO inventario (producto_id, cantidad_actual, ubicacion, estado)
            VALUES (NEW.producto_id, NEW.cantidad, NEW.ubicacion, 'DISPONIBLE');
        END IF;
    
    -- Operaciones que RESTAN del stock (salidas)
    ELSIF NEW.tipo_transaccion IN ('VENTA', 'CANJE_SALIDA', 'TRANSFERENCIA') THEN
        UPDATE inventario 
        SET cantidad_actual = cantidad_actual - NEW.cantidad,
            updated_at = NOW()
        WHERE producto_id = NEW.producto_id 
        AND ubicacion = NEW.ubicacion
        AND estado = 'DISPONIBLE';
        
        -- Verificar que no quede stock negativo
        IF FOUND THEN
            UPDATE inventario 
            SET cantidad_actual = GREATEST(cantidad_actual, 0)
            WHERE producto_id = NEW.producto_id 
            AND ubicacion = NEW.ubicacion
            AND estado = 'DISPONIBLE';
        END IF;
    END IF;
    
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

-- Recrear el trigger
CREATE TRIGGER trigger_actualizar_inventario
AFTER INSERT ON transacciones
FOR EACH ROW
EXECUTE FUNCTION actualizar_inventario();

-- Comentario
COMMENT ON FUNCTION actualizar_inventario() IS 'Actualiza el inventario automáticamente según el tipo de transacción. COMPRA y CANJE_ENTRADA suman, VENTA, CANJE_SALIDA y TRANSFERENCIA restan.';
