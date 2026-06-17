import { useEffect, useState } from 'react'
import { supabase } from '../lib/supabase'
import { AlertTriangle, X } from 'lucide-react'

type Alerta = {
  id: string
  producto_id: string
  tipo_alerta: string
  mensaje: string
  cantidad_actual: number
  created_at: string
  productos?: {
    marca: string
    modelo: string
    capacidad_gb: string
  }
}

type NotificacionesAlertasProps = {
  onNavigateToAlertas: () => void
}

export default function NotificacionesAlertas({ onNavigateToAlertas }: NotificacionesAlertasProps) {
  const [alertasNuevas, setAlertasNuevas] = useState<Alerta[]>([])
  const [alertasVistas, setAlertasVistas] = useState<Set<string>>(new Set())

  useEffect(() => {
    // Cargar alertas al inicio
    cargarAlertas()

    // Suscribirse a cambios en tiempo real
    const subscription = supabase
      .channel('alertas_changes')
      .on(
        'postgres_changes',
        {
          event: 'INSERT',
          schema: 'public',
          table: 'alertas_stock'
        },
        (payload) => {
          console.log('Nueva alerta detectada:', payload)
          cargarAlertas()
        }
      )
      .subscribe()

    return () => {
      subscription.unsubscribe()
    }
  }, [])

  async function cargarAlertas() {
    try {
      const { data, error } = await supabase
        .from('alertas_stock')
        .select(`
          *,
          productos:producto_id (marca, modelo, capacidad_gb)
        `)
        .eq('resuelta', false)
        .order('created_at', { ascending: false })
        .limit(5)

      if (error) throw error

      const alertas = (data || []) as Alerta[]
      
      // Filtrar solo las que no han sido vistas
      const nuevas = alertas.filter(a => !alertasVistas.has(a.id))
      
      if (nuevas.length > 0) {
        setAlertasNuevas(nuevas)
      }
    } catch (error) {
      console.error('Error cargando alertas:', error)
    }
  }

  function cerrarAlerta(id: string) {
    setAlertasVistas(prev => new Set([...prev, id]))
    setAlertasNuevas(prev => prev.filter(a => a.id !== id))
  }

  function irAAlertas(id: string) {
    cerrarAlerta(id)
    onNavigateToAlertas()
  }

  if (alertasNuevas.length === 0) return null

  return (
    <div className="fixed bottom-4 right-4 z-50 space-y-2 max-w-sm">
      {alertasNuevas.map((alerta) => (
        <div
          key={alerta.id}
          className="bg-red-50 border-2 border-red-500 rounded-lg shadow-lg p-4 animate-bounce"
          style={{ animationIterationCount: '3' }}
        >
          <div className="flex items-start gap-3">
            <AlertTriangle className="w-6 h-6 text-red-600 flex-shrink-0 mt-1" />
            <div className="flex-1">
              <h3 className="font-semibold text-red-900 mb-1">
                {alerta.tipo_alerta === 'SIN_STOCK' ? '⚠️ Sin Stock' : '⚠️ Stock Bajo'}
              </h3>
              <p className="text-sm text-red-800 mb-2">
                {alerta.productos?.marca} {alerta.productos?.modelo} {alerta.productos?.capacidad_gb}
              </p>
              <p className="text-sm text-red-700 mb-3">
                {alerta.mensaje}
              </p>
              <div className="flex gap-2">
                <button
                  onClick={() => irAAlertas(alerta.id)}
                  className="flex-1 bg-red-600 text-white px-3 py-2 rounded-md text-sm font-medium hover:bg-red-700"
                >
                  Ver Alertas
                </button>
                <button
                  onClick={() => cerrarAlerta(alerta.id)}
                  className="bg-gray-200 text-gray-700 px-3 py-2 rounded-md text-sm hover:bg-gray-300"
                >
                  <X className="w-4 h-4" />
                </button>
              </div>
            </div>
          </div>
        </div>
      ))}
    </div>
  )
}
