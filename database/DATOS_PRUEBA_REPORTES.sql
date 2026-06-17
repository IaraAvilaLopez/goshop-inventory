-- ============================================
-- DATOS DE PRUEBA PARA VERIFICAR REPORTES
-- ============================================
-- Este script inserta ventas en diferentes fechas para probar
-- los filtros de Diario, Semanal y Mensual

-- IMPORTANTE: Ajusta los producto_id según tus productos reales
-- Puedes ver tus productos con: SELECT id, marca, modelo FROM productos LIMIT 5;

-- ============================================
-- PASO 1: Ver tus productos disponibles
-- ============================================
SELECT 
    id as producto_id,
    marca,
    modelo,
    capacidad_gb
FROM productos
ORDER BY marca, modelo
LIMIT 10;

-- ============================================
-- PASO 2: Copiar los IDs de arriba y usarlos abajo
-- ============================================

-- EJEMPLO: Reemplaza 'ID_PRODUCTO_1', 'ID_PRODUCTO_2', etc.
-- con los IDs reales de tus productos

DO $$
DECLARE
    -- CAMBIA ESTOS IDs POR LOS REALES DE TUS PRODUCTOS
    producto1 UUID := 'ID_PRODUCTO_1'; -- Ejemplo: Samsung S24
    producto2 UUID := 'ID_PRODUCTO_2'; -- Ejemplo: iPhone 11
    producto3 UUID := 'ID_PRODUCTO_3'; -- Ejemplo: Xiaomi
BEGIN
    -- ============================================
    -- VENTAS DE JUNIO 2026
    -- ============================================
    
    -- SEMANA 1 (02/06 al 08/06)
    -- Lunes 02/06
    INSERT INTO transacciones (producto_id, tipo_transaccion, cantidad, precio_unitario, precio_total, fecha_transaccion, observaciones, ubicacion)
    VALUES (producto1, 'CIERRE_DIA', 2, 0, 0, '2026-06-02 18:00:00', 'Cierre de día', 'RESISTENCIA');
    
    -- Martes 03/06 (HOY)
    INSERT INTO transacciones (producto_id, tipo_transaccion, cantidad, precio_unitario, precio_total, fecha_transaccion, observaciones, ubicacion)
    VALUES (producto2, 'CIERRE_DIA', 3, 0, 0, '2026-06-03 18:00:00', 'Cierre de día', 'RESISTENCIA');
    
    -- Miércoles 04/06
    INSERT INTO transacciones (producto_id, tipo_transaccion, cantidad, precio_unitario, precio_total, fecha_transaccion, observaciones, ubicacion)
    VALUES (producto1, 'CIERRE_DIA', 1, 0, 0, '2026-06-04 18:00:00', 'Cierre de día', 'RESISTENCIA');
    
    -- Jueves 05/06
    INSERT INTO transacciones (producto_id, tipo_transaccion, cantidad, precio_unitario, precio_total, fecha_transaccion, observaciones, ubicacion)
    VALUES (producto3, 'CIERRE_DIA', 4, 0, 0, '2026-06-05 18:00:00', 'Cierre de día', 'RESISTENCIA');
    
    -- Viernes 06/06
    INSERT INTO transacciones (producto_id, tipo_transaccion, cantidad, precio_unitario, precio_total, fecha_transaccion, observaciones, ubicacion)
    VALUES (producto2, 'CIERRE_DIA', 2, 0, 0, '2026-06-06 18:00:00', 'Cierre de día', 'RESISTENCIA');
    
    -- SEMANA 2 (09/06 al 15/06)
    -- Lunes 09/06
    INSERT INTO transacciones (producto_id, tipo_transaccion, cantidad, precio_unitario, precio_total, fecha_transaccion, observaciones, ubicacion)
    VALUES (producto1, 'CIERRE_DIA', 3, 0, 0, '2026-06-09 18:00:00', 'Cierre de día', 'RESISTENCIA');
    
    -- Miércoles 11/06
    INSERT INTO transacciones (producto_id, tipo_transaccion, cantidad, precio_unitario, precio_total, fecha_transaccion, observaciones, ubicacion)
    VALUES (producto2, 'CIERRE_DIA', 2, 0, 0, '2026-06-11 18:00:00', 'Cierre de día', 'RESISTENCIA');
    
    -- SEMANA 3 (16/06 al 22/06)
    -- Martes 17/06
    INSERT INTO transacciones (producto_id, tipo_transaccion, cantidad, precio_unitario, precio_total, fecha_transaccion, observaciones, ubicacion)
    VALUES (producto3, 'CIERRE_DIA', 5, 0, 0, '2026-06-17 18:00:00', 'Cierre de día', 'RESISTENCIA');
    
    -- Jueves 19/06
    INSERT INTO transacciones (producto_id, tipo_transaccion, cantidad, precio_unitario, precio_total, fecha_transaccion, observaciones, ubicacion)
    VALUES (producto1, 'CIERRE_DIA', 1, 0, 0, '2026-06-19 18:00:00', 'Cierre de día', 'RESISTENCIA');
    
    -- SEMANA 4 (23/06 al 29/06)
    -- Lunes 23/06
    INSERT INTO transacciones (producto_id, tipo_transaccion, cantidad, precio_unitario, precio_total, fecha_transaccion, observaciones, ubicacion)
    VALUES (producto2, 'CIERRE_DIA', 4, 0, 0, '2026-06-23 18:00:00', 'Cierre de día', 'RESISTENCIA');
    
    -- Viernes 27/06
    INSERT INTO transacciones (producto_id, tipo_transaccion, cantidad, precio_unitario, precio_total, fecha_transaccion, observaciones, ubicacion)
    VALUES (producto1, 'CIERRE_DIA', 2, 0, 0, '2026-06-27 18:00:00', 'Cierre de día', 'RESISTENCIA');
    
    RAISE NOTICE '✅ Datos de prueba insertados correctamente';
