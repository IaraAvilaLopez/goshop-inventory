import { useEffect, useState } from 'react'
import { supabase, type Producto } from '../lib/supabase'
import { Plus, Trash2, CheckCircle } from 'lucide-react'
import { useSucursal } from '../context/SucursalContext'

type VentaDelDia = {
  id?: string
  producto_id: string
  cantidad: number
  fecha: string
  procesada: boolean
  comentarios?: string
}

export default function VentasDia() {
  const { sucursal } = useSucursal()
  const [productos, setProductos] = useState<Producto[]>([])
  const [ventas, setVentas] = useState<VentaDelDia[]>([])
  const [loading, setLoading] = useState(true)
  const [nuevaVenta, setNuevaVenta] = useState({
    producto_id: '',
    cantidad: 1,
    comentarios: ''
  })
  const [productoTexto, setProductoTexto] = useState('')
  const [mostrarSugerencias, setMostrarSugerencias] = useState(false)

  useEffect(() => {
    fetchData()
  }, [sucursal])

  async function fetchData() {
    try {
      const { data: inventarioData, error: invError } = await supabase
        .from('inventario')
        .select(`
          producto_id,
          cantidad_actual,
          productos (
            id,
            marca,
            modelo,
            capacidad_gb,
            color,
            bateria_porcentaje
          )
        `)
        .eq('ubicacion', sucursal)
        .gt('cantidad_actual', 0)
        .limit(1000)
        .order('productos(marca)', { ascending: true })

      if (invError) throw invError

      const productosConStock = (inventarioData || []).map((item: any) => ({
        id: item.productos?.id || '',
        marca: item.productos?.marca || '',
        modelo: item.productos?.modelo || '',
        capacidad_gb: item.productos?.capacidad_gb || '',
        color: item.productos?.color || '',
        bateria_porcentaje: item.productos?.bateria_porcentaje || null,
        created_at: '',
        updated_at: ''
      }))

      const { data: ventasData, error: ventasError } = await supabase
        .from('ventas_pendientes')
        .select('*')
        .eq('procesada', false)
        .eq('ubicacion', sucursal)
        .order('created_at', { ascending: false })

      if (ventasError) throw ventasError
      
      setProductos(productosConStock)
      setVentas(ventasData || [])
    } catch (error) {
      console.error('Error fetching data:', error)
    } finally {
      setLoading(false)
    }
  }

  async function agregarVenta() {
    if (!nuevaVenta.producto_id || nuevaVenta.cantidad <= 0) {
      alert('Selecciona un producto y cantidad válida')
      return
    }

    try {
      // Obtener fecha local de Argentina
      const now = new Date()
      const argentinaOffset = -3 * 60 // UTC-3 en minutos
      const localTime = new Date(now.getTime() + (argentinaOffset + now.getTimezoneOffset()) * 60000)
      const fechaLocal = localTime.toISOString().split('T')[0]
      
      const { error } = await supabase.from('ventas_pendientes').insert([{
        producto_id: nuevaVenta.producto_id,
        cantidad: nuevaVenta.cantidad,
        fecha: fechaLocal,
        ubicacion: sucursal,
        procesada: false,
        comentarios: nuevaVenta.comentarios || null
      }])

      if (error) throw error

      alert('Venta agregada. Se procesará en el Cierre de Día.')
      setNuevaVenta({ producto_id: '', cantidad: 1, comentarios: '' })
      setProductoTexto('')
      setMostrarSugerencias(false)
      fetchData()
    } catch (error: any) {
      console.error('Error adding sale:', error)
      alert(`Error al agregar venta: ${error.message || 'Error desconocido'}`)
    }
  }

  async function eliminarVenta(id: string) {
    if (!confirm('¿Eliminar esta venta?')) return

    try {
      const { error } = await supabase.from('ventas_pendientes').delete().eq('id', id)
      if (error) throw error
      fetchData()
    } catch (error) {
      console.error('Error deleting sale:', error)
      alert('Error al eliminar venta')
    }
  }

  const getProductoNombre = (id: string) => {
    const prod = productos.find(p => p.id === id)
    if (!prod) return 'Desconocido'
    return `${prod.marca} ${prod.modelo} ${prod.capacidad_gb}${prod.color ? ` - ${prod.color}` : ''}`
  }

  if (loading) {
    return <div className="flex items-center justify-center h-64">Cargando...</div>
  }

  return (
    <div className="px-4 py-6 sm:px-0">
      <div className="mb-6">
        <h2 className="text-2xl font-bold text-gray-900">Registro de Ventas</h2>
        <p className="mt-1 text-sm text-gray-600">
          Registra cada venta realizada. Al finalizar el día, procesa todas las ventas en "Cierre".
        </p>
      </div>

      <div className="bg-white shadow rounded-lg p-6 mb-6">
        <h3 className="text-lg font-medium text-gray-900 mb-4">Agregar Venta</h3>
        <div className="grid grid-cols-1 md:grid-cols-3 gap-4">
          <div className="md:col-span-2 relative">
            <label className="block text-sm font-medium text-gray-700 mb-1">Producto</label>
            <input
              type="text"
              placeholder="Buscar producto (ej: iPhone 15, JBL Flip 6)"
              value={productoTexto}
              onChange={(e) => {
                setProductoTexto(e.target.value)
                setMostrarSugerencias(e.target.value.length > 0)
                setNuevaVenta({...nuevaVenta, producto_id: ''})
              }}
              onFocus={() => setMostrarSugerencias(productoTexto.length > 0)}
              className="w-full rounded-md border-gray-300 shadow-sm focus:border-blue-500 focus:ring-blue-500"
            />
            {mostrarSugerencias && productos.filter(p => 
              `${p.marca} ${p.modelo} ${p.capacidad_gb}`.toLowerCase().includes(productoTexto.toLowerCase())
            ).length > 0 && (
              <div className="absolute z-10 w-full mt-1 bg-white border border-gray-300 rounded-md shadow-lg max-h-60 overflow-auto">
                {productos.filter(p => 
                  `${p.marca} ${p.modelo} ${p.capacidad_gb}`.toLowerCase().includes(productoTexto.toLowerCase())
                ).map(prod => (
                  <div
                    key={prod.id}
                    onClick={() => {
                      setProductoTexto(`${prod.marca} ${prod.modelo} ${prod.capacidad_gb}`)
                      setNuevaVenta({...nuevaVenta, producto_id: prod.id})
                      setMostrarSugerencias(false)
                    }}
                    className="px-4 py-2 hover:bg-blue-50 cursor-pointer border-b border-gray-100 last:border-0"
                  >
                    <div className="font-medium text-gray-900">{prod.marca} {prod.modelo} {prod.capacidad_gb}</div>
                    {prod.color && <div className="text-sm text-gray-500">{prod.color}</div>}
                  </div>
                ))}
              </div>
            )}
          </div>
          <div>
            <label className="block text-sm font-medium text-gray-700 mb-1">Cantidad</label>
            <input
              type="number"
              min="1"
              value={nuevaVenta.cantidad}
              onChange={(e) => setNuevaVenta({...nuevaVenta, cantidad: parseInt(e.target.value)})}
              className="w-full rounded-md border-gray-300 shadow-sm focus:border-blue-500 focus:ring-blue-500"
            />
          </div>
          <div>
            <label className="block text-sm font-medium text-gray-700 mb-1">Comentarios (opcional)</label>
            <textarea
              value={nuevaVenta.comentarios}
              onChange={(e) => setNuevaVenta({...nuevaVenta, comentarios: e.target.value})}
              placeholder="Ej: Vendido por Juan, Cliente VIP, etc."
              rows={2}
              className="w-full rounded-md border-gray-300 shadow-sm focus:border-blue-500 focus:ring-blue-500"
            />
          </div>
          <div className="flex items-end">
            <button
              onClick={agregarVenta}
              className="w-full inline-flex items-center justify-center px-4 py-2 border border-transparent text-sm font-medium rounded-md shadow-sm text-white bg-blue-600 hover:bg-blue-700"
            >
              <Plus className="w-4 h-4 mr-1" />
              Agregar
            </button>
          </div>
        </div>
      </div>

      <div className="bg-white shadow rounded-lg overflow-hidden">
        <div className="px-6 py-4 border-b border-gray-200 bg-gray-50">
          <h3 className="text-lg font-medium text-gray-900">
            Ventas Pendientes de Procesar ({ventas.length})
          </h3>
        </div>
        
        {ventas.length === 0 ? (
          <div className="px-6 py-12 text-center">
            <CheckCircle className="mx-auto h-12 w-12 text-gray-400" />
            <h3 className="mt-2 text-sm font-medium text-gray-900">No hay ventas pendientes</h3>
            <p className="mt-1 text-sm text-gray-500">
              Agrega ventas arriba. Se procesarán en el Cierre de Día.
            </p>
          </div>
        ) : (
          <table className="min-w-full divide-y divide-gray-200">
            <thead className="bg-gray-50">
              <tr>
                <th className="px-6 py-3 text-left text-xs font-medium text-gray-500 uppercase">Producto</th>
                <th className="px-6 py-3 text-left text-xs font-medium text-gray-500 uppercase">Cantidad</th>
                <th className="px-6 py-3 text-left text-xs font-medium text-gray-500 uppercase">Fecha</th>
                <th className="px-6 py-3 text-left text-xs font-medium text-gray-500 uppercase">Comentarios</th>
                <th className="px-6 py-3 text-left text-xs font-medium text-gray-500 uppercase">Acciones</th>
              </tr>
            </thead>
            <tbody className="bg-white divide-y divide-gray-200">
              {ventas.map((venta) => (
                <tr key={venta.id} className="hover:bg-gray-50">
                  <td className="px-6 py-4 whitespace-nowrap text-sm font-medium text-gray-900">
                    {getProductoNombre(venta.producto_id)}
                  </td>
                  <td className="px-6 py-4 whitespace-nowrap text-sm text-gray-900">
                    {venta.cantidad}
                  </td>
                  <td className="px-6 py-4 whitespace-nowrap text-sm text-gray-500">
                    {venta.fecha.split('-').reverse().join('/')}
                  </td>
                  <td className="px-6 py-4 text-sm text-gray-500 max-w-xs truncate">
                    {venta.comentarios || '-'}
                  </td>
                  <td className="px-6 py-4 whitespace-nowrap text-sm">
                    <button
                      onClick={() => eliminarVenta(venta.id!)}
                      className="text-red-600 hover:text-red-900 inline-flex items-center"
                    >
                      <Trash2 className="w-4 h-4 mr-1" />
                      Eliminar
                    </button>
                  </td>
                </tr>
              ))}
            </tbody>
          </table>
        )}
      </div>

      <div className="mt-6 bg-blue-50 border border-blue-200 rounded-lg p-4">
        <h4 className="text-sm font-medium text-blue-900 mb-2">ℹ️ ¿Cómo funciona?</h4>
        <ul className="text-sm text-blue-700 space-y-1">
          <li>• Agrega todas las ventas del día aquí</li>
          <li>• Al final del día, ve a <strong>Cierre de Día</strong></li>
          <li>• Las ventas se cargarán automáticamente</li>
          <li>• Al procesar el cierre, el stock se descuenta automáticamente</li>
        </ul>
      </div>
    </div>
  )
}
