-- Actualizar vista_stock_actual para incluir bateria_porcentaje
-- Ejecutar en Supabase SQL Editor

-- 1. Eliminar la vista existente
DROP VIEW IF EXISTS vista_stock_actual;

-- 2. Recrear la vista con el campo bateria_porcentaje
CREATE VIEW vista_stock_actual AS
SELECT 
    p.id as producto_id,
    p.modelo,
    p.marca,
    p.color,
    p.capacidad_gb,
    p.bateria_porcentaje,
    i.cantidad_actual,
    i.cantidad_minima,
    i.ubicacion,
    i.estado,
    CASE 
        WHEN i.cantidad_actual <= i.cantidad_minima THEN 'CRÍTICO'
        WHEN i.cantidad_actual <= (i.cantidad_minima * 2) THEN 'BAJO'
        ELSE 'NORMAL'
    END as nivel_stock,
    i.updated_at as ultima_actualizacion
FROM productos p
LEFT JOIN inventario i ON p.id = i.producto_id
ORDER BY p.marca, p.modelo;

-- 3. Verificar que la vista se creó correctamente
SELECT * FROM vista_stock_actual LIMIT 5;
