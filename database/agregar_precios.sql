-- Agregar columnas de precio a productos
ALTER TABLE productos 
ADD COLUMN IF NOT EXISTS precio_compra DECIMAL(10,2),
ADD COLUMN IF NOT EXISTS precio_venta DECIMAL(10,2),
ADD COLUMN IF NOT EXISTS ganancia_porcentaje DECIMAL(5,2) GENERATED ALWAYS AS (
  CASE 
    WHEN precio_compra > 0 THEN ((precio_venta - precio_compra) / precio_compra * 100)
    ELSE 0
  END
) STORED;

-- Agregar índice para búsquedas rápidas
CREATE INDEX IF NOT EXISTS idx_productos_busqueda ON productos(marca, modelo, capacidad_gb);

-- Comentarios
COMMENT ON COLUMN productos.precio_compra IS 'Precio de compra del producto';
COMMENT ON COLUMN productos.precio_venta IS 'Precio de venta al público';
COMMENT ON COLUMN productos.ganancia_porcentaje IS 'Porcentaje de ganancia calculado automáticamente';
