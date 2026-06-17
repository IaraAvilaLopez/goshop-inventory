import { useEffect, useState } from 'react'
import { supabase } from '../lib/supabase'
import { Package, ShoppingCart, Calendar, TrendingUp } from 'lucide-react'
import { useSucursal } from '../context/SucursalContext'

type VentasPorDia = {
  fecha: string
  total_unidades: number
}

type ProductoMasVendido = {
  producto_id: string
  marca: string
  modelo: string
  capacidad_gb: string
  total_vendido: number
}

export default function Reportes() {
  const { sucursal } = useSucursal()
  const [ventasPorDia, setVentasPorDia] = useState<VentasPorDia[]>([])
  const [productosMasVendidos, setProductosMasVendidos] = useState<ProductoMasVendido[]>([])
  const [loading, setLoading] = useState(true)
  const [periodo, setPeriodo] = useState<'dia' | 'semana' | 'mes'>('dia')
  const [fechaSeleccionada, setFechaSeleccionada] = useState(() => {
    const now = new Date()
    const argentinaOffset = -3 * 60
    const localTime = new Date(now.getTime() + (argentinaOffset + now.getTimezoneOffset()) * 60000)
    return localTime.toISOString().split('T')[0]
  })

  useEffect(() => {
    fetchReportes()
  }, [periodo, fechaSeleccionada, sucursal])

  function calcularRangoFechas() {
    let fechaDesde: string
    let fechaHasta: string
    
    // Parsear fecha correctamente (año, mes-1, día)
    const partes = fechaSeleccionada.split('-')
    const fecha = new Date(parseInt(partes[0]), parseInt(partes[1]) - 1, parseInt(partes[2]))
    
    if (periodo === 'dia') {
      fechaDesde = fechaSeleccionada
      fechaHasta = fechaSeleccionada
    } else if (periodo === 'semana') {
      // Lunes de la semana
      const dia = fecha.getDay()
      const diff = fecha.getDate() - dia + (dia === 0 ? -6 : 1)
      const lunes = new Date(fecha)
      lunes.setDate(diff)
      
      const year = lunes.getFullYear()
      const month = String(lunes.getMonth() + 1).padStart(2, '0')
      const day = String(lunes.getDate()).padStart(2, '0')
      fechaDesde = `${year}-${month}-${day}`
      
      // Domingo de la semana
      const domingo = new Date(lunes)
      domingo.setDate(lunes.getDate() + 6)
      
      const yearD = domingo.getFullYear()
      const monthD = String(domingo.getMonth() + 1).padStart(2, '0')
      const dayD = String(domingo.getDate()).padStart(2, '0')
      fechaHasta = `${yearD}-${monthD}-${dayD}`
    } else {
      // Primer día del mes
      const year = fecha.getFullYear()
      const month = String(fecha.getMonth() + 1).padStart(2, '0')
      fechaDesde = `${year}-${month}-01`
      
      // Último día del mes
      const ultimoDia = new Date(fecha.getFullYear(), fecha.getMonth() + 1, 0)
      const yearU = ultimoDia.getFullYear()
      const monthU = String(ultimoDia.getMonth() + 1).padStart(2, '0')
      const dayU = String(ultimoDia.getDate()).padStart(2, '0')
      fechaHasta = `${yearU}-${monthU}-${dayU}`
    }
    
    return { fechaDesde, fechaHasta }
  }

  async function fetchReportes() {
    try {
      const { fechaDesde, fechaHasta } = calcularRangoFechas()
      
      const fechaDesdeCompleta = `${fechaDesde}T00:00:00`
      const fechaHastaCompleta = `${fechaHasta}T23:59:59`
      
      const { data: transacciones, error } = await supabase
        .from('transacciones')
        .select(`
          *,
          productos:producto_id (marca, modelo, capacidad_gb)
        `)
        .eq('ubicacion', sucursal)
        .in('tipo_transaccion', ['VENTA', 'CIERRE_DIA'])
        .gte('fecha_transaccion', fechaDesdeCompleta)
        .lte('fecha_transaccion', fechaHastaCompleta)
        .order('fecha_transaccion', { ascending: true })

      if (error) throw error

      const ventasPorFecha: { [key: string]: number } = {}
      const ventasPorProducto: { [key: string]: { producto: any; total: number } } = {}

      transacciones?.forEach(t => {
        const fecha = new Date(t.fecha_transaccion).toISOString().split('T')[0]
        
        if (!ventasPorFecha[fecha]) {
          ventasPorFecha[fecha] = 0
        }
        ventasPorFecha[fecha] += t.cantidad

        if (!ventasPorProducto[t.producto_id]) {
          ventasPorProducto[t.producto_id] = {
            producto: t.productos,
            total: 0
          }
        }
        ventasPorProducto[t.producto_id].total += t.cantidad
      })

      const ventasDia = Object.entries(ventasPorFecha).map(([fecha, unidades]) => ({
        fecha,
        total_unidades: unidades
      }))

      const productosMasVendidos = Object.entries(ventasPorProducto)
        .map(([id, data]) => ({
          producto_id: id,
          marca: data.producto?.marca || '',
          modelo: data.producto?.modelo || '',
          capacidad_gb: data.producto?.capacidad_gb || '',
          total_vendido: data.total
        }))
        .sort((a, b) => b.total_vendido - a.total_vendido)
        .slice(0, 10)

      setVentasPorDia(ventasDia)
      setProductosMasVendidos(productosMasVendidos)
    } catch (error) {
      console.error('Error fetching reports:', error)
    } finally {
      setLoading(false)
    }
  }

  const totalUnidades = ventasPorDia.reduce((sum, v) => sum + v.total_unidades, 0)
  const promedioUnidadesDia = ventasPorDia.length > 0 ? totalUnidades / ventasPorDia.length : 0
  const diasConVentas = ventasPorDia.length

  if (loading) {
    return <div className="flex items-center justify-center h-64">Cargando reportes...</div>
  }

  return (
    <div className="px-4 py-6 sm:px-0">
      <div className="mb-6">
        <h2 className="text-2xl font-bold text-gray-900">Reportes y Estadísticas</h2>
        <p className="mt-1 text-sm text-gray-600">Análisis de ventas y rendimiento</p>
      </div>

      {/* Pestañas de Período */}
      <div className="bg-white shadow rounded-lg mb-6">
        <div className="border-b border-gray-200">
          <nav className="-mb-px flex" aria-label="Tabs">
            <button
              onClick={() => setPeriodo('dia')}
              className={`w-1/3 py-4 px-1 text-center border-b-2 font-medium text-sm ${
                periodo === 'dia'
                  ? 'border-green-700 text-green-700'
                  : 'border-transparent text-gray-500 hover:text-gray-700 hover:border-gray-300'
              }`}
            >
              <Calendar className="w-5 h-5 mx-auto mb-1" />
              Diario
            </button>
            <button
              onClick={() => setPeriodo('semana')}
              className={`w-1/3 py-4 px-1 text-center border-b-2 font-medium text-sm ${
                periodo === 'semana'
                  ? 'border-green-700 text-green-700'
                  : 'border-transparent text-gray-500 hover:text-gray-700 hover:border-gray-300'
              }`}
            >
              <TrendingUp className="w-5 h-5 mx-auto mb-1" />
              Semanal
            </button>
            <button
              onClick={() => setPeriodo('mes')}
              className={`w-1/3 py-4 px-1 text-center border-b-2 font-medium text-sm ${
                periodo === 'mes'
                  ? 'border-green-700 text-green-700'
                  : 'border-transparent text-gray-500 hover:text-gray-700 hover:border-gray-300'
              }`}
            >
              <Package className="w-5 h-5 mx-auto mb-1" />
              Mensual
            </button>
          </nav>
        </div>
        
        {/* Selector de Fecha */}
        <div className="p-6">
          <label className="block text-sm font-medium text-gray-700 mb-2">
            {periodo === 'dia' && 'Seleccionar Día'}
            {periodo === 'semana' && 'Seleccionar Semana (cualquier día de la semana)'}
            {periodo === 'mes' && 'Seleccionar Mes'}
          </label>
          <input
            type="date"
            value={fechaSeleccionada}
            onChange={(e) => setFechaSeleccionada(e.target.value)}
            className="w-full rounded-md border-gray-300 shadow-sm focus:border-green-700 focus:ring-green-700"
          />
          
          {/* Indicador de Rango */}
          {(() => {
            const { fechaDesde, fechaHasta } = calcularRangoFechas()
            const formatearFecha = (fecha: string) => {
              const partes = fecha.split('-')
              return `${partes[2]}/${partes[1]}/${partes[0]}`
            }
            
            if (periodo !== 'dia') {
              return (
                <div className="mt-3 p-3 bg-green-50 border border-green-200 rounded-md">
                  <p className="text-sm text-green-800">
                    <span className="font-semibold">Período seleccionado:</span> {formatearFecha(fechaDesde)} al {formatearFecha(fechaHasta)}
                  </p>
                </div>
              )
            }
            return null
          })()}
        </div>
      </div>

      <div className="grid grid-cols-1 gap-5 sm:grid-cols-3 mb-8">
        <div className="bg-white overflow-hidden shadow rounded-lg">
          <div className="p-5">
            <div className="flex items-center">
              <div className="flex-shrink-0">
                <Package className="h-6 w-6" style={{ color: '#6B7456' }} />
              </div>
              <div className="ml-5 w-0 flex-1">
                <dl>
                  <dt className="text-sm font-medium text-gray-500 truncate">Total Unidades Vendidas</dt>
                  <dd className="text-2xl font-bold text-gray-900">{totalUnidades}</dd>
                </dl>
              </div>
            </div>
          </div>
        </div>

        <div className="bg-white overflow-hidden shadow rounded-lg">
          <div className="p-5">
            <div className="flex items-center">
              <div className="flex-shrink-0">
                <ShoppingCart className="h-6 w-6" style={{ color: '#6B7456' }} />
              </div>
              <div className="ml-5 w-0 flex-1">
                <dl>
                  <dt className="text-sm font-medium text-gray-500 truncate">Promedio Unidades/Día</dt>
                  <dd className="text-2xl font-bold text-gray-900">{promedioUnidadesDia.toFixed(1)}</dd>
                </dl>
              </div>
            </div>
          </div>
        </div>

        <div className="bg-white overflow-hidden shadow rounded-lg">
          <div className="p-5">
            <div className="flex items-center">
              <div className="flex-shrink-0">
                <Package className="h-6 w-6" style={{ color: '#6B7456' }} />
              </div>
              <div className="ml-5 w-0 flex-1">
                <dl>
                  <dt className="text-sm font-medium text-gray-500 truncate">Días con Ventas</dt>
                  <dd className="text-2xl font-bold text-gray-900">{diasConVentas}</dd>
                </dl>
              </div>
            </div>
          </div>
        </div>
      </div>

      <div className="grid grid-cols-1 lg:grid-cols-2 gap-6">
        <div className="bg-white shadow rounded-lg p-6">
          <h3 className="text-lg font-medium text-gray-900 mb-4">Ventas por Día</h3>
          <div className="space-y-2">
            {ventasPorDia.length === 0 ? (
              <p className="text-gray-500 text-center py-8">No hay ventas en este período</p>
            ) : (
              ventasPorDia.map((venta) => {
                const maxVenta = Math.max(...ventasPorDia.map(v => v.total_unidades))
                const porcentaje = (venta.total_unidades / maxVenta) * 100
                
                return (
                  <div key={venta.fecha} className="space-y-1">
                    <div className="flex justify-between text-sm">
                      <span className="text-gray-600">
                        {venta.fecha.split('-').reverse().join('/')}
                      </span>
                      <span className="font-medium text-gray-900">
                        {venta.total_unidades} unidades
                      </span>
                    </div>
                    <div className="w-full bg-gray-200 rounded-full h-2">
                      <div
                        className="h-2 rounded-full"
                        style={{ 
                          width: `${porcentaje}%`,
                          backgroundColor: '#6B7456'
                        }}
                      />
                    </div>
                  </div>
                )
              })
            )}
          </div>
        </div>

        <div className="bg-white shadow rounded-lg p-6">
          <h3 className="text-lg font-medium text-gray-900 mb-4">Productos Más Vendidos</h3>
          <div className="space-y-3">
            {productosMasVendidos.length === 0 ? (
              <p className="text-gray-500 text-center py-8">No hay datos de productos</p>
            ) : (
              productosMasVendidos.map((producto, index) => (
                <div key={producto.producto_id} className="flex items-center justify-between">
                  <div className="flex items-center gap-3">
                    <div 
                      className="w-8 h-8 rounded-full flex items-center justify-center text-white font-bold text-sm"
                      style={{ backgroundColor: '#6B7456' }}
                    >
                      {index + 1}
                    </div>
                    <div>
                      <p className="text-sm font-medium text-gray-900">
                        {producto.marca} {producto.modelo}
                      </p>
                      <p className="text-xs text-gray-500">{producto.capacidad_gb}</p>
                    </div>
                  </div>
                  <span className="text-sm font-semibold text-gray-900">
                    {producto.total_vendido} vendidos
                  </span>
                </div>
              ))
            )}
          </div>
        </div>
      </div>
    </div>
  )
}
