-- ============================================
-- CONFIGURACIÓN MULTI-SUCURSAL
-- ============================================
-- Este script prepara la base de datos para soportar múltiples sucursales
-- Resistencia (ya existente con datos) y Corrientes (nueva, sin stock)

-- ============================================
-- PASO 1: Verificar datos actuales
-- ============================================

-- Ver productos actuales (todos son de Resistencia)
SELECT COUNT(*) as total_productos FROM productos;

-- Ver inventario actual (todo es de Resistencia)
SELECT ubicacion, COUNT(*) as total_items, SUM(cantidad_actual) as total_unidades
FROM inventario
GROUP BY ubicacion;

-- ============================================
-- PASO 2: Verificar que ubicacion ya existe en inventario
-- ============================================

-- La columna 'ubicacion' ya existe en la tabla inventario
-- Todos los registros actuales tienen ubicacion = 'RESISTENCIA'

SELECT column_name, data_type, is_nullable
FROM information_schema.columns
WHERE table_name = 'inventario'
AND column_name = 'ubicacion';

-- ============================================
-- PASO 3: Crear productos para Corrientes (copiar estructura)
-- ============================================

-- Los productos son compartidos entre sucursales
-- Solo el inventario es diferente por sucursal

-- Verificar que todos los productos existen
SELECT id, marca, modelo, capacidad_gb 
FROM productos 
ORDER BY marca, modelo
LIMIT 10;

-- ============================================
-- PASO 4: Crear inventario vacío para Corrientes
-- ============================================

-- Para cada producto que existe en Resistencia,
-- crear un registro en inventario para Corrientes con stock 0

INSERT INTO inventario (producto_id, ubicacion, cantidad_actual, stock_minimo)
SELECT 
    producto_id,
    'CORRIENTES' as ubicacion,
    0 as cantidad_actual,
    stock_minimo
FROM inventario
WHERE ubicacion = 'RESISTENCIA'
ON CONFLICT (producto_id, ubicacion) DO NOTHING;

-- ============================================
-- PASO 5: Verificar inventario de ambas sucursales
-- ============================================

-- Resistencia (con stock)
SELECT 
    p.marca,
    p.modelo,
    p.capacidad_gb,
    i.cantidad_actual,
    i.stock_minimo,
    i.ubicacion
FROM inventario i
JOIN productos p ON i.producto_id = p.id
WHERE i.ubicacion = 'RESISTENCIA'
ORDER BY p.marca, p.modelo
LIMIT 10;

-- Corrientes (sin stock)
SELECT 
    p.marca,
    p.modelo,
    p.capacidad_gb,
    i.cantidad_actual,
    i.stock_minimo,
    i.ubicacion
FROM inventario i
JOIN productos p ON i.producto_id = p.id
WHERE i.ubicacion = 'CORRIENTES'
ORDER BY p.marca, p.modelo
LIMIT 10;

-- ============================================
-- PASO 6: Resumen por sucursal
-- ============================================

SELECT 
    ubicacion,
    COUNT(*) as total_productos,
    SUM(cantidad_actual) as total_unidades,
    SUM(CASE WHEN cantidad_actual < stock_minimo THEN 1 ELSE 0 END) as productos_bajo_stock
FROM inventario
GROUP BY ubicacion
ORDER BY ubicacion;

-- ============================================
-- PASO 7: Verificar vistas y funciones
-- ============================================

-- La vista vista_stock_actual ya filtra por ubicación
SELECT * FROM vista_stock_actual 
WHERE ubicacion = 'CORRIENTES'
LIMIT 5;

-- La vista vista_alertas_activas también filtra por ubicación
SELECT * FROM vista_alertas_activas
WHERE ubicacion = 'CORRIENTES'
LIMIT 5;

-- ============================================
-- PASO 8: Notas importantes
-- ============================================

/*
IMPORTANTE:

1. PRODUCTOS:
   - Los productos son COMPARTIDOS entre sucursales
   - No se duplican, ambas sucursales ven los mismos productos
   - Se pueden agregar nuevos productos desde cualquier sucursal

2. INVENTARIO:
   - Cada sucursal tiene su propio inventario (stock)
   - Resistencia: Stock actual con datos
   - Corrientes: Stock en 0, listo para cargar

3. TRANSACCIONES:
   - Cada transacción tiene su ubicación
   - Se filtran automáticamente por sucursal

4. VENTAS PENDIENTES:
   - Cada venta se asocia a una ubicación
   - El cierre de día es por sucursal

5. ALERTAS:
   - Se generan por sucursal
   - Cada sucursal ve solo sus alertas

6. REPORTES:
   - Se filtran automáticamente por sucursal
   - Cada sucursal ve solo sus datos

FLUJO DE TRABAJO:

Resistencia:
- Ya tiene stock cargado
- Puede seguir operando normalmente
- Todas las funciones activas

Corrientes:
- Stock en 0 (vacío)
- Puede agregar productos (compras)
- Puede hacer ventas (cuando tenga stock)
- Puede hacer cierres de día
- Puede ver reportes (cuando tenga datos)

PRÓXIMOS PASOS:

1. Ejecutar este script
2. Verificar que Corrientes tiene inventario en 0
3. Desde la app, seleccionar Corrientes
4. Agregar stock mediante compras
5. Empezar a operar normalmente
*/

-- ============================================
-- VERIFICACIÓN FINAL
-- ============================================

-- Contar registros por sucursal
SELECT 
    'Inventario Resistencia' as descripcion,
    COUNT(*) as cantidad
FROM inventario 
WHERE ubicacion = 'RESISTENCIA'

UNION ALL

SELECT 
    'Inventario Corrientes' as descripcion,
    COUNT(*) as cantidad
FROM inventario 
WHERE ubicacion = 'CORRIENTES'

UNION ALL

SELECT 
    'Total Productos' as descripcion,
    COUNT(*) as cantidad
FROM productos;

-- ============================================
-- ¡LISTO! Base de datos configurada para multi-sucursal
-- ============================================

DO $$
BEGIN
  RAISE NOTICE '✅ Base de datos configurada correctamente';
  RAISE NOTICE '📍 Resistencia: Stock completo';
  RAISE NOTICE '📍 Corrientes: Stock vacío, listo para cargar';
  RAISE NOTICE '🚀 Puedes empezar a usar ambas sucursales';
END $$;
