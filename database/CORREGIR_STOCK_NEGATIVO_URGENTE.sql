-- ============================================
-- CORREGIR STOCK NEGATIVO URGENTE
-- ============================================

-- PASO 1: Ver todos los stocks negativos
SELECT 
    'STOCK NEGATIVO DETECTADO' as alerta,
    i.ubicacion,
    p.marca,
    p.modelo,
    p.capacidad_gb,
    i.cantidad_actual,
    i.estado
FROM inventario i
JOIN productos p ON i.producto_id = p.id
WHERE i.cantidad_actual < 0
ORDER BY i.cantidad_actual ASC;

-- PASO 2: CORREGIR stock negativo (poner en 0)
UPDATE inventario
SET cantidad_actual = 0
WHERE cantidad_actual < 0;

-- PASO 3: Ver resultado
SELECT 
    'DESPUÉS DE CORRECCIÓN' as info,
    i.ubicacion,
    p.marca,
    p.modelo,
    i.cantidad_actual
FROM inventario i
JOIN productos p ON i.producto_id = p.id
WHERE p.marca = 'SAMSUNG'
AND p.modelo = 'S24 ULTRA'
ORDER BY i.ubicacion;

-- PASO 4: Actualizar alertas para productos corregidos
UPDATE alertas_stock a
SET cantidad_actual = 0,
    mensaje = 'SIN STOCK'
FROM inventario i
WHERE a.producto_id = i.producto_id
AND a.ubicacion = i.ubicacion
AND i.cantidad_actual = 0
AND a.estado_alerta = 'ACTIVA';

-- CONFIRMACIÓN
DO $$
DECLARE
    v_corregidos INTEGER;
BEGIN
    SELECT COUNT(*) INTO v_corregidos
    FROM inventario
    WHERE cantidad_actual < 0;
    
    IF v_corregidos > 0 THEN
        RAISE NOTICE '⚠️ AÚN HAY % PRODUCTOS CON STOCK NEGATIVO', v_corregidos;
    ELSE
        RAISE NOTICE '✅ TODOS LOS STOCKS NEGATIVOS FUERON CORREGIDOS';
        RAISE NOTICE '✅ Ahora todos los productos tienen stock >= 0';
    END IF;
END $$;
