import { useEffect, useState } from 'react'
import { supabase, type StockActual } from '../lib/supabase'
import { useSucursal } from '../context/SucursalContext'
import { ArrowRightLeft, Package, AlertCircle } from 'lucide-react'

type Transferencia = {
  producto_id: string
  cantidad: number
  origen: 'RESISTENCIA' | 'CORRIENTES'
  destino: 'RESISTENCIA' | 'CORRIENTES'
  observaciones: string
}

export default function Transferencias() {
  const { sucursal } = useSucursal()
  const [productos, setProductos] = useState<StockActual[]>([])
  const [loading, setLoading] = useState(true)
  const [procesando, setProcesando] = useState(false)

  const [transferencia, setTransferencia] = useState<Transferencia>({
    producto_id: '',
    cantidad: 1,
    origen: sucursal || 'RESISTENCIA',
    destino: sucursal === 'RESISTENCIA' ? 'CORRIENTES' : 'RESISTENCIA',
    observaciones: ''
  })

  useEffect(() => {
    if (sucursal) {
      fetchProductos()
      setTransferencia(prev => ({
        ...prev,
        origen: sucursal,
        destino: sucursal === 'RESISTENCIA' ? 'CORRIENTES' : 'RESISTENCIA'
      }))
    }
  }, [sucursal])

  async function fetchProductos() {
    try {
      const { data, error } = await supabase
        .from('vista_stock_actual')
        .select('*')
        .eq('ubicacion', sucursal)
        .gt('cantidad_actual', 0)
        .order('marca', { ascending: true })

      if (error) throw error
      setProductos(data || [])
    } catch (error) {
      console.error('Error fetching productos:', error)
    } finally {
      setLoading(false)
    }
  }

  async function handleTransferencia() {
    if (!transferencia.producto_id) {
      alert('❌ Selecciona un producto')
      return
    }

    if (transferencia.cantidad <= 0) {
      alert('❌ La cantidad debe ser mayor a 0')
      return
    }

    // Verificar stock disponible
    const productoSeleccionado = productos.find(p => p.producto_id === transferencia.producto_id)
    if (!productoSeleccionado) {
      alert('❌ Producto no encontrado')
      return
    }

    if (transferencia.cantidad > productoSeleccionado.cantidad_actual) {
      alert(`❌ Stock insuficiente. Disponible: ${productoSeleccionado.cantidad_actual}`)
      return
    }

    if (!confirm(`¿Confirmar transferencia de ${transferencia.cantidad} unidad(es) de ${productoSeleccionado.marca} ${productoSeleccionado.modelo} desde ${transferencia.origen} hacia ${transferencia.destino}?`)) {
      return
    }

    setProcesando(true)

    try {
      // Obtener fecha/hora local de Argentina (UTC-3)
      const now = new Date()
      const argentinaOffset = -3 * 60
      const localTime = new Date(now.getTime() + (argentinaOffset + now.getTimezoneOffset()) * 60000)
      const fechaHora = localTime.toISOString()

      // 1. Crear transacción de SALIDA en origen (TRANSFERENCIA)
      const { error: salidaError } = await supabase
        .from('transacciones')
        .insert([{
          producto_id: transferencia.producto_id,
          tipo_transaccion: 'TRANSFERENCIA',
          cantidad: transferencia.cantidad,
          precio_unitario: 0,
          precio_total: 0,
          fecha_transaccion: fechaHora,
          observaciones: `Transferencia a ${transferencia.destino}${transferencia.observaciones ? ` - ${transferencia.observaciones}` : ''}`,
          ubicacion: transferencia.origen
        }])

      if (salidaError) throw salidaError

      // 2. Descontar del inventario de origen
      const { error: descontar } = await supabase.rpc('ajustar_stock', {
        p_producto_id: transferencia.producto_id,
        p_ubicacion: transferencia.origen,
        p_cantidad: -transferencia.cantidad
      })

      if (descontar) throw descontar

      // 3. Crear transacción de ENTRADA en destino (TRANSFERENCIA)
      const { error: entradaError } = await supabase
        .from('transacciones')
        .insert([{
          producto_id: transferencia.producto_id,
          tipo_transaccion: 'TRANSFERENCIA',
          cantidad: transferencia.cantidad,
          precio_unitario: 0,
          precio_total: 0,
          fecha_transaccion: fechaHora,
          observaciones: `Transferencia desde ${transferencia.origen}${transferencia.observaciones ? ` - ${transferencia.observaciones}` : ''}`,
          ubicacion: transferencia.destino
        }])

      if (entradaError) throw entradaError

      // 4. Agregar al inventario de destino
      const { error: agregar } = await supabase.rpc('ajustar_stock', {
        p_producto_id: transferencia.producto_id,
        p_ubicacion: transferencia.destino,
        p_cantidad: transferencia.cantidad
      })

      if (agregar) throw agregar

      alert(`✅ Transferencia realizada exitosamente\n\n${transferencia.cantidad} unidad(es) transferidas de ${transferencia.origen} a ${transferencia.destino}`)

      // Resetear formulario
      setTransferencia({
        producto_id: '',
        cantidad: 1,
        origen: sucursal || 'RESISTENCIA',
        destino: sucursal === 'RESISTENCIA' ? 'CORRIENTES' : 'RESISTENCIA',
        observaciones: ''
      })

      // Recargar productos
      fetchProductos()

    } catch (error: any) {
      console.error('Error en transferencia:', error)
      alert(`❌ Error al realizar transferencia: ${error.message}`)
    } finally {
      setProcesando(false)
    }
  }

  if (loading) {
    return <div className="flex items-center justify-center h-64">Cargando...</div>
  }

  const productoSeleccionado = productos.find(p => p.producto_id === transferencia.producto_id)

  return (
    <div className="px-4 py-6 sm:px-0">
      <div className="mb-6">
        <h2 className="text-2xl font-bold text-gray-900">Transferencias entre Sucursales</h2>
        <p className="mt-1 text-sm text-gray-600">
          Transfiere productos entre {transferencia.origen} y {transferencia.destino}
        </p>
      </div>

      <div className="bg-white shadow rounded-lg p-6">
        {/* Indicador de Dirección */}
        <div className="mb-6 p-4 bg-blue-50 border border-blue-200 rounded-lg">
          <div className="flex items-center justify-center gap-4">
            <div className="text-center">
              <div className="text-sm font-medium text-gray-600">Origen</div>
              <div className="text-xl font-bold text-blue-600">{transferencia.origen}</div>
            </div>
            <ArrowRightLeft className="w-8 h-8 text-blue-600" />
            <div className="text-center">
              <div className="text-sm font-medium text-gray-600">Destino</div>
              <div className="text-xl font-bold text-green-600">{transferencia.destino}</div>
            </div>
          </div>
        </div>

        {/* Formulario */}
        <div className="space-y-4">
          {/* Seleccionar Producto */}
          <div>
            <label className="block text-sm font-medium text-gray-700 mb-1">
              Producto a Transferir
            </label>
            <select
              value={transferencia.producto_id}
              onChange={(e) => setTransferencia({ ...transferencia, producto_id: e.target.value })}
              className="w-full rounded-md border-gray-300 shadow-sm focus:border-blue-500 focus:ring-blue-500"
              disabled={procesando}
            >
              <option value="">Seleccionar producto...</option>
              {productos.map((producto) => (
                <option key={producto.producto_id} value={producto.producto_id}>
                  {producto.marca} {producto.modelo} {producto.capacidad_gb} - Stock: {producto.cantidad_actual}
                </option>
              ))}
            </select>
          </div>

          {/* Stock Disponible */}
          {productoSeleccionado && (
            <div className="p-3 bg-gray-50 rounded-md border border-gray-200">
              <div className="flex items-center gap-2 text-sm">
                <Package className="w-4 h-4 text-gray-500" />
                <span className="text-gray-600">Stock disponible en {transferencia.origen}:</span>
                <span className="font-bold text-gray-900">{productoSeleccionado.cantidad_actual} unidades</span>
              </div>
            </div>
          )}

          {/* Cantidad */}
          <div>
            <label className="block text-sm font-medium text-gray-700 mb-1">
              Cantidad a Transferir
            </label>
            <input
              type="number"
              min="1"
              max={productoSeleccionado?.cantidad_actual || 1}
              value={transferencia.cantidad}
              onChange={(e) => setTransferencia({ ...transferencia, cantidad: parseInt(e.target.value) || 1 })}
              className="w-full rounded-md border-gray-300 shadow-sm focus:border-blue-500 focus:ring-blue-500"
              disabled={procesando || !transferencia.producto_id}
            />
          </div>

          {/* Observaciones */}
          <div>
            <label className="block text-sm font-medium text-gray-700 mb-1">
              Observaciones (Opcional)
            </label>
            <textarea
              value={transferencia.observaciones}
              onChange={(e) => setTransferencia({ ...transferencia, observaciones: e.target.value })}
              rows={3}
              className="w-full rounded-md border-gray-300 shadow-sm focus:border-blue-500 focus:ring-blue-500"
              placeholder="Motivo de la transferencia, notas adicionales..."
              disabled={procesando}
            />
          </div>

          {/* Advertencia */}
          <div className="p-4 bg-yellow-50 border border-yellow-200 rounded-md">
            <div className="flex gap-3">
              <AlertCircle className="w-5 h-5 text-yellow-600 flex-shrink-0 mt-0.5" />
              <div className="text-sm text-yellow-800">
                <p className="font-medium mb-1">Importante:</p>
                <ul className="list-disc list-inside space-y-1">
                  <li>Se descontará del stock de <strong>{transferencia.origen}</strong></li>
                  <li>Se agregará al stock de <strong>{transferencia.destino}</strong></li>
                  <li>Se crearán 2 transacciones (salida y entrada)</li>
                  <li>Esta acción no se puede deshacer automáticamente</li>
                </ul>
              </div>
            </div>
          </div>

          {/* Botón */}
          <button
            onClick={handleTransferencia}
            disabled={procesando || !transferencia.producto_id || productos.length === 0}
            className="w-full bg-blue-600 hover:bg-blue-700 disabled:bg-gray-300 text-white font-medium py-3 px-4 rounded-md transition-colors flex items-center justify-center gap-2"
          >
            {procesando ? (
              <>
                <div className="animate-spin rounded-full h-5 w-5 border-b-2 border-white"></div>
                Procesando transferencia...
              </>
            ) : (
              <>
                <ArrowRightLeft className="w-5 h-5" />
                Realizar Transferencia
              </>
            )}
          </button>
        </div>

        {/* Sin productos */}
        {productos.length === 0 && (
          <div className="text-center py-8">
            <Package className="w-16 h-16 text-gray-300 mx-auto mb-4" />
            <p className="text-gray-500">No hay productos con stock disponible en {sucursal}</p>
          </div>
        )}
      </div>
    </div>
  )
}