END $$;

-- ============================================
-- PASO 3: VERIFICAR LOS DATOS
-- ============================================

-- Ver todas las transacciones de Junio 2026
SELECT 
    t.fecha_transaccion::date as fecha,
    p.marca,
    p.modelo,
    t.cantidad,
    t.tipo_transaccion
FROM transacciones t
JOIN productos p ON t.producto_id = p.id
WHERE t.fecha_transaccion >= '2026-06-01'
AND t.fecha_transaccion < '2026-07-01'
AND t.tipo_transaccion = 'CIERRE_DIA'
ORDER BY t.fecha_transaccion;

-- ============================================
-- PASO 4: CÓMO PROBAR EN LA APP
-- ============================================

/*
AHORA PUEDES PROBAR:

1. REPORTE DIARIO:
   - Click en "Diario"
   - Selecciona: 03/06/2026
   - Debe mostrar solo las ventas del 03/06

2. REPORTE SEMANAL:
   - Click en "Semanal"
   - Selecciona: 03/06/2026 (cualquier día de esa semana)
   - Debe mostrar: "Período seleccionado: 02/06/2026 al 08/06/2026"
   - Debe sumar: 2 + 3 + 1 + 4 + 2 = 12 unidades

3. REPORTE MENSUAL:
   - Click en "Mensual"
   - Selecciona: 03/06/2026 (cualquier día de junio)
   - Debe mostrar: "Período seleccionado: 01/06/2026 al 30/06/2026"
   - Debe sumar todas las ventas de junio

VERIFICACIÓN:
- El indicador verde debe mostrar el rango correcto
- Los productos más vendidos deben aparecer ordenados
- Las barras de ventas por día deben ser proporcionales
*/

-- ============================================
-- PASO 5: LIMPIAR DATOS DE PRUEBA (OPCIONAL)
-- ============================================

-- Si quieres eliminar estos datos de prueba después:
/*
DELETE FROM transacciones 
WHERE tipo_transaccion = 'CIERRE_DIA'
AND fecha_transaccion >= '2026-06-01'
AND fecha_transaccion < '2026-07-01'
AND observaciones = 'Cierre de día';
*/
