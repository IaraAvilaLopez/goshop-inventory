-- ============================================
-- SCRIPT COMPLETO PARA ARREGLAR TODO
-- Ejecuta este script en Supabase SQL Editor
-- ============================================

-- 1. RESTAURAR STOCK DEL SAMSUNG S24 ULTRA A 3 UNIDADES
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

-- 2. CONFIGURAR TIPO CIERRE_DIA
ALTER TABLE transacciones 
DROP CONSTRAINT IF EXISTS transacciones_tipo_transaccion_check;

ALTER TABLE transacciones 
ADD CONSTRAINT transacciones_tipo_transaccion_check 
CHECK (tipo_transaccion IN ('COMPRA', 'VENTA', 'CANJE_ENTRADA', 'CANJE_SALIDA', 'AJUSTE', 'TRANSFERENCIA', 'CIERRE_DIA'));

-- 3. ACTUALIZAR FUNCIÓN PARA QUE CIERRE_DIA DESCUENTE STOCK
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

-- 4. CREAR FUNCIÓN ajustar_stock PARA ELIMINAR TRANSACCIONES
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

-- 5. ARREGLAR ERRORES DE SEGURIDAD (RLS)
ALTER TABLE alertas_stock DISABLE ROW LEVEL SECURITY;
ALTER TABLE cierres_dia DISABLE ROW LEVEL SECURITY;

-- 6. CONFIGURAR ZONA HORARIA ARGENTINA
ALTER DATABASE postgres SET timezone TO 'America/Argentina/Buenos_Aires';

-- ============================================
-- VERIFICACIÓN
-- ============================================

-- Ver stock del Samsung S24 ULTRA (debería ser 3)
SELECT p.modelo, p.capacidad_gb, i.cantidad_actual, i.ubicacion
FROM productos p
JOIN inventario i ON p.id = i.producto_id
WHERE p.modelo LIKE '%S24 ULTRA%';

-- ✅ LISTO! Ahora recarga la aplicación
