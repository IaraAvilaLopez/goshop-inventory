# 📱 GoShop - Guía Rápida con Imágenes

## 🎯 7 Pantallas Principales

---

## 1️⃣ INICIO - Vista General
**[ADJUNTAR CAPTURA DE PANTALLA DEL DASHBOARD]**

### Lo que ves:
- 📊 **4 Tarjetas**: Total Productos, Stock Crítico, Total Unidades, Alertas
- 📋 **Tabla**: Lista completa de productos con stock

### Lo que haces:
✅ Ver estado general del negocio  
✅ Identificar problemas de stock rápidamente

---

## 2️⃣ STOCK - Inventario Completo
**[ADJUNTAR CAPTURA DE PANTALLA DE STOCK]**

### Lo que ves:
- 🔍 **Buscador** + Filtros (Marca, Capacidad)
- 📋 **Tabla**: Marca, Modelo, Color, Capacidad, Stock, Mínimo, Estado, Acciones
- ➕ **Botón "Nuevo Producto"**

### Lo que haces:
✅ Buscar productos  
✅ Filtrar por marca o capacidad  
✅ Agregar productos nuevos  
✅ Eliminar productos  
✅ Ver niveles de stock (🟢 Normal, 🟡 Bajo, 🔴 Crítico)

---

## 3️⃣ VENTAS - Registro Diario
**[ADJUNTAR CAPTURA DE PANTALLA DE VENTAS]**

### Lo que ves:
- 📝 **Formulario**: Producto + Cantidad + Botón "Agregar"
- 📋 **Tabla "Ventas Pendientes"**: Todas las ventas del día
- ℹ️ **Instrucciones**: Cómo funciona el sistema

### Lo que haces:
✅ Registrar cada venta (10 segundos)  
✅ Ver ventas del día  
✅ Eliminar si te equivocaste

**IMPORTANTE**: El stock NO se descuenta aquí, se descuenta en el Cierre.

---

## 4️⃣ CIERRE - Cierre de Día
**[ADJUNTAR CAPTURA DE PANTALLA DE CIERRE]**

### Lo que ves:
- 📅 **Fecha del cierre**
- 📋 **Tabla "Ventas del Día"**: Se cargan automáticamente desde "Ventas"
- ➕ **Botón "Agregar Venta"**: Por si olvidaste alguna
- 📝 **Observaciones**: Notas del día
- ✅ **Botón "Procesar Cierre"**

### Lo que haces:
✅ Al final del día, procesar el cierre  
✅ Stock se descuenta AUTOMÁTICAMENTE  
✅ Ventas quedan guardadas en historial

**Flujo:**
1. Verificar ventas del día
2. Agregar observaciones (opcional)
3. Clic "Procesar Cierre"
4. ✅ Listo

---

## 5️⃣ REPORTES - Estadísticas
**[ADJUNTAR CAPTURA DE PANTALLA DE REPORTES]**

### Lo que ves:
- 📅 **Filtros de fecha**: Desde / Hasta
- 📊 **3 Métricas**: Total Ventas ($), Unidades Vendidas, Promedio/Día
- 📈 **Gráfico "Ventas por Día"**: Barras verdes mostrando ventas diarias
- 🏆 **Top 10 "Productos Más Vendidos"**: Ranking numerado

### Lo que haces:
✅ Ver ventas de cualquier período  
✅ Identificar productos más vendidos  
✅ Saber qué días vendés más  
✅ Tomar decisiones de compra

**Ejemplo:**
- Seleccionar "Último mes"
- Ver que iPhone 13 128GB es el #1
- **Decisión**: Comprar más iPhone 13 128GB

---

## 6️⃣ HISTORIAL - Todas las Transacciones
**[ADJUNTAR CAPTURA DE PANTALLA DE HISTORIAL]**

### Lo que ves:
- 🔍 **Filtros**: Tipo (Compra/Venta/Canje), Desde, Hasta
- 📋 **Tabla**: Fecha, Producto, Tipo, Cantidad, Precio, Observaciones
- ➕ **Botón "Nueva Transacción"**

### Lo que haces:
✅ Ver todas las ventas  
✅ Ver todas las compras  
✅ Registrar compras de stock  
✅ Registrar canjes  
✅ Filtrar por fecha o tipo

**Ejemplo - Registrar compra:**
1. Clic "Nueva Transacción"
2. Tipo: "Compra"
3. Producto: "IPHONE 15 PRO 256"
4. Cantidad: 10
5. Precio: (lo que pagaste)
6. ✅ Stock sube en 10 automáticamente

---

## 7️⃣ ALERTAS - Stock Bajo
**[ADJUNTAR CAPTURA DE PANTALLA DE ALERTAS]**

### Lo que ves:
- 🚨 **Tabla de Alertas**: Producto, Stock Actual, Mínimo, Fecha, Acciones
- ✅ **Mensaje**: "No hay alertas" cuando todo está bien

