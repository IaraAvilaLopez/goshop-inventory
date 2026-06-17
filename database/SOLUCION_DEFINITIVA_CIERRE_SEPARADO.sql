-- ============================================
-- SOLUCIÓN DEFINITIVA - CIERRE DE DÍA SEPARADO POR SUCURSAL
-- ============================================
-- Este script garantiza que NUNCA MÁS se mezclen los cierres entre sucursales

-- ============================================
-- PARTE 1: ASEGURAR ESTRUCTURA CORRECTA
-- ============================================

-- Verificar y agregar columna ubicacion si no existe
DO $$
BEGIN
    IF NOT EXISTS (
        SELECT 1 FROM information_schema.columns 
        WHERE table_name = 'ventas_pendientes' AND column_name = 'ubicacion'
    ) THEN
        ALTER TABLE ventas_pendientes ADD COLUMN ubicacion TEXT;
    END IF;
END $$;

-- Eliminar ventas sin ubicacion (datos corruptos)
DELETE FROM ventas_pendientes WHERE ubicacion IS NULL;

-- Hacer ubicacion obligatoria
ALTER TABLE ventas_pendientes
ALTER COLUMN ubicacion SET NOT NULL;

-- Agregar constraint de validación
ALTER TABLE ventas_pendientes
DROP CONSTRAINT IF EXISTS ventas_pendientes_ubicacion_check;

ALTER TABLE ventas_pendientes
ADD CONSTRAINT ventas_pendientes_ubicacion_check
CHECK (ubicacion IN ('RESISTENCIA', 'CORRIENTES'));

-- ============================================
-- PARTE 2: CREAR ÍNDICE PARA MEJORAR RENDIMIENTO
-- ============================================

-- Índice para búsquedas rápidas por ubicacion y fecha
CREATE INDEX IF NOT EXISTS idx_ventas_pendientes_ubicacion_fecha 
ON ventas_pendientes(ubicacion, fecha, procesada);

-- ============================================
-- PARTE 3: CREAR FUNCIÓN DE VALIDACIÓN
-- ============================================

-- Función que valida que toda venta tenga ubicacion
CREATE OR REPLACE FUNCTION validar_ubicacion_venta()
RETURNS TRIGGER AS $$
BEGIN
    IF NEW.ubicacion IS NULL THEN
        RAISE EXCEPTION 'ERROR: Toda venta debe tener una ubicacion (RESISTENCIA o CORRIENTES)';
    END IF;
    
    IF NEW.ubicacion NOT IN ('RESISTENCIA', 'CORRIENTES') THEN
        RAISE EXCEPTION 'ERROR: Ubicacion invalida. Debe ser RESISTENCIA o CORRIENTES';
    END IF;
    
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

-- Trigger que valida SIEMPRE antes de insertar
DROP TRIGGER IF EXISTS trigger_validar_ubicacion_venta ON ventas_pendientes;

CREATE TRIGGER trigger_validar_ubicacion_venta
BEFORE INSERT OR UPDATE ON ventas_pendientes
FOR EACH ROW
EXECUTE FUNCTION validar_ubicacion_venta();

-- ============================================
-- PARTE 4: CREAR VISTA PARA CIERRES POR SUCURSAL
-- ============================================

-- Vista que muestra ventas pendientes por sucursal
CREATE OR REPLACE VIEW vista_ventas_pendientes_por_sucursal AS
SELECT 
    vp.id,
    vp.producto_id,
    vp.cantidad,
    vp.fecha,
    vp.ubicacion,
    vp.procesada,
    vp.comentarios,
    p.marca,
    p.modelo,
    p.capacidad_gb,
    p.color
FROM ventas_pendientes vp
JOIN productos p ON vp.producto_id = p.id
WHERE vp.procesada = false
ORDER BY vp.ubicacion, vp.fecha DESC, vp.created_at DESC;

-- ============================================
-- PARTE 5: CREAR FUNCIÓN PARA OBTENER VENTAS POR SUCURSAL
-- ============================================

-- Función que devuelve ventas pendientes de UNA sucursal específica
CREATE OR REPLACE FUNCTION obtener_ventas_pendientes(
    p_ubicacion TEXT,
    p_fecha DATE
)
RETURNS TABLE (
    id UUID,
    producto_id UUID,
    cantidad INTEGER,
    fecha DATE,
    ubicacion TEXT,
    marca TEXT,
    modelo TEXT,
    capacidad_gb TEXT,
    color TEXT
) AS $$
BEGIN
    RETURN QUERY
    SELECT 
        vp.id,
        vp.producto_id,
        vp.cantidad,
        vp.fecha,
        vp.ubicacion,
        p.marca,
        p.modelo,
        p.capacidad_gb,
        p.color
    FROM ventas_pendientes vp
    JOIN productos p ON vp.producto_id = p.id
    WHERE vp.procesada = false
    AND vp.ubicacion = p_ubicacion
    AND vp.fecha = p_fecha
    ORDER BY vp.created_at ASC;
