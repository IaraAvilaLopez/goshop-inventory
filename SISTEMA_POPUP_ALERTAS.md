# 🔔 SISTEMA DE POPUP DE ALERTAS

## 🎯 CARACTERÍSTICAS IMPLEMENTADAS

### **✅ LO QUE HACE:**

1. **Detecta alertas automáticamente** cuando se generan
2. **Muestra un popup** con las alertas nuevas
3. **Permite ir directamente** a la sección de Alertas
4. **Actualización en tiempo real** usando Supabase Realtime
5. **Recuerda alertas vistas** para no mostrarlas de nuevo

---

## 🎨 DISEÑO DEL POPUP

### **Apariencia:**

```
┌─────────────────────────────────────────────────────┐
│ 🔔 ¡Alerta de Stock!                           [X]  │
│    2 productos necesitan atención                   │
├─────────────────────────────────────────────────────┤
│                                                      │
│  ⚠️  SAMSUNG S24 ULTRA 256                          │
│      Stock actual: 2 unidades                       │
│      Stock mínimo: 5 unidades                       │
│      [CRÍTICO]                                      │
│                                                      │
│  ⚠️  IPHONE 11 PRO MAX 256                          │
│      Stock actual: 3 unidades                       │
│      Stock mínimo: 5 unidades                       │
│      [BAJO]                                         │
│                                                      │
├─────────────────────────────────────────────────────┤
│  [Cerrar]                    [🔔 Ver Alertas]      │
└─────────────────────────────────────────────────────┘
```

### **Colores según nivel:**

- **CRÍTICO**: Rojo (bg-red-50, border-red-500)
- **BAJO**: Amarillo (bg-yellow-50, border-yellow-500)
- **NORMAL**: Azul (bg-blue-50, border-blue-500)

---

## ⚙️ CÓMO FUNCIONA

### **1. Verificación Automática**

```typescript
// Verifica alertas cada 30 segundos
const interval = setInterval(verificarAlertas, 30000)
```

### **2. Tiempo Real (Realtime)**

```typescript
// Se suscribe a cambios en la tabla alertas_stock
const subscription = supabase
  .channel('alertas_changes')
  .on('postgres_changes', {
    event: 'INSERT',
    schema: 'public',
    table: 'alertas_stock'
  }, () => {
    verificarAlertas()
  })
  .subscribe()
```

**Cuando se inserta una nueva alerta en la BD, el popup se muestra automáticamente.**

### **3. Alertas Vistas**

```typescript
// Guarda en localStorage las alertas ya vistas
localStorage.setItem('alertasVistas', JSON.stringify([...]))

// Filtra solo alertas nuevas
const alertasNuevas = data.filter(alerta => !alertasVistas.has(alerta.id))
```

**El popup solo muestra alertas que NO has visto antes.**

---

## 🔄 FLUJO COMPLETO

### **Escenario: Stock Crítico**

1. **Venta se procesa** → Stock baja a 2 unidades
2. **Trigger de BD** → Inserta alerta en `alertas_stock`
3. **Realtime detecta** → Notifica al frontend
4. **Popup aparece** → Muestra la alerta
5. **Usuario hace click** → Va a sección Alertas
6. **Alerta marcada como vista** → No se muestra de nuevo

---

## 📊 CUÁNDO SE MUESTRA EL POPUP

### **✅ SE MUESTRA:**

- ✅ Cuando hay alertas ACTIVAS nuevas
- ✅ Cuando se inserta una alerta en tiempo real
- ✅ Cada 30 segundos si hay alertas no vistas
- ✅ Al recargar la página si hay alertas no vistas

### **❌ NO SE MUESTRA:**

- ❌ Si no hay alertas activas
- ❌ Si todas las alertas ya fueron vistas
- ❌ Si el usuario cerró el popup (se marcan como vistas)

---

## 🎯 ACCIONES DISPONIBLES

### **1. Botón "Cerrar"**

```typescript
function cerrarPopup() {
  // Marca alertas como vistas
  const nuevasVistas = new Set(alertasVistas)
  alertas.forEach(alerta => nuevasVistas.add(alerta.id))
  setAlertasVistas(nuevasVistas)
  localStorage.setItem('alertasVistas', JSON.stringify(Array.from(nuevasVistas)))
  
  setMostrarPopup(false)
}
```

**Resultado:** Cierra el popup y no lo vuelve a mostrar para esas alertas.

### **2. Botón "Ver Alertas"**

```typescript
function irAAlertas() {
  cerrarPopup()
  onNavigateToAlertas() // Navega a la sección de Alertas
}
```

**Resultado:** Cierra el popup y te lleva directamente a la sección de Alertas.

### **3. Botón "X" (cerrar)**

Igual que el botón "Cerrar".

---

## 🧪 CÓMO PROBAR

### **OPCIÓN 1: Simular Stock Crítico**

1. **Ve a Stock**
2. **Edita un producto** y pon stock muy bajo (ej: 2 unidades)
3. **Asegúrate** que el stock mínimo sea mayor (ej: 5 unidades)
4. **Espera 30 segundos** o recarga la página
5. **Popup aparece** automáticamente

