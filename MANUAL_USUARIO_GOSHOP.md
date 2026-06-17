# 📱 GoShop - Manual de Usuario Completo

## 🎯 Guía Visual Paso a Paso

---

## 1️⃣ INICIO - Resumen General

### ¿Qué ves aquí?
Al abrir GoShop, la primera pantalla muestra:

**📊 4 Tarjetas con Métricas:**
- **Total Productos**: Cuántos productos diferentes tenés
- **Stock Crítico**: Productos con 1 unidad o menos
- **Total Unidades**: Suma de todas las unidades disponibles
- **Alertas Activas**: Cuántas alertas de stock bajo hay

**📋 Tabla de Productos:**
- Lista completa de tu inventario
- Ordenado por marca y modelo
- Muestra: Marca, Modelo, Capacidad, Stock actual, Estado

### ¿Para qué sirve?
- Ver el estado general del negocio de un vistazo
- Identificar rápidamente problemas de stock
- Tomar decisiones sobre qué reponer

---

## 2️⃣ STOCK - Gestión de Inventario

### ¿Qué ves aquí?

**🔍 Barra de Búsqueda y Filtros:**
- **Buscar**: Escribe cualquier palabra (marca, modelo, color)
- **Filtro por Marca**: IPHONE, SAMSUNG
- **Filtro por Capacidad**: 128, 256, 512, 1T
- **Limpiar Filtros**: Vuelve a mostrar todo

**📋 Tabla Completa:**
Columnas:
1. **Marca**: IPHONE o SAMSUNG
2. **Modelo**: 13, 14, 15 PRO, etc.
3. **Color**: Si tiene color específico
4. **Capacidad**: 128GB, 256GB, etc.
5. **Stock**: Cantidad actual (en NEGRITA)
6. **Mínimo**: Cantidad mínima antes de alerta
7. **Estado**: 
   - 🟢 NORMAL (stock suficiente)
   - 🟡 BAJO (cerca del mínimo)
   - 🔴 CRÍTICO (1 unidad o menos)
8. **Acciones**: Botón "Eliminar"

**➕ Botón "Nuevo Producto":**
Abre un formulario para agregar productos nuevos

### ¿Qué puedes hacer?

#### ✅ Buscar un producto:
1. Escribe en "Buscar..." (ej: "iPhone 13")
2. La tabla se filtra automáticamente

#### ✅ Filtrar por marca:
1. Selecciona "IPHONE" o "SAMSUNG"
2. Solo muestra esa marca

#### ✅ Filtrar por capacidad:
1. Selecciona "128", "256", etc.
2. Solo muestra esa capacidad

#### ✅ Agregar producto nuevo:
1. Clic en "Nuevo Producto"
2. Completa el formulario:
   - Marca (ej: IPHONE)
   - Modelo (ej: 16 PRO MAX)
   - Color (opcional)
   - Capacidad (ej: 512)
   - Cantidad inicial
   - Cantidad mínima (para alertas)
3. Clic en "Agregar"
4. ✅ El producto aparece en la lista

#### ✅ Eliminar producto:
1. Busca el producto en la tabla
2. Clic en "Eliminar"
3. Confirma
4. ✅ Se elimina del inventario

---

## 3️⃣ VENTAS - Registro Diario

### ¿Qué ves aquí?

**📝 Formulario "Agregar Venta":**
- **Producto**: Dropdown con todos los productos disponibles
- **Cantidad**: Número de unidades vendidas
- **Botón "Agregar"**: Registra la venta

**📋 Tabla "Ventas Pendientes de Procesar":**
- Muestra todas las ventas del día
- Columnas: Producto, Cantidad, Fecha, Acciones
- Contador: (X ventas pendientes)

**ℹ️ Cuadro Informativo:**
Explica cómo funciona el sistema

### ¿Qué puedes hacer?

#### ✅ Registrar una venta:
**Ejemplo: Vendiste un iPhone 13 128GB**

