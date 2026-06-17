-- RESTAURAR STOCK DEL SAMSUNG S24 ULTRA A 3 UNIDADES
-- Ejecuta este script en Supabase SQL Editor

-- 1. Ver el estado actual
SELECT p.modelo, p.capacidad_gb, i.cantidad_actual, i.ubicacion
FROM productos p
JOIN inventario i ON p.id = i.producto_id
WHERE p.modelo LIKE '%S24 ULTRA%';

-- 2. Ver todas las transacciones del S24 ULTRA
SELECT t.id, t.tipo_transaccion, t.cantidad, t.fecha_transaccion, t.observaciones
FROM transacciones t
JOIN productos p ON t.producto_id = p.id
WHERE p.modelo LIKE '%S24 ULTRA%'
ORDER BY t.fecha_transaccion DESC;

-- 3. ELIMINAR todas las transacciones de prueba del S24 ULTRA
DELETE FROM transacciones 
WHERE producto_id IN (
  SELECT id FROM productos WHERE modelo LIKE '%S24 ULTRA%'
);

-- 4. RESTAURAR el stock a 3 unidades
UPDATE inventario 
SET cantidad_actual = 3
WHERE producto_id IN (
  SELECT id FROM productos WHERE modelo LIKE '%S24 ULTRA%'
)
AND ubicacion = 'RESISTENCIA'
AND estado = 'DISPONIBLE';

-- 5. Verificar que quedó en 3
SELECT p.modelo, p.capacidad_gb, i.cantidad_actual, i.ubicacion
FROM productos p
JOIN inventario i ON p.id = i.producto_id
WHERE p.modelo LIKE '%S24 ULTRA%';

-- ✅ Listo! El stock del Samsung S24 ULTRA debería estar en 3 unidades