### **OPCIÓN 2: Insertar Alerta Manualmente**

```sql
-- Ejecuta en Supabase
INSERT INTO alertas_stock (
  producto_id,
  tipo_alerta,
  nivel_stock,
  cantidad_actual,
  stock_minimo,
  estado_alerta
)
SELECT 
  id,
  'STOCK_BAJO',
  'CRÍTICO',
  2,
  5,
  'ACTIVA'
FROM productos
WHERE marca = 'SAMSUNG'
LIMIT 1;
```

**El popup aparecerá inmediatamente** gracias a Realtime.

### **OPCIÓN 3: Procesar Venta**

1. **Ve a Ventas**
2. **Agrega una venta** que deje el stock por debajo del mínimo
3. **Procesa el cierre**
4. **El trigger genera la alerta** automáticamente
5. **Popup aparece**

---

## 🎨 ANIMACIONES

### **Entrada del Popup:**

```css
@keyframes bounce-in {
  0% {
    transform: scale(0.3);
    opacity: 0;
  }
  50% {
    transform: scale(1.05);
  }
  70% {
    transform: scale(0.9);
  }
  100% {
    transform: scale(1);
    opacity: 1;
  }
}
```

**Efecto:** El popup aparece con un rebote suave.

### **Ícono de Campana:**

```typescript
<Bell className="w-6 h-6 text-red-600 animate-pulse" />
```

**Efecto:** La campana pulsa para llamar la atención.

---

## 📱 RESPONSIVE

### **Móvil:**
- Popup ocupa el 90% del ancho
- Scroll vertical si hay muchas alertas
- Botones apilados verticalmente

### **Desktop:**
- Popup centrado con ancho máximo de 28rem
- Botones lado a lado

---

## 🔧 CONFIGURACIÓN

### **Intervalo de Verificación:**

```typescript
// Cambiar de 30 segundos a otro valor
const interval = setInterval(verificarAlertas, 30000) // 30000ms = 30s
```

### **Desactivar Realtime:**

```typescript
// Comentar la suscripción
/*
const subscription = supabase
  .channel('alertas_changes')
  ...
*/
```

### **Limpiar Alertas Vistas:**

```javascript
// Ejecutar en consola del navegador
localStorage.removeItem('alertasVistas')
```

**Resultado:** Todas las alertas se mostrarán de nuevo.

---

## 📊 INFORMACIÓN MOSTRADA

### **Por cada alerta:**

1. **Producto**: Marca + Modelo + Capacidad
2. **Stock actual**: Cantidad en inventario
3. **Stock mínimo**: Umbral configurado
4. **Nivel**: Badge con color (CRÍTICO/BAJO/NORMAL)
5. **Ícono**: Triángulo de advertencia con color

---

## 🎯 VENTAJAS

1. ✅ **Notificación inmediata** cuando hay problemas de stock
2. ✅ **No invasivo**: Se puede cerrar fácilmente
3. ✅ **Navegación directa**: Un click para ir a Alertas
4. ✅ **Inteligente**: No muestra alertas ya vistas
5. ✅ **Tiempo real**: Usa Supabase Realtime
6. ✅ **Persistente**: Recuerda alertas vistas entre sesiones
7. ✅ **Visual**: Colores según gravedad

---

## 🚀 ARCHIVOS CREADOS/MODIFICADOS

### **Nuevos:**
1. ✅ `AlertaPopup.tsx` - Componente del popup
2. ✅ `SISTEMA_POPUP_ALERTAS.md` - Esta documentación

### **Modificados:**
1. ✅ `App.tsx` - Integración del popup
2. ✅ `index.css` - Animaciones CSS

---

## 📝 EJEMPLO DE USO

### **Usuario ve el popup:**

```
Usuario: *Está en Dashboard*
Sistema: *Detecta nueva alerta*
Popup: *Aparece con animación*
Usuario: *Lee la alerta*
Usuario: *Click en "Ver Alertas"*
Sistema: *Navega a sección Alertas*
Popup: *Se cierra y marca como vista*
```

### **Usuario cierra el popup:**

```
Usuario: *Ve el popup*
Usuario: *Click en "Cerrar"*
Popup: *Se cierra*
Sistema: *Marca alertas como vistas*
Sistema: *No vuelve a mostrar esas alertas*
```

---

## ✅ CHECKLIST DE VERIFICACIÓN

- [ ] Popup aparece cuando hay alertas nuevas
- [ ] Botón "Cerrar" funciona
- [ ] Botón "Ver Alertas" navega correctamente
- [ ] Alertas vistas no se muestran de nuevo
- [ ] Realtime funciona (insertar alerta en BD)
- [ ] Animación de entrada es suave
- [ ] Colores según nivel son correctos
- [ ] Responsive en móvil funciona

---

## 🎉 RESULTADO FINAL

**Sistema completo de notificaciones de alertas que:**
- ✅ Detecta automáticamente
- ✅ Muestra en tiempo real
- ✅ Permite navegación rápida
- ✅ Recuerda alertas vistas
- ✅ Diseño profesional y atractivo

**¡Recarga la app (F5) y prueba el sistema!** 🚀
