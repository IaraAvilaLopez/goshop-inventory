# 🔄 TRANSFERENCIAS ENTRE SUCURSALES

## 🎯 SISTEMA IMPLEMENTADO

### **✅ LO QUE HACE:**

El sistema de transferencias permite **mover stock entre sucursales** de forma automática:
- ✅ Descuenta del stock de origen
- ✅ Agrega al stock de destino
- ✅ Crea 2 transacciones (salida y entrada)
- ✅ Usa fecha/hora local de Argentina (UTC-3)
- ✅ Registra observaciones
- ✅ Validación de stock disponible

---

## 🎨 INTERFAZ

### **Pantalla de Transferencias:**

```
┌────────────────────────────────────────────────┐
│  Transferencias entre Sucursales               │
│  Transfiere productos entre RESISTENCIA y      │
│  CORRIENTES                                    │
├────────────────────────────────────────────────┤
│                                                │
│  ┌──────────────────────────────────────────┐ │
│  │  Origen          ⇄         Destino       │ │
│  │  RESISTENCIA              CORRIENTES     │ │
│  └──────────────────────────────────────────┘ │
│                                                │
│  Producto a Transferir:                        │
│  [SAMSUNG S24 ULTRA 256 - Stock: 10]          │
│                                                │
│  📦 Stock disponible en RESISTENCIA: 10 unid.  │
│                                                │
│  Cantidad a Transferir:                        │
│  [5]                                           │
│                                                │
│  Observaciones (Opcional):                     │
│  [Reposición de stock en Corrientes]          │
│                                                │
│  ⚠️ Importante:                                │
│  • Se descontará del stock de RESISTENCIA     │
│  • Se agregará al stock de CORRIENTES         │
│  • Se crearán 2 transacciones                 │
│  • Esta acción no se puede deshacer           │
│                                                │
│  [⇄ Realizar Transferencia]                   │
│                                                │
└────────────────────────────────────────────────┘
```

---

## 🔄 CÓMO FUNCIONA

### **Flujo Completo:**

```
1. Usuario en RESISTENCIA
   ↓
2. Va a "Transferencias"
   ↓
3. Selecciona producto (ej: Samsung S24)
   ↓
4. Ingresa cantidad (ej: 5 unidades)
   ↓
5. Agrega observaciones (opcional)
   ↓
6. Click "Realizar Transferencia"
   ↓
7. Confirmación
   ↓
8. SISTEMA EJECUTA:
   
   A. Crea transacción SALIDA en RESISTENCIA
      - Tipo: TRANSFERENCIA
      - Cantidad: -5
      - Observaciones: "Transferencia a CORRIENTES"
   
   B. Descuenta stock de RESISTENCIA
      - Stock anterior: 10
      - Stock nuevo: 5
   
   C. Crea transacción ENTRADA en CORRIENTES
      - Tipo: TRANSFERENCIA
      - Cantidad: +5
      - Observaciones: "Transferencia desde RESISTENCIA"
   
   D. Agrega stock a CORRIENTES
      - Stock anterior: 0
      - Stock nuevo: 5
   
   ↓
9. ✅ Transferencia completada
```

---

## 📊 EJEMPLO PRÁCTICO

### **Escenario: Enviar stock de Resistencia a Corrientes**

**Estado Inicial:**
```
RESISTENCIA:
- Samsung S24 Ultra 256: 10 unidades

CORRIENTES:
- Samsung S24 Ultra 256: 0 unidades
```

**Transferencia:**
```
Origen: RESISTENCIA
Destino: CORRIENTES
Producto: Samsung S24 Ultra 256
Cantidad: 5 unidades
Observaciones: "Reposición inicial"
```

**Estado Final:**
```
RESISTENCIA:
- Samsung S24 Ultra 256: 5 unidades ✅ (-5)

CORRIENTES:
- Samsung S24 Ultra 256: 5 unidades ✅ (+5)
```

**Transacciones Creadas:**

1. **En RESISTENCIA:**
   ```
   Tipo: TRANSFERENCIA
   Cantidad: 5
   Fecha: 08/06/2026 12:30:00
   Observaciones: "Transferencia a CORRIENTES - Reposición inicial"
   Ubicación: RESISTENCIA
   ```