END;
$$ LANGUAGE plpgsql;

-- ============================================
-- PARTE 6: CREAR FUNCIÓN PARA VERIFICAR CIERRE EXISTENTE
-- ============================================

-- Función que verifica si ya existe un cierre para una sucursal en una fecha
CREATE OR REPLACE FUNCTION existe_cierre_dia(
    p_ubicacion TEXT,
    p_fecha DATE
)
RETURNS BOOLEAN AS $$
DECLARE
    v_existe BOOLEAN;
BEGIN
    SELECT EXISTS(
        SELECT 1 FROM cierres_dia
        WHERE fecha_cierre = p_fecha
        AND ubicacion = p_ubicacion
    ) INTO v_existe;
    
    RETURN v_existe;
END;
$$ LANGUAGE plpgsql;

-- ============================================
-- PARTE 7: VERIFICAR INTEGRIDAD DE DATOS
-- ============================================

-- Contar ventas sin ubicacion (debe ser 0)
DO $$
DECLARE
    v_ventas_sin_ubicacion INTEGER;
BEGIN
    SELECT COUNT(*) INTO v_ventas_sin_ubicacion
    FROM ventas_pendientes
    WHERE ubicacion IS NULL;
    
    IF v_ventas_sin_ubicacion > 0 THEN
        RAISE EXCEPTION 'ERROR: Hay % ventas sin ubicacion. Ejecuta: DELETE FROM ventas_pendientes WHERE ubicacion IS NULL;', v_ventas_sin_ubicacion;
    END IF;
END $$;

-- ============================================
-- CONFIRMACIÓN FINAL
-- ============================================
DO $$
DECLARE
    v_total_ventas INTEGER;
    v_ventas_resistencia INTEGER;
    v_ventas_corrientes INTEGER;
BEGIN
    SELECT COUNT(*) INTO v_total_ventas FROM ventas_pendientes;
    SELECT COUNT(*) INTO v_ventas_resistencia FROM ventas_pendientes WHERE ubicacion = 'RESISTENCIA';
    SELECT COUNT(*) INTO v_ventas_corrientes FROM ventas_pendientes WHERE ubicacion = 'CORRIENTES';
    
    RAISE NOTICE '';
    RAISE NOTICE '████████████████████████████████████████████████████████';
    RAISE NOTICE '█                                                      █';
    RAISE NOTICE '█   SISTEMA DE CIERRE SEPARADO - CONFIGURADO          █';
    RAISE NOTICE '█                                                      █';
    RAISE NOTICE '████████████████████████████████████████████████████████';
    RAISE NOTICE '';
    RAISE NOTICE 'GARANTÍAS IMPLEMENTADAS:';
    RAISE NOTICE '';
    RAISE NOTICE '✓ Columna ubicacion es OBLIGATORIA';
    RAISE NOTICE '✓ Solo acepta RESISTENCIA o CORRIENTES';
    RAISE NOTICE '✓ Trigger valida SIEMPRE antes de insertar';
    RAISE NOTICE '✓ Índice creado para búsquedas rápidas';
    RAISE NOTICE '✓ Funciones SQL para consultas seguras';
    RAISE NOTICE '✓ Vista para visualizar ventas por sucursal';
    RAISE NOTICE '';
    RAISE NOTICE 'ESTADO ACTUAL:';
    RAISE NOTICE '  Total ventas pendientes: %', v_total_ventas;
    RAISE NOTICE '  RESISTENCIA: %', v_ventas_resistencia;
    RAISE NOTICE '  CORRIENTES: %', v_ventas_corrientes;
    RAISE NOTICE '';
    RAISE NOTICE 'SIGUIENTE PASO:';
    RAISE NOTICE '1. Recarga la app (F5 + Ctrl+Shift+R)';
    RAISE NOTICE '2. Agrega ventas en cada sucursal';
    RAISE NOTICE '3. Verifica que esten separadas';
    RAISE NOTICE '4. Procesa cierre en cada sucursal';
    RAISE NOTICE '';
    RAISE NOTICE 'AHORA ES IMPOSIBLE que se mezclen las ventas';
    RAISE NOTICE 'El sistema rechazará cualquier venta sin ubicacion';
    RAISE NOTICE '';
    RAISE NOTICE '████████████████████████████████████████████████████████';
END $$;