1. Ve a "Ventas"
2. En "Producto", selecciona "IPHONE 13 128"
3. En "Cantidad", deja 1 (o cambia si vendiste más)
4. Clic en "Agregar"
5. ✅ La venta aparece en "Ventas Pendientes"

**IMPORTANTE**: El stock NO se descuenta todavía. Eso pasa en el Cierre de Día.

#### ✅ Ver ventas del día:
- Todas las ventas registradas aparecen en la tabla
- Puedes ver qué vendiste y cuánto

#### ✅ Eliminar una venta (si te equivocaste):
1. Busca la venta en la tabla
2. Clic en "Eliminar"
3. ✅ Se borra (antes del cierre)

### ¿Por qué funciona así?
- Podés registrar ventas durante todo el día
- Si te equivocás, podés corregir
- Al final del día, procesás todo junto en "Cierre"
- El stock se descuenta automáticamente al procesar el cierre

---

## 4️⃣ CIERRE - Cierre de Día

### ¿Qué ves aquí?

**📅 Fecha del Cierre:**
- Por defecto: Hoy
- Podés cambiarla si necesitás

**📋 Tabla "Ventas del Día":**
- Se cargan AUTOMÁTICAMENTE las ventas de "Ventas"
- Columnas: Producto, Cantidad
- Podés agregar más ventas manualmente

**➕ Botón "Agregar Venta":**
- Por si olvidaste registrar alguna

**📝 Observaciones:**
- Campo de texto para notas del día

**✅ Botón "Procesar Cierre":**
- Ejecuta el cierre del día

### ¿Qué puedes hacer?

#### ✅ Procesar el cierre del día:
**Paso a paso:**

1. **Al final del día**, ve a "Cierre"
2. Verifica que estén todas las ventas del día
3. Si falta alguna, agregala con "Agregar Venta"
4. Escribe observaciones si querés (opcional)
   - Ej: "Día tranquilo" o "Mucha demanda de iPhone 15"
5. Clic en "Procesar Cierre"
6. ✅ **Mensaje de confirmación**
7. ✅ **Stock actualizado automáticamente**
8. ✅ **Ventas guardadas en historial**

#### ¿Qué pasa al procesar el cierre?
1. **Stock se descuenta**: Si vendiste 3 iPhone 13, el stock baja en 3
2. **Ventas se guardan**: Quedan en el historial para siempre
3. **Cierre registrado**: Queda guardado con fecha y observaciones
4. **Ventas marcadas como procesadas**: Ya no aparecen como pendientes

---

## 5️⃣ REPORTES - Estadísticas y Gráficos

### ¿Qué ves aquí?

**📅 Filtros de Fecha:**
- **Desde**: Fecha inicial
- **Hasta**: Fecha final
- Por defecto: Últimos 30 días

**📊 3 Tarjetas de Métricas:**
1. **Total Ventas**: Suma en pesos de todas las ventas
2. **Unidades Vendidas**: Total de productos vendidos
3. **Promedio/Día**: Cuánto vendés en promedio por día

**📈 Gráfico "Ventas por Día":**
- Barras horizontales verdes
- Muestra cuántas unidades vendiste cada día
- Fecha + cantidad

**🏆 Tabla "Productos Más Vendidos":**
- Top 10 productos
- Numerados del 1 al 10
- Muestra: Posición, Producto, Cantidad vendida

### ¿Qué puedes hacer?

#### ✅ Ver ventas del último mes:
1. Ve a "Reportes"
2. Por defecto muestra últimos 30 días
3. Ves gráficos y estadísticas

#### ✅ Ver ventas de un período específico:
**Ejemplo: Ventas de enero 2026**

1. En "Desde", selecciona: 01/01/2026
2. En "Hasta", selecciona: 31/01/2026
3. Los gráficos se actualizan automáticamente
4. Ves:
   - Total vendido en enero
   - Unidades vendidas
   - Promedio por día
   - Qué días vendiste más
   - Qué productos se vendieron más

