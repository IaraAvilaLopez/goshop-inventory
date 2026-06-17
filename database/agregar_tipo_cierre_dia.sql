-- Agregar CIERRE_DIA como tipo de transacción válido
-- Esto permite identificar claramente las transacciones de cierre de día

ALTER TABLE transacciones 
DROP CONSTRAINT IF EXISTS transacciones_tipo_transaccion_check;

ALTER TABLE transacciones 
ADD CONSTRAINT transacciones_tipo_transaccion_check 
CHECK (tipo_transaccion IN ('COMPRA', 'VENTA', 'CANJE_ENTRADA', 'CANJE_SALIDA', 'AJUSTE', 'TRANSFERENCIA', 'CIERRE_DIA'));

-- Nota: Ejecuta este script en Supabase SQL Editor para agregar el nuevo tipo de transacción
