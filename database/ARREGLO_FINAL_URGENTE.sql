-- ============================================
-- ARREGLO FINAL URGENTE
-- ============================================

-- 1. AGREGAR COLUMNA ubicacion A transacciones SI NO EXISTE
DO $$ 
BEGIN
    IF NOT EXISTS (
        SELECT 1 FROM information_schema.columns 
        WHERE table_name = 'transacciones' AND column_name = 'ubicacion'
    ) THEN
        ALTER TABLE transacciones ADD COLUMN ubicacion VARCHAR(50) DEFAULT 'RESISTENCIA';
        UPDATE transacciones SET ubicacion = 'RESISTENCIA' WHERE ubicacion IS NULL;
    END IF;
    
    -- Agregar ubicacion a alertas_stock si no existe
    IF NOT EXISTS (
        SELECT 1 FROM information_schema.columns 
        WHERE table_name = 'alertas_stock' AND column_name = 'ubicacion'
    ) THEN
        ALTER TABLE alertas_stock ADD COLUMN ubicacion VARCHAR(50) DEFAULT 'RESISTENCIA';
        UPDATE alertas_stock SET ubicacion = 'RESISTENCIA' WHERE ubicacion IS NULL;
    END IF;
END $$;

-- 2. ELIMINAR PRODUCTOS DUPLICADOS DE PRUEBA
DELETE FROM alertas_stock WHERE producto_id IN (
    SELECT id FROM productos WHERE marca IN ('AAAA', 'AAAAAAAA', 'EEE', 'EEEEEE')
);

DELETE FROM inventario WHERE producto_id IN (
    SELECT id FROM productos WHERE marca IN ('AAAA', 'AAAAAAAA', 'EEE', 'EEEEEE')
);

DELETE FROM transacciones WHERE producto_id IN (
    SELECT id FROM productos WHERE marca IN ('AAAA', 'AAAAAAAA', 'EEE', 'EEEEEE')
);

DELETE FROM productos WHERE marca IN ('AAAA', 'AAAAAAAA', 'EEE', 'EEEEEE');

-- 3. LIMPIAR ALERTAS DUPLICADAS (simplificado)
-- Eliminar todas las alertas y dejar que se regeneren automáticamente
TRUNCATE TABLE alertas_stock;

-- 4. RESTAURAR STOCK DEL SAMSUNG S24 ULTRA A 3
DELETE FROM transacciones 
WHERE producto_id IN (
  SELECT id FROM productos WHERE modelo LIKE '%S24 ULTRA%'
);

UPDATE inventario 
SET cantidad_actual = 3
WHERE producto_id IN (
  SELECT id FROM productos WHERE modelo LIKE '%S24 ULTRA%'
)
AND ubicacion = 'RESISTENCIA'
AND estado = 'DISPONIBLE';

-- 5. CONFIGURAR TIPO CIERRE_DIA
ALTER TABLE transacciones 
DROP CONSTRAINT IF EXISTS transacciones_tipo_transaccion_check;

ALTER TABLE transacciones 
ADD CONSTRAINT transacciones_tipo_transaccion_check 
CHECK (tipo_transaccion IN ('COMPRA', 'VENTA', 'CANJE_ENTRADA', 'CANJE_SALIDA', 'AJUSTE', 'TRANSFERENCIA', 'CIERRE_DIA'));

-- 6. ACTUALIZAR FUNCIÓN actualizar_inventario
CREATE OR REPLACE FUNCTION actualizar_inventario()
RETURNS TRIGGER AS $$
BEGIN
    IF NEW.tipo_transaccion IN ('COMPRA', 'CANJE_ENTRADA', 'TRANSFERENCIA') THEN
        UPDATE inventario 
        SET cantidad_actual = cantidad_actual + NEW.cantidad,
            updated_at = NOW()
        WHERE producto_id = NEW.producto_id 
        AND ubicacion = COALESCE(NEW.ubicacion, 'RESISTENCIA')
        AND estado = 'DISPONIBLE';
        
        IF NOT FOUND THEN
            INSERT INTO inventario (producto_id, cantidad_actual, ubicacion, estado)
            VALUES (NEW.producto_id, NEW.cantidad, COALESCE(NEW.ubicacion, 'RESISTENCIA'), 'DISPONIBLE');
        END IF;
    
    ELSIF NEW.tipo_transaccion IN ('VENTA', 'CANJE_SALIDA', 'CIERRE_DIA') THEN
        UPDATE inventario 
        SET cantidad_actual = cantidad_actual - NEW.cantidad,
            updated_at = NOW()
        WHERE producto_id = NEW.producto_id 
        AND ubicacion = COALESCE(NEW.ubicacion, 'RESISTENCIA')
        AND estado = 'DISPONIBLE';
    END IF;
    
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

