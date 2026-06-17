-- ============================================
-- ARREGLAR TRIGGER DE ALERTAS (SIN updated_at)
-- ============================================

-- Eliminar trigger anterior
DROP TRIGGER IF EXISTS trigger_gestionar_alertas ON inventario;
DROP FUNCTION IF EXISTS gestionar_alertas_stock();

-- Crear función SIN usar updated_at
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
            
            RAISE NOTICE '🔔 ALERTA CREADA para producto % en %', NEW.producto_id, NEW.ubicacion;
        ELSE
            -- Actualizar alerta existente (SIN updated_at)
            UPDATE alertas_stock
            SET cantidad_actual = NEW.cantidad_actual,
                mensaje = CASE 
                    WHEN NEW.cantidad_actual = 0 THEN 'SIN STOCK'
                    ELSE 'STOCK BAJO'
                END
            WHERE id = v_alerta_existente_id;
            
            RAISE NOTICE '🔔 ALERTA ACTUALIZADA para producto % en %', NEW.producto_id, NEW.ubicacion;
        END IF;
    
    -- CASO 2: Stock recuperado (desactivar alerta)
    ELSIF NEW.cantidad_actual > NEW.cantidad_minima AND v_alerta_existente_id IS NOT NULL THEN
        UPDATE alertas_stock
        SET estado_alerta = 'RESUELTA'
        WHERE id = v_alerta_existente_id;
        
        RAISE NOTICE '✅ ALERTA RESUELTA para producto % en %', NEW.producto_id, NEW.ubicacion;
    END IF;
    
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

-- Crear trigger
CREATE TRIGGER trigger_gestionar_alertas
AFTER INSERT OR UPDATE ON inventario
FOR EACH ROW
EXECUTE FUNCTION gestionar_alertas_stock();

-- CONFIRMACIÓN
DO $$
BEGIN
    RAISE NOTICE '';
    RAISE NOTICE '═══════════════════════════════════════';
    RAISE NOTICE '✅ TRIGGER DE ALERTAS CORREGIDO';
    RAISE NOTICE '═══════════════════════════════════════';
    RAISE NOTICE '✅ Ya NO usa updated_at';
    RAISE NOTICE '✅ Las alertas se crearán automáticamente';
    RAISE NOTICE '═══════════════════════════════════════';
END $$;
```

---

**Ejecuta este script y luego intenta la transferencia de nuevo.** 🔧
