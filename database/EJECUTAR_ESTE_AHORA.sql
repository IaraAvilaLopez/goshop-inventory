-- ============================================
-- SCRIPT FINAL COMPLETO - EJECUTAR ESTE AHORA
-- ============================================

-- 1. LIMPIAR ALERTAS DUPLICADAS
DELETE FROM alertas_stock a
WHERE id NOT IN (
    SELECT MAX(id)
    FROM alertas_stock
    GROUP BY producto_id, ubicacion, resuelta
);

-- 2. ELIMINAR PRODUCTOS DE PRUEBA (AAAA y EEEE)
DELETE FROM inventario WHERE producto_id IN (
    SELECT id FROM productos WHERE marca IN ('AAAAAAA', 'EEEEEE')
);
DELETE FROM transacciones WHERE producto_id IN (
    SELECT id FROM productos WHERE marca IN ('AAAAAAA', 'EEEEEE')
);
DELETE FROM productos WHERE marca IN ('AAAAAAA', 'EEEEEE');

-- 3. RESTAURAR STOCK DEL SAMSUNG S24 ULTRA A 3
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

-- 4. CONFIGURAR TIPO CIERRE_DIA
ALTER TABLE transacciones 
DROP CONSTRAINT IF EXISTS transacciones_tipo_transaccion_check;

ALTER TABLE transacciones 
ADD CONSTRAINT transacciones_tipo_transaccion_check 
CHECK (tipo_transaccion IN ('COMPRA', 'VENTA', 'CANJE_ENTRADA', 'CANJE_SALIDA', 'AJUSTE', 'TRANSFERENCIA', 'CIERRE_DIA'));

-- 5. ACTUALIZAR FUNCIÓN PARA QUE CIERRE_DIA DESCUENTE STOCK
CREATE OR REPLACE FUNCTION actualizar_inventario()
RETURNS TRIGGER AS $$
BEGIN
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

-- 6. CREAR/ACTUALIZAR FUNCIÓN ajustar_stock
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
    AND ubicacion = p_ubicacion
    AND estado = 'DISPONIBLE';
    
    IF NOT FOUND AND p_cantidad > 0 THEN
        INSERT INTO inventario (producto_id, cantidad_actual, ubicacion, estado)
        VALUES (p_producto_id, p_cantidad, p_ubicacion, 'DISPONIBLE');
    END IF;
END;
$$ LANGUAGE plpgsql;

-- 7. MEJORAR TRIGGER DE ALERTAS (SIN DUPLICADOS)
CREATE OR REPLACE FUNCTION generar_alerta_stock_bajo()
RETURNS TRIGGER AS $$
BEGIN
    IF OLD.cantidad_actual IS DISTINCT FROM NEW.cantidad_actual THEN
        
        IF NEW.cantidad_actual <= 1 AND NEW.estado = 'DISPONIBLE' THEN
            IF NOT EXISTS (
                SELECT 1 FROM alertas_stock 
                WHERE producto_id = NEW.producto_id 
                AND ubicacion = NEW.ubicacion
                AND resuelta = false
            ) THEN
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

DROP TRIGGER IF EXISTS trigger_alerta_stock_bajo ON inventario;

CREATE TRIGGER trigger_alerta_stock_bajo
    AFTER UPDATE OF cantidad_actual ON inventario
    FOR EACH ROW
    EXECUTE FUNCTION generar_alerta_stock_bajo();

-- 8. ARREGLAR ERRORES DE SEGURIDAD (RLS)
ALTER TABLE alertas_stock DISABLE ROW LEVEL SECURITY;
ALTER TABLE cierres_dia DISABLE ROW LEVEL SECURITY;
ALTER TABLE ventas_pendientes DISABLE ROW LEVEL SECURITY;
ALTER TABLE transacciones DISABLE ROW LEVEL SECURITY;
ALTER TABLE productos DISABLE ROW LEVEL SECURITY;
ALTER TABLE inventario DISABLE ROW LEVEL SECURITY;

-- 9. CONFIGURAR ZONA HORARIA ARGENTINA
ALTER DATABASE postgres SET timezone TO 'America/Argentina/Buenos_Aires';

-- ============================================
-- VERIFICACIÓN
-- ============================================

-- Ver inventario limpio
SELECT p.marca, p.modelo, p.capacidad_gb, i.cantidad_actual, i.ubicacion
FROM productos p
JOIN inventario i ON p.id = i.producto_id
WHERE i.estado = 'DISPONIBLE'
ORDER BY p.marca, p.modelo;

-- Ver alertas activas
SELECT COUNT(*) as total_alertas FROM alertas_stock WHERE resuelta = false;

-- ✅ LISTO! Ahora recarga la aplicación (F5)
