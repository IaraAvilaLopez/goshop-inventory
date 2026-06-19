import { useEffect, useState } from 'react'
import { supabase } from '../lib/supabase'
import { Calendar, Save, Package } from 'lucide-react'
import { useSucursal } from '../context/SucursalContext'

type VentaPendiente = {
  id: string
  producto_id: string
  producto: string
  cantidad: number
  fecha: string
  comentarios?: string
}

// Función para obtener la fecha actual en zona horaria de Argentina (UTC-3)
function getFechaArgentina(): string {
  const ahora = new Date()
  // Convertir a hora de Argentina (UTC-3)
  const argentinaTime = new Date(ahora.toLocaleString('en-US', { timeZone: 'America/Argentina/Buenos_Aires' }))
  const year = argentinaTime.getFullYear()
  const month = String(argentinaTime.getMonth() + 1).padStart(2, '0')
  const day = String(argentinaTime.getDate()).padStart(2, '0')
  return `${year}-${month}-${day}`
}

export default function CierreDiaNuevo() {
  const { sucursal } = useSucursal()
  const [fecha, setFecha] = useState(getFechaArgentina())
  const [ventasPendientes, setVentasPendientes] = useState<VentaPendiente[]>([])
  const [observaciones, setObservaciones] = useState('')
  const [loading, setLoading] = useState(true)
  const [yaCerrado, setYaCerrado] = useState(false)

  // Verificar cambio de día cada minuto
  useEffect(() => {
    const interval = setInterval(() => {
      const fechaActual = getFechaArgentina()
      if (fechaActual !== fecha) {
        console.log('🔄 Cambio de día detectado:', fecha, '→', fechaActual)
        setFecha(fechaActual)
      }
    }, 60000) // Verificar cada minuto

    return () => clearInterval(interval)
  }, [fecha])

  useEffect(() => {
    cargarDatosDia()
  }, [fecha, sucursal])

  async function cargarDatosDia() {
    setLoading(true)
    try {
      // Cargar ventas pendientes
      const { data: ventas, error: errorVentas } = await supabase
        .from('ventas_pendientes')
        .select(`
          id,
          producto_id,
          cantidad,
          fecha,
          procesada,
          comentarios,
          productos:producto_id (marca, modelo, capacidad_gb)
        `)
        .eq('fecha', fecha)
        .eq('procesada', false)
        .eq('ubicacion', sucursal)

      if (errorVentas) throw errorVentas

      const ventasFormateadas = (ventas || []).map((v: any) => ({
        id: v.id,
        producto_id: v.producto_id,
        producto: `${v.productos?.marca || ''} ${v.productos?.modelo || ''} ${v.productos?.capacidad_gb || ''}`.trim(),
        cantidad: v.cantidad,
        fecha: v.fecha,
        comentarios: v.comentarios
      }))

      setVentasPendientes(ventasFormateadas)

      // Verificar si ya hay un cierre para este día y sucursal
      const { data: cierre } = await supabase
        .from('cierres_dia')
        .select('id')
        .eq('fecha_cierre', fecha)
        .eq('ubicacion', sucursal)
        .single()

      setYaCerrado(!!cierre)

    } catch (error) {
      console.error('Error cargando datos del día:', error)
    } finally {
      setLoading(false)
    }
  }

  async function procesarCierre() {
    if (ventasPendientes.length === 0) {
      alert('⚠️ No hay ventas pendientes para procesar')
      return
    }

    const totalVentasPendientes = ventasPendientes.reduce((sum, v) => sum + v.cantidad, 0)
    
    const [year, month, day] = fecha.split('-')
    const fechaFormateada = `${day}/${month}/${year}`
    
    if (!confirm(
      `¿Procesar cierre del día ${fechaFormateada}?\n\n` +
      `✅ Se procesarán ${totalVentasPendientes} unidades de VENTAS PENDIENTES\n` +
      `ℹ️ Las compras, transferencias y canjes YA modificaron el stock cuando se registraron\n\n` +
      `Solo se descontarán las ventas del stock.`
    )) {
      return
    }

    try {
      // IMPORTANTE: Solo se procesan las VENTAS PENDIENTES
      // Las COMPRAS, TRANSFERENCIAS y CANJES ya modificaron el stock cuando se crearon
      // Aquí solo se crean transacciones CIERRE_DIA para las ventas
      
      // Obtener hora actual de Argentina (UTC-3)
      const now = new Date()
      const argentinaOffset = -3 * 60 // UTC-3 en minutos
      const localTime = new Date(now.getTime() + (argentinaOffset + now.getTimezoneOffset()) * 60000)
      const fechaCierre = localTime.toISOString()
      
      for (const venta of ventasPendientes) {
        // Combinar observaciones del cierre con comentarios de la venta
        const observacionesCompletas = [
          observaciones || 'Cierre de día',
          venta.comentarios ? `Venta: ${venta.comentarios}` : null
        ].filter(Boolean).join(' | ')
        
        const { error } = await supabase.from('transacciones').insert([{
          producto_id: venta.producto_id,
          tipo_transaccion: 'CIERRE_DIA',
          cantidad: venta.cantidad,
          precio_unitario: 0,
          precio_total: 0,
          fecha_transaccion: fechaCierre,
          observaciones: observacionesCompletas,
          ubicacion: sucursal,
        }])

        if (error) throw error
      }

      const totalVentas = ventasPendientes.reduce((sum, v) => sum + v.cantidad, 0)

      // Crear registro de cierre
      const { error: cierreError } = await supabase.from('cierres_dia').insert([{
        fecha_cierre: fecha,
        ubicacion: sucursal,
        total_ventas: totalVentas,
        observaciones,
      }])

      if (cierreError) throw cierreError

      // Marcar ventas como procesadas
      await supabase
        .from('ventas_pendientes')
        .update({ procesada: true })
        .eq('fecha', fecha)
        .eq('procesada', false)
        .eq('ubicacion', sucursal)

      alert('✅ Cierre procesado exitosamente. El stock se ha actualizado automáticamente.')
      
      // Recargar datos
      setObservaciones('')
      cargarDatosDia()
    } catch (error: any) {
      console.error('Error processing closure:', error)
      alert(`❌ Error al procesar cierre: ${error.message}`)
    }
  }

  async function reiniciarCierre() {
    const [year, month, day] = fecha.split('-')
    const fechaFormateada = `${day}/${month}/${year}`
    
    if (!confirm(
      `¿Reiniciar el cierre del día ${fechaFormateada}?\n\n` +
      `⚠️ ADVERTENCIA:\n` +
      `• Se eliminará el cierre procesado\n` +
      `• Se restaurará el stock automáticamente\n` +
      `• Las ventas volverán a estado PENDIENTE\n` +
      `• Podrá modificar o eliminar las ventas antes de volver a procesar\n\n` +
      `¿Estás seguro?`
    )) {
      return
    }

    try {
      // PASO 1: Marcar ventas como NO procesadas (esto restaura el stock vía trigger)
      const { error: errorVentas } = await supabase
        .from('ventas_pendientes')
        .update({ procesada: false })
        .eq('fecha', fecha)
        .eq('ubicacion', sucursal)
        .eq('procesada', true)

      if (errorVentas) throw errorVentas

      // PASO 2: Eliminar transacciones CIERRE_DIA (NO restaura stock con trigger corregido)
      const inicioFecha = `${fecha}T00:00:00`
      const finFecha = `${fecha}T23:59:59`
      
      const { error: errorTrans } = await supabase
        .from('transacciones')
        .delete()
        .eq('tipo_transaccion', 'CIERRE_DIA')
        .eq('ubicacion', sucursal)
        .gte('fecha_transaccion', inicioFecha)
        .lte('fecha_transaccion', finFecha)

      if (errorTrans) throw errorTrans

      // PASO 3: Eliminar el registro de cierre
      const { error: errorCierre } = await supabase
        .from('cierres_dia')
        .delete()
        .eq('fecha_cierre', fecha)
        .eq('ubicacion', sucursal)

      if (errorCierre) throw errorCierre

      alert('✅ Cierre reiniciado. Las ventas vuelven a estar pendientes y el stock fue restaurado.')
      cargarDatosDia()
    } catch (error: any) {
      console.error('Error resetting closure:', error)
      alert(`❌ Error al reiniciar cierre: ${error.message}`)
    }
  }

  if (loading) {
    return <div className="flex items-center justify-center h-64">Cargando...</div>
  }

  return (
    <div className="px-4 py-6 sm:px-0">
      <div className="flex justify-between items-center mb-6">
        <h2 className="text-2xl font-bold text-gray-900">Cierre de Día</h2>
        <div className="flex items-center gap-4">
          <Calendar className="w-5 h-5 text-gray-500" />
          <input
            type="date"
            value={fecha}
            onChange={(e) => setFecha(e.target.value)}
            className="rounded-md border-gray-300 shadow-sm focus:border-blue-500 focus:ring-blue-500"
          />
        </div>
      </div>

      {/* Estado del cierre */}
      <div className="mb-6 flex items-center gap-4">
        <div className="bg-blue-50 border border-blue-200 rounded-lg p-4 inline-block">
          <div className="flex items-center gap-2 mb-2">
            <Package className="w-5 h-5 text-blue-600" />
            <h3 className="font-semibold text-blue-900">Estado</h3>
          </div>
          {yaCerrado ? (
            <p className="text-sm text-blue-700">Día cerrado</p>
          ) : (
            <p className="text-sm text-blue-700">Pendiente de cierre</p>
          )}
        </div>
        
        {yaCerrado && (
          <button
            onClick={reiniciarCierre}
            className="px-4 py-2 bg-orange-600 text-white rounded-md hover:bg-orange-700 transition-colors text-sm font-medium"
          >
            Reiniciar Cierre
          </button>
        )}
      </div>

      {/* Detalle de transacciones del día */}
      <div className="bg-white shadow rounded-lg p-6 mb-6">
        <h3 className="text-lg font-medium text-gray-900 mb-4">Detalle del Día</h3>
        
        {ventasPendientes.length === 0 ? (
          <p className="text-gray-500 text-center py-8">No hay ventas pendientes para este día</p>
        ) : (
          <div className="space-y-4">
            {/* Ventas Pendientes */}
            <div>
              <h4 className="font-medium text-red-700 mb-2">Ventas Pendientes de Procesar</h4>
                <div className="space-y-2">
                  {ventasPendientes.map(v => (
                    <div key={v.id} className="flex items-center justify-between text-sm pl-4 pr-2">
                      <span className="text-gray-600">• {v.producto} - {v.cantidad} unidades</span>
                      <button
                        onClick={async () => {
                          if (!confirm(`¿Eliminar esta venta pendiente?\n${v.producto} - ${v.cantidad} unidades`)) return
                          try {
                            const { error } = await supabase
                              .from('ventas_pendientes')
                              .delete()
                              .eq('id', v.id)
                            
                            if (error) throw error
                            
                            alert('✅ Venta pendiente eliminada')
                            cargarDatosDia()
                          } catch (error: any) {
                            console.error('Error eliminando venta:', error)
                            alert(`❌ Error: ${error.message}`)
                          }
                        }}
                        className="text-red-600 hover:text-red-800 text-xs font-medium"
                      >
                        Eliminar
                      </button>
                    </div>
                  ))}
                </div>
            </div>
          </div>
        )}
      </div>

      {/* Procesar cierre */}
      {!yaCerrado && ventasPendientes.length > 0 && (
        <div className="bg-white shadow rounded-lg p-6">
          <h3 className="text-lg font-medium text-gray-900 mb-4">Procesar Cierre</h3>
          
          <div className="mb-4">
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

          <div className="bg-blue-50 border border-blue-200 rounded-lg p-4 mb-4">
            <h4 className="text-sm font-medium text-blue-900 mb-2">ℹ️ Información importante</h4>
            <ul className="text-sm text-blue-700 space-y-1">
              <li>• Las <strong>compras, transferencias y canjes</strong> ya modificaron el stock cuando se registraron</li>
              <li>• Al procesar el cierre, solo se descontarán las <strong>{ventasPendientes.length} ventas pendientes</strong> ({ventasPendientes.reduce((sum, v) => sum + v.cantidad, 0)} unidades)</li>
              <li>• El stock NO se modificará dos veces</li>
            </ul>
          </div>

          <div className="flex justify-end">
            <button
              onClick={procesarCierre}
              className="inline-flex items-center px-6 py-3 border border-transparent text-base font-medium rounded-md shadow-sm text-white bg-blue-600 hover:bg-blue-700"
            >
              <Save className="w-5 h-5 mr-2" />
              Procesar Cierre del Día
            </button>
          </div>
        </div>
      )}

      {yaCerrado && (
        <div className="bg-green-50 border border-green-200 rounded-lg p-4">
          <p className="text-green-700">✅ El cierre de este día ya fue procesado</p>
        </div>
      )}
    </div>
  )
}
