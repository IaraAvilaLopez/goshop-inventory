# 🔄 CÓMO FUNCIONAN LAS TRANSFERENCIAS

## 📍 REGLA PRINCIPAL

**Las transferencias muestran el stock de la OTRA sucursal (origen de la transferencia)**

---

## 🏢 DESDE CORRIENTES

### **Cuando estás en CORRIENTES:**

```
┌─────────────────────────────────────────┐
│ Sucursal Actual: CORRIENTES             │
│                                         │
│ Nueva Transacción                       │
│ Tipo: Transferencia                     │
│                                         │
│ ┌─────────────────────────────────────┐ │
│ │ Transferir desde: RESISTENCIA →     │ │
│ │ Hacia: CORRIENTES                   │ │
│ └─────────────────────────────────────┘ │
│                                         │
│ Producto: [Dropdown]                    │
│ ┌─────────────────────────────────────┐ │
│ │ SAMSUNG A26 128 (5 unidades)        │ │
│ │ SAMSUNG S24 ULTRA 256 (3 unidades)  │ │
│ │ SAMSUNG S25 ULTRA 256 (2 unidades)  │ │
│ │ SAMSUNG S26 ULTRA 256 (2 unidades)  │ │ ← DEBE APARECER
│ │ IPHONE 11 PRO MAX 256 (1 unidad)    │ │
│ │ IPHONE 13 PRO 128 (1 unidad)        │ │
│ │ ... TODOS los de RESISTENCIA ...    │ │
│ └─────────────────────────────────────┘ │
└─────────────────────────────────────────┘
```

**Muestra:** TODO el stock de RESISTENCIA  
**Resultado:** Descuenta de RESISTENCIA, Agrega a CORRIENTES

---

## 🏢 DESDE RESISTENCIA

### **Cuando estás en RESISTENCIA:**

```
┌─────────────────────────────────────────┐
│ Sucursal Actual: RESISTENCIA            │
│                                         │
│ Nueva Transacción                       │
│ Tipo: Transferencia                     │
│                                         │
│ ┌─────────────────────────────────────┐ │
│ │ Transferir desde: CORRIENTES →      │ │
│ │ Hacia: RESISTENCIA                  │ │
│ └─────────────────────────────────────┘ │
│                                         │
│ Producto: [Dropdown]                    │
│ ┌─────────────────────────────────────┐ │
│ │ IPHONE 13 PRO 128 (1 unidad)        │ │
│ │ SAMSUNG S24 ULTRA 256 (3 unidades)  │ │
│ │ ... TODOS los de CORRIENTES ...     │ │
│ └─────────────────────────────────────┘ │
└─────────────────────────────────────────┘
```

**Muestra:** TODO el stock de CORRIENTES  
**Resultado:** Descuenta de CORRIENTES, Agrega a RESISTENCIA

---

## ✅ VERIFICACIÓN

### **Script: ASEGURAR_STOCK_TRANSFERENCIAS.sql**

Ejecuta este script para verificar que:

1. ✅ Todos los productos de RESISTENCIA aparecen en el dropdown de CORRIENTES
2. ✅ Todos los productos de CORRIENTES aparecen en el dropdown de RESISTENCIA
3. ✅ No faltan productos en la vista `vista_stock_actual`

---

## 🔍 DIAGNÓSTICO

Si un producto NO aparece en el dropdown:

### **Posibles causas:**

1. ❌ El producto no está en `vista_stock_actual`
2. ❌ El producto tiene `cantidad_actual = 0`
3. ❌ El producto tiene `estado != 'DISPONIBLE'`
4. ❌ Hay un problema de mayúsculas/minúsculas

### **Solución:**

```sql
-- Ver productos que faltan
SELECT 
    i.ubicacion,
    p.marca,
    p.modelo,
    i.cantidad_actual,
    i.estado
FROM inventario i
JOIN productos p ON i.producto_id = p.id
WHERE i.cantidad_actual > 0
AND i.estado = 'DISPONIBLE'
AND NOT EXISTS (
    SELECT 1 FROM vista_stock_actual v
    WHERE v.producto_id = i.producto_id
    AND v.ubicacion = i.ubicacion
);
```

---

## 📊 EJEMPLO COMPLETO

### **Estado Inicial:**

```
RESISTENCIA:
- SAMSUNG S26 ULTRA 256: 2 unidades
- IPHONE 13 PRO 128: 1 unidad

CORRIENTES:
- SAMSUNG S24 ULTRA 256: 3 unidades
```

### **Transferencia 1: Desde Corrientes**

```
Estás en: CORRIENTES
Dropdown muestra: Productos de RESISTENCIA
  - SAMSUNG S26 ULTRA 256 (2 unidades) ✅
  - IPHONE 13 PRO 128 (1 unidad) ✅

Seleccionas: SAMSUNG S26 ULTRA 256
Cantidad: 1

Resultado:
RESISTENCIA: 2 → 1 unidad ✅
CORRIENTES: 0 → 1 unidad ✅
```

### **Transferencia 2: Desde Resistencia**

```
Estás en: RESISTENCIA
Dropdown muestra: Productos de CORRIENTES
  - SAMSUNG S24 ULTRA 256 (3 unidades) ✅
  - SAMSUNG S26 ULTRA 256 (1 unidad) ✅ (recién transferido)

Seleccionas: SAMSUNG S24 ULTRA 256
Cantidad: 2

Resultado:
CORRIENTES: 3 → 1 unidad ✅
RESISTENCIA: 0 → 2 unidades ✅
```

---

## 🚀 PASOS PARA VERIFICAR

1. **Ejecuta:** `ASEGURAR_STOCK_TRANSFERENCIAS.sql`
2. **Verifica:** Que todos los productos aparezcan
3. **Recarga:** La app (F5)
4. **Prueba:** Transferencias en ambas direcciones

---

## ✅ CHECKLIST

- [ ] Todos los productos de RESISTENCIA aparecen en dropdown de CORRIENTES
- [ ] Todos los productos de CORRIENTES aparecen en dropdown de RESISTENCIA
- [ ] No hay productos faltantes en `vista_stock_actual`
- [ ] Las transferencias descuentan de origen correctamente
- [ ] Las transferencias agregan a destino correctamente
- [ ] El historial muestra las transferencias en ambas sucursales

---

**¡Ejecuta el script y verifica que TODO el stock aparezca correctamente!** 🎯✨
