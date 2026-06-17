# MANUAL DE USUARIO - GOSHOP
## Sistema de Gestión de Inventario Multi-Sucursal

---

## ÍNDICE

1. [Introducción](#introducción)
2. [Acceso al Sistema](#acceso-al-sistema)
3. [Selección de Sucursal](#selección-de-sucursal)
4. [Panel de Inicio (Dashboard)](#panel-de-inicio-dashboard)
5. [Gestión de Stock](#gestión-de-stock)
6. [Registro de Ventas](#registro-de-ventas)
7. [Cierre de Día](#cierre-de-día)
8. [Transacciones](#transacciones)
9. [Reportes](#reportes)
10. [Historial de Operaciones](#historial-de-operaciones)
11. [Sistema de Alertas](#sistema-de-alertas)
12. [Preguntas Frecuentes](#preguntas-frecuentes)

---

## INTRODUCCIÓN

**GoShop** es un sistema integral de gestión de inventario diseñado específicamente para negocios con múltiples sucursales. Permite controlar el stock de productos, registrar transacciones comerciales, realizar transferencias entre sucursales y generar reportes detallados de forma automática.

### Características Principales

- **Multi-Sucursal**: Gestión independiente de inventario para cada sucursal (Resistencia y Corrientes)
- **Control de Stock en Tiempo Real**: Actualización automática del inventario con cada transacción
- **Sistema de Alertas**: Notificaciones automáticas cuando el stock alcanza niveles críticos
- **Cierre de Día Automatizado**: Procesamiento de ventas diarias con un solo clic
- **Reportes Detallados**: Análisis de ventas, compras, transferencias y estado del inventario
- **Historial Completo**: Registro de todas las operaciones con posibilidad de reversión
- **Interfaz Intuitiva**: Diseño moderno y fácil de usar

---

## ACCESO AL SISTEMA

### Requisitos Previos

- Navegador web actualizado (Chrome, Firefox, Safari o Edge)
- Conexión a Internet estable
- Credenciales de acceso proporcionadas por el administrador

### Inicio de Sesión

1. Ingrese a la URL del sistema proporcionada
2. Introduzca su correo electrónico
3. Ingrese su contraseña
4. Haga clic en "Iniciar Sesión"

**Nota de Seguridad**: Las credenciales son personales e intransferibles. No comparta su contraseña con terceros.

---

## SELECCIÓN DE SUCURSAL

Al ingresar al sistema, lo primero que debe hacer es **seleccionar la sucursal** desde la cual está trabajando.

### Cómo Cambiar de Sucursal

1. En la esquina superior derecha, haga clic en el botón **"Cambiar Sucursal"**
2. Seleccione la sucursal correspondiente:
   - **RESISTENCIA**
   - **CORRIENTES**
3. El sistema cargará automáticamente el inventario y datos de la sucursal seleccionada

**IMPORTANTE**: Todas las operaciones que realice afectarán únicamente a la sucursal seleccionada. Verifique siempre que está en la sucursal correcta antes de realizar cualquier transacción.

---

## PANEL DE INICIO (DASHBOARD)

El Dashboard es la pantalla principal del sistema y muestra un resumen general del estado de su sucursal.

### Información Visible

#### Métricas Principales
- **Total de Productos**: Cantidad total de productos diferentes en el inventario
- **Stock Total**: Suma de todas las unidades disponibles
- **Productos con Stock Bajo**: Cantidad de productos que requieren reposición
- **Alertas Activas**: Número de alertas de stock crítico

#### Gráficos y Estadísticas
- **Distribución de Stock por Categoría**: Visualización del inventario por tipo de producto
- **Productos Más Vendidos**: Ranking de los productos con mayor rotación
- **Tendencias de Ventas**: Gráfico de ventas en el período seleccionado

### Acciones Rápidas

Desde el Dashboard puede acceder rápidamente a:
- Agregar nueva transacción
- Ver alertas activas
- Consultar reportes del día
- Acceder al cierre de día

---

## GESTIÓN DE STOCK

La sección de **Stock** le permite visualizar y gestionar todo el inventario de la sucursal actual.

### Visualización del Inventario

#### Información Mostrada por Producto
- **Marca y Modelo**: Identificación del producto
- **Capacidad/Especificaciones**: Detalles técnicos (GB, características)
- **Color**: Variante del producto
- **Cantidad Actual**: Unidades disponibles en stock
- **Stock Mínimo**: Nivel de alerta configurado
- **Estado**: Indicador visual del nivel de stock
  - 🟢 **NORMAL**: Stock por encima del mínimo
  - 🟡 **BAJO**: Stock igual al mínimo
  - 🔴 **CRÍTICO**: Stock por debajo del mínimo o en cero

### Filtros y Búsqueda

#### Búsqueda de Productos
- Utilice el campo de búsqueda para encontrar productos por marca, modelo o especificaciones
- La búsqueda es instantánea y no distingue mayúsculas de minúsculas

#### Filtros Disponibles
- **Por Estado**: Normal, Bajo, Crítico
- **Por Categoría**: Celulares, Accesorios, Otros
- **Por Marca**: Filtrar por fabricante específico

### Acciones sobre el Stock

#### Eliminar Producto
1. Haga clic en el botón **"Eliminar"** junto al producto deseado
2. Confirme la acción en el cuadro de diálogo
3. **ADVERTENCIA**: Solo puede eliminar productos con stock en cero

**Nota**: La eliminación de productos es permanente y no se puede deshacer. Use esta función con precaución.

---

## REGISTRO DE VENTAS

La sección de **Ventas** permite registrar todas las ventas realizadas durante el día para su posterior procesamiento en el cierre.

### Cómo Registrar una Venta

1. Acceda a la sección **"Ventas"** desde el menú principal
2. En el campo **"Producto"**, comience a escribir el nombre del producto
3. Seleccione el producto de la lista de sugerencias
4. Ingrese la **cantidad** vendida
5. (Opcional) Agregue **comentarios** sobre la venta (ej: "Vendido a Juan", "Cliente VIP")
6. Haga clic en **"+ Agregar"**

### Características Importantes

#### Validaciones Automáticas
- Solo puede seleccionar productos que tengan stock disponible en su sucursal
- El sistema valida que la cantidad ingresada no exceda el stock actual
- No se permite registrar ventas con cantidad cero o negativa

#### Ventas Pendientes
- Las ventas registradas quedan en estado **"Pendiente de Procesar"**
- El stock NO se descuenta hasta que se procese el cierre de día
- Puede ver todas las ventas pendientes en la lista inferior
- Puede eliminar ventas pendientes antes del cierre si se cometió un error

### Gestión de Ventas Pendientes

#### Ver Ventas Pendientes
La tabla muestra:
- **Producto**: Descripción completa del artículo vendido
- **Cantidad**: Unidades vendidas
- **Fecha**: Día de la venta
- **Comentarios**: Observaciones adicionales
- **Acciones**: Botón para eliminar la venta

#### Eliminar una Venta Pendiente
1. Haga clic en **"Eliminar"** junto a la venta
2. Confirme la acción
3. La venta se eliminará de la lista de pendientes

**IMPORTANTE**: Una vez procesado el cierre de día, las ventas ya no se pueden eliminar individualmente. Deberá reiniciar el cierre completo.

---

## CIERRE DE DÍA

El **Cierre de Día** es el proceso mediante el cual se procesan todas las ventas pendientes y se actualiza el inventario.

### Cuándo Realizar el Cierre

- Al finalizar la jornada laboral
- Antes de generar reportes diarios
- Cuando necesite consolidar las ventas del día

### Proceso de Cierre

#### Paso 1: Verificar Ventas Pendientes
1. Acceda a **"Cierre"** desde el menú principal
2. Revise la lista de **"Ventas Pendientes de Procesar"**
3. Verifique que todas las ventas sean correctas
4. Si encuentra errores, elimine las ventas incorrectas antes de procesar

#### Paso 2: Agregar Observaciones (Opcional)
- En el campo **"Observaciones"**, puede agregar notas sobre el cierre
- Ejemplo: "Día con alta demanda", "Promoción especial", etc.

#### Paso 3: Procesar el Cierre
1. Haga clic en **"Procesar Cierre del Día"**
2. El sistema mostrará un resumen:
   - Cantidad total de ventas a procesar
   - Unidades totales que se descontarán del stock
3. Confirme la operación
4. El sistema procesará automáticamente:
   - Creación de transacciones tipo CIERRE_DIA
   - Descuento del stock en el inventario
   - Registro del cierre en el historial
   - Marcado de ventas como procesadas

### Estados del Cierre

#### Pendiente de Cierre
- Hay ventas sin procesar
- El botón **"Procesar Cierre del Día"** está habilitado
- Puede agregar más ventas

#### Cierre Procesado
- Todas las ventas del día fueron procesadas
- El estado muestra **"Cierre Procesado"**
- Aparece el botón **"Reiniciar Cierre"** (naranja)

### Reiniciar un Cierre

Si necesita corregir un cierre ya procesado:

1. Haga clic en **"Reiniciar Cierre"**
2. Lea atentamente la advertencia:
   - Se eliminará el cierre procesado
   - Se restaurará el stock automáticamente
   - Se eliminarán las ventas pendientes de ese día
3. Confirme la acción
4. El sistema revertirá todas las operaciones del cierre

**ADVERTENCIA**: Reiniciar un cierre es una operación delicada. Use esta función solo cuando sea absolutamente necesario.

---

## TRANSACCIONES

La sección de **Transacciones** es el núcleo del sistema, donde se registran todas las operaciones que afectan el inventario.

### Tipos de Transacciones

#### 1. COMPRA
**Descripción**: Ingreso de mercadería nueva al inventario.

**Cuándo usar**: Al recibir productos de proveedores.

**Proceso**:
1. Haga clic en **"+ Nueva Transacción"**
2. Seleccione tipo: **"Compra"**
3. Busque el producto o créelo si no existe:
   - **Opción A**: Escriba el nombre y seleccione de las sugerencias
   - **Opción B**: Haga clic en **"+ Nuevo Celular"** o **"+ Nuevo Otro"** para crear un producto
4. Ingrese la **cantidad** comprada
5. (Opcional) Agregue **observaciones** (ej: "Proveedor XYZ", "Factura #123")
6. Haga clic en **"Agregar"**

**Efecto en el inventario**: Suma las unidades al stock de la sucursal actual.

#### 2. TRANSFERENCIA
**Descripción**: Envío de productos desde otra sucursal hacia la sucursal actual.

**Cuándo usar**: Cuando necesita recibir stock de la otra sucursal.

**Proceso**:
1. Seleccione tipo: **"Transferencia"**
2. Busque el producto en la lista de la **otra sucursal**
   - Si está en RESISTENCIA, verá productos disponibles en CORRIENTES
   - Si está en CORRIENTES, verá productos disponibles en RESISTENCIA
3. Ingrese la **cantidad** a transferir
4. Agregue **observaciones** si es necesario
5. Haga clic en **"Agregar"**

**Efecto en el inventario**:
- **Sucursal de origen**: Descuenta las unidades
- **Sucursal de destino**: Suma las unidades

**IMPORTANTE**: Las transferencias se registran en ambas sucursales automáticamente.

#### 3. CANJE ENTRADA
**Descripción**: Ingreso de productos recibidos por canje.

**Cuándo usar**: Cuando un cliente entrega un producto usado como parte de pago.

**Proceso**:
1. Seleccione tipo: **"Canje Entrada"**
2. Busque o cree el producto
3. Ingrese la **cantidad**
4. Agregue **observaciones** (ej: "Canje iPhone 12 por iPhone 15")
5. Haga clic en **"Agregar"**

**Efecto en el inventario**: Suma las unidades al stock.

#### 4. CANJE SALIDA
**Descripción**: Salida de productos entregados en un canje.

**Cuándo usar**: Cuando entrega un producto nuevo como parte de un canje.

**Proceso**:
1. Seleccione tipo: **"Canje Salida"**
2. Busque el producto en su stock actual
3. Ingrese la **cantidad**
4. Agregue **observaciones**
5. Haga clic en **"Agregar"**

**Efecto en el inventario**: Descuenta las unidades del stock.

**IMPORTANTE**: Solo puede seleccionar productos que tenga en stock.

#### 5. CIERRE_DIA
**Descripción**: Transacciones generadas automáticamente al procesar el cierre de día.

**Cuándo se crea**: Automáticamente al hacer clic en "Procesar Cierre del Día".

**Características**:
- No se crea manualmente
- Agrupa todas las ventas del día
- Incluye los comentarios de cada venta individual
- Puede expandirse para ver el detalle de cada venta

### Crear un Nuevo Producto

Si el producto no existe en el sistema, puede crearlo durante el registro de una transacción:

#### Opción 1: Nuevo Celular
1. Haga clic en **"+ Nuevo Celular"**
2. Complete los campos:
   - **Marca**: Fabricante (ej: SAMSUNG, APPLE, MOTOROLA)
   - **Modelo**: Nombre del modelo (ej: S24 ULTRA, iPhone 15 PRO)
   - **Capacidad**: Almacenamiento en GB (ej: 128, 256, 512)
   - **Color**: Color del dispositivo (ej: Negro, Blanco, Azul)
3. Haga clic en **"Crear y Usar"**

#### Opción 2: Nuevo Otro Producto
1. Haga clic en **"+ Nuevo Otro"**
2. Complete los campos:
   - **Marca**: Fabricante
   - **Modelo**: Nombre del producto
   - **Descripción**: Detalles adicionales
   - **Color**: Color (opcional)
3. Haga clic en **"Crear y Usar"**

**Nota**: El producto creado estará disponible para todas las sucursales, pero el stock se gestiona independientemente.

### Historial de Transacciones

#### Filtros de Período
- **Todas**: Muestra todas las transacciones (limitado a 500 registros)
- **Hoy**: Solo transacciones del día actual
- **Última Semana**: Últimos 7 días
- **Último Mes**: Últimos 30 días
- **Personalizado**: Seleccione rango de fechas específico

#### Filtros por Tipo
Puede filtrar las transacciones por:
- Todos los tipos
- Solo COMPRA
- Solo TRANSFERENCIA
- Solo CANJE_ENTRADA
- Solo CANJE_SALIDA
- Solo CIERRE_DIA

#### Información Mostrada
Las transacciones se agrupan por día y muestran:
- **Fecha**: Día de la transacción
- **Resumen**: Cantidad de cada tipo de transacción
- **Detalle expandible**: Haga clic en el día para ver todas las transacciones

#### Detalle de Cada Transacción
- **Hora**: Momento exacto de la operación
- **Producto**: Descripción completa
- **Tipo**: Tipo de transacción
- **Cantidad**: Unidades afectadas
- **Observaciones**: Comentarios adicionales
- **Acciones**: Botón "Eliminar" (si corresponde)

### Eliminar una Transacción

**ADVERTENCIA**: Eliminar una transacción restaura automáticamente el stock. Use esta función con extrema precaución.

#### Proceso de Eliminación
1. Localice la transacción en el historial
2. Haga clic en **"Eliminar"**
3. Confirme la acción
4. El sistema:
   - Eliminará la transacción
   - Restaurará el stock automáticamente
   - Registrará la operación en el log del sistema

#### Restricciones
- No puede eliminar transacciones de CIERRE_DIA individuales
- Para revertir un cierre, use el botón "Reiniciar Cierre" en la sección de Cierre de Día
- Algunas transacciones antiguas pueden estar bloqueadas para eliminación

---

## REPORTES

La sección de **Reportes** proporciona análisis detallados de las operaciones de su sucursal.

### Tipos de Reportes

#### 1. Reporte de Ventas
**Información incluida**:
- Total de ventas en el período
- Cantidad de unidades vendidas
- Productos más vendidos
- Tendencias de ventas por día

**Cómo generar**:
1. Acceda a **"Reportes"**
2. Seleccione el período deseado
3. El reporte se genera automáticamente

#### 2. Reporte de Compras
**Información incluida**:
- Total de compras realizadas
- Cantidad de unidades ingresadas
- Proveedores principales
- Inversión en inventario

#### 3. Reporte de Transferencias
**Información incluida**:
- Transferencias enviadas
- Transferencias recibidas
- Balance de transferencias entre sucursales
- Productos más transferidos

#### 4. Reporte de Stock Actual
**Información incluida**:
- Inventario completo de la sucursal
- Valor total del inventario
- Productos con stock crítico
- Distribución por categoría

### Exportar Reportes

Los reportes pueden exportarse en los siguientes formatos:
- **PDF**: Para impresión o archivo
- **Excel**: Para análisis adicional
- **CSV**: Para importar en otros sistemas

**Proceso de exportación**:
1. Genere el reporte deseado
2. Haga clic en **"Exportar"**
3. Seleccione el formato
4. El archivo se descargará automáticamente

---

## HISTORIAL DE OPERACIONES

El **Historial** mantiene un registro completo de todas las operaciones realizadas en el sistema.

### Información Registrada

- Fecha y hora exacta de cada operación
- Usuario que realizó la acción
- Tipo de operación
- Detalles de la transacción
- Cambios en el inventario

### Consulta del Historial

#### Filtros Disponibles
- Por fecha
- Por usuario
- Por tipo de operación
- Por producto
- Por sucursal

#### Búsqueda Avanzada
Puede buscar operaciones específicas utilizando:
- Nombre de producto
- Número de transacción
- Observaciones

---

## SISTEMA DE ALERTAS

El sistema de alertas notifica automáticamente cuando el stock de un producto alcanza niveles críticos.

### Tipos de Alertas

#### Alerta de Stock Bajo
- Se activa cuando el stock alcanza el nivel mínimo configurado
- Indicador: 🟡 Amarillo
- Acción recomendada: Planificar reposición

#### Alerta de Stock Crítico
- Se activa cuando el stock está por debajo del mínimo
- Indicador: 🔴 Rojo
- Acción recomendada: Reposición urgente

#### Alerta de Stock Agotado
- Se activa cuando el stock llega a cero
- Indicador: ⚫ Negro
- Acción recomendada: Reposición inmediata

### Visualización de Alertas

#### Desde el Dashboard
- Contador de alertas activas en la tarjeta principal
- Acceso rápido a la lista completa

#### Sección de Alertas
1. Acceda a **"Alertas"** desde el menú
2. Vea todas las alertas activas de su sucursal
3. Información mostrada:
   - Producto afectado
   - Stock actual
   - Stock mínimo configurado
   - Nivel de criticidad
   - Fecha de activación

### Gestión de Alertas

#### Resolución Automática
Las alertas se resuelven automáticamente cuando:
- El stock supera el nivel mínimo (por compra o transferencia)
- Se ajusta el stock mínimo del producto

#### Configuración de Niveles
Para modificar el stock mínimo de un producto:
1. Acceda a la sección **"Stock"**
2. Localice el producto
3. Haga clic en **"Editar"**
4. Modifique el **"Stock Mínimo"**
5. Guarde los cambios

---

## PREGUNTAS FRECUENTES

### Operaciones Generales

**P: ¿Puedo trabajar en ambas sucursales simultáneamente?**
R: No. Debe seleccionar una sucursal a la vez. Para cambiar de sucursal, use el botón "Cambiar Sucursal" en la esquina superior derecha.

**P: ¿Qué sucede si registro una venta en la sucursal equivocada?**
R: Si aún no procesó el cierre de día, puede eliminar la venta pendiente. Si ya procesó el cierre, deberá reiniciar el cierre completo.

**P: ¿Puedo modificar una transacción después de crearla?**
R: No. Las transacciones no se pueden modificar. Debe eliminar la transacción incorrecta y crear una nueva.

### Cierre de Día

**P: ¿Qué pasa si olvido hacer el cierre de día?**
R: Las ventas quedarán pendientes y podrá procesarlas al día siguiente. El sistema permite procesar ventas de días anteriores.

**P: ¿Puedo hacer varios cierres en un mismo día?**
R: No. Solo se permite un cierre por día por sucursal. Si necesita corregir algo, debe reiniciar el cierre.

**P: ¿Qué sucede con el stock al reiniciar un cierre?**
R: El stock se restaura automáticamente a su estado anterior al cierre. Las ventas se eliminan y puede volver a registrarlas.

### Transferencias

**P: ¿Cómo sé si una transferencia fue recibida en la otra sucursal?**
R: Las transferencias se registran automáticamente en ambas sucursales. Puede verificarlo en el historial de transacciones de cada sucursal.

**P: ¿Puedo transferir productos que no tengo en stock?**
R: No. Solo puede transferir productos que estén disponibles en la sucursal de origen.

**P: ¿Qué pasa si elimino una transferencia?**
R: El sistema revertirá automáticamente el movimiento de stock en ambas sucursales.

### Stock y Productos

**P: ¿Puedo eliminar un producto con stock?**
R: No. Solo puede eliminar productos que tengan stock en cero en todas las sucursales.

**P: ¿Cómo agrego un producto nuevo?**
R: Puede crear productos nuevos al registrar una transacción, usando los botones "+ Nuevo Celular" o "+ Nuevo Otro".

**P: ¿Los productos son compartidos entre sucursales?**
R: Sí, el catálogo de productos es compartido, pero el stock se gestiona independientemente para cada sucursal.

### Reportes y Análisis

**P: ¿Los reportes incluyen datos de ambas sucursales?**
R: No. Los reportes muestran únicamente información de la sucursal seleccionada actualmente.

**P: ¿Puedo generar reportes de períodos personalizados?**
R: Sí. Use el filtro "Personalizado" y seleccione las fechas de inicio y fin deseadas.

**P: ¿Con qué frecuencia se actualizan los reportes?**
R: Los reportes se generan en tiempo real con la información más actualizada del sistema.

---

## SOPORTE TÉCNICO

Para asistencia técnica o consultas adicionales, contacte a:

**Email**: [correo de soporte]
**Teléfono**: [número de contacto]
**Horario de atención**: [horario]

---

## NOTAS IMPORTANTES

1. **Realice copias de seguridad periódicas** de la información crítica
2. **Verifique siempre la sucursal activa** antes de realizar operaciones
3. **Procese el cierre de día diariamente** para mantener la información actualizada
4. **Revise las alertas regularmente** para evitar quiebres de stock
5. **Mantenga sus credenciales seguras** y no las comparta
6. **Cierre sesión** al finalizar su jornada laboral

---

**Versión del Manual**: 1.0
**Fecha de Actualización**: Junio 2026
**Sistema**: GoShop - Gestión de Inventario Multi-Sucursal

---

*Este manual está sujeto a actualizaciones. Consulte regularmente la versión más reciente.*
