-- Arreglar transferencias para que SUMEN al stock (productos que llegan de otra sucursal)
DROP TRIGGER IF EXISTS trigger_actualizar_inventario ON transacciones;
DROP FUNCTION IF EXISTS actualizar_inventario();

CREATE OR REPLACE FUNCTION actualizar_inventario()
RETURNS TRIGGER AS $$
BEGIN
    -- Operaciones que SUMAN al stock (entradas)
    -- COMPRA: Compraste stock nuevo
    -- CANJE_ENTRADA: Cliente te dio un producto
    -- TRANSFERENCIA: Producto llega de otra sucursal
    IF NEW.tipo_transaccion IN ('COMPRA', 'CANJE_ENTRADA', 'TRANSFERENCIA') THEN
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
    -- VENTA: Vendiste el producto
    -- CANJE_SALIDA: Entregaste un producto en canje
    ELSIF NEW.tipo_transaccion IN ('VENTA', 'CANJE_SALIDA') THEN
        UPDATE inventario 
        SET cantidad_actual = cantidad_actual - NEW.cantidad,
            updated_at = NOW()
        WHERE producto_id = NEW.producto_id 
        AND ubicacion = NEW.ubicacion
        AND estado = 'DISPONIBLE';
        
        -- Evitar stock negativo
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

-- Recrear trigger
CREATE TRIGGER trigger_actualizar_inventario
AFTER INSERT ON transacciones
FOR EACH ROW
EXECUTE FUNCTION actualizar_inventario();

-- Comentario explicativo
COMMENT ON FUNCTION actualizar_inventario() IS 
'Actualiza inventario automáticamente:
- SUMAN (+): COMPRA, CANJE_ENTRADA, TRANSFERENCIA (productos que llegan)
- RESTAN (-): VENTA, CANJE_SALIDA (productos que salen)';
