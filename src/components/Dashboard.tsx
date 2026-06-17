import { useEffect, useState } from 'react'
import { supabase, type StockActual } from '../lib/supabase'
import { useSucursal } from '../context/SucursalContext'
import { Package, AlertTriangle, TrendingUp, Bell } from 'lucide-react'

export default function Dashboard() {
  const { sucursal } = useSucursal()
  const [stockData, setStockData] = useState<StockActual[]>([])
  const [loading, setLoading] = useState(true)
  const [stats, setStats] = useState({
    totalProductos: 0,
    stockCritico: 0,
    totalUnidades: 0,
    alertasActivas: 0,
  })

  useEffect(() => {
    if (sucursal) {
      fetchDashboardData()
    }
  }, [sucursal])

  async function fetchDashboardData() {
    try {
      const { data: stock, error: stockError } = await supabase
        .from('vista_stock_actual')
        .select('*')
        .eq('ubicacion', sucursal)

      if (stockError) throw stockError

      const { data: alertas, error: alertasError } = await supabase
        .from('vista_alertas_activas')
        .select('*')
        .eq('ubicacion', sucursal)

      if (alertasError) throw alertasError

      if (stock) {
        setStockData(stock)
        const totalUnidades = stock.reduce((sum, item) => sum + (item.cantidad_actual || 0), 0)
        const stockCritico = stock.filter(item => item.nivel_stock === 'CRÍTICO').length

        setStats({
          totalProductos: stock.length,
          stockCritico,
          totalUnidades,
          alertasActivas: alertas?.length || 0,
        })
      }
    } catch (error) {
      console.error('Error fetching dashboard data:', error)
    } finally {
      setLoading(false)
    }
  }

  if (loading) {
    return (
      <div className="flex items-center justify-center h-64">
        <div className="text-gray-500">Cargando...</div>
      </div>
    )
  }

  return (
    <div className="px-4 py-6 sm:px-0">
      <div className="mb-6">
        <h2 className="text-2xl font-bold text-gray-900">Resumen General</h2>
        <p className="mt-1 text-sm text-gray-600">Vista rápida del estado de tu inventario</p>
      </div>

      <div className="grid grid-cols-1 gap-5 sm:grid-cols-2 lg:grid-cols-4 mb-8">
        <div className="bg-white overflow-hidden shadow rounded-lg">
          <div className="p-5">
            <div className="flex items-center">
              <div className="flex-shrink-0">
                <Package className="h-6 w-6 text-blue-600" />
              </div>
              <div className="ml-5 w-0 flex-1">
                <dl>
                  <dt className="text-sm font-medium text-gray-500 truncate">
                    Total Productos
                  </dt>
                  <dd className="text-3xl font-semibold text-gray-900">
                    {stats.totalProductos}
                  </dd>
                </dl>
              </div>
            </div>
          </div>
        </div>

        <div className="bg-white overflow-hidden shadow rounded-lg">
          <div className="p-5">
            <div className="flex items-center">
              <div className="flex-shrink-0">
                <TrendingUp className="h-6 w-6 text-green-600" />
              </div>
              <div className="ml-5 w-0 flex-1">
                <dl>
                  <dt className="text-sm font-medium text-gray-500 truncate">
                    Total Unidades
                  </dt>
                  <dd className="text-3xl font-semibold text-gray-900">
                    {stats.totalUnidades}
                  </dd>
                </dl>
              </div>
            </div>
          </div>
        </div>

        <div className="bg-white overflow-hidden shadow rounded-lg">
          <div className="p-5">
            <div className="flex items-center">
              <div className="flex-shrink-0">
                <AlertTriangle className="h-6 w-6 text-red-600" />
              </div>
              <div className="ml-5 w-0 flex-1">
                <dl>
                  <dt className="text-sm font-medium text-gray-500 truncate">
                    Stock Crítico
                  </dt>
                  <dd className="text-3xl font-semibold text-gray-900">
                    {stats.stockCritico}
                  </dd>
                </dl>
              </div>
            </div>
          </div>
        </div>

        <div className="bg-white overflow-hidden shadow rounded-lg">
          <div className="p-5">
            <div className="flex items-center">
              <div className="flex-shrink-0">
                <Bell className="h-6 w-6 text-yellow-600" />
              </div>
              <div className="ml-5 w-0 flex-1">
                <dl>
                  <dt className="text-sm font-medium text-gray-500 truncate">
                    Alertas Activas
                  </dt>
                  <dd className="text-3xl font-semibold text-gray-900">
                    {stats.alertasActivas}
                  </dd>
                </dl>
              </div>
            </div>
          </div>
        </div>
      </div>

      <div className="bg-white shadow rounded-lg">
        <div className="px-4 py-5 sm:p-6">
          <h3 className="text-lg font-medium text-gray-900 mb-4">
            Productos con Stock Crítico
          </h3>
          <div className="overflow-x-auto">
            <table className="min-w-full divide-y divide-gray-200">
              <thead className="bg-gray-50">
                <tr>
                  <th className="px-6 py-3 text-left text-xs font-medium text-gray-500 uppercase tracking-wider">
                    Producto
                  </th>
                  <th className="px-6 py-3 text-left text-xs font-medium text-gray-500 uppercase tracking-wider">
                    Color
                  </th>
                  <th className="px-6 py-3 text-left text-xs font-medium text-gray-500 uppercase tracking-wider">
                    Capacidad
                  </th>
                  <th className="px-6 py-3 text-left text-xs font-medium text-gray-500 uppercase tracking-wider">
                    Stock Actual
                  </th>
                  <th className="px-6 py-3 text-left text-xs font-medium text-gray-500 uppercase tracking-wider">
                    Estado
                  </th>
                </tr>
              </thead>
              <tbody className="bg-white divide-y divide-gray-200">
                {stockData
                  .filter(item => item.nivel_stock === 'CRÍTICO')
                  .map((item, index) => (
                    <tr key={index}>
                      <td className="px-6 py-4 whitespace-nowrap text-sm font-medium text-gray-900">
                        {item.marca} {item.modelo}
                      </td>
                      <td className="px-6 py-4 whitespace-nowrap text-sm text-gray-500">
                        {item.color || '-'}
                      </td>
                      <td className="px-6 py-4 whitespace-nowrap text-sm text-gray-500">
                        {item.capacidad_gb}
                      </td>
                      <td className="px-6 py-4 whitespace-nowrap text-sm text-gray-500">
                        {item.cantidad_actual}
                      </td>
                      <td className="px-6 py-4 whitespace-nowrap">
                        <span className="px-2 inline-flex text-xs leading-5 font-semibold rounded-full bg-red-100 text-red-800">
                          {item.nivel_stock}
                        </span>
                      </td>
                    </tr>
                  ))}
                {stockData.filter(item => item.nivel_stock === 'CRÍTICO').length === 0 && (
                  <tr>
                    <td colSpan={5} className="px-6 py-4 text-center text-sm text-gray-500">
                      No hay productos con stock crítico
                    </td>
                  </tr>
                )}
              </tbody>
            </table>
          </div>
        </div>
      </div>
    </div>
  )
}
