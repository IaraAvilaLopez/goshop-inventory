# ✅ VERIFICACIÓN DE REPORTES - GUÍA COMPLETA

## 🎯 CAMBIOS REALIZADOS:

### **1. Cálculo de Fechas Corregido** ✅

**ANTES**: Usaba `new Date(fechaSeleccionada)` que podía causar problemas de zona horaria

**AHORA**: Parsea la fecha correctamente:
```typescript
const partes = fechaSeleccionada.split('-')
const fecha = new Date(parseInt(partes[0]), parseInt(partes[1]) - 1, parseInt(partes[2]))
```

### **2. Indicador Visual de Rango** ✅

Ahora muestra un cuadro verde con el rango de fechas seleccionado:

```
┌─────────────────────────────────────────────────┐
│ Período seleccionado: 02/06/2026 al 08/06/2026 │
└─────────────────────────────────────────────────┘
```

---

## 📊 CÓMO FUNCIONA CADA PERÍODO:

### **📅 DIARIO:**

**Entrada:**
- Seleccionas: `03/06/2026`

**Cálculo:**
- Desde: `03/06/2026`
- Hasta: `03/06/2026`

**Resultado:**
- Muestra solo ventas del 03/06/2026
- NO muestra indicador de rango (es solo un día)

---

### **📈 SEMANAL:**

**Entrada:**
- Seleccionas: `03/06/2026` (Martes)

**Cálculo:**
1. Detecta que es Martes (día 2 de la semana)
2. Calcula el Lunes: `02/06/2026`
3. Calcula el Domingo: `08/06/2026`

**Resultado:**
- Desde: `02/06/2026` (Lunes)
- Hasta: `08/06/2026` (Domingo)
- Muestra indicador: **"Período seleccionado: 02/06/2026 al 08/06/2026"**

**Ejemplo con diferentes días:**
- Si seleccionas `05/06/2026` (Jueves) → Muestra del 02/06 al 08/06
- Si seleccionas `07/06/2026` (Sábado) → Muestra del 02/06 al 08/06
- Si seleccionas `08/06/2026` (Domingo) → Muestra del 02/06 al 08/06

**Siempre muestra la semana completa de Lunes a Domingo.**

---

### **📦 MENSUAL:**

**Entrada:**
- Seleccionas: `03/06/2026`

**Cálculo:**
1. Extrae el mes: Junio (06)
2. Extrae el año: 2026
3. Primer día: `01/06/2026`
4. Último día del mes: `30/06/2026`

**Resultado:**
- Desde: `01/06/2026`
- Hasta: `30/06/2026`
- Muestra indicador: **"Período seleccionado: 01/06/2026 al 30/06/2026"**

**Ejemplo con diferentes meses:**
- Febrero 2026: 01/02/2026 al 28/02/2026 (28 días)
- Marzo 2026: 01/03/2026 al 31/03/2026 (31 días)
- Abril 2026: 01/04/2026 al 30/04/2026 (30 días)

**Calcula automáticamente el último día del mes.**

---

## 🧪 CÓMO PROBAR:

### **OPCIÓN 1: Con Datos Reales**

Si ya tienes ventas en diferentes fechas:

1. **Recarga la app** (F5)
2. **Ve a Reportes**
3. **Prueba cada pestaña:**
   - Diario: Selecciona hoy
   - Semanal: Selecciona hoy (verás la semana completa)
   - Mensual: Selecciona hoy (verás el mes completo)

---

### **OPCIÓN 2: Con Datos de Prueba** (Recomendado)

Para probar con datos en diferentes fechas:

#### **PASO 1: Ver tus productos**
```sql
SELECT id, marca, modelo FROM productos LIMIT 5;
```

Copia los IDs de 3 productos.

#### **PASO 2: Editar el script**

Abre `DATOS_PRUEBA_REPORTES.sql` y reemplaza:
```sql
producto1 UUID := 'ID_PRODUCTO_1'; -- Pega el ID real aquí
producto2 UUID := 'ID_PRODUCTO_2'; -- Pega el ID real aquí
producto3 UUID := 'ID_PRODUCTO_3'; -- Pega el ID real aquí
```

