# 🔄 CÓMO HACER TRANSFERENCIAS ENTRE SUCURSALES

## 📍 IMPORTANTE: Corrientes Empieza Vacío

**Corrientes NO tiene productos** porque no sabemos qué hay en esa sucursal.
Los chicos de Corrientes deben **cargar manualmente** los productos en Stock.

---

## 🔧 PASO 1: LIMPIAR CORRIENTES (Ejecutar una sola vez)

```sql
-- Ejecuta este script en Supabase para eliminar todos los productos de Corrientes
-- Archivo: LIMPIAR_CORRIENTES.sql

DELETE FROM inventario 
WHERE ubicacion = 'CORRIENTES';
```

**Resultado:**
- ✅ Resistencia: 32 productos con stock
- ✅ Corrientes: 0 productos (vacío)

---

## 📦 CÓMO CARGAR PRODUCTOS EN CORRIENTES

### **Opción 1: Agregar Manualmente en Stock**

1. **Selecciona Corrientes**
2. **Ve a Stock**
3. **Click "Agregar Producto"**
4. **Llena el formulario:**
   - Marca: SAMSUNG
   - Modelo: S24 ULTRA
   - Capacidad: 256
   - Cantidad Inicial: 10
   - Stock Mínimo: 3
5. **Guardar**

✅ El producto se agrega solo a Corrientes

---

### **Opción 2: Registrar Compra**

1. **Selecciona Corrientes**
2. **Ve a Historial**
3. **Click "Nueva Transacción"**
4. **Tipo: COMPRA**
5. **Producto: Escribe o selecciona**
6. **Cantidad: 10**
7. **Guardar**

✅ El producto se agrega al inventario de Corrientes

---

## 🔄 CÓMO HACER TRANSFERENCIAS

### **De Resistencia → Corrientes:**

1. **Selecciona Resistencia**
2. **Ve a Historial**
3. **Click "Nueva Transacción"**
4. **Tipo: TRANSFERENCIA**
5. **Producto: SAMSUNG S24 ULTRA 256**
6. **Cantidad: 5**
7. **Observaciones: "Envío a Corrientes"**
8. **Guardar**

**¿Qué pasa?**
```
ANTES:
Resistencia: 10 unidades
Corrientes: 0 unidades

DESPUÉS:
Resistencia: 5 unidades ✅ (se descontó)
Corrientes: 5 unidades ✅ (se agregó)
```

**Transacciones creadas:**
- ✅ En Resistencia: TRANSFERENCIA -5 unidades
- ✅ En Corrientes: TRANSFERENCIA +5 unidades (automático)

---

### **De Corrientes → Resistencia:**

1. **Selecciona Corrientes**
2. **Ve a Historial**
3. **Click "Nueva Transacción"**
4. **Tipo: TRANSFERENCIA**
5. **Producto: SAMSUNG S24 ULTRA 256**
6. **Cantidad: 3**
7. **Observaciones: "Devolución a Resistencia"**
8. **Guardar**

**¿Qué pasa?**
```
ANTES:
Corrientes: 5 unidades
Resistencia: 5 unidades

DESPUÉS:
Corrientes: 2 unidades ✅ (se descontó)
Resistencia: 8 unidades ✅ (se agregó)
```

---

## ⚙️ CÓMO FUNCIONA TÉCNICAMENTE

### **Trigger Automático:**

Cuando registras una TRANSFERENCIA:

```sql
-- 1. Se crea la transacción en la sucursal actual
INSERT INTO transacciones (
  producto_id, 
  tipo_transaccion, 
  cantidad, 
  ubicacion
) VALUES (
  'uuid-producto',
  'TRANSFERENCIA',
  5,
  'RESISTENCIA'  -- Sucursal actual
);

-- 2. El trigger actualizar_inventario se ejecuta automáticamente
-- y descuenta el stock de Resistencia

-- 3. El trigger también crea una transacción en la otra sucursal
-- y agrega el stock a Corrientes
```

### **Resultado:**
- ✅ Stock se descuenta de origen
- ✅ Stock se agrega a destino
- ✅ 2 transacciones creadas (una en cada sucursal)

---

## 📊 VERIFICAR TRANSFERENCIAS

### **En Resistencia:**

**Historial → Filtrar por TRANSFERENCIA**

Verás:
```
Fecha: 08/06/2026 12:30
Tipo: TRANSFERENCIA
Producto: Samsung S24 Ultra 256
Cantidad: 5
Observaciones: Envío a Corrientes
```

### **En Corrientes:**

**Historial → Filtrar por TRANSFERENCIA**

Verás:
```
Fecha: 08/06/2026 12:30
Tipo: TRANSFERENCIA
Producto: Samsung S24 Ultra 256
Cantidad: 5
Observaciones: Desde Resistencia
```

---

## ⚠️ IMPORTANTE

### **Corrientes Empieza Vacío:**
- ❌ NO tiene productos al inicio
- ✅ Los chicos deben cargar manualmente
- ✅ O recibir transferencias de Resistencia

### **Productos Compartidos:**
- ✅ Los productos son los mismos en ambas sucursales
- ✅ Solo el stock es diferente

### **Stock Independiente:**
- ✅ Cada sucursal tiene su propio stock
- ✅ Las transferencias mueven stock entre sucursales

---

## ✅ CHECKLIST

- [ ] Ejecutar `LIMPIAR_CORRIENTES.sql` en Supabase
- [ ] Verificar que Corrientes está vacío
- [ ] Recargar la app (F5)
- [ ] Seleccionar Corrientes → Stock debe estar vacío
- [ ] Agregar un producto manualmente en Corrientes
- [ ] Verificar que aparece en Stock de Corrientes
- [ ] Hacer una transferencia de Resistencia a Corrientes
- [ ] Verificar que stock se descuenta de Resistencia
- [ ] Verificar que stock se agrega a Corrientes
- [ ] Ver historial en ambas sucursales

---

## 🚀 RESUMEN

**Corrientes:**
- ✅ Empieza vacío (sin productos)
- ✅ Cargar manualmente en Stock
- ✅ O recibir transferencias

**Transferencias:**
- ✅ Se hacen desde "Nueva Transacción"
- ✅ Tipo: TRANSFERENCIA
- ✅ Descuenta de origen automáticamente
- ✅ Agrega a destino automáticamente

**¡Ejecuta LIMPIAR_CORRIENTES.sql y recarga la app!** 🎉