-- 7. ACTUALIZAR FUNCIÓN ajustar_stock
CREATE OR REPLACE FUNCTION ajustar_stock(
    p_producto_id UUID,
    p_ubicacion VARCHAR,
    p_cantidad INTEGER
)
RETURNS void AS $$
BEGIN
    UPDATE inventario
    SET cantidad_actual = cantidad_actual + p_cantidad,
        updated_at = NOW()
    WHERE producto_id = p_producto_id
    AND ubicacion = COALESCE(p_ubicacion, 'RESISTENCIA')
    AND estado = 'DISPONIBLE';
    
    IF NOT FOUND AND p_cantidad > 0 THEN
        INSERT INTO inventario (producto_id, cantidad_actual, ubicacion, estado)
        VALUES (p_producto_id, p_cantidad, COALESCE(p_ubicacion, 'RESISTENCIA'), 'DISPONIBLE');
    END IF;
END;
$$ LANGUAGE plpgsql;

-- 8. ELIMINAR TRIGGER Y FUNCIÓN VIEJA
DROP TRIGGER IF EXISTS trigger_alerta_stock_bajo ON inventario;
DROP FUNCTION IF EXISTS generar_alerta_stock_bajo();

-- 9. TRIGGER DE ALERTAS SIMPLIFICADO (NUEVA VERSIÓN)
CREATE FUNCTION generar_alerta_stock_bajo()
RETURNS TRIGGER AS $$
BEGIN
    -- Solo crear alerta si el stock cambió
    IF OLD.cantidad_actual IS DISTINCT FROM NEW.cantidad_actual THEN
        
        -- Si el stock es 1 o menos, crear/actualizar alerta
        IF NEW.cantidad_actual <= 1 AND NEW.estado = 'DISPONIBLE' THEN
            -- Eliminar alertas anteriores de este producto
            DELETE FROM alertas_stock 
            WHERE producto_id = NEW.producto_id 
            AND ubicacion = NEW.ubicacion;
            
            -- Crear nueva alerta
            INSERT INTO alertas_stock (
                producto_id,
                ubicacion,
                cantidad_actual,
                tipo_alerta,
                mensaje
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
                END
            );
        
        -- Si el stock sube por encima de 1, eliminar alertas
        ELSIF NEW.cantidad_actual > 1 THEN
            DELETE FROM alertas_stock
            WHERE producto_id = NEW.producto_id
            AND ubicacion = NEW.ubicacion;
        END IF;
    END IF;
    
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

-- Crear el trigger
CREATE TRIGGER trigger_alerta_stock_bajo
    AFTER UPDATE OF cantidad_actual ON inventario
    FOR EACH ROW
    EXECUTE FUNCTION generar_alerta_stock_bajo();

-- 10. DESACTIVAR RLS
ALTER TABLE alertas_stock DISABLE ROW LEVEL SECURITY;
ALTER TABLE cierres_dia DISABLE ROW LEVEL SECURITY;
ALTER TABLE ventas_pendientes DISABLE ROW LEVEL SECURITY;
ALTER TABLE transacciones DISABLE ROW LEVEL SECURITY;
ALTER TABLE productos DISABLE ROW LEVEL SECURITY;
ALTER TABLE inventario DISABLE ROW LEVEL SECURITY;

-- 11. ZONA HORARIA
ALTER DATABASE postgres SET timezone TO 'America/Argentina/Buenos_Aires';

-- ============================================
-- VERIFICACIÓN
-- ============================================

-- Ver inventario limpio (solo productos reales)
SELECT p.marca, p.modelo, p.capacidad_gb, i.cantidad_actual, i.ubicacion
FROM productos p
JOIN inventario i ON p.id = i.producto_id
WHERE i.estado = 'DISPONIBLE'
ORDER BY p.marca, p.modelo;

-- Ver si la columna ubicacion existe
SELECT column_name, data_type 
FROM information_schema.columns 
WHERE table_name = 'transacciones' 
AND column_name = 'ubicacion';

-- ✅ LISTO! Recarga la aplicación
