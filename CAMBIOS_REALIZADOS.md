# 🔧 Cambios Realizados en GoShop

## ✅ Modificaciones Implementadas

### 1️⃣ **Sistema de Categorías de Productos**

**Antes:** Solo celulares  
**Ahora:** Cualquier tipo de producto

#### Categorías disponibles:
- 📱 **CELULAR** - iPhone, Samsung, etc.
- 🎧 **ACCESORIO** - Fundas, cargadores, cables
- 🎮 **CONSOLA** - PlayStation, Xbox, Nintendo
- 🔊 **AUDIO** - Parlantes JBL, auriculares
- 📦 **OTRO** - Cualquier otro producto

#### Nuevos campos en productos:
- **Categoría**: Obligatorio (dropdown con iconos)
- **Descripción**: Opcional (para productos que no son celulares)
- **Capacidad**: Ahora es opcional (no todos los productos tienen GB)

---

### 2️⃣ **Arreglo de TRANSFERENCIAS**

**Problema:** Las transferencias NO afectaban el stock  
**Solución:** Ahora las transferencias SÍ restan del stock

#### Cómo funciona ahora:

**Operaciones que SUMAN (+):**
- COMPRA
- CANJE_ENTRADA

**Operaciones que RESTAN (-):**
- VENTA
- CANJE_SALIDA
- **TRANSFERENCIA** ← NUEVO

#### Ejemplo de uso:
**Situación:** Transferiste 2 iPhone 13 a otra sucursal

1. Historial → Nueva Transacción
2. Tipo: **Transferencia**
3. Producto: IPHONE 13 128
4. Cantidad: 2
5. Observaciones: "Transferencia a sucursal X"
6. ✅ Stock baja de 10 a 8 automáticamente

---

### 3️⃣ **Formulario Mejorado para Agregar Productos**

**Antes:**
- Solo campos para celulares
- Capacidad obligatoria

**Ahora:**
- Selector de categoría con iconos
- Descripción para productos no-celulares
- Capacidad opcional
- Placeholders más claros

#### Ejemplo: Agregar un Parlante JBL

1. Stock → Nuevo Producto
2. **Categoría**: 🔊 Audio
3. **Marca**: JBL
4. **Modelo**: Flip 6
5. **Color**: Negro (opcional)
6. **Capacidad**: (dejar vacío)
7. **Descripción**: "Parlante Bluetooth resistente al agua"
8. **Cantidad inicial**: 5
9. **Cantidad mínima**: 1
10. ✅ Agregar

#### Ejemplo: Agregar una PlayStation 5

1. Stock → Nuevo Producto
2. **Categoría**: 🎮 Consola
3. **Marca**: PlayStation
4. **Modelo**: 5
5. **Color**: Blanco
6. **Capacidad**: 1T (opcional)
7. **Descripción**: "Consola PS5 con lector de discos"
8. **Cantidad inicial**: 3
9. **Cantidad mínima**: 1
10. ✅ Agregar

---

## 📋 SQL a Ejecutar en Supabase

### Paso 1: Agregar Categorías
```sql
-- Agregar categoría a productos
ALTER TABLE productos 
ADD COLUMN IF NOT EXISTS categoria VARCHAR(50) DEFAULT 'CELULAR' 
CHECK (categoria IN ('CELULAR', 'ACCESORIO', 'CONSOLA', 'AUDIO', 'OTRO'));

-- Hacer capacidad opcional
ALTER TABLE productos 
ALTER COLUMN capacidad_gb DROP NOT NULL;

-- Agregar descripción
ALTER TABLE productos 
ADD COLUMN IF NOT EXISTS descripcion TEXT;

-- Índice para búsquedas
CREATE INDEX IF NOT EXISTS idx_productos_categoria ON productos(categoria);

-- Actualizar productos existentes
UPDATE productos SET categoria = 'CELULAR' WHERE categoria IS NULL;
```

