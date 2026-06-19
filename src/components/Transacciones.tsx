import { useEffect, useState } from 'react'
import { supabase, type Transaccion, type Producto } from '../lib/supabase'
import { useSucursal } from '../context/SucursalContext'
import { Plus, Trash2, ChevronDown, ChevronRight } from 'lucide-react'

export default function Transacciones() {
  const { sucursal } = useSucursal()
  const [transacciones, setTransacciones] = useState<Transaccion[]>([])
  const [productos, setProductos] = useState<Producto[]>([])
  const [productosOtraSucursal, setProductosOtraSucursal] = useState<Producto[]>([])
  const [loading, setLoading] = useState(true)
  const [showModal, setShowModal] = useState(false)
  const [filterTipo, setFilterTipo] = useState('')
  const [filterFechaDesde, setFilterFechaDesde] = useState('')
  const [filterFechaHasta, setFilterFechaHasta] = useState('')
  const [filterPeriodo, setFilterPeriodo] = useState<'dia' | 'semana' | 'mes' | 'personalizado' | 'todas'>('todas')
  const [diasExpandidos, setDiasExpandidos] = useState<Set<string>>(new Set())
  const [transaccionesExpandidas, setTransaccionesExpandidas] = useState<Set<string>>(new Set())

  const [newTransaccion, setNewTransaccion] = useState<{
    producto_id: string
    tipo_transaccion: string
    cantidad: number
    observaciones: string
  }>({
    producto_id: '',
    tipo_transaccion: 'COMPRA',
    cantidad: 1,
    observaciones: '',
  })

  const [productoTexto, setProductoTexto] = useState('')
  const [mostrarSugerencias, setMostrarSugerencias] = useState(false)
  const [mostrarFormularioOtro, setMostrarFormularioOtro] = useState(false)
  const [mostrarFormularioCelular, setMostrarFormularioCelular] = useState(false)
  const [nuevoProductoOtro, setNuevoProductoOtro] = useState({
    marca: '',
    modelo: '',
    descripcion: '',
    color: '',
  })
  const [nuevoProductoCelular, setNuevoProductoCelular] = useState({
    marca: '',
    modelo: '',
    color: '',
    capacidad_gb: '',
    bateria_porcentaje: '',
  })
  
  // Estado para búsqueda en transferencias
  const [busquedaTransferencia, setBusquedaTransferencia] = useState('')
  const [mostrarListaTransferencia, setMostrarListaTransferencia] = useState(false)

  useEffect(() => {
    if (sucursal) {
      fetchData()
    }
  }, [sucursal])

  async function fetchData() {
    try {
      const otraSucursal = sucursal === 'RESISTENCIA' ? 'CORRIENTES' : 'RESISTENCIA'
      
      // Cargar productos de la SUCURSAL ACTUAL (para COMPRA, CANJE_SALIDA)
      const inventarioActualRes = await supabase
        .from('inventario')
        .select('producto_id, cantidad_actual')
        .eq('ubicacion', sucursal)
        .gt('cantidad_actual', 0)

      if (inventarioActualRes.error) throw inventarioActualRes.error

      const productosIdsActual = inventarioActualRes.data?.map((item: any) => item.producto_id) || []

      const productosActualRes = await supabase
        .from('productos')
        .select('id, marca, modelo, capacidad_gb, color, bateria_porcentaje')
        .in('id', productosIdsActual)

      if (productosActualRes.error) throw productosActualRes.error

      // Cargar productos de la OTRA SUCURSAL (para TRANSFERENCIA)
      const inventarioOtraRes = await supabase
        .from('inventario')
        .select('producto_id, cantidad_actual')
        .eq('ubicacion', otraSucursal)
        .gt('cantidad_actual', 0)

      if (inventarioOtraRes.error) throw inventarioOtraRes.error

      const productosIdsOtra = inventarioOtraRes.data?.map((item: any) => item.producto_id) || []

      const productosOtraRes = await supabase
        .from('productos')
        .select('id, marca, modelo, capacidad_gb, color, bateria_porcentaje')
        .in('id', productosIdsOtra)

      if (productosOtraRes.error) throw productosOtraRes.error

      // Obtener transacciones
      const transRes = await supabase
        .from('transacciones')
        .select(`
          *,
          productos:producto_id (marca, modelo, capacidad_gb, color)
        `)
        .eq('ubicacion', sucursal)
        .order('fecha_transaccion', { ascending: false })
        .limit(500)

      if (transRes.error) throw transRes.error

      setTransacciones(transRes.data || [])
      
      // Mapear productos de la sucursal actual
      const productosActual = (productosActualRes.data || [])
        .map((prod: any) => ({
          id: prod.id || '',
          modelo: prod.modelo || '',
          marca: prod.marca || '',
          color: prod.color || '',
          capacidad_gb: prod.capacidad_gb || '',
          bateria_porcentaje: prod.bateria_porcentaje || null,
          created_at: '',
          updated_at: ''
        }))
        .sort((a, b) => {
          const marcaCompare = a.marca.localeCompare(b.marca)
          if (marcaCompare !== 0) return marcaCompare
          return a.modelo.localeCompare(b.modelo)
        })

      // Mapear productos de la otra sucursal
      const productosOtra = (productosOtraRes.data || [])
        .map((prod: any) => ({
          id: prod.id || '',
          modelo: prod.modelo || '',
          marca: prod.marca || '',
          color: prod.color || '',
          capacidad_gb: prod.capacidad_gb || '',
          bateria_porcentaje: prod.bateria_porcentaje || null,
          created_at: '',
          updated_at: ''
        }))
        .sort((a, b) => {
          const marcaCompare = a.marca.localeCompare(b.marca)
          if (marcaCompare !== 0) return marcaCompare
          return a.modelo.localeCompare(b.modelo)
        })
      
      console.log(`Productos cargados de ${sucursal}:`, productosActual.length)
      console.log(`Productos cargados de ${otraSucursal}:`, productosOtra.length)
      
      setProductos(productosActual)
      setProductosOtraSucursal(productosOtra)
    } catch (error) {
      console.error('Error fetching data:', error)
    } finally {
      setLoading(false)
    }
  }

  async function handleAddTransaccion() {
    try {
      let productoId = newTransaccion.producto_id

      // Si está usando el formulario de "Celular", crear el producto con esos datos
      if (mostrarFormularioCelular && nuevoProductoCelular.marca && nuevoProductoCelular.modelo) {
        const { data: nuevoProducto, error: prodError } = await supabase
          .from('productos')
          .insert([{
            categoria: 'CELULAR',
            marca: nuevoProductoCelular.marca.toUpperCase(),
            modelo: nuevoProductoCelular.modelo.toUpperCase(),
            color: nuevoProductoCelular.color || null,
            capacidad_gb: nuevoProductoCelular.capacidad_gb || null,
            bateria_porcentaje: nuevoProductoCelular.bateria_porcentaje ? parseInt(nuevoProductoCelular.bateria_porcentaje) : null,
            descripcion: null,
          }])
          .select()
          .single()

        if (prodError) throw prodError
        productoId = nuevoProducto.id
      }
      // Si está usando el formulario de "Otro", crear el producto con esos datos
      else if (mostrarFormularioOtro && nuevoProductoOtro.marca && nuevoProductoOtro.modelo) {
        const { data: nuevoProducto, error: prodError } = await supabase
          .from('productos')
          .insert([{
            categoria: 'OTRO',
            marca: nuevoProductoOtro.marca.toUpperCase(),
            modelo: nuevoProductoOtro.modelo.toUpperCase(),
            color: nuevoProductoOtro.color || null,
            capacidad_gb: null,
            descripcion: nuevoProductoOtro.descripcion || null,
          }])
          .select()
          .single()

        if (prodError) throw prodError
        productoId = nuevoProducto.id
      }
      // Si no hay producto_id pero hay texto, crear el producto parseando el texto
      else if (!productoId && productoTexto.trim()) {
        const partes = productoTexto.trim().split(' ')
        const marca = partes[0] || ''
        const modelo = partes.slice(1).join(' ') || ''

        const { data: nuevoProducto, error: prodError } = await supabase
          .from('productos')
          .insert([{
            categoria: 'CELULAR', // Por defecto CELULAR si se escribe texto
            marca: marca.toUpperCase(),
            modelo: modelo.toUpperCase(),
            capacidad_gb: null,
            descripcion: null,
          }])
          .select()
          .single()

        if (prodError) throw prodError
        productoId = nuevoProducto.id
      }

      if (!productoId) {
        alert('Debes seleccionar o escribir un producto')
        return
      }

      const { error } = await supabase.from('transacciones').insert([{
        producto_id: productoId,
        tipo_transaccion: newTransaccion.tipo_transaccion,
        cantidad: newTransaccion.cantidad,
        precio_unitario: 0,
        precio_total: 0,
        observaciones: newTransaccion.observaciones,
        ubicacion: sucursal,
      }])

      if (error) throw error

      alert('Transacción registrada exitosamente. El stock se actualizó automáticamente.')
      setShowModal(false)
      setNewTransaccion({
        producto_id: '',
        tipo_transaccion: 'VENTA',
        cantidad: 1,
        observaciones: '',
      })
      setProductoTexto('')
      setMostrarFormularioOtro(false)
      setMostrarFormularioCelular(false)
      setNuevoProductoOtro({
        marca: '',
        modelo: '',
        descripcion: '',
        color: '',
      })
      setNuevoProductoCelular({
        marca: '',
        modelo: '',
        color: '',
        capacidad_gb: '',
        bateria_porcentaje: '',
      })
      fetchData()
    } catch (error: any) {
      console.error('Error adding transaction:', error)
      alert(`Error al registrar transacción: ${error.message || 'Error desconocido'}`)
    }
  }

  const filteredTransacciones = transacciones.filter(t => {
    let matches = true
    
    if (filterTipo && t.tipo_transaccion !== filterTipo) {
      matches = false
    }
    
    if (filterFechaDesde) {
      const fechaTransaccion = t.fecha_transaccion.split('T')[0]
      if (fechaTransaccion < filterFechaDesde) {
        matches = false
      }
    }
    
    if (filterFechaHasta) {
      const fechaTransaccion = t.fecha_transaccion.split('T')[0]
      if (fechaTransaccion > filterFechaHasta) {
        matches = false
      }
    }
    
    return matches
  })

  const getProductoNombre = (trans: any) => {
    // Primero intentar obtener del objeto productos de la transacción
    if (trans.productos) {
      const prod = trans.productos
      return `${prod.marca || ''} ${prod.modelo || ''} ${prod.capacidad_gb || ''}${prod.color ? ` - ${prod.color}` : ''}`.trim()
    }
    // Si no, buscar en la lista de productos
    const prod = productos.find(p => p.id === trans.producto_id)
    if (!prod) return 'Desconocido'
    return `${prod.marca} ${prod.modelo} ${prod.capacidad_gb}${prod.color ? ` - ${prod.color}` : ''}`
  }

  // Agrupar transacciones por día
  const transaccionesPorDia = filteredTransacciones.reduce((acc: any, trans) => {
    const fecha = trans.fecha_transaccion.split('T')[0]
    if (!acc[fecha]) {
      acc[fecha] = []
    }
    acc[fecha].push(trans)
    return acc
  }, {})

  const diasOrdenados = Object.keys(transaccionesPorDia).sort((a, b) => b.localeCompare(a))

  const toggleDia = (fecha: string) => {
    const newSet = new Set(diasExpandidos)
    if (newSet.has(fecha)) {
      newSet.delete(fecha)
    } else {
      newSet.add(fecha)
    }
    setDiasExpandidos(newSet)
  }

  const formatFecha = (fecha: string) => {
    const [year, month, day] = fecha.split('-')
    return `${day}/${month}/${year}`
  }

  if (loading) {
    return <div className="flex items-center justify-center h-64">Cargando...</div>
  }

  return (
    <div className="px-4 py-6 sm:px-0">
      <div className="flex justify-between items-center mb-6">
        <h2 className="text-2xl font-bold text-gray-900">Transacciones</h2>
        <button
          onClick={() => setShowModal(true)}
          className="inline-flex items-center px-4 py-2 border border-transparent text-sm font-medium rounded-md shadow-sm text-white bg-blue-600 hover:bg-blue-700"
        >
          <Plus className="w-4 h-4 mr-2" />
          Nueva Transacción
        </button>
      </div>

      <div className="bg-white shadow rounded-lg mb-6 p-4">
        <div className="mb-4">
          <label className="block text-sm font-medium text-gray-700 mb-2">Período</label>
          <div className="flex gap-2 flex-wrap">
            <button
              onClick={() => {
                setFilterPeriodo('todas')
                setFilterFechaDesde('')
                setFilterFechaHasta('')
              }}
              className={`px-4 py-2 rounded-md text-sm font-medium ${
                filterPeriodo === 'todas'
                  ? 'bg-blue-600 text-white'
                  : 'bg-gray-100 text-gray-700 hover:bg-gray-200'
              }`}
            >
              Todas
            </button>
            <button
              onClick={() => {
                setFilterPeriodo('dia')
                const hoy = new Date().toISOString().split('T')[0]
                setFilterFechaDesde(hoy)
                setFilterFechaHasta(hoy)
              }}
              className={`px-4 py-2 rounded-md text-sm font-medium ${
                filterPeriodo === 'dia'
                  ? 'bg-blue-600 text-white'
                  : 'bg-gray-100 text-gray-700 hover:bg-gray-200'
              }`}
            >
              Hoy
            </button>
            <button
              onClick={() => {
                setFilterPeriodo('semana')
                const hoy = new Date()
                const hace7dias = new Date(hoy)
                hace7dias.setDate(hoy.getDate() - 7)
                setFilterFechaDesde(hace7dias.toISOString().split('T')[0])
                setFilterFechaHasta(hoy.toISOString().split('T')[0])
              }}
              className={`px-4 py-2 rounded-md text-sm font-medium ${
                filterPeriodo === 'semana'
                  ? 'bg-blue-600 text-white'
                  : 'bg-gray-100 text-gray-700 hover:bg-gray-200'
              }`}
            >
              Última Semana
            </button>
            <button
              onClick={() => {
                setFilterPeriodo('mes')
                const hoy = new Date()
                const hace30dias = new Date(hoy)
                hace30dias.setDate(hoy.getDate() - 30)
                setFilterFechaDesde(hace30dias.toISOString().split('T')[0])
                setFilterFechaHasta(hoy.toISOString().split('T')[0])
              }}
              className={`px-4 py-2 rounded-md text-sm font-medium ${
                filterPeriodo === 'mes'
                  ? 'bg-blue-600 text-white'
                  : 'bg-gray-100 text-gray-700 hover:bg-gray-200'
              }`}
            >
              Último Mes
            </button>
            <button
              onClick={() => setFilterPeriodo('personalizado')}
              className={`px-4 py-2 rounded-md text-sm font-medium ${
                filterPeriodo === 'personalizado'
                  ? 'bg-blue-600 text-white'
                  : 'bg-gray-100 text-gray-700 hover:bg-gray-200'
              }`}
            >
              Personalizado
            </button>
          </div>
        </div>
        
        <div className="grid grid-cols-1 md:grid-cols-3 gap-4">
          <div>
            <label className="block text-sm font-medium text-gray-700 mb-1">Tipo</label>
            <select
              value={filterTipo}
              onChange={(e) => setFilterTipo(e.target.value)}
              className="w-full rounded-md border-gray-300 shadow-sm focus:border-blue-500 focus:ring-blue-500"
            >
              <option value="">Todos los tipos</option>
              <option value="COMPRA">Compra</option>
              <option value="VENTA">Venta</option>
              <option value="CANJE_ENTRADA">Canje Entrada</option>
              <option value="CANJE_SALIDA">Canje Salida</option>
              <option value="TRANSFERENCIA">Transferencia</option>
              <option value="CIERRE_DIA">Cierre de Día</option>
            </select>
          </div>
          <div>
            <label className="block text-sm font-medium text-gray-700 mb-1">Desde</label>
            <input
              type="date"
              value={filterFechaDesde}
              onChange={(e) => {
                setFilterFechaDesde(e.target.value)
                setFilterPeriodo('personalizado')
              }}
              className="w-full rounded-md border-gray-300 shadow-sm focus:border-blue-500 focus:ring-blue-500"
            />
          </div>
          <div>
            <label className="block text-sm font-medium text-gray-700 mb-1">Hasta</label>
            <input
              type="date"
              value={filterFechaHasta}
              onChange={(e) => {
                setFilterFechaHasta(e.target.value)
                setFilterPeriodo('personalizado')
              }}
              className="w-full rounded-md border-gray-300 shadow-sm focus:border-blue-500 focus:ring-blue-500"
            />
          </div>
        </div>
        <div className="mt-3 text-sm text-gray-600">
          Mostrando {filteredTransacciones.length} transacciones
        </div>
      </div>

      <div className="bg-white shadow rounded-lg overflow-hidden">
        <div className="divide-y divide-gray-200">
          {diasOrdenados.map((fecha) => {
            const transaccionesDia = transaccionesPorDia[fecha]
            const isExpanded = diasExpandidos.has(fecha)
            const totalCompras = transaccionesDia.filter((t: any) => t.tipo_transaccion === 'COMPRA').length
            const totalVentas = transaccionesDia.filter((t: any) => t.tipo_transaccion === 'CIERRE_DIA').length
            const totalTransferencias = transaccionesDia.filter((t: any) => t.tipo_transaccion === 'TRANSFERENCIA').length
            const totalCanjes = transaccionesDia.filter((t: any) => t.tipo_transaccion.includes('CANJE')).length

            return (
              <div key={fecha}>
                {/* Cabecera del día */}
                <div
                  onClick={() => toggleDia(fecha)}
                  className="px-6 py-4 bg-gray-50 hover:bg-gray-100 cursor-pointer flex items-center justify-between"
                >
                  <div className="flex items-center gap-3">
                    {isExpanded ? (
                      <ChevronDown className="w-5 h-5 text-gray-500" />
                    ) : (
                      <ChevronRight className="w-5 h-5 text-gray-500" />
                    )}
                    <div>
                      <h3 className="text-lg font-semibold text-gray-900">{formatFecha(fecha)}</h3>
                      <p className="text-sm text-gray-500">
                        {transaccionesDia.length} transacciones
                        {totalCompras > 0 && ` • ${totalCompras} compras`}
                        {totalVentas > 0 && ` • ${totalVentas} ventas`}
                        {totalTransferencias > 0 && ` • ${totalTransferencias} transferencias`}
                        {totalCanjes > 0 && ` • ${totalCanjes} canjes`}
                      </p>
                    </div>
                  </div>
                </div>

                {/* Detalle expandible */}
                {isExpanded && (
                  <div className="overflow-x-auto">
                    <table className="min-w-full divide-y divide-gray-200">
                      <thead className="bg-gray-100">
                        <tr>
                          <th className="px-6 py-3 text-left text-xs font-medium text-gray-500 uppercase">Hora</th>
                          <th className="px-6 py-3 text-left text-xs font-medium text-gray-500 uppercase">Producto</th>
                          <th className="px-6 py-3 text-left text-xs font-medium text-gray-500 uppercase">Tipo</th>
                          <th className="px-6 py-3 text-left text-xs font-medium text-gray-500 uppercase">Cantidad</th>
                          <th className="px-6 py-3 text-left text-xs font-medium text-gray-500 uppercase">Observaciones</th>
                          <th className="px-6 py-3 text-left text-xs font-medium text-gray-500 uppercase">Acciones</th>
                        </tr>
                      </thead>
                      <tbody className="bg-white divide-y divide-gray-200">
                        {transaccionesDia.map((trans: any) => {
                          const isExpanded = transaccionesExpandidas.has(trans.id)
                          const esCierreDia = trans.tipo_transaccion === 'CIERRE_DIA'
                          
                          // Extraer comentario de las observaciones
                          const observaciones = trans.observaciones || ''
                          const partes = observaciones.split(' | Venta: ')
                          const comentarioVenta = partes[1] || null
                          
                          return (
                            <>
                              <tr key={trans.id} className="hover:bg-gray-50">
                                <td className="px-6 py-4 whitespace-nowrap text-sm text-gray-500">
                                  {new Date(trans.fecha_transaccion).toLocaleTimeString('es-AR', { hour: '2-digit', minute: '2-digit' })}
                                </td>
                                <td className="px-6 py-4 whitespace-nowrap text-sm font-medium text-gray-900">
                                  {getProductoNombre(trans)}
                                </td>
                                <td className="px-6 py-4 whitespace-nowrap">
                                  <span className={`px-2 inline-flex text-xs leading-5 font-semibold rounded-full ${
                                    trans.tipo_transaccion === 'COMPRA' || trans.tipo_transaccion === 'CANJE_ENTRADA' ? 'bg-green-100 text-green-800' :
                                    trans.tipo_transaccion === 'VENTA' || trans.tipo_transaccion === 'CANJE_SALIDA' ? 'bg-red-100 text-red-800' :
                                    trans.tipo_transaccion === 'CIERRE_DIA' ? 'bg-purple-100 text-purple-800' :
                                    'bg-blue-100 text-blue-800'
                                  }`}>
                                    {trans.tipo_transaccion === 'CIERRE_DIA' ? 'CIERRE DE DÍA' : trans.tipo_transaccion}
                                  </span>
                                </td>
                                <td className="px-6 py-4 whitespace-nowrap text-sm text-gray-900">{trans.cantidad}</td>
                                <td className="px-6 py-4 text-sm text-gray-500">
                                  {esCierreDia && comentarioVenta ? (
                                    <button
                                      onClick={() => {
                                        const newSet = new Set(transaccionesExpandidas)
                                        if (isExpanded) {
                                          newSet.delete(trans.id)
                                        } else {
                                          newSet.add(trans.id)
                                        }
                                        setTransaccionesExpandidas(newSet)
                                      }}
                                      className="inline-flex items-center text-purple-600 hover:text-purple-800 font-medium"
                                    >
                                      {isExpanded ? <ChevronDown className="w-4 h-4 mr-1" /> : <ChevronRight className="w-4 h-4 mr-1" />}
                                      Ver detalles
                                    </button>
                                  ) : (
                                    observaciones || '-'
                                  )}
                                </td>
                                <td className="px-6 py-4 whitespace-nowrap text-sm">
                  <button
                    onClick={async () => {
                      // Mensaje especial para CIERRE_DIA
                      const mensaje = esCierreDia 
                        ? `⚠️ ADVERTENCIA: Eliminar cierre de día desde historial\n\n` +
                          `• NO se recomienda eliminar cierres procesados\n` +
                          `• Use el botón "Reiniciar Cierre" en la sección Cierre\n` +
                          `• El stock NO se restaurará automáticamente\n` +
                          `• Deberá ajustar el stock manualmente si es necesario\n\n` +
                          `¿Está seguro de eliminar este cierre?`
                        : `¿Eliminar esta transacción?\n\nEl stock se restaurará automáticamente mediante el trigger de la base de datos.`
                      
                      if (!confirm(mensaje)) return
                      
                      try {
                        // Eliminar la transacción (el trigger se encarga del stock)
                        const { error } = await supabase
                          .from('transacciones')
                          .delete()
                          .eq('id', trans.id)
                        
                        if (error) throw error
                        
                        const mensajeExito = esCierreDia
                          ? '✅ Cierre eliminado. IMPORTANTE: El stock NO fue restaurado. Ajuste manualmente si es necesario.'
                          : '✅ Transacción eliminada correctamente. El stock fue restaurado automáticamente.'
                        
                        alert(mensajeExito)
                        fetchData()
                      } catch (error: any) {
                        console.error('Error eliminando transacción:', error)
                        alert(`❌ Error: ${error.message}`)
                      }
                    }}
                    className="inline-flex items-center text-red-600 hover:text-red-900 font-medium"
                  >
                    <Trash2 className="w-4 h-4 mr-1" />
                    {esCierreDia ? 'Eliminar (No recomendado)' : 'Eliminar'}
                  </button>
                </td>
              </tr>
              
              {/* Fila expandida para mostrar comentarios */}
              {isExpanded && esCierreDia && comentarioVenta && (
                <tr className="bg-purple-50">
                  <td colSpan={6} className="px-6 py-4">
                    <div className="flex items-start gap-3">
                      <div className="flex-shrink-0">
                        <div className="w-8 h-8 bg-purple-100 rounded-full flex items-center justify-center">
                          <span className="text-purple-600 font-semibold text-sm">💬</span>
                        </div>
                      </div>
                      <div className="flex-1">
                        <h4 className="text-sm font-semibold text-purple-900 mb-1">Detalles de la Venta</h4>
                        <p className="text-sm text-gray-700">{comentarioVenta}</p>
                      </div>
                    </div>
                  </td>
                </tr>
              )}
            </>
                          )
                        })}
                      </tbody>
                    </table>
                  </div>
                )}
              </div>
            )
          })}
        </div>
      </div>

      {showModal && (
        <div className="fixed inset-0 bg-gray-500 bg-opacity-75 flex items-center justify-center p-4 z-50">
          <div className="bg-white rounded-lg max-w-md w-full p-6">
            <h3 className="text-lg font-medium text-gray-900 mb-4">Nueva Transacción</h3>
            <div className="space-y-4">
              <select
                value={newTransaccion.tipo_transaccion}
                onChange={(e) => {
                  setNewTransaccion({...newTransaccion, tipo_transaccion: e.target.value as any, producto_id: ''})
                  // Resetear formularios cuando se cambia el tipo
                  setMostrarFormularioCelular(false)
                  setMostrarFormularioOtro(false)
                  setMostrarSugerencias(false)
                  setProductoTexto('')
                  setBusquedaTransferencia('')
                  setMostrarListaTransferencia(false)
                }}
                className="w-full rounded-md border-gray-300 shadow-sm focus:border-blue-500 focus:ring-blue-500"
              >
                <option value="COMPRA">Compra</option>
                <option value="CANJE_ENTRADA">Canje Entrada</option>
                <option value="CANJE_SALIDA">Canje Salida</option>
                <option value="TRANSFERENCIA">Transferencia</option>
              </select>
              <div>
                <label className="block text-sm font-medium text-gray-700 mb-2">Producto</label>
                {newTransaccion.tipo_transaccion === 'TRANSFERENCIA' ? (
                  <>
                    {/* Indicador de dirección de transferencia */}
                    <div className="mb-3 p-3 bg-blue-50 border border-blue-200 rounded-md">
                      <div className="text-sm text-blue-800">
                        <strong>Transferir desde:</strong> {sucursal === 'RESISTENCIA' ? 'CORRIENTES' : 'RESISTENCIA'} → <strong>Hacia:</strong> {sucursal}
                      </div>
                      <div className="text-xs text-blue-600 mt-1">
                        Busca el producto disponible en {sucursal === 'RESISTENCIA' ? 'Corrientes' : 'Resistencia'}
                      </div>
                    </div>
                    {/* Buscador de productos con filtro */}
                    <div className="relative">
                      <input
                        type="text"
                        placeholder="🔍 Buscar producto (marca, modelo, capacidad)..."
                        value={busquedaTransferencia}
                        onChange={(e) => {
                          setBusquedaTransferencia(e.target.value)
                          setMostrarListaTransferencia(true)
                        }}
                        onFocus={() => setMostrarListaTransferencia(true)}
                        className="w-full rounded-md border-gray-300 shadow-sm focus:border-blue-500 focus:ring-blue-500"
                      />
                      {/* Lista filtrada de productos */}
                      {mostrarListaTransferencia && (
                        <div className="absolute z-10 w-full mt-1 bg-white border border-gray-300 rounded-md shadow-lg max-h-60 overflow-y-auto">
                          {productosOtraSucursal
                            .filter(prod => {
                              const searchText = busquedaTransferencia.toLowerCase()
                              const productText = `${prod.marca} ${prod.modelo} ${prod.capacidad_gb} ${prod.color || ''}`.toLowerCase()
                              return productText.includes(searchText)
                            })
                            .map((prod) => (
                              <div
                                key={prod.id}
                                onClick={() => {
                                  setNewTransaccion({...newTransaccion, producto_id: prod.id})
                                  setBusquedaTransferencia(`${prod.marca} ${prod.modelo} ${prod.capacidad_gb}${prod.color ? ` - ${prod.color}` : ''}`)
                                  setMostrarListaTransferencia(false)
                                }}
                                className="px-4 py-2 hover:bg-blue-50 cursor-pointer border-b border-gray-100 last:border-b-0"
                              >
                                <div className="font-medium text-gray-900">
                                  {prod.marca} {prod.modelo}
                                </div>
                                <div className="text-sm text-gray-500">
                                  {prod.capacidad_gb} {prod.color ? `• ${prod.color}` : ''}
                                </div>
                              </div>
                            ))}
                          {productosOtraSucursal.filter(prod => {
                            const searchText = busquedaTransferencia.toLowerCase()
                            const productText = `${prod.marca} ${prod.modelo} ${prod.capacidad_gb} ${prod.color || ''}`.toLowerCase()
                            return productText.includes(searchText)
                          }).length === 0 && (
                            <div className="px-4 py-3 text-sm text-gray-500 text-center">
                              No se encontraron productos
                            </div>
                          )}
                        </div>
                      )}
                    </div>
                    {/* Mostrar producto seleccionado */}
                    {newTransaccion.producto_id && (
                      <div className="mt-2 p-2 bg-green-50 border border-green-200 rounded text-sm text-green-800">
                        ✅ Producto seleccionado
                      </div>
                    )}
                  </>
                ) : (newTransaccion.tipo_transaccion === 'COMPRA' || newTransaccion.tipo_transaccion === 'CANJE_ENTRADA') && (
                  <div className="flex gap-2 mb-2">
                    <button
                      type="button"
                      onClick={() => {
                        setMostrarFormularioCelular(true)
                        setMostrarFormularioOtro(false)
                        setMostrarSugerencias(false)
                      }}
                      className="flex-1 inline-flex items-center justify-center px-3 py-2 border border-blue-300 text-sm font-medium rounded-md text-blue-700 bg-blue-50 hover:bg-blue-100"
                    >
                      📱 Celular
                    </button>
                    <button
                      type="button"
                      onClick={() => {
                        setMostrarFormularioOtro(true)
                        setMostrarFormularioCelular(false)
                        setMostrarSugerencias(false)
                      }}
                      className="flex-1 inline-flex items-center justify-center px-3 py-2 border border-green-300 text-sm font-medium rounded-md text-green-700 bg-green-50 hover:bg-green-100"
                    >
                      🎮 Otro
                    </button>
                  </div>
                )}
                {mostrarFormularioCelular ? (
                  <div className="space-y-3 p-4 bg-blue-50 rounded-md">
                    <input
                      type="text"
                      placeholder="Marca (ej: iPhone, Samsung)"
                      value={nuevoProductoCelular.marca}
                      onChange={(e) => setNuevoProductoCelular({...nuevoProductoCelular, marca: e.target.value})}
                      className="w-full rounded-md border-gray-300 shadow-sm focus:border-blue-500 focus:ring-blue-500"
                    />
                    <input
                      type="text"
                      placeholder="Modelo (ej: 13 PRO MAX, S24 ULTRA)"
                      value={nuevoProductoCelular.modelo}
                      onChange={(e) => setNuevoProductoCelular({...nuevoProductoCelular, modelo: e.target.value})}
                      className="w-full rounded-md border-gray-300 shadow-sm focus:border-blue-500 focus:ring-blue-500"
                    />
                    <input
                      type="text"
                      placeholder="Color (opcional)"
                      value={nuevoProductoCelular.color}
                      onChange={(e) => setNuevoProductoCelular({...nuevoProductoCelular, color: e.target.value})}
                      className="w-full rounded-md border-gray-300 shadow-sm focus:border-blue-500 focus:ring-blue-500"
                    />
                    <input
                      type="text"
                      placeholder="Capacidad (ej: 128, 256, 512, 1T)"
                      value={nuevoProductoCelular.capacidad_gb}
                      onChange={(e) => setNuevoProductoCelular({...nuevoProductoCelular, capacidad_gb: e.target.value})}
                      className="w-full rounded-md border-gray-300 shadow-sm focus:border-blue-500 focus:ring-blue-500"
                    />
                    <input
                      type="number"
                      min="0"
                      max="100"
                      placeholder="Batería % (ej: 85, 90, 95)"
                      value={nuevoProductoCelular.bateria_porcentaje}
                      onChange={(e) => setNuevoProductoCelular({...nuevoProductoCelular, bateria_porcentaje: e.target.value})}
                      className="w-full rounded-md border-gray-300 shadow-sm focus:border-blue-500 focus:ring-blue-500"
                    />
                  </div>
                ) : mostrarFormularioOtro ? (
                  <div className="space-y-3 p-4 bg-green-50 rounded-md">
                    <input
                      type="text"
                      placeholder="Marca (ej: JBL, PlayStation, Sony)"
                      value={nuevoProductoOtro.marca}
                      onChange={(e) => setNuevoProductoOtro({...nuevoProductoOtro, marca: e.target.value})}
                      className="w-full rounded-md border-gray-300 shadow-sm focus:border-blue-500 focus:ring-blue-500"
                    />
                    <input
                      type="text"
                      placeholder="Modelo (ej: Flip 6, PS5, AirPods Pro)"
                      value={nuevoProductoOtro.modelo}
                      onChange={(e) => setNuevoProductoOtro({...nuevoProductoOtro, modelo: e.target.value})}
                      className="w-full rounded-md border-gray-300 shadow-sm focus:border-blue-500 focus:ring-blue-500"
                    />
                    <textarea
                      placeholder="Descripción (ej: Parlante Bluetooth resistente al agua)"
                      value={nuevoProductoOtro.descripcion}
                      onChange={(e) => setNuevoProductoOtro({...nuevoProductoOtro, descripcion: e.target.value})}
                      rows={2}
                      className="w-full rounded-md border-gray-300 shadow-sm focus:border-blue-500 focus:ring-blue-500"
                    />
                    <input
                      type="text"
                      placeholder="Color (opcional)"
                      value={nuevoProductoOtro.color}
                      onChange={(e) => setNuevoProductoOtro({...nuevoProductoOtro, color: e.target.value})}
                      className="w-full rounded-md border-gray-300 shadow-sm focus:border-blue-500 focus:ring-blue-500"
                    />
                  </div>
                ) : newTransaccion.tipo_transaccion !== 'TRANSFERENCIA' && (
                  <div className="relative">
                    <input
                      type="text"
                      placeholder={newTransaccion.tipo_transaccion === 'CANJE_SALIDA' ? "Buscar producto en stock" : "Escribir producto (ej: JBL Flip 6, iPhone 15 PRO 256)"}
                      value={productoTexto}
                      onChange={(e) => {
                        setProductoTexto(e.target.value)
                        setMostrarSugerencias(e.target.value.length > 0)
                        setNewTransaccion({...newTransaccion, producto_id: ''})
                      }}
                      onFocus={() => setMostrarSugerencias(productoTexto.length > 0)}
                      className="w-full rounded-md border-gray-300 shadow-sm focus:border-blue-500 focus:ring-blue-500"
                    />
                    {mostrarSugerencias && (() => {
                      // Usar productos de la sucursal correcta según el tipo de transacción
                      const productosAMostrar = newTransaccion.tipo_transaccion === 'TRANSFERENCIA' 
                        ? productosOtraSucursal 
                        : productos
                      
                      const productosFiltrados = productosAMostrar.filter(p => 
                        `${p.marca} ${p.modelo} ${p.capacidad_gb}`.toLowerCase().includes(productoTexto.toLowerCase())
                      )
                      
                      return productosFiltrados.length > 0 && (
                        <div className="absolute z-10 w-full mt-1 bg-white border border-gray-300 rounded-md shadow-lg max-h-60 overflow-auto">
                          {productosFiltrados.map(prod => (
                            <div
                              key={prod.id}
                              onClick={() => {
                                setProductoTexto(`${prod.marca} ${prod.modelo} ${prod.capacidad_gb}`)
                                setNewTransaccion({...newTransaccion, producto_id: prod.id})
                                setMostrarSugerencias(false)
                              }}
                              className="px-4 py-2 hover:bg-gray-100 cursor-pointer"
                            >
                              {prod.marca} {prod.modelo} {prod.capacidad_gb} {prod.color ? `- ${prod.color}` : ''}
                            </div>
                          ))}
                        </div>
                      )
                    })()}
                    <p className="mt-1 text-xs text-gray-500">
                      {newTransaccion.tipo_transaccion === 'CANJE_SALIDA' || newTransaccion.tipo_transaccion === 'VENTA' 
                        ? "Busca y selecciona un producto de tu stock" 
                        : "Escribe el producto o selecciona de las sugerencias. Si no existe, se creará automáticamente."}
                    </p>
                  </div>
                )}
              </div>
              <input
                type="number"
                placeholder="Cantidad"
                value={newTransaccion.cantidad}
                onChange={(e) => setNewTransaccion({...newTransaccion, cantidad: parseInt(e.target.value)})}
                className="w-full rounded-md border-gray-300 shadow-sm focus:border-blue-500 focus:ring-blue-500"
              />
              <textarea
                placeholder="Observaciones"
                value={newTransaccion.observaciones}
                onChange={(e) => setNewTransaccion({...newTransaccion, observaciones: e.target.value})}
                className="w-full rounded-md border-gray-300 shadow-sm focus:border-blue-500 focus:ring-blue-500"
                rows={3}
              />
            </div>
            <div className="mt-6 flex justify-end space-x-3">
              <button
                onClick={() => setShowModal(false)}
                className="px-4 py-2 border border-gray-300 rounded-md text-sm font-medium text-gray-700 hover:bg-gray-50"
              >
                Cancelar
              </button>
              <button
                onClick={handleAddTransaccion}
                className="px-4 py-2 border border-transparent rounded-md shadow-sm text-sm font-medium text-white bg-blue-600 hover:bg-blue-700"
              >
                Registrar
              </button>
            </div>
          </div>
        </div>
      )}
    </div>
  )
}