#### **PASO 3: Ejecutar el script**

Ejecuta `DATOS_PRUEBA_REPORTES.sql` en Supabase.

Esto insertará ventas en diferentes fechas de Junio 2026.

#### **PASO 4: Probar en la app**

**A. Reporte DIARIO:**
1. Click en **"Diario"**
2. Selecciona: **03/06/2026**
3. **Resultado esperado:**
   - Total Unidades: 3
   - Solo muestra ventas del 03/06

**B. Reporte SEMANAL:**
1. Click en **"Semanal"**
2. Selecciona: **03/06/2026**
3. **Resultado esperado:**
   - Indicador verde: "Período seleccionado: 02/06/2026 al 08/06/2026"
   - Total Unidades: 12 (2+3+1+4+2)
   - Ventas por Día muestra:
     - 02/06: 2 unidades
     - 03/06: 3 unidades
     - 04/06: 1 unidad
     - 05/06: 4 unidades
     - 06/06: 2 unidades

**C. Reporte MENSUAL:**
1. Click en **"Mensual"**
2. Selecciona: **03/06/2026**
3. **Resultado esperado:**
   - Indicador verde: "Período seleccionado: 01/06/2026 al 30/06/2026"
   - Total Unidades: 29 (suma de todas las ventas de junio)
   - Muestra todos los días con ventas del mes

---

## ✅ CHECKLIST DE VERIFICACIÓN:

### **Diario:**
- [ ] Selecciono un día y solo muestra ese día
- [ ] NO muestra indicador de rango
- [ ] Total de unidades es correcto

### **Semanal:**
- [ ] Selecciono cualquier día y muestra la semana completa (Lunes-Domingo)
- [ ] Indicador verde muestra el rango correcto
- [ ] Si selecciono diferentes días de la misma semana, muestra el mismo rango
- [ ] Total de unidades suma todos los días de la semana

### **Mensual:**
- [ ] Selecciono cualquier día y muestra el mes completo
- [ ] Indicador verde muestra del día 1 al último día del mes
- [ ] Si selecciono diferentes días del mismo mes, muestra el mismo rango
- [ ] Total de unidades suma todos los días del mes

---

## 🔍 VERIFICACIÓN SQL:

### **Verificar datos de una semana:**
```sql
SELECT 
    fecha_transaccion::date as fecha,
    COUNT(*) as transacciones,
    SUM(cantidad) as total_unidades
FROM transacciones
WHERE tipo_transaccion IN ('VENTA', 'CIERRE_DIA')
AND fecha_transaccion >= '2026-06-02'
AND fecha_transaccion <= '2026-06-08'
GROUP BY fecha_transaccion::date
ORDER BY fecha;
```

### **Verificar datos de un mes:**
```sql
SELECT 
    fecha_transaccion::date as fecha,
    COUNT(*) as transacciones,
    SUM(cantidad) as total_unidades
FROM transacciones
WHERE tipo_transaccion IN ('VENTA', 'CIERRE_DIA')
AND fecha_transaccion >= '2026-06-01'
AND fecha_transaccion < '2026-07-01'
GROUP BY fecha_transaccion::date
ORDER BY fecha;
```

---

## 🚨 SI ALGO NO FUNCIONA:

### **Problema: El indicador de rango no aparece**
**Solución:** Recarga la app con Ctrl+Shift+R

### **Problema: Las fechas no coinciden**
**Solución:** Verifica que ejecutaste el script de datos de prueba correctamente

### **Problema: No muestra ventas**
**Solución:** Verifica que hay transacciones en esas fechas con:
```sql
SELECT * FROM transacciones 
WHERE fecha_transaccion::date = '2026-06-03'
AND tipo_transaccion IN ('VENTA', 'CIERRE_DIA');
```

---

## 📝 RESUMEN:

**DIARIO**: 1 día específico
**SEMANAL**: Lunes a Domingo de la semana seleccionada
**MENSUAL**: Día 1 al último día del mes seleccionado

**Indicador verde**: Muestra el rango exacto que se está consultando (solo en Semanal y Mensual)

**¡Ahora puedes verificar que todo funciona correctamente!** ✅
