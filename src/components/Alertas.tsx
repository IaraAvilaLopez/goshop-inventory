import { useEffect, useState } from 'react'
import { supabase } from '../lib/supabase'
import { useSucursal } from '../context/SucursalContext'
import { AlertTriangle, CheckCircle } from 'lucide-react'
import { formatDateTime } from '../lib/utils'

type AlertaView = {
  alerta_id: string
  modelo: string
  marca: string
  color: string | null
  capacidad_gb: string
  cantidad_actual: number
  cantidad_minima: number
  ubicacion: string
  fecha_alerta: string
  estado_alerta: string
}

export default function Alertas() {
  const { sucursal } = useSucursal()
  const [alertas, setAlertas] = useState<AlertaView[]>([])
  const [loading, setLoading] = useState(true)

  useEffect(() => {
    if (sucursal) {
      fetchAlertas()
    }
  }, [sucursal])

  async function fetchAlertas() {
    try {
      const { data, error } = await supabase
        .from('alertas_stock')
        .select(`
          alerta_id:id,
          cantidad_actual,
          cantidad_minima,
          ubicacion,
          fecha_alerta:created_at,
          estado_alerta,
          productos:producto_id (
            modelo,
            marca,
            color,
            capacidad_gb
          )
        `)
        .eq('ubicacion', sucursal)
        .eq('estado_alerta', 'ACTIVA')
        .order('created_at', { ascending: false })

      if (error) throw error
      
      // Mapear datos para que coincidan con el tipo AlertaView
      const alertasMapeadas = (data || []).map((item: any) => ({
        alerta_id: item.alerta_id,
        modelo: item.productos?.modelo || '',
        marca: item.productos?.marca || '',
        color: item.productos?.color || null,
        capacidad_gb: item.productos?.capacidad_gb || '',
        cantidad_actual: item.cantidad_actual,
        cantidad_minima: item.cantidad_minima,
        ubicacion: item.ubicacion,
        fecha_alerta: item.fecha_alerta,
        estado_alerta: item.estado_alerta
      }))
      
      setAlertas(alertasMapeadas)
    } catch (error) {
      console.error('Error fetching alerts:', error)
    } finally {
      setLoading(false)
    }
  }

  async function resolverAlerta(alertaId: string) {
    if (!confirm('¿Marcar esta alerta como resuelta? Esto indica que ya restauraste el stock o compensaste con otro producto.')) {
      return
    }

    try {
      const { error } = await supabase
        .from('alertas_stock')
        .update({ estado_alerta: 'RESUELTA', fecha_resolucion: new Date().toISOString() })
        .eq('id', alertaId)

      if (error) throw error

      alert('✅ Alerta resuelta correctamente')
      fetchAlertas()
    } catch (error) {
      console.error('Error resolving alert:', error)
      alert('❌ Error al resolver alerta')
    }
  }

  if (loading) {
    return <div className="flex items-center justify-center h-64">Cargando...</div>
  }

  return (
    <div className="px-4 py-6 sm:px-0">
      <div className="flex justify-between items-center mb-6">
        <h2 className="text-2xl font-bold text-gray-900">Alertas de Stock</h2>
        <div className="flex items-center">
          <AlertTriangle className="w-5 h-5 text-red-500 mr-2" />
          <span className="text-lg font-semibold text-gray-700">{alertas.length} alertas activas</span>
        </div>
      </div>

      {alertas.length === 0 ? (
        <div className="bg-white shadow rounded-lg p-8 text-center">
          <CheckCircle className="w-16 h-16 text-green-500 mx-auto mb-4" />
          <h3 className="text-lg font-medium text-gray-900 mb-2">¡Todo en orden!</h3>
          <p className="text-gray-500">No hay alertas de stock bajo en este momento</p>
        </div>
      ) : (
        <div className="bg-white shadow rounded-lg overflow-hidden">
          <table className="min-w-full divide-y divide-gray-200">
            <thead className="bg-gray-50">
              <tr>
                <th className="px-6 py-3 text-left text-xs font-medium text-gray-500 uppercase">Producto</th>
                <th className="px-6 py-3 text-left text-xs font-medium text-gray-500 uppercase">Color</th>
                <th className="px-6 py-3 text-left text-xs font-medium text-gray-500 uppercase">Capacidad</th>
                <th className="px-6 py-3 text-left text-xs font-medium text-gray-500 uppercase">Stock Actual</th>
                <th className="px-6 py-3 text-left text-xs font-medium text-gray-500 uppercase">Stock Mínimo</th>
                <th className="px-6 py-3 text-left text-xs font-medium text-gray-500 uppercase">Ubicación</th>
                <th className="px-6 py-3 text-left text-xs font-medium text-gray-500 uppercase">Fecha</th>
                <th className="px-6 py-3 text-left text-xs font-medium text-gray-500 uppercase">Acción</th>
              </tr>
            </thead>
            <tbody className="bg-white divide-y divide-gray-200">
              {alertas.map((alerta) => (
                <tr key={alerta.alerta_id} className="hover:bg-gray-50">
                  <td className="px-6 py-4 whitespace-nowrap text-sm font-medium text-gray-900">
                    {alerta.marca} {alerta.modelo}
                  </td>
                  <td className="px-6 py-4 whitespace-nowrap text-sm text-gray-500">
                    {alerta.color || '-'}
                  </td>
                  <td className="px-6 py-4 whitespace-nowrap text-sm text-gray-500">
                    {alerta.capacidad_gb}
                  </td>
                  <td className="px-6 py-4 whitespace-nowrap">
                    <span className="px-2 inline-flex text-xs leading-5 font-semibold rounded-full bg-red-100 text-red-800">
                      {alerta.cantidad_actual}
                    </span>
                  </td>
                  <td className="px-6 py-4 whitespace-nowrap text-sm text-gray-500">
                    {alerta.cantidad_minima}
                  </td>
                  <td className="px-6 py-4 whitespace-nowrap text-sm text-gray-500">
                    {alerta.ubicacion}
                  </td>
                  <td className="px-6 py-4 whitespace-nowrap text-sm text-gray-500">
                    {formatDateTime(alerta.fecha_alerta)}
                  </td>
                  <td className="px-6 py-4 whitespace-nowrap text-sm">
                    <button
                      onClick={() => resolverAlerta(alerta.alerta_id)}
                      className="inline-flex items-center px-3 py-1.5 bg-green-600 hover:bg-green-700 text-white rounded-md font-medium transition-colors"
                    >
                      <CheckCircle className="w-4 h-4 mr-1" />
                      Resolver
                    </button>
                  </td>
                </tr>
              ))}
            </tbody>
          </table>
        </div>
      )}
    </div>
  )
}