#### ✅ Identificar productos más vendidos:
1. Mira la tabla "Productos Más Vendidos"
2. Los primeros 3 son tus best sellers
3. **Decisión**: Comprá más stock de esos productos

#### ✅ Identificar días de más ventas:
1. Mira el gráfico "Ventas por Día"
2. Las barras más largas = días con más ventas
3. **Decisión**: Sabés qué días tener más personal

---

## 6️⃣ HISTORIAL - Todas las Transacciones

### ¿Qué ves aquí?

**🔍 Filtros:**
- **Tipo**: Todos, Compra, Venta, Canje Entrada, Canje Salida, Transferencia
- **Desde**: Fecha inicial
- **Hasta**: Fecha final
- Contador: "Mostrando X de Y transacciones"

**📋 Tabla de Transacciones:**
Columnas:
1. **Fecha**: Cuándo se hizo
2. **Producto**: Qué producto
3. **Tipo**: COMPRA, VENTA, CANJE, etc.
4. **Cantidad**: Cuántas unidades
5. **Precio Unit.**: Precio por unidad
6. **Precio Total**: Total de la transacción
7. **Observaciones**: Notas adicionales

**➕ Botón "Nueva Transacción":**
Para registrar compras, canjes, etc.

### ¿Qué puedes hacer?

#### ✅ Ver todas las ventas:
1. En "Tipo", selecciona "Venta"
2. Ves solo las ventas
3. Podés filtrar por fecha también

#### ✅ Ver todas las compras:
1. En "Tipo", selecciona "Compra"
2. Ves cuándo compraste stock

#### ✅ Registrar una compra de stock:
**Ejemplo: Compraste 10 iPhone 15 PRO**

1. Clic en "Nueva Transacción"
2. Tipo: "Compra"
3. Producto: "IPHONE 15 PRO 256"
4. Cantidad: 10
5. Precio unitario: (lo que pagaste por cada uno)
6. Observaciones: "Compra a proveedor X"
7. Clic en "Registrar"
8. ✅ Stock se suma automáticamente (+10)
9. ✅ Queda en historial

#### ✅ Registrar un canje:
**Ejemplo: Cliente te dio un iPhone 13 y se llevó un iPhone 15**

**Canje Entrada (lo que recibís):**
1. Nueva Transacción
2. Tipo: "Canje Entrada"
3. Producto: "IPHONE 13 128"
4. Cantidad: 1
5. Registrar
6. ✅ Stock de iPhone 13 sube en 1

**Canje Salida (lo que entregás):**
1. Nueva Transacción
2. Tipo: "Canje Salida"
3. Producto: "IPHONE 15 128"
4. Cantidad: 1
5. Registrar
6. ✅ Stock de iPhone 15 baja en 1

#### ✅ Ver historial completo:
1. Deja todos los filtros en "Todos"
2. Ves TODAS las transacciones
3. Trazabilidad total del negocio

---

## 7️⃣ ALERTAS - Stock Bajo

### ¿Qué ves aquí?

**🚨 Tabla de Alertas Activas:**
Columnas:
1. **Producto**: Qué producto está bajo
2. **Actual**: Cuánto stock queda
3. **Mínimo**: Cuánto debería haber
4. **Ubicación**: RESISTENCIA
5. **Fecha**: Cuándo se generó la alerta
6. **Acciones**: Botón "Resolver"

**✅ Mensaje cuando no hay alertas:**
"No hay alertas activas"

### ¿Qué puedes hacer?

#### ✅ Ver productos con stock bajo:
1. Ve a "Alertas"
2. Ves lista de productos críticos
3. Ejemplo: "IPHONE 13 128 - Actual: 1, Mínimo: 1"

#### ✅ Resolver una alerta:
**Cuando ya reponiste el stock:**

1. Busca la alerta en la tabla
2. Clic en "Resolver"
3. ✅ La alerta desaparece
4. (Si el stock vuelve a bajar, se genera nueva alerta)

