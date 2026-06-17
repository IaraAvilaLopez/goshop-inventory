-- ============================================
-- CORREGIR TRIGGER PARA INCLUIR CIERRE_DIA
-- ============================================
-- Este script corrige la función actualizar_inventario() para que
-- las transacciones de tipo CIERRE_DIA descuenten el stock automáticamente

-- 1. Eliminar trigger y función existente
DROP TRIGGER IF EXISTS trigger_actualizar_inventario ON transacciones CASCADE;
DROP FUNCTION IF EXISTS actualizar_inventario() CASCADE;

-- 2. Crear función corregida
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
    -- CIERRE_DIA: Ventas procesadas en el cierre diario ✅ AGREGADO
    ELSIF NEW.tipo_transaccion IN ('VENTA', 'CANJE_SALIDA', 'CIERRE_DIA') THEN
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

-- 3. Recrear trigger
CREATE TRIGGER trigger_actualizar_inventario
AFTER INSERT ON transacciones
FOR EACH ROW
EXECUTE FUNCTION actualizar_inventario();

-- 4. Agregar comentario explicativo
COMMENT ON FUNCTION actualizar_inventario() IS 
'Actualiza inventario automáticamente:
- SUMAN (+): COMPRA, CANJE_ENTRADA, TRANSFERENCIA (productos que llegan)
- RESTAN (-): VENTA, CANJE_SALIDA, CIERRE_DIA (productos que salen)';

-- 5. Verificar que se creó correctamente
SELECT 
    'Trigger actualizado correctamente' as resultado,
    'CIERRE_DIA ahora descuenta stock automáticamente' as detalle;

-- 6. Verificar triggers activos
SELECT 
    trigger_name,
    event_manipulation,
    event_object_table,
    action_statement
FROM information_schema.triggers
WHERE trigger_name = 'trigger_actualizar_inventario';
