# AGREGAR BOTÓN ELIMINAR EN HISTORIAL

## Problema
El botón "Eliminar" no aparece en la columna Acciones del Historial de Transacciones.

## Solución

### 1. Abre el archivo:
`C:\Users\iaraa\OneDrive\Escritorio\GoShop\src\components\Transacciones.tsx`

### 2. Busca esta línea (alrededor de la línea 287):
```tsx
<th className="px-6 py-3 text-left text-xs font-medium text-gray-500 uppercase">Observaciones</th>
```

### 3. Justo DESPUÉS de esa línea, agrega:
```tsx
<th className="px-6 py-3 text-left text-xs font-medium text-gray-500 uppercase">Acciones</th>
```

### 4. Busca esta línea (alrededor de la línea 312):
```tsx
<td className="px-6 py-4 text-sm text-gray-500">{trans.observaciones || '-'}</td>
```

### 5. Justo DESPUÉS de esa línea, agrega este código completo:
```tsx
<td className="px-6 py-4 whitespace-nowrap text-sm">
  <button
    onClick={async () => {
      if (!confirm(`¿Eliminar esta transacción? El stock se restaurará automáticamente.`)) return
      
      try {
        const cantidad = trans.cantidad
        const productoId = trans.producto_id
        const ubicacion = trans.ubicacion || 'RESISTENCIA'
        
        if (['COMPRA', 'CANJE_ENTRADA', 'TRANSFERENCIA'].includes(trans.tipo_transaccion)) {
          await supabase.rpc('ajustar_stock', {
            p_producto_id: productoId,
            p_ubicacion: ubicacion,
            p_cantidad: -cantidad
          })
        }
        else if (['VENTA', 'CANJE_SALIDA'].includes(trans.tipo_transaccion)) {
          await supabase.rpc('ajustar_stock', {
            p_producto_id: productoId,
            p_ubicacion: ubicacion,
            p_cantidad: cantidad
          })
        }
        
        const { error } = await supabase
          .from('transacciones')
          .delete()
          .eq('id', trans.id)
        
        if (error) throw error
        
        alert('Transacción eliminada y stock restaurado')
        fetchData()
      } catch (error: any) {
        console.error('Error eliminando transacción:', error)
        alert(`Error: ${error.message}`)
      }
    }}
    className="text-red-600 hover:text-red-900 font-medium"
  >
    Eliminar
  </button>
</td>
```

### 6. Guarda el archivo (Ctrl + S)

### 7. En la terminal, reinicia el servidor:
- Ctrl + C (detener)
- `npm run dev` (iniciar)

### 8. Refresca el navegador (F5)

## Resultado
Deberías ver una columna "Acciones" con un botón rojo "Eliminar" en cada transacción.
