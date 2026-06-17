-- GoShop - Sistema de Gestión de Inventario de Celulares
-- Esquema de base de datos PostgreSQL para Supabase

-- Tabla de productos (catálogo de celulares)
CREATE TABLE productos (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    modelo VARCHAR(100) NOT NULL,
    marca VARCHAR(50) NOT NULL,
    color VARCHAR(50),
    capacidad_gb VARCHAR(20) NOT NULL,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

CREATE INDEX idx_productos_modelo ON productos(modelo);
CREATE INDEX idx_productos_marca ON productos(marca);

-- Tabla de inventario (stock actual por producto y ubicación)
CREATE TABLE inventario (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    producto_id UUID REFERENCES productos(id) ON DELETE CASCADE,
    cantidad_actual INTEGER NOT NULL DEFAULT 0,
    cantidad_minima INTEGER NOT NULL DEFAULT 1,
    ubicacion VARCHAR(100) DEFAULT 'RESISTENCIA',
    estado VARCHAR(50) DEFAULT 'DISPONIBLE',
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    UNIQUE(producto_id, ubicacion, estado)
);

CREATE INDEX idx_inventario_producto ON inventario(producto_id);

-- Tabla de transacciones (registro de todas las operaciones)
CREATE TABLE transacciones (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    producto_id UUID REFERENCES productos(id) ON DELETE CASCADE,
    tipo_transaccion VARCHAR(50) NOT NULL CHECK (tipo_transaccion IN ('COMPRA', 'VENTA', 'CANJE_ENTRADA', 'CANJE_SALIDA', 'AJUSTE', 'TRANSFERENCIA')),
    cantidad INTEGER NOT NULL,
    precio_unitario DECIMAL(10, 2),
    precio_total DECIMAL(10, 2),
    fecha_transaccion TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    observaciones TEXT,
    usuario VARCHAR(100),
    ubicacion VARCHAR(100) DEFAULT 'RESISTENCIA',
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

CREATE INDEX idx_transacciones_producto ON transacciones(producto_id);
CREATE INDEX idx_transacciones_fecha ON transacciones(fecha_transaccion);
CREATE INDEX idx_transacciones_tipo ON transacciones(tipo_transaccion);

-- Tabla de alertas de stock bajo
CREATE TABLE alertas_stock (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    producto_id UUID REFERENCES productos(id) ON DELETE CASCADE,
    inventario_id UUID REFERENCES inventario(id) ON DELETE CASCADE,
    cantidad_actual INTEGER NOT NULL,
    cantidad_minima INTEGER NOT NULL,
    estado_alerta VARCHAR(50) DEFAULT 'ACTIVA' CHECK (estado_alerta IN ('ACTIVA', 'RESUELTA', 'IGNORADA')),
    fecha_alerta TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    fecha_resolucion TIMESTAMP WITH TIME ZONE,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

CREATE INDEX idx_alertas_estado ON alertas_stock(estado_alerta);

-- Tabla de cierres de día
CREATE TABLE cierres_dia (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    fecha_cierre DATE NOT NULL,
    ubicacion VARCHAR(100) DEFAULT 'RESISTENCIA',
    total_ventas INTEGER NOT NULL DEFAULT 0,
    total_ingresos DECIMAL(10, 2) DEFAULT 0,
    observaciones TEXT,
    usuario VARCHAR(100),
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    UNIQUE(fecha_cierre, ubicacion)
);

-- Tabla de detalle de cierres
CREATE TABLE detalle_cierres (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    cierre_id UUID REFERENCES cierres_dia(id) ON DELETE CASCADE,
    producto_id UUID REFERENCES productos(id) ON DELETE CASCADE,
    cantidad_vendida INTEGER NOT NULL,
    precio_promedio DECIMAL(10, 2),
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- Función para actualizar inventario automáticamente
CREATE OR REPLACE FUNCTION actualizar_inventario()
RETURNS TRIGGER AS $$
BEGIN
    IF NEW.tipo_transaccion IN ('COMPRA', 'CANJE_ENTRADA') THEN
        UPDATE inventario 
        SET cantidad_actual = cantidad_actual + NEW.cantidad,
            updated_at = NOW()
        WHERE producto_id = NEW.producto_id 
        AND ubicacion = NEW.ubicacion
        AND estado = 'DISPONIBLE';
        
        IF NOT FOUND THEN
            INSERT INTO inventario (producto_id, cantidad_actual, ubicacion, estado)
            VALUES (NEW.producto_id, NEW.cantidad, NEW.ubicacion, 'DISPONIBLE');
        END IF;
        
    ELSIF NEW.tipo_transaccion IN ('VENTA', 'CANJE_SALIDA') THEN
        UPDATE inventario 
        SET cantidad_actual = cantidad_actual - NEW.cantidad,
            updated_at = NOW()
        WHERE producto_id = NEW.producto_id 
        AND ubicacion = NEW.ubicacion
        AND estado = 'DISPONIBLE';
    END IF;
    
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

-- Trigger para actualizar inventario
CREATE TRIGGER trigger_actualizar_inventario
AFTER INSERT ON transacciones
FOR EACH ROW
EXECUTE FUNCTION actualizar_inventario();

-- Función para generar alertas de stock bajo
CREATE OR REPLACE FUNCTION verificar_stock_bajo()
RETURNS TRIGGER AS $$
BEGIN
    IF NEW.cantidad_actual <= NEW.cantidad_minima AND NEW.estado = 'DISPONIBLE' THEN
        INSERT INTO alertas_stock (producto_id, inventario_id, cantidad_actual, cantidad_minima, estado_alerta)
        VALUES (NEW.producto_id, NEW.id, NEW.cantidad_actual, NEW.cantidad_minima, 'ACTIVA')
        ON CONFLICT DO NOTHING;
    END IF;
    
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

-- Trigger para alertas de stock bajo
CREATE TRIGGER trigger_verificar_stock_bajo
AFTER UPDATE OF cantidad_actual ON inventario
FOR EACH ROW
EXECUTE FUNCTION verificar_stock_bajo();

-- Vista para stock actual con detalles
CREATE VIEW vista_stock_actual AS
SELECT 
    p.id as producto_id,
    p.modelo,
    p.marca,
    p.color,
    p.capacidad_gb,
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

-- Vista para alertas activas
CREATE VIEW vista_alertas_activas AS
SELECT 
    a.id as alerta_id,
    p.modelo,
    p.marca,
    p.color,
    p.capacidad_gb,
    a.cantidad_actual,
    a.cantidad_minima,
    i.ubicacion,
    a.fecha_alerta,
    a.estado_alerta
FROM alertas_stock a
JOIN productos p ON a.producto_id = p.id
JOIN inventario i ON a.inventario_id = i.id
WHERE a.estado_alerta = 'ACTIVA'
ORDER BY a.fecha_alerta DESC;
