# 📱 GoShop - Sistema de Gestión de Inventario de Celulares

Sistema completo para control de stock en tiempo real con alertas automáticas, registro de transacciones, plan canje y reportes.

## ✨ Características

### 🎯 Control de Stock en Tiempo Real
- Visualización instantánea de inventario por **modelo, color y capacidad GB**
- Actualización automática con cada transacción
- Filtros avanzados por múltiples criterios
- Vista de stock actual con niveles (Normal, Bajo, Crítico)

### 🚨 Sistema de Alertas Automáticas
- Notificaciones cuando el stock llega al mínimo configurado
- Panel dedicado de alertas activas
- Configuración personalizable de niveles mínimos por producto
- **Ejemplo**: Si queda 1 unidad, salta alerta automáticamente

### 📦 Gestión de Transacciones
- **Compras**: Registro de nuevos equipos con fecha
- **Ventas**: Descuento automático del stock
- **Plan Canje**: Entrada de usado + Salida de nuevo
- **Transferencias**: Entre sucursales
- Historial completo con filtros por fecha y tipo

### 📅 Cierre de Día
- Carga masiva de ventas del día
- Descuento automático del inventario
- Registro de fecha para análisis histórico
- Identificación de períodos con más ingresos

### 📊 Reportes y Análisis
- Filtros por fecha para identificar tendencias
- Reportes de ventas por modelo, color y GB
- Dashboard con métricas clave
- Historial completo de movimientos

## 🛠️ Stack Tecnológico

- **Frontend**: React 18 + TypeScript + Vite
- **UI**: TailwindCSS (diseño moderno y responsive)
- **Backend**: Supabase (PostgreSQL + Auth + Realtime)
- **Iconos**: Lucide React
- **Base de Datos**: PostgreSQL con triggers automáticos

## 🚀 Instalación

### Paso 1: Configurar Supabase

