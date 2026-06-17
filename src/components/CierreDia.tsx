import { useEffect, useState } from 'react'
import { supabase, type Producto } from '../lib/supabase'
import { Calendar, Save } from 'lucide-react'
import { useSucursal } from '../context/SucursalContext'

type VentaItem = {
  producto_id: string
  cantidad: number
}

export default function CierreDia() {
  const { sucursal } = useSucursal()
  const [productos, setProductos] = useState<Producto[]>([])
  const [ventas, setVentas] = useState<VentaItem[]>([])
  const [fecha, setFecha] = useState(new Date().toISOString().split('T')[0])
  const [observaciones, setObservaciones] = useState('')
  const [loading, setLoading] = useState(true)
  const [cierreExistente, setCierreExistente] = useState(false)

  useEffect(() => {
    fetchProductos()
    cargarVentasPendientes()
    verificarCierreExistente()
  }, [sucursal, fecha])

  async function fetchProductos() {
    try {
      const { data, error } = await supabase
        .from('inventario')
        .select(`
          producto_id,
          cantidad_actual,
          productos (
            id,
            marca,
            modelo,
            capacidad_gb,
            color
          )
        `)
        .eq('ubicacion', sucursal)
        .gt('cantidad_actual', 0)
        .limit(1000)
        .order('productos(marca)', { ascending: true })

      if (error) throw error
      
      const productosConStock = (data || []).map((item: any) => ({
        id: item.productos?.id || '',
        marca: item.productos?.marca || '',
        modelo: item.productos?.modelo || '',
        capacidad_gb: item.productos?.capacidad_gb || '',
        color: item.productos?.color || '',
        created_at: '',
        updated_at: ''
      }))
      
      setProductos(productosConStock)
    } catch (error) {
      console.error('Error fetching products:', error)
    } finally {
      setLoading(false)
    }
  }

  async function cargarVentasPendientes() {
    try {
      const { data, error } = await supabase
        .from('ventas_pendientes')
        .select('*')
        .eq('procesada', false)
        .eq('fecha', fecha)
        .eq('ubicacion', sucursal)

      if (error) throw error

      const ventasPendientes = (data || []).map(v => ({
        producto_id: v.producto_id,
        cantidad: v.cantidad
      }))

      setVentas(ventasPendientes)
    } catch (error) {
      console.error('Error loading pending sales:', error)
    }
  }

  async function verificarCierreExistente() {
    try {
      const { data, error } = await supabase
        .from('cierres_dia')
        .select('id')
        .eq('fecha_cierre', fecha)
        .eq('ubicacion', sucursal)
        .maybeSingle()

      if (error) throw error
      setCierreExistente(!!data)
    } catch (error) {
      console.error('Error checking existing closure:', error)
    }
  }

  function agregarVenta() {
    setVentas([...ventas, { producto_id: '', cantidad: 1 }])
  }

  function actualizarVenta(index: number, field: keyof VentaItem, value: any) {
    const nuevasVentas = [...ventas]
    nuevasVentas[index] = { ...nuevasVentas[index], [field]: value }
    setVentas(nuevasVentas)
  }

  function eliminarVenta(index: number) {
    setVentas(ventas.filter((_, i) => i !== index))
  }

  async function procesarCierre() {
    if (ventas.length === 0) {
      alert('Debe agregar al menos una venta')
      return
    }

    if (ventas.some(v => !v.producto_id || v.cantidad <= 0)) {
      alert('Complete todos los campos de ventas')
      return
    }

    try {
      for (const venta of ventas) {
        const { error } = await supabase.from('transacciones').insert([{
          producto_id: venta.producto_id,
          tipo_transaccion: 'CIERRE_DIA',
          cantidad: venta.cantidad,
          precio_unitario: 0,
          precio_total: 0,
          fecha_transaccion: new Date(fecha).toISOString(),
          observaciones: observaciones || 'Cierre de día',
          ubicacion: sucursal,
        }])

        if (error) throw error
      }

      const totalVentas = ventas.reduce((sum, v) => sum + v.cantidad, 0)

      const { error: cierreError } = await supabase.from('cierres_dia').insert([{
        fecha_cierre: fecha,
        ubicacion: sucursal,
        total_ventas: totalVentas,
        observaciones,
      }])

      if (cierreError) throw cierreError

      await supabase
        .from('ventas_pendientes')
        .update({ procesada: true })
        .eq('fecha', fecha)
        .eq('ubicacion', sucursal)
        .eq('procesada', false)

      alert('✅ Cierre procesado exitosamente. El stock se ha actualizado automáticamente.')
      
      // Limpiar formulario
      setVentas([])
      setObservaciones('')
      setCierreExistente(true)
      
      // Recargar productos para mostrar stock actualizado
      fetchProductos()
    } catch (error: any) {
      console.error('Error processing closure:', error)
      alert(`❌ Error al procesar cierre: ${error.message || 'Verifica que hayas ejecutado el script SQL para agregar CIERRE_DIA'}`)
    }
  }

  if (loading) {
    return <div className="flex items-center justify-center h-64">Cargando...</div>
  }

  return (
    <div className="px-4 py-6 sm:px-0">
      <div className="flex justify-between items-center mb-6">
        <h2 className="text-2xl font-bold text-gray-900">Cierre de Día</h2>
        <div className="flex items-center">
          <Calendar className="w-5 h-5 text-gray-500 mr-2" />
          <input
            type="date"
            value={fecha}
            onChange={(e) => setFecha(e.target.value)}
            className="rounded-md border-gray-300 shadow-sm focus:border-blue-500 focus:ring-blue-500"
          />
        </div>
      </div>

      {cierreExistente && (
        <div className="bg-green-50 border border-green-200 rounded-lg p-4 mb-6">
          <h4 className="text-sm font-medium text-green-900 mb-2">✅ Día Cerrado</h4>
          <p className="text-sm text-green-700">
            El cierre de este día ya fue procesado para {sucursal}.
          </p>
          <button
            onClick={async () => {
              if (confirm('⚠️ ¿REVERTIR el cierre de este día?\n\nEsto:\n- Eliminará las transacciones de CIERRE_DIA\n- RESTAURARÁ el stock automáticamente\n- Permitirá procesar el cierre nuevamente\n\n¿Continuar?')) {
                try {
                  // PASO 1: Eliminar transacciones de CIERRE_DIA (esto restaura el stock automáticamente)
                  const { error: transError } = await supabase
                    .from('transacciones')
                    .delete()
                    .eq('tipo_transaccion', 'CIERRE_DIA')
                    .eq('ubicacion', sucursal)
                    .gte('fecha_transaccion', `${fecha}T00:00:00`)
                    .lte('fecha_transaccion', `${fecha}T23:59:59`)
                  
                  if (transError) throw transError
                  
                  // PASO 2: Eliminar registro de cierre
                  const { error: cierreError } = await supabase
                    .from('cierres_dia')
                    .delete()
                    .eq('fecha_cierre', fecha)
                    .eq('ubicacion', sucursal)
                  
                  if (cierreError) throw cierreError
                  
                  // PASO 3: Marcar ventas como no procesadas
                  await supabase
                    .from('ventas_pendientes')
                    .update({ procesada: false })
                    .eq('fecha', fecha)
                    .eq('ubicacion', sucursal)
                  
                  setCierreExistente(false)
                  alert('✅ Cierre revertido exitosamente. El stock ha sido restaurado.')
                  
                  // Recargar datos
                  fetchProductos()
                  cargarVentasPendientes()
                } catch (error: any) {
                  console.error('Error reverting closure:', error)
                  alert(`❌ Error al revertir cierre: ${error.message}`)
                }
              }
            }}
            className="mt-2 px-4 py-2 bg-orange-600 text-white rounded-md hover:bg-orange-700 text-sm"
          >
            ⚠️ Revertir Cierre
          </button>
        </div>
      )}

      <div className="bg-white shadow rounded-lg p-6 mb-6">
        <h3 className="text-lg font-medium text-gray-900 mb-4">Ventas Pendientes de Procesar</h3>
        
        {ventas.length === 0 && !cierreExistente && (
          <div className="bg-yellow-50 border border-yellow-200 rounded-lg p-4 mb-4">
            <p className="text-sm text-yellow-800">
              No hay ventas pendientes para {sucursal} en esta fecha. Agrega ventas desde la sección "Ventas".
            </p>
          </div>
        )}
        
        <div className="space-y-4">
          {ventas.map((venta, index) => (
            <div key={index} className="flex gap-4 items-center">
              <select
                value={venta.producto_id}
                onChange={(e) => actualizarVenta(index, 'producto_id', e.target.value)}
                className="flex-1 rounded-md border-gray-300 shadow-sm focus:border-blue-500 focus:ring-blue-500"
              >
                <option value="">Seleccionar producto</option>
                {productos.map(prod => (
                  <option key={prod.id} value={prod.id}>
                    {prod.marca} {prod.modelo} {prod.capacidad_gb} {prod.color ? `- ${prod.color}` : ''}
                  </option>
                ))}
              </select>
              <input
                type="number"
                placeholder="Cantidad"
                value={venta.cantidad}
                onChange={(e) => actualizarVenta(index, 'cantidad', parseInt(e.target.value))}
                className="w-32 rounded-md border-gray-300 shadow-sm focus:border-blue-500 focus:ring-blue-500"
              />
              <button
                onClick={() => eliminarVenta(index)}
                className="px-3 py-2 text-red-600 hover:text-red-800 font-medium"
              >
                Eliminar
              </button>
            </div>
          ))}
        </div>

        <button
          onClick={agregarVenta}
          className="mt-4 px-4 py-2 border border-gray-300 rounded-md text-sm font-medium text-gray-700 hover:bg-gray-50"
        >
          + Agregar Venta
        </button>

        <div className="mt-6">
          <label className="block text-sm font-medium text-gray-700 mb-2">
            Observaciones
          </label>
          <textarea
            value={observaciones}
            onChange={(e) => setObservaciones(e.target.value)}
            className="w-full rounded-md border-gray-300 shadow-sm focus:border-blue-500 focus:ring-blue-500"
            rows={3}
            placeholder="Notas adicionales sobre el cierre..."
          />
        </div>

        <div className="mt-6 flex justify-end">
          <button
            onClick={procesarCierre}
            className="inline-flex items-center px-6 py-3 border border-transparent text-base font-medium rounded-md shadow-sm text-white bg-blue-600 hover:bg-blue-700"
          >
            <Save className="w-5 h-5 mr-2" />
            Procesar Cierre
          </button>
        </div>
      </div>

      <div className="bg-blue-50 border border-blue-200 rounded-lg p-4">
        <h4 className="text-sm font-medium text-blue-900 mb-2">ℹ️ Información</h4>
        <p className="text-sm text-blue-700">
          Al procesar el cierre, todas las ventas se registrarán como transacciones y el stock se descontará automáticamente del inventario.
        </p>
      </div>
    </div>
  )
}
