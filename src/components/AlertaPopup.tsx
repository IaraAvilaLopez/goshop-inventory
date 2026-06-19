import { useEffect, useState } from 'react'
import { supabase } from '../lib/supabase'
import { useSucursal } from '../context/SucursalContext'
import { Bell } from 'lucide-react'

type AlertaPopupProps = {
  onNavigateToAlertas: () => void
  currentView: string
}

export default function AlertaPopup({ onNavigateToAlertas, currentView }: AlertaPopupProps) {
  const { sucursal } = useSucursal()
  const [cantidadAlertas, setCantidadAlertas] = useState(0)

  useEffect(() => {
    if (sucursal) {
      verificarAlertas()
      const interval = setInterval(verificarAlertas, 30000)

      const subscription = supabase
        .channel('alertas_changes')
        .on('postgres_changes', {
          event: '*',
          schema: 'public',
          table: 'alertas_stock'
        }, () => {
          verificarAlertas()
        })
        .subscribe()

      return () => {
        clearInterval(interval)
        subscription.unsubscribe()
      }
    }
  }, [sucursal])

  async function verificarAlertas() {
    try {
      const { data, error } = await supabase
        .from('vista_stock_actual')
        .select('producto_id, nivel_stock')
        .eq('ubicacion', sucursal)
        .in('nivel_stock', ['CRÍTICO', 'BAJO'])

      if (error) throw error
      setCantidadAlertas(data?.length || 0)
    } catch (error) {
      console.error('Error verificando alertas:', error)
    }
  }

  // Solo mostrar en dashboard
  if (currentView !== 'dashboard' || cantidadAlertas === 0) {
    return null
  }

  return (
    <button
      onClick={onNavigateToAlertas}
      className="fixed bottom-6 right-6 z-50 bg-red-600 hover:bg-red-700 text-white rounded-full p-4 shadow-lg transition-all hover:scale-110 animate-bounce-in"
      title={`${cantidadAlertas} alerta${cantidadAlertas !== 1 ? 's' : ''} activa${cantidadAlertas !== 1 ? 's' : ''}`}
    >
      <div className="relative">
        <Bell className="w-6 h-6" />
        <span className="absolute -top-2 -right-2 bg-white text-red-600 rounded-full w-6 h-6 flex items-center justify-center text-xs font-bold border-2 border-red-600">
          {cantidadAlertas}
        </span>
      </div>
    </button>
  )
}