### Lo que haces:
✅ Ver qué productos están por agotarse  
✅ Resolver alertas cuando reponés stock

**Se generan AUTOMÁTICAMENTE** cuando el stock llega al mínimo.

---

## 📋 FLUJO DIARIO COMPLETO

### 🌅 Mañana:
1. Abrir GoShop
2. Ver "Inicio" → Estado general
3. Ver "Alertas" → ¿Hay que reponer algo?

### 💼 Durante el día (cada venta):
**Cliente compra iPhone 13:**
1. "Ventas" → Seleccionar producto → Cantidad → "Agregar"
2. ✅ Listo (10 segundos)

### 🌙 Noche (cierre):
1. "Cierre" → Verificar ventas → "Procesar Cierre"
2. ✅ Stock actualizado automáticamente

### 📊 Fin de semana/mes:
1. "Reportes" → Seleccionar período
2. Ver qué se vendió más
3. **Decidir qué comprar**

---

## 🎯 CASOS DE USO CON EJEMPLOS

### Ejemplo 1: Venta Simple
**Situación**: Vendiste 1 iPhone 15 PRO 256GB

**Pasos:**
1. Ventas → IPHONE 15 PRO 256 → Cantidad 1 → Agregar
2. Al cierre → Procesar Cierre
3. ✅ Stock baja de 6 a 5

---

### Ejemplo 2: Compra de Stock
**Situación**: Compraste 20 iPhone 15 128GB

**Pasos:**
1. Historial → Nueva Transacción
2. Tipo: Compra → IPHONE 15 128 → Cantidad 20
3. ✅ Stock sube de 4 a 24

---

### Ejemplo 3: Canje
**Situación**: Cliente trae iPhone 13, se lleva iPhone 15

**Pasos:**
1. **Entrada**: Historial → Canje Entrada → IPHONE 13 → Cantidad 1
2. **Salida**: Historial → Canje Salida → IPHONE 15 → Cantidad 1
3. ✅ Stock de iPhone 13 sube, iPhone 15 baja

---

### Ejemplo 4: Análisis Mensual
**Situación**: Querés saber qué comprar

**Pasos:**
1. Reportes → Último mes
2. Ver "Productos Más Vendidos"
3. iPhone 13 128GB es #1 (45 vendidos)
4. **Decisión**: Comprar más iPhone 13 128GB

---

## ⚡ VENTAJAS CLAVE

### vs. Google Sheets:
| Google Sheets | GoShop |
|---------------|--------|
| ❌ Manual | ✅ **Automático** |
| ❌ Errores | ✅ **Sin errores** |
| ❌ Lento | ✅ **10 segundos** |
| ❌ Sin alertas | ✅ **Alertas automáticas** |
| ❌ Sin reportes | ✅ **Gráficos profesionales** |

### Beneficios:
- ⏱️ **Ahorrás 2-3 horas diarias**
- 📉 **Cero errores de stock**
- 📊 **Decisiones basadas en datos**
- 🚨 **Nunca te quedás sin stock**
- 💰 **Más ventas** (sabés qué tenés)

---

## 📸 INSTRUCCIONES PARA LAS CAPTURAS

### Capturas que necesitás:

1. **INICIO**: Pantalla principal con las 4 tarjetas y tabla
2. **STOCK**: Tabla completa con filtros arriba
3. **VENTAS**: Formulario + tabla de ventas pendientes
4. **CIERRE**: Tabla de ventas del día + botón procesar
5. **REPORTES**: Gráficos + top 10 productos
6. **HISTORIAL**: Tabla de transacciones con filtros
7. **ALERTAS**: Tabla de alertas (o mensaje "no hay alertas")

### Cómo tomarlas:
1. Abre GoShop en tu navegador
2. Ve a cada sección
3. Presiona **Windows + Shift + S** (captura de pantalla)
4. Selecciona el área
5. Pega en Word

---

## 📄 ESTRUCTURA DEL WORD

```
PORTADA:
- Logo GoShop
- "Sistema de Gestión de Inventario"
- "Manual de Usuario"

PÁGINA 1: INICIO
- [IMAGEN]
- Explicación breve

PÁGINA 2: STOCK
- [IMAGEN]
- Explicación breve

PÁGINA 3: VENTAS
- [IMAGEN]
- Explicación breve

... (una página por sección)

ÚLTIMA PÁGINA:
- Resumen de beneficios
- Contacto
```

---

## ✅ CHECKLIST PARA EL CLIENTE

- [ ] Ver las 7 pantallas principales
- [ ] Entender el flujo diario
- [ ] Probar registrar una venta
- [ ] Probar procesar un cierre
- [ ] Ver reportes
- [ ] Entender las ventajas vs Google Sheets

---

**🎯 GoShop: Control total de tu inventario en 10 segundos por venta.**

*Guía Rápida - Versión 1.0 - Mayo 2026*