### Paso 2: Arreglar Transferencias
```sql
-- Eliminar trigger y función antiguos
DROP TRIGGER IF EXISTS trigger_actualizar_inventario ON transacciones;
DROP FUNCTION IF EXISTS actualizar_inventario();

-- Crear función mejorada
CREATE OR REPLACE FUNCTION actualizar_inventario()
RETURNS TRIGGER AS $$
BEGIN
    -- Operaciones que SUMAN
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
    
    -- Operaciones que RESTAN (incluye TRANSFERENCIA)
    ELSIF NEW.tipo_transaccion IN ('VENTA', 'CANJE_SALIDA', 'TRANSFERENCIA') THEN
        UPDATE inventario 
        SET cantidad_actual = cantidad_actual - NEW.cantidad,
            updated_at = NOW()
        WHERE producto_id = NEW.producto_id 
        AND ubicacion = NEW.ubicacion
        AND estado = 'DISPONIBLE';
        
        -- Evitar stock negativo
        IF FOUND THEN
            UPDATE inventario 
            SET cantidad_actual = GREATEST(cantidad_actual, 0)
            WHERE producto_id = NEW.producto_id 
            AND ubicacion = NEW.ubicacion
            AND estado = 'DISPONIBLE';
        END IF;
    END IF;
    
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

-- Recrear trigger
CREATE TRIGGER trigger_actualizar_inventario
AFTER INSERT ON transacciones
FOR EACH ROW
EXECUTE FUNCTION actualizar_inventario();
```

---

## 🎯 Casos de Uso Nuevos

### Caso 1: Vender un Parlante JBL
1. Ventas → Seleccionar "JBL Flip 6" → Cantidad 1 → Agregar
2. Al cierre → Procesar
3. ✅ Stock de parlantes baja

### Caso 2: Comprar Consolas
1. Historial → Nueva Transacción
2. Tipo: Compra
3. Producto: PlayStation 5
4. Cantidad: 5
5. ✅ Stock de consolas sube en 5

### Caso 3: Transferir Celulares
1. Historial → Nueva Transacción
2. Tipo: **Transferencia**
3. Producto: IPHONE 15 PRO 256
4. Cantidad: 3
5. Observaciones: "Transferencia a sucursal Corrientes"
6. ✅ Stock baja en 3

### Caso 4: Inventario Mixto
Ahora podés tener en el mismo inventario:
- 50 celulares iPhone
- 20 parlantes JBL
- 5 consolas PlayStation
- 100 fundas (accesorios)

Todo en el mismo sistema, con las mismas alertas y reportes.

---

## ⚠️ IMPORTANTE

### Ejecutar SQL en este orden:
1. **Primero**: `agregar_categorias.sql`
2. **Segundo**: `arreglar_transferencias.sql`
3. **Tercero**: Refresca GoShop (F5)

### Verificar que funcionó:
1. Ve a Stock → Nuevo Producto
2. Deberías ver el selector de categoría
3. Agrega un producto de prueba (ej: Parlante JBL)
4. Verifica que aparece en la tabla

---

## 📊 Beneficios

### Antes:
- ❌ Solo celulares
- ❌ Transferencias no funcionaban
- ❌ Capacidad siempre obligatoria

### Ahora:
- ✅ Cualquier tipo de producto
- ✅ Transferencias funcionan correctamente
- ✅ Flexibilidad total
- ✅ Mismo sistema para todo el inventario

---

## 🎓 Actualización del Manual

### Agregar a la documentación:

**Sección: Agregar Productos**

"GoShop ahora soporta cualquier tipo de producto, no solo celulares:

- **Celulares**: iPhone, Samsung, etc.
- **Accesorios**: Fundas, cargadores, cables
- **Consolas**: PlayStation, Xbox, Nintendo
- **Audio**: Parlantes JBL, auriculares
- **Otros**: Cualquier producto que vendas

Al agregar un producto, selecciona la categoría correcta y completa los campos relevantes. La capacidad y descripción son opcionales."

**Sección: Transferencias**

"Las transferencias ahora descuentan automáticamente del stock. Úsalas cuando:
- Transferís productos a otra sucursal
- Enviás productos a reparación
- Cualquier salida que no sea venta o canje"

---

*Cambios implementados - Mayo 2026*