2. **En CORRIENTES:**
   ```
   Tipo: TRANSFERENCIA
   Cantidad: 5
   Fecha: 08/06/2026 12:30:00
   Observaciones: "Transferencia desde RESISTENCIA - Reposición inicial"
   Ubicación: CORRIENTES
   ```

---

## ✅ VALIDACIONES

### **El sistema valida:**

1. ✅ **Producto seleccionado**: No puede estar vacío
2. ✅ **Cantidad mayor a 0**: Debe ser al menos 1
3. ✅ **Stock suficiente**: No puede transferir más de lo disponible
4. ✅ **Confirmación**: Pide confirmación antes de ejecutar
5. ✅ **Sucursal válida**: Origen y destino deben ser diferentes

### **Mensajes de Error:**

```
❌ Selecciona un producto
❌ La cantidad debe ser mayor a 0
❌ Stock insuficiente. Disponible: 10
❌ Error al realizar transferencia: [detalle]
```

### **Mensaje de Éxito:**

```
✅ Transferencia realizada exitosamente

5 unidad(es) transferidas de RESISTENCIA a CORRIENTES
```

---

## 🗄️ BASE DE DATOS

### **Transacciones Creadas:**

```sql
-- Transacción de SALIDA (origen)
INSERT INTO transacciones (
  producto_id,
  tipo_transaccion,
  cantidad,
  precio_unitario,
  precio_total,
  fecha_transaccion,
  observaciones,
  ubicacion
) VALUES (
  'uuid-producto',
  'TRANSFERENCIA',
  5,
  0,
  0,
  '2026-06-08T12:30:00',
  'Transferencia a CORRIENTES - Reposición inicial',
  'RESISTENCIA'
);

-- Transacción de ENTRADA (destino)
INSERT INTO transacciones (
  producto_id,
  tipo_transaccion,
  cantidad,
  precio_unitario,
  precio_total,
  fecha_transaccion,
  observaciones,
  ubicacion
) VALUES (
  'uuid-producto',
  'TRANSFERENCIA',
  5,
  0,
  0,
  '2026-06-08T12:30:00',
  'Transferencia desde RESISTENCIA - Reposición inicial',
  'CORRIENTES'
);
```

### **Ajuste de Stock:**

```sql
-- Descontar de origen
UPDATE inventario 
SET cantidad_actual = cantidad_actual - 5
WHERE producto_id = 'uuid-producto' 
AND ubicacion = 'RESISTENCIA';

-- Agregar a destino
UPDATE inventario 
SET cantidad_actual = cantidad_actual + 5
WHERE producto_id = 'uuid-producto' 
AND ubicacion = 'CORRIENTES';
```

---

## 📱 USO DESDE CADA SUCURSAL

### **Desde RESISTENCIA:**

```
Origen: RESISTENCIA (automático)
Destino: CORRIENTES (automático)

Productos disponibles:
- Solo productos con stock > 0 en RESISTENCIA
```

### **Desde CORRIENTES:**

```
Origen: CORRIENTES (automático)
Destino: RESISTENCIA (automático)

Productos disponibles:
- Solo productos con stock > 0 en CORRIENTES
```

**El origen siempre es la sucursal actual.**

---

## 🎯 CASOS DE USO

### **1. Reposición de Stock**
```
Situación: Corrientes necesita stock
Acción: Transferir desde Resistencia
Resultado: Corrientes tiene stock para vender
```

### **2. Redistribución**
```
Situación: Resistencia tiene exceso de stock
Acción: Transferir a Corrientes
Resultado: Stock balanceado entre sucursales
```

### **3. Devolución**
```
Situación: Corrientes no vendió ciertos productos
Acción: Transferir de vuelta a Resistencia
Resultado: Stock consolidado en Resistencia
```

### **4. Pedido Especial**
```
Situación: Cliente en Corrientes pide producto que no hay
Acción: Transferir desde Resistencia
Resultado: Producto disponible para venta en Corrientes
```

---

## 📊 HISTORIAL DE TRANSFERENCIAS

### **Ver en Historial:**

Las transferencias aparecen en el **Historial de Transacciones** de cada sucursal:

**En RESISTENCIA:**
```
Fecha: 08/06/2026 12:30
Tipo: TRANSFERENCIA
Producto: Samsung S24 Ultra 256
Cantidad: 5
Observaciones: Transferencia a CORRIENTES - Reposición inicial
```

**En CORRIENTES:**
```
Fecha: 08/06/2026 12:30
Tipo: TRANSFERENCIA
Producto: Samsung S24 Ultra 256
Cantidad: 5
Observaciones: Transferencia desde RESISTENCIA - Reposición inicial
```

---

## ⚠️ IMPORTANTE

### **NO SE PUEDE DESHACER AUTOMÁTICAMENTE:**

Si te equivocas, debes hacer una **transferencia inversa**:

```
Error: Transferiste 10 en lugar de 5

Solución:
1. Hacer transferencia inversa de 5 unidades
2. Esto devolverá el exceso
```

### **STOCK DEBE EXISTIR:**

- ✅ Solo puedes transferir productos que **ya existen** en el inventario de destino
- ✅ Si el producto no existe en destino, primero debes agregarlo (con stock 0)

### **FECHA Y HORA:**

- ✅ Usa hora local de Argentina (UTC-3)
- ✅ Ambas transacciones tienen la misma fecha/hora
- ✅ Permite rastrear transferencias relacionadas

---

## 🔍 VERIFICACIÓN

### **Verificar Transferencia:**

```sql
-- Ver últimas transferencias
SELECT 
    t.fecha_transaccion,
    p.marca,
    p.modelo,
    t.cantidad,
    t.ubicacion,
    t.observaciones
FROM transacciones t
JOIN productos p ON t.producto_id = p.id
WHERE t.tipo_transaccion = 'TRANSFERENCIA'
ORDER BY t.fecha_transaccion DESC
LIMIT 10;

-- Ver stock actual por sucursal
SELECT 
    p.marca,
    p.modelo,
    i.ubicacion,
    i.cantidad_actual
FROM inventario i
JOIN productos p ON i.producto_id = p.id
WHERE p.modelo = 'S24 ULTRA'
ORDER BY i.ubicacion;
```

---

## 🎨 CARACTERÍSTICAS DE LA INTERFAZ

### **Indicador Visual:**
```
┌────────────────────────────────┐
│  Origen      ⇄      Destino    │
│  RESISTENCIA      CORRIENTES   │
└────────────────────────────────┘
```

### **Stock Disponible:**
```
📦 Stock disponible en RESISTENCIA: 10 unidades
```

### **Advertencia:**
```
⚠️ Importante:
• Se descontará del stock de RESISTENCIA
• Se agregará al stock de CORRIENTES
• Se crearán 2 transacciones
• Esta acción no se puede deshacer automáticamente
```

### **Estado de Procesamiento:**
```
[⚙️ Procesando transferencia...]
```

---

## 📄 ARCHIVOS CREADOS

1. ✅ `Transferencias.tsx` - Componente principal
2. ✅ `TRANSFERENCIAS_ENTRE_SUCURSALES.md` - Esta documentación

**Modificados:**
- ✅ `App.tsx` - Agregada opción de menú

---

## ✅ CHECKLIST DE VERIFICACIÓN

- [ ] Recargar app (F5)
- [ ] Ir a "Transferencias" en el menú
- [ ] Seleccionar producto con stock
- [ ] Ingresar cantidad válida
- [ ] Agregar observaciones
- [ ] Confirmar transferencia
- [ ] Verificar que stock se descontó de origen
- [ ] Cambiar a otra sucursal
- [ ] Verificar que stock se agregó a destino
- [ ] Ver historial en ambas sucursales
- [ ] Verificar que aparecen 2 transacciones

---

## 🎉 RESULTADO FINAL

**Sistema completo de transferencias que:**
- ✅ Descuenta automáticamente de origen
- ✅ Agrega automáticamente a destino
- ✅ Crea 2 transacciones relacionadas
- ✅ Valida stock disponible
- ✅ Usa fecha/hora correcta (Argentina UTC-3)
- ✅ Registra observaciones
- ✅ Interfaz clara y fácil de usar
- ✅ Funciona desde cualquier sucursal

**¡Recarga la app (F5) y prueba las transferencias!** 🚀