### ¿Cómo se generan las alertas?
**AUTOMÁTICAMENTE** cuando:
- El stock llega a la cantidad mínima o menos
- Ejemplo: Si el mínimo es 1 y vendés hasta quedar con 1, se genera alerta

---

## 📋 FLUJO DE TRABAJO COMPLETO

### 🌅 Lunes por la mañana:

1. **Abrir GoShop**
2. **Ver "Inicio"**: Chequear estado general
3. **Ver "Alertas"**: ¿Hay productos por reponer?
4. Si hay alertas → Anotar qué comprar

### 💼 Durante el día (cada venta):

**Cliente compra iPhone 13 128GB:**

1. Ve a **"Ventas"**
2. Selecciona "IPHONE 13 128"
3. Cantidad: 1
4. Clic "Agregar"
5. ✅ Venta registrada (10 segundos)

**Repite esto con cada venta del día**

### 🌙 Al cerrar (noche):

1. Ve a **"Cierre"**
2. Verifica que estén todas las ventas
3. Agrega observaciones si querés
4. Clic "Procesar Cierre"
5. ✅ Stock actualizado
6. ✅ Día cerrado

### 📊 Fin de semana/mes:

1. Ve a **"Reportes"**
2. Selecciona el período (semana/mes)
3. Analiza:
   - ¿Qué se vendió más?
   - ¿Qué días vendiste más?
   - ¿Cuánto vendiste en total?
4. **Toma decisiones**:
   - Comprar más de lo que se vende
   - Reducir stock de lo que no se vende

---

## 🎯 CASOS DE USO REALES

### Caso 1: Venta Simple
**Situación**: Cliente compra 1 iPhone 15 PRO 256GB

**Pasos:**
1. Ventas → Seleccionar producto → Cantidad 1 → Agregar
2. Al cierre → Procesar Cierre
3. ✅ Stock baja de 6 a 5 automáticamente

---

### Caso 2: Venta Múltiple
**Situación**: Cliente compra 2 iPhone 13 128GB

**Pasos:**
1. Ventas → Seleccionar "IPHONE 13 128" → Cantidad 2 → Agregar
2. Al cierre → Procesar Cierre
3. ✅ Stock baja de 11 a 9

---

### Caso 3: Compra de Stock
**Situación**: Compraste 20 iPhone 15 128GB a tu proveedor

**Pasos:**
1. Historial → Nueva Transacción
2. Tipo: Compra
3. Producto: IPHONE 15 128
4. Cantidad: 20
5. Precio: (lo que pagaste)
6. Registrar
7. ✅ Stock sube de 4 a 24

---

### Caso 4: Canje
**Situación**: Cliente trae iPhone 13 y se lleva iPhone 15

**Pasos:**
1. **Entrada** (lo que recibís):
   - Historial → Nueva Transacción
   - Tipo: Canje Entrada
   - Producto: IPHONE 13 128
   - Cantidad: 1
   - Registrar

2. **Salida** (lo que entregás):
   - Nueva Transacción
   - Tipo: Canje Salida
   - Producto: IPHONE 15 128
   - Cantidad: 1
   - Registrar

3. ✅ Stock de iPhone 13 sube en 1
4. ✅ Stock de iPhone 15 baja en 1

---

### Caso 5: Alerta de Stock Bajo
**Situación**: Vendiste el penúltimo iPhone 15 PRO

**Qué pasa:**
1. Al procesar el cierre, stock baja a 1
2. **Sistema genera alerta automática** 🚨
3. Aparece en "Alertas"
4. Sabés que tenés que reponer

**Acción:**
1. Comprar más iPhone 15 PRO
2. Registrar compra en Historial
3. Stock sube
4. Resolver alerta

---

### Caso 6: Análisis Mensual
**Situación**: Fin de mes, querés saber qué comprar

