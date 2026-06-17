-- ELIMINAR COMPLETAMENTE LOS PRODUCTOS DE PRUEBA

-- 1. Eliminar de alertas_stock
DELETE FROM alertas_stock 
WHERE producto_id IN (
    SELECT id FROM productos 
    WHERE marca IN ('AAAA', 'AAAAAAAA', 'AAAA AAAA', 'EEEE', 'EEEEEE', 'EEEE EEEE', 'EEE', 'EEE EEEE')
);

-- 2. Eliminar de inventario
DELETE FROM inventario 
WHERE producto_id IN (
    SELECT id FROM productos 
    WHERE marca IN ('AAAA', 'AAAAAAAA', 'AAAA AAAA', 'EEEE', 'EEEEEE', 'EEEE EEEE', 'EEE', 'EEE EEEE')
);

-- 3. Eliminar de transacciones
DELETE FROM transacciones 
WHERE producto_id IN (
    SELECT id FROM productos 
    WHERE marca IN ('AAAA', 'AAAAAAAA', 'AAAA AAAA', 'EEEE', 'EEEEEE', 'EEEE EEEE', 'EEE', 'EEE EEEE')
);

-- 4. Eliminar de ventas_pendientes
DELETE FROM ventas_pendientes 
WHERE producto_id IN (
    SELECT id FROM productos 
    WHERE marca IN ('AAAA', 'AAAAAAAA', 'AAAA AAAA', 'EEEE', 'EEEEEE', 'EEEE EEEE', 'EEE', 'EEE EEEE')
);

-- 5. Eliminar de productos
DELETE FROM productos 
WHERE marca IN ('AAAA', 'AAAAAAAA', 'AAAA AAAA', 'EEEE', 'EEEEEE', 'EEEE EEEE', 'EEE', 'EEE EEEE');

-- 6. Verificar que se eliminaron
SELECT * FROM productos 
WHERE marca IN ('AAAA', 'AAAAAAAA', 'AAAA AAAA', 'EEEE', 'EEEEEE', 'EEEE EEEE', 'EEE', 'EEE EEEE');

-- Debería retornar 0 filas
