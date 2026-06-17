-- Tabla para ventas pendientes de procesar en el cierre
CREATE TABLE IF NOT EXISTS ventas_pendientes (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    producto_id UUID NOT NULL REFERENCES productos(id) ON DELETE CASCADE,
    cantidad INTEGER NOT NULL CHECK (cantidad > 0),
    fecha DATE NOT NULL DEFAULT CURRENT_DATE,
    procesada BOOLEAN DEFAULT FALSE,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP
);

-- Índices para mejor rendimiento
CREATE INDEX idx_ventas_pendientes_producto ON ventas_pendientes(producto_id);
CREATE INDEX idx_ventas_pendientes_fecha ON ventas_pendientes(fecha);
CREATE INDEX idx_ventas_pendientes_procesada ON ventas_pendientes(procesada);

-- Trigger para actualizar updated_at
CREATE TRIGGER actualizar_ventas_pendientes_timestamp
    BEFORE UPDATE ON ventas_pendientes
    FOR EACH ROW
    EXECUTE FUNCTION actualizar_timestamp();

COMMENT ON TABLE ventas_pendientes IS 'Ventas del día pendientes de procesar en el cierre';
