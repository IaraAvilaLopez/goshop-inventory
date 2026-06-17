-- ============================================
-- AGREGAR CIERRE_DIA AL CONSTRAINT DE TRANSACCIONES
-- ============================================
-- Este script agrega CIERRE_DIA como tipo de transacción válido

-- 1. Eliminar constraint existente
ALTER TABLE transacciones 
DROP CONSTRAINT IF EXISTS transacciones_tipo_transaccion_check;

-- 2. Agregar nuevo constraint con CIERRE_DIA incluido
ALTER TABLE transacciones 
ADD CONSTRAINT transacciones_tipo_transaccion_check 
CHECK (tipo_transaccion IN (
    'COMPRA', 
    'VENTA', 
    'CANJE_ENTRADA', 
    'CANJE_SALIDA', 
    'AJUSTE', 
    'TRANSFERENCIA',
    'CIERRE_DIA'
));

-- 3. Verificar
SELECT 
    'Constraint actualizado' as resultado,
    'CIERRE_DIA ahora es un tipo de transacción válido' as detalle;

-- 4. Ver tipos de transacción permitidos
SELECT 
    constraint_name,
    check_clause
FROM information_schema.check_constraints
WHERE constraint_name = 'transacciones_tipo_transaccion_check';
