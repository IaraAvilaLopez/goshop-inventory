-- Ajustar zona horaria para Argentina (UTC-3)
-- Esto hace que las fechas se guarden con la hora local de Argentina

-- Configurar zona horaria por defecto para la sesión
ALTER DATABASE postgres SET timezone TO 'America/Argentina/Buenos_Aires';

-- Función para obtener la fecha/hora actual de Argentina
CREATE OR REPLACE FUNCTION now_argentina()
RETURNS TIMESTAMP WITH TIME ZONE AS $$
BEGIN
    RETURN NOW() AT TIME ZONE 'America/Argentina/Buenos_Aires';
END;
$$ LANGUAGE plpgsql;

-- Nota: Esta configuración hace que:
-- 1. Las fechas se muestren en hora de Argentina
-- 2. NOW() devuelva la hora de Argentina
-- 3. Los filtros de fecha funcionen correctamente con hora local
