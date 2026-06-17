# 📦 FLUJO COMPLETO DE GESTIÓN DE STOCK

## 🔄 CÓMO FUNCIONA EL SISTEMA

### **1. TRANSACCIONES QUE SUMAN STOCK (+)**

| Tipo | Cuándo se usa | Ejemplo | Efecto en Stock |
|------|---------------|---------|-----------------|
| **COMPRA** | Compras productos nuevos | Compraste 10 iPhones | Stock: +10 |
| **TRANSFERENCIA** | Recibes productos de otra sucursal | Te enviaron 5 Samsung | Stock: +5 |
| **CANJE_ENTRADA** | Cliente te da un producto usado | Cliente canjea su iPhone viejo | Stock: +1 |

**Trigger automático**: Cuando insertas una transacción de estos tipos, el trigger `actualizar_inventario()` SUMA la cantidad al stock.

---

### **2. TRANSACCIONES QUE RESTAN STOCK (-)**

| Tipo | Cuándo se usa | Ejemplo | Efecto en Stock |
|------|---------------|---------|-----------------|
| **VENTA** | Vendes un producto directamente | Vendiste 1 iPhone | Stock: -1 |
| **CANJE_SALIDA** | Entregas un producto en canje | Entregaste 1 Samsung nuevo | Stock: -1 |
| **CIERRE_DIA** | Procesas ventas pendientes del día | Cierre con 3 ventas | Stock: -3 |

**Trigger automático**: Cuando insertas una transacción de estos tipos, el trigger `actualizar_inventario()` RESTA la cantidad del stock.

---

### **3. FLUJO DE VENTAS DIARIAS**

#### **Paso 1: Registrar Venta**
```
Usuario → Ventas → Agrega venta
↓
Se crea registro en: ventas_pendientes
- producto_id
- cantidad
- fecha
- procesada: false
- comentarios (opcional)
↓
Stock: NO SE MODIFICA (todavía)
```

#### **Paso 2: Cierre de Día**
```
Usuario → Cierre de Día → Procesar Cierre
↓
Por cada venta pendiente:
  - Se crea transacción tipo CIERRE_DIA
  - Trigger actualizar_inventario() se ejecuta
  - Stock se descuenta automáticamente
  - Venta se marca como procesada: true
↓
Se crea registro en: cierres_dia
```

#### **Paso 3: Resultado**
```
- Stock actualizado ✅
- Ventas procesadas ✅
- Transacciones registradas en historial ✅
- Reportes actualizados ✅
```

---

### **4. ELIMINAR TRANSACCIONES**

Cuando eliminas una transacción desde el Historial:

```typescript
// El código en Transacciones.tsx hace:

// Si era ENTRADA (sumaba stock), ahora RESTAR
if (['COMPRA', 'CANJE_ENTRADA', 'TRANSFERENCIA'].includes(tipo)) {
  ajustar_stock(producto_id, ubicacion, -cantidad)  // Resta
}

// Si era SALIDA (restaba stock), ahora SUMAR
if (['VENTA', 'CANJE_SALIDA', 'CIERRE_DIA'].includes(tipo)) {
  ajustar_stock(producto_id, ubicacion, +cantidad)  // Suma
}
```

**Resultado**: El stock vuelve al estado anterior a la transacción.

---

### **5. RESETEAR CIERRE DE DÍA**

#### **Opción A: Script RESETEAR_DIA_COMPLETO.sql** ✅
```sql
1. Busca ventas procesadas del día
2. Por cada venta: SUMA la cantidad al stock
3. Elimina el cierre
4. Marca ventas como no procesadas
5. Elimina transacciones CIERRE_DIA
```

**Resultado**: Todo vuelve al estado antes del cierre.

#### **Opción B: Botón "Reiniciar Cierre"** ⚠️
```typescript
1. Elimina el cierre
2. Marca ventas como no procesadas
3. Elimina transacciones CIERRE_DIA
4. Stock NO se restaura (queda como está)
```

**Resultado**: Puedes reprocesar, pero debes ajustar stock manualmente.

---

## ✅ VERIFICACIÓN DEL SISTEMA

### **Scripts a ejecutar EN ORDEN:**

1. **`AGREGAR_CIERRE_DIA_CONSTRAINT.sql`**
   - Agrega CIERRE_DIA como tipo de transacción válido

2. **`CORREGIR_TRIGGER_CIERRE_DIA.sql`**
   - Actualiza el trigger para que CIERRE_DIA descuente stock

3. **`agregar_comentarios_ventas.sql`**
   - Agrega campo de comentarios a ventas

4. **`corregir_fechas_ventas.sql`**
   - Corrige fechas de ventas existentes

### **Para pruebas:**

5. **`RESETEAR_DIA_COMPLETO.sql`**
   - Resetea cierre y restaura stock

6. **`eliminar_productos_prueba_final.sql`**
   - Elimina productos de prueba (AAA, EEE, etc.)

---

## 🎯 RESUMEN EJECUTIVO

### **¿El stock se actualiza automáticamente?**

| Acción | Stock se actualiza | Cuándo |
|--------|-------------------|--------|
| Crear COMPRA | ✅ Sí (+) | Al insertar transacción |
| Crear TRANSFERENCIA | ✅ Sí (+) | Al insertar transacción |
| Crear VENTA directa | ✅ Sí (-) | Al insertar transacción |
| Agregar venta pendiente | ❌ No | Se espera al cierre |
| **Procesar cierre** | ✅ **Sí (-)** | Al crear CIERRE_DIA |
| Eliminar transacción | ✅ Sí (reversa) | Al eliminar |

### **¿Qué hace cada componente?**

- **Ventas**: Registra ventas pendientes (NO modifica stock)
- **Cierre de Día**: Procesa ventas pendientes (SÍ modifica stock)
- **Transacciones**: Crea transacciones directas (SÍ modifica stock)
- **Historial**: Muestra y permite eliminar (reversa el stock)

---

## 🚨 PROBLEMAS ENCONTRADOS Y SOLUCIONADOS

### **Problema 1: CIERRE_DIA no descontaba stock** ❌
**Causa**: El trigger no incluía CIERRE_DIA en la lista de operaciones que restan stock.
**Solución**: Script `CORREGIR_TRIGGER_CIERRE_DIA.sql`

### **Problema 2: Fechas incorrectas en reportes** ❌
**Causa**: Uso de UTC en lugar de hora local de Argentina.
**Solución**: Modificado `Reportes.tsx` para usar fecha local.

### **Problema 3: Hora incorrecta en CIERRE_DIA** ❌
**Causa**: Hora hardcodeada a 21:00:00.
**Solución**: Modificado `CierreDiaNuevo.tsx` para usar hora actual.

### **Problema 4: Sin campo de comentarios** ❌
**Causa**: No existía la columna en la base de datos.
**Solución**: Script `agregar_comentarios_ventas.sql`

---

## ✅ ESTADO ACTUAL

Después de ejecutar los scripts de corrección:

- ✅ CIERRE_DIA descuenta stock automáticamente
- ✅ Fechas y horas correctas (Argentina UTC-3)
- ✅ Comentarios en ventas
- ✅ Reportes funcionando correctamente
- ✅ Alertas de stock bajo
- ✅ Eliminación de transacciones revierte stock
- ✅ Reseteo de cierre restaura stock

**El sistema está completamente funcional.** 🎉
