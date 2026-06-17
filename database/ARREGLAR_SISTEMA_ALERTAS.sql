-- ============================================
-- ARREGLAR SISTEMA DE ALERTAS
-- ============================================

-- PASO 1: Ver triggers actuales de alertas
SELECT 
    trigger_name,
    event_object_table,
    action_timing,
    event_manipulation
FROM information_schema.triggers
WHERE trigger_name LIKE '%alerta%'
ORDER BY trigger_name;

-- PASO 2: Eliminar triggers antiguos de alertas
DROP TRIGGER IF EXISTS trigger_gestionar_alertas ON inventario;
DROP FUNCTION IF EXISTS gestionar_alertas_stock();

-- PASO 3: Crear función mejorada para gestionar alertas
CREATE OR REPLACE FUNCTION gestionar_alertas_stock()
RETURNS TRIGGER AS $$
DECLARE
    v_alerta_existente_id UUID;
BEGIN
    -- Solo procesar si el stock cambió
    IF TG_OP = 'UPDATE' AND OLD.cantidad_actual = NEW.cantidad_actual THEN
        RETURN NEW;
    END IF;
    
    -- Verificar si hay alerta existente
    SELECT id INTO v_alerta_existente_id
    FROM alertas_stock
    WHERE producto_id = NEW.producto_id
    AND ubicacion = NEW.ubicacion
    AND estado_alerta = 'ACTIVA';
    
    -- CASO 1: Stock bajo o en 0 (crear o mantener alerta)
    IF NEW.cantidad_actual <= NEW.cantidad_minima THEN
        IF v_alerta_existente_id IS NULL THEN
            -- Crear nueva alerta
            INSERT INTO alertas_stock (
                producto_id,
                ubicacion,
                cantidad_actual,
                cantidad_minima,
                estado_alerta,
                mensaje
            ) VALUES (
                NEW.producto_id,
                NEW.ubicacion,
                NEW.cantidad_actual,
                NEW.cantidad_minima,
                'ACTIVA',
                CASE 
                    WHEN NEW.cantidad_actual = 0 THEN 'SIN STOCK'
                    ELSE 'STOCK BAJO'
                END
            );
            
            RAISE NOTICE '🔔 ALERTA CREADA: Producto % en % tiene % unidades (mínimo: %)',
                NEW.producto_id, NEW.ubicacion, NEW.cantidad_actual, NEW.cantidad_minima;
        ELSE
            -- Actualizar alerta existente
            UPDATE alertas_stock
            SET cantidad_actual = NEW.cantidad_actual,
                mensaje = CASE 
                    WHEN NEW.cantidad_actual = 0 THEN 'SIN STOCK'
                    ELSE 'STOCK BAJO'
                END,
                updated_at = NOW()
            WHERE id = v_alerta_existente_id;
            
            RAISE NOTICE '🔔 ALERTA ACTUALIZADA: Producto % en % tiene % unidades',
                NEW.producto_id, NEW.ubicacion, NEW.cantidad_actual;
        END IF;
    
    -- CASO 2: Stock recuperado (desactivar alerta)
    ELSIF NEW.cantidad_actual > NEW.cantidad_minima AND v_alerta_existente_id IS NOT NULL THEN
        UPDATE alertas_stock
        SET estado_alerta = 'RESUELTA',
            updated_at = NOW()
        WHERE id = v_alerta_existente_id;
        
        RAISE NOTICE '✅ ALERTA RESUELTA: Producto % en % recuperó stock (%)',
            NEW.producto_id, NEW.ubicacion, NEW.cantidad_actual;
    END IF;
    
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

-- PASO 4: Crear trigger para INSERT y UPDATE
CREATE TRIGGER trigger_gestionar_alertas
AFTER INSERT OR UPDATE ON inventario
FOR EACH ROW
EXECUTE FUNCTION gestionar_alertas_stock();

-- PASO 5: Crear alertas para productos que YA están en stock bajo
INSERT INTO alertas_stock (producto_id, ubicacion, cantidad_actual, cantidad_minima, estado_alerta, mensaje)
SELECT 
    i.producto_id,
    i.ubicacion,
    i.cantidad_actual,
    i.cantidad_minima,
    'ACTIVA',
    CASE 
        WHEN i.cantidad_actual = 0 THEN 'SIN STOCK'
        ELSE 'STOCK BAJO'
    END
FROM inventario i
WHERE i.cantidad_actual <= i.cantidad_minima
AND NOT EXISTS (
    SELECT 1 FROM alertas_stock a
    WHERE a.producto_id = i.producto_id
    AND a.ubicacion = i.ubicacion
    AND a.estado_alerta = 'ACTIVA'
);

-- PASO 6: Ver alertas creadas
SELECT 
    'ALERTAS ACTIVAS' as info,
    p.marca,
    p.modelo,
    a.ubicacion,
    a.cantidad_actual,
    a.cantidad_minima,
    a.mensaje,
    a.created_at
FROM alertas_stock a
JOIN productos p ON a.producto_id = p.id
WHERE a.estado_alerta = 'ACTIVA'
ORDER BY a.created_at DESC;

-- CONFIRMACIÓN
DO $$
DECLARE
    v_alertas_activas INTEGER;
BEGIN
    SELECT COUNT(*) INTO v_alertas_activas
    FROM alertas_stock
    WHERE estado_alerta = 'ACTIVA';
    
    RAISE NOTICE '';
    RAISE NOTICE '═══════════════════════════════════════';
    RAISE NOTICE '✅ SISTEMA DE ALERTAS CONFIGURADO';
    RAISE NOTICE '═══════════════════════════════════════';
    RAISE NOTICE 'Alertas activas: %', v_alertas_activas;
    RAISE NOTICE '';
    RAISE NOTICE '🔔 Las alertas se crearán automáticamente cuando:';
    RAISE NOTICE '   - Stock llegue a 0';
    RAISE NOTICE '   - Stock baje del mínimo';
    RAISE NOTICE '';
    RAISE NOTICE '✅ Las alertas se resolverán cuando:';
    RAISE NOTICE '   - Stock supere el mínimo';
    RAISE NOTICE '═══════════════════════════════════════';
END $$;
