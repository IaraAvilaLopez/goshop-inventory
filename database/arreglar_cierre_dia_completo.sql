-- SCRIPT COMPLETO PARA ARREGLAR CIERRE DE DÍA
-- Ejecuta este script en Supabase SQL Editor

-- 1. Agregar CIERRE_DIA como tipo de transacción válido
ALTER TABLE transacciones 
DROP CONSTRAINT IF EXISTS transacciones_tipo_transaccion_check;

ALTER TABLE transacciones 
ADD CONSTRAINT transacciones_tipo_transaccion_check 
CHECK (tipo_transaccion IN ('COMPRA', 'VENTA', 'CANJE_ENTRADA', 'CANJE_SALIDA', 'AJUSTE', 'TRANSFERENCIA', 'CIERRE_DIA'));

-- 2. Actualizar la función para que CIERRE_DIA descuente del stock
CREATE OR REPLACE FUNCTION actualizar_inventario()
RETURNS TRIGGER AS $$
BEGIN
    -- Entradas: COMPRA, CANJE_ENTRADA, TRANSFERENCIA
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
    
    -- Salidas: VENTA, CANJE_SALIDA, CIERRE_DIA
    ELSIF NEW.tipo_transaccion IN ('VENTA', 'CANJE_SALIDA', 'CIERRE_DIA') THEN
        UPDATE inventario 
        SET cantidad_actual = cantidad_actual - NEW.cantidad,
            updated_at = NOW()
        WHERE producto_id = NEW.producto_id 
        AND ubicacion = NEW.ubicacion
        AND estado = 'DISPONIBLE';
    END IF;
    
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

-- 3. Eliminar las transacciones duplicadas de prueba (opcional)
-- DELETE FROM transacciones WHERE tipo_transaccion = 'CIERRE_DIA';

-- ✅ Listo! Ahora CIERRE_DIA descontará del stock automáticamente