1. Crear cuenta gratuita en [supabase.com](https://supabase.com)
2. Crear nuevo proyecto
3. Ir a **SQL Editor** en el panel de Supabase
4. Copiar y ejecutar el contenido completo de `database/schema.sql`
5. Copiar las credenciales:
   - Ve a **Settings** → **API**
   - Copia `Project URL` y `anon public key`

### Paso 2: Instalar Dependencias

```bash
cd GoShop
npm install
```

Esto instalará:
- React y React DOM
- Supabase client
- TailwindCSS
- Lucide icons
- TypeScript
- Vite

### Paso 3: Configurar Variables de Entorno

Crear archivo `.env.local` en la raíz del proyecto:

```env
VITE_SUPABASE_URL=https://tu-proyecto.supabase.co
VITE_SUPABASE_ANON_KEY=tu_anon_key_aqui
```

### Paso 4: Ejecutar Aplicación

```bash
npm run dev
```

La aplicación estará disponible en `http://localhost:5173`

## 📁 Estructura del Proyecto

```
GoShop/
├── database/
│   └── schema.sql              # Esquema completo de BD con triggers
├── src/
│   ├── components/
│   │   ├── Dashboard.tsx       # Panel principal con métricas
│   │   ├── Inventario.tsx      # Gestión de stock con filtros
│   │   ├── Transacciones.tsx   # Registro de movimientos
│   │   ├── Alertas.tsx         # Panel de alertas de stock bajo
│   │   └── CierreDia.tsx       # Cierre diario con descuento automático
│   ├── lib/
│   │   ├── supabase.ts         # Cliente y tipos TypeScript
│   │   └── utils.ts            # Utilidades (formateo, etc.)
│   ├── App.tsx                 # Componente principal con navegación
│   ├── main.tsx                # Punto de entrada
│   └── index.css               # Estilos globales con Tailwind
├── package.json
├── vite.config.ts
├── tailwind.config.js
└── README.md
```

## 📖 Guía de Uso

### 1. Agregar Nuevo Producto

1. Ir a **Inventario**
2. Clic en **"Nuevo Producto"**
3. Completar:
   - Marca (ej: iPhone, Samsung)
   - Modelo (ej: 13 PRO MAX)
   - Color
   - Capacidad GB (ej: 128, 256, 512, 1T)
   - Cantidad inicial
   - **Cantidad mínima** (para alertas automáticas)
4. Guardar

### 2. Registrar Compra de Nuevos Equipos

1. Ir a **Transacciones** → **"Nueva Transacción"**
2. Seleccionar tipo: **COMPRA**
3. Seleccionar producto
4. Ingresar cantidad y precio
5. Agregar observaciones (opcional)
6. **El stock se actualiza automáticamente** ✅

### 3. Plan Canje

**Paso 1 - Entrada del usado:**
1. Ir a **Transacciones** → **"Nueva Transacción"**
2. Tipo: **CANJE_ENTRADA**
3. Seleccionar el equipo usado que ingresa
4. Cantidad: 1

**Paso 2 - Salida del nuevo:**
1. Nueva transacción
2. Tipo: **CANJE_SALIDA**
3. Seleccionar el equipo nuevo que sale
4. Cantidad: 1

Ambas transacciones quedan registradas con fecha para trazabilidad.

### 4. Cierre de Día

1. Ir a **Cierre de Día**
2. Seleccionar fecha
3. Clic en **"+ Agregar Venta"** por cada modelo vendido
4. Seleccionar producto (modelo + color + GB)
5. Ingresar cantidad vendida
6. Agregar observaciones
7. Clic en **"Procesar Cierre"**
8. **El sistema descuenta automáticamente del stock** ✅

### 5. Ver Alertas de Stock Bajo

1. Ir a **Alertas**
2. Ver productos con stock crítico
3. Clic en **"Resolver"** cuando se reabastezca
4. Las alertas se generan automáticamente cuando:
   - Stock actual ≤ Stock mínimo configurado

### 6. Filtrar por Fecha

**En Transacciones:**
- Todas las transacciones tienen fecha de registro
- Puedes filtrar por tipo (Compra, Venta, Canje)
- Ver historial completo de movimientos

**En Dashboard:**
- Ver métricas generales
- Productos con stock crítico
- Total de unidades en inventario

## 🔄 Funcionalidades Automáticas

### Triggers de Base de Datos

El sistema incluye triggers que se ejecutan automáticamente:

1. **Actualización de Stock**
   - Al registrar COMPRA o CANJE_ENTRADA → suma al stock
   - Al registrar VENTA o CANJE_SALIDA → resta del stock
   - No necesitas actualizar manualmente

2. **Generación de Alertas**
   - Cuando stock ≤ mínimo → crea alerta automáticamente
   - Aparece en el panel de Alertas
   - Notificación visual en Dashboard

## 📊 Migración de Datos desde Google Sheet

Para migrar tus datos actuales:

1. Exporta tu Google Sheet como CSV
2. Por cada fila, crea el producto en **Inventario**
3. O usa el siguiente script SQL adaptado:

```sql
-- Ejemplo para insertar productos masivamente
INSERT INTO productos (modelo, marca, color, capacidad_gb) VALUES
('11 PRO MAX', 'IPHONE', NULL, '256'),
('13 PRO', 'IPHONE', NULL, '128'),
('15 PRO', 'IPHONE', NULL, '128');

-- Luego insertar el inventario inicial
INSERT INTO inventario (producto_id, cantidad_actual, cantidad_minima, ubicacion, estado)
SELECT id, 4, 1, 'RESISTENCIA', 'DISPONIBLE'
FROM productos WHERE modelo = '11 PRO MAX' AND capacidad_gb = '256';
```

## 🎨 Personalización

### Cambiar Ubicación por Defecto

Editar en cada componente donde aparece `'RESISTENCIA'` y cambiar por tu sucursal.

### Ajustar Niveles de Alerta

En `database/schema.sql`, línea 155:
```sql
WHEN i.cantidad_actual <= i.cantidad_minima THEN 'CRÍTICO'
WHEN i.cantidad_actual <= (i.cantidad_minima * 2) THEN 'BAJO'
```

### Agregar Más Tipos de Transacción

Editar en `database/schema.sql`, línea 43:
```sql
CHECK (tipo_transaccion IN ('COMPRA', 'VENTA', 'CANJE_ENTRADA', 'CANJE_SALIDA', 'AJUSTE', 'TRANSFERENCIA', 'TU_NUEVO_TIPO'))
```

## 🐛 Solución de Problemas

### Error: "Cannot find module"
```bash
rm -rf node_modules package-lock.json
npm install
```

### Error de conexión a Supabase
- Verificar que `.env.local` existe y tiene las credenciales correctas
- Verificar que el proyecto de Supabase está activo
- Verificar que ejecutaste el `schema.sql` completo

### Stock no se actualiza
- Verificar que los triggers se crearon correctamente en Supabase
- Ir a SQL Editor y ejecutar:
```sql
SELECT * FROM pg_trigger WHERE tgname LIKE '%actualizar%';
```

## 📝 Próximas Mejoras

- [ ] Autenticación de usuarios
- [ ] Múltiples sucursales con sincronización
- [ ] Exportar reportes a Excel/PDF
- [ ] Gráficos de ventas por período
- [ ] Notificaciones push para alertas
- [ ] App móvil (React Native)
- [ ] Código de barras/QR para productos

## 📄 Licencia

Este proyecto es de código abierto y está disponible bajo la licencia MIT.

## 🤝 Soporte

Para consultas o problemas:
- Revisar la documentación de [Supabase](https://supabase.com/docs)
- Revisar la documentación de [React](https://react.dev)
- Revisar la documentación de [TailwindCSS](https://tailwindcss.com)

---

**Desarrollado con ❤️ para gestión eficiente de inventarios de celulares**