**Pasos:**
1. Reportes → Desde: 01/01 → Hasta: 31/01
2. Miras "Productos Más Vendidos"
3. Ves que iPhone 13 128GB es el #1 (vendiste 45)
4. **Decisión**: Comprar más iPhone 13 128GB
5. Ves que Samsung A07 es el #10 (vendiste 2)
6. **Decisión**: No comprar más Samsung A07

---

## ⚡ ATAJOS Y TIPS

### 🔍 Búsqueda Rápida:
- En Stock, escribe solo parte del nombre
- Ej: "13 pro" encuentra "iPhone 13 PRO"

### 📅 Filtros de Fecha:
- En Reportes e Historial, usa los filtros de fecha
- Ej: Ver solo ventas de ayer

### 🎯 Limpiar Filtros:
- Botón "Limpiar Filtros" vuelve a mostrar todo
- Útil cuando filtraste y querés ver todo de nuevo

### 📊 Nivel de Stock:
- 🟢 Verde = Tranquilo
- 🟡 Amarillo = Atención
- 🔴 Rojo = ¡Reponer YA!

### ⏱️ Tiempo de Registro:
- Registrar venta: **10 segundos**
- Procesar cierre: **30 segundos**
- Ver reportes: **Instantáneo**

---

## ❓ PREGUNTAS FRECUENTES

### ¿Cuándo se descuenta el stock?
**Al procesar el Cierre de Día**, no al registrar la venta.

### ¿Puedo corregir una venta antes del cierre?
**Sí**, en "Ventas" podés eliminar ventas antes de procesar el cierre.

### ¿Qué pasa si me olvido de registrar una venta?
Podés agregarla manualmente en "Cierre" antes de procesar.

### ¿Puedo ver ventas de hace 6 meses?
**Sí**, en "Historial" filtrá por fecha.

### ¿Las alertas se generan solas?
**Sí**, automáticamente cuando el stock llega al mínimo.

### ¿Puedo tener varios usuarios?
**Sí**, Supabase permite múltiples usuarios trabajando simultáneamente.

### ¿Se pierden los datos?
**No**, todo está en la nube con respaldo automático.

### ¿Necesito internet?
**Sí**, es una aplicación web que necesita conexión.

---

## 🎓 CAPACITACIÓN RÁPIDA (15 minutos)

### Módulo 1: Ventas (5 min)
1. Abrir "Ventas"
2. Registrar 3 ventas de prueba
3. Ver que aparecen en la tabla
4. Eliminar una

### Módulo 2: Cierre (5 min)
1. Ir a "Cierre"
2. Ver las ventas cargadas
3. Procesar cierre
4. Verificar que el stock bajó

### Módulo 3: Reportes (3 min)
1. Ir a "Reportes"
2. Cambiar fechas
3. Ver gráficos
4. Identificar producto más vendido

### Módulo 4: Stock (2 min)
1. Ir a "Stock"
2. Buscar un producto
3. Filtrar por marca
4. Agregar producto nuevo

---

## 📞 SOPORTE

### Problemas Comunes:

**No aparecen productos en "Ventas":**
- Verificar que haya stock disponible
- Solo muestra productos con stock > 0

**El cierre no procesa:**
- Verificar que haya al menos 1 venta
- Verificar conexión a internet

**No veo reportes:**
- Verificar que haya ventas en el período seleccionado
- Cambiar rango de fechas

---

## ✅ CHECKLIST DIARIO

### Mañana:
- [ ] Abrir GoShop
- [ ] Ver "Inicio" (estado general)
- [ ] Revisar "Alertas"

### Durante el día:
- [ ] Registrar cada venta en "Ventas"

### Noche:
- [ ] Ir a "Cierre"
- [ ] Verificar ventas del día
- [ ] Procesar cierre
- [ ] Verificar que el stock se actualizó

### Semanal:
- [ ] Ver "Reportes" de la semana
- [ ] Identificar productos más vendidos
- [ ] Planificar compras

---

**🎯 Con GoShop, tu tienda está siempre organizada y bajo control.**

*Manual de Usuario - Versión 1.0 - Mayo 2026*
