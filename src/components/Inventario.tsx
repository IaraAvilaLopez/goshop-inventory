import { useEffect, useState } from 'react'
import { supabase, type StockActual } from '../lib/supabase'
import { useSucursal } from '../context/SucursalContext'
import { Plus, Search, Edit } from 'lucide-react'

export default function Inventario() {
  const { sucursal } = useSucursal()
  const [stock, setStock] = useState<StockActual[]>([])
  const [loading, setLoading] = useState(true)
  const [searchTerm, setSearchTerm] = useState('')
  const [filterMarca, setFilterMarca] = useState('')
  const [filterCapacidad, setFilterCapacidad] = useState('')
  const [filterBateria, setFilterBateria] = useState('')
  const [showAddModal, setShowAddModal] = useState(false)
  const [showEditModal, setShowEditModal] = useState(false)
  const [editingProduct, setEditingProduct] = useState<StockActual | null>(null)
  const [tipoProducto, setTipoProducto] = useState<'CELULAR' | 'OTRO'>('CELULAR')

  const [newProduct, setNewProduct] = useState({
    categoria: 'PRODUCTO',
    modelo: '',
    marca: '',
    color: '',
    capacidad_gb: '',
    bateria_porcentaje: '',
    descripcion: '',
    cantidad_inicial: 1,
    cantidad_minima: 1,
  })

  useEffect(() => {
    if (sucursal) {
      fetchStock()
    }
  }, [sucursal])

  async function fetchStock() {
    try {
      const { data, error } = await supabase
        .from('vista_stock_actual')
        .select('*')
        .eq('ubicacion', sucursal)
        .order('marca', { ascending: true })
        .order('modelo', { ascending: true })

      if (error) throw error
      setStock(data || [])
    } catch (error) {
      console.error('Error fetching stock:', error)
    } finally {
      setLoading(false)
    }
  }

  async function handleAddProduct() {
    try {
      // Verificar si el producto ya existe
      const { data: productoExistente, error: searchError } = await supabase
        .from('productos')
        .select('id')
        .eq('marca', newProduct.marca.toUpperCase())
        .eq('modelo', newProduct.modelo.toUpperCase())
        .eq('capacidad_gb', newProduct.capacidad_gb || null)
        .eq('color', newProduct.color || null)
        .eq('bateria_porcentaje', newProduct.bateria_porcentaje ? parseInt(newProduct.bateria_porcentaje) : null)
        .maybeSingle()

      if (searchError) throw searchError

      let productoId: string

      if (productoExistente) {
        // El producto ya existe, usar ese ID
        productoId = productoExistente.id
        
        // Verificar si ya existe inventario para esta sucursal
        const { data: invExistente } = await supabase
          .from('inventario')
          .select('id')
          .eq('producto_id', productoId)
          .eq('ubicacion', sucursal)
          .maybeSingle()

        if (invExistente) {
          alert('Este producto ya existe en el inventario de esta sucursal')
          return
        }
      } else {
        // Crear nuevo producto
        const { data: nuevoProducto, error: prodError } = await supabase
          .from('productos')
          .insert([{
            categoria: tipoProducto,
            modelo: newProduct.modelo.toUpperCase(),
            marca: newProduct.marca.toUpperCase(),
            color: newProduct.color ? newProduct.color.toUpperCase() : null,
            capacidad_gb: newProduct.capacidad_gb || null,
            bateria_porcentaje: newProduct.bateria_porcentaje ? parseInt(newProduct.bateria_porcentaje) : null,
            descripcion: newProduct.descripcion || null,
          }])
          .select()
          .single()

        if (prodError) throw prodError
        productoId = nuevoProducto.id
      }

      // Crear inventario para esta sucursal
      const { error: invError } = await supabase
        .from('inventario')
        .insert([{
          producto_id: productoId,
          cantidad_actual: newProduct.cantidad_inicial,
          cantidad_minima: newProduct.cantidad_minima,
          ubicacion: sucursal,
          estado: 'DISPONIBLE',
        }])

      if (invError) throw invError

      alert('Producto agregado exitosamente')
      setShowAddModal(false)
      setNewProduct({
        categoria: 'PRODUCTO',
        modelo: '',
        marca: '',
        color: '',
        capacidad_gb: '',
        bateria_porcentaje: '',
        descripcion: '',
        cantidad_inicial: 1,
        cantidad_minima: 1,
      })
      fetchStock()
    } catch (error: any) {
      console.error('Error adding product:', error)
      alert(`Error al agregar producto: ${error.message || JSON.stringify(error)}`)
    }
  }

  const filteredStock = stock.filter(item => {
    const matchesSearch = 
      item.modelo?.toLowerCase().includes(searchTerm.toLowerCase()) ||
      item.marca?.toLowerCase().includes(searchTerm.toLowerCase()) ||
      item.color?.toLowerCase().includes(searchTerm.toLowerCase())
    
    const matchesMarca = !filterMarca || item.marca === filterMarca
    const matchesCapacidad = !filterCapacidad || item.capacidad_gb === filterCapacidad
    const matchesBateria = !filterBateria || (item.bateria_porcentaje !== null && item.bateria_porcentaje.toString() === filterBateria)

    return matchesSearch && matchesMarca && matchesCapacidad && matchesBateria
  })

  const marcas = [...new Set(stock.map(item => item.marca).filter(Boolean))]
  const capacidades = [...new Set(stock.map(item => item.capacidad_gb).filter(Boolean))]
  const baterias = [...new Set(stock.map(item => item.bateria_porcentaje).filter(b => b !== null))].sort((a, b) => (b || 0) - (a || 0))

  if (loading) {
    return <div className="flex items-center justify-center h-64">Cargando...</div>
  }

  return (
    <div className="px-4 py-6 sm:px-0">
      <div className="flex justify-between items-center mb-6">
        <h2 className="text-2xl font-bold text-gray-900">Inventario</h2>
        <div className="flex gap-3">
          <button
            onClick={() => {
              setTipoProducto('CELULAR')
              setShowAddModal(true)
            }}
            className="inline-flex items-center px-4 py-2 border border-transparent text-sm font-medium rounded-md shadow-sm text-white bg-blue-600 hover:bg-blue-700"
          >
            <Plus className="w-4 h-4 mr-2" />
            📱 Ingresar Celular
          </button>
          <button
            onClick={() => {
              setTipoProducto('OTRO')
              setShowAddModal(true)
            }}
            className="inline-flex items-center px-4 py-2 border border-transparent text-sm font-medium rounded-md shadow-sm text-white bg-green-600 hover:bg-green-700"
          >
            <Plus className="w-4 h-4 mr-2" />
            🎮 Ingresar Otro Producto
          </button>
        </div>
      </div>

      <div className="bg-white shadow rounded-lg mb-6 p-4">
        <div className="grid grid-cols-1 md:grid-cols-5 gap-4">
          <div className="relative">
            <Search className="absolute left-3 top-3 h-4 w-4 text-gray-400" />
            <input
              type="text"
              placeholder="Buscar..."
              value={searchTerm}
              onChange={(e) => setSearchTerm(e.target.value)}
              className="pl-10 w-full rounded-md border-gray-300 shadow-sm focus:border-blue-500 focus:ring-blue-500"
            />
          </div>
          <select
            value={filterMarca}
            onChange={(e) => setFilterMarca(e.target.value)}
            className="rounded-md border-gray-300 shadow-sm focus:border-blue-500 focus:ring-blue-500"
          >
            <option value="">Todas las marcas</option>
            {marcas.map(marca => (
              <option key={marca} value={marca}>{marca}</option>
            ))}
          </select>
          <select
            value={filterCapacidad}
            onChange={(e) => setFilterCapacidad(e.target.value)}
            className="rounded-md border-gray-300 shadow-sm focus:border-blue-500 focus:ring-blue-500"
          >
            <option value="">Todas las capacidades</option>
            {capacidades.map(cap => (
              <option key={cap} value={cap}>{cap}</option>
            ))}
          </select>
          <select
            value={filterBateria}
            onChange={(e) => setFilterBateria(e.target.value)}
            className="rounded-md border-gray-300 shadow-sm focus:border-blue-500 focus:ring-blue-500"
          >
            <option value="">Todas las baterías</option>
            {baterias.map(bat => (
              <option key={bat} value={bat}>{bat}%</option>
            ))}
          </select>
          <button
            onClick={() => {
              setSearchTerm('')
              setFilterMarca('')
              setFilterCapacidad('')
              setFilterBateria('')
            }}
            className="px-4 py-2 border border-gray-300 rounded-md text-sm font-medium text-gray-700 hover:bg-gray-50"
          >
            Limpiar Filtros
          </button>
        </div>
      </div>

      <div className="bg-white shadow rounded-lg overflow-hidden">
        <table className="min-w-full divide-y divide-gray-200">
          <thead className="bg-gray-50">
            <tr>
              <th className="px-6 py-3 text-left text-xs font-medium text-gray-500 uppercase">Marca</th>
              <th className="px-6 py-3 text-left text-xs font-medium text-gray-500 uppercase">Modelo</th>
              <th className="px-6 py-3 text-left text-xs font-medium text-gray-500 uppercase">Color</th>
              <th className="px-6 py-3 text-left text-xs font-medium text-gray-500 uppercase">Capacidad</th>
              <th className="px-6 py-3 text-left text-xs font-medium text-gray-500 uppercase">Batería %</th>
              <th className="px-6 py-3 text-left text-xs font-medium text-gray-500 uppercase">Stock</th>
              <th className="px-6 py-3 text-left text-xs font-medium text-gray-500 uppercase">Mínimo</th>
              <th className="px-6 py-3 text-left text-xs font-medium text-gray-500 uppercase">Estado</th>
              <th className="px-6 py-3 text-left text-xs font-medium text-gray-500 uppercase">Acciones</th>
            </tr>
          </thead>
          <tbody className="bg-white divide-y divide-gray-200">
            {filteredStock.map((item, index) => (
              <tr key={index} className="hover:bg-gray-50">
                <td className="px-6 py-4 whitespace-nowrap text-sm font-medium text-gray-900">{item.marca}</td>
                <td className="px-6 py-4 whitespace-nowrap text-sm text-gray-500">{item.modelo}</td>
                <td className="px-6 py-4 whitespace-nowrap text-sm text-gray-500">{item.color || '-'}</td>
                <td className="px-6 py-4 whitespace-nowrap text-sm text-gray-500">{item.capacidad_gb}</td>
                <td className="px-6 py-4 whitespace-nowrap text-sm text-gray-500">
                  {item.bateria_porcentaje ? `${item.bateria_porcentaje}%` : '-'}
                </td>
                <td className="px-6 py-4 whitespace-nowrap text-sm text-gray-900 font-semibold">{item.cantidad_actual}</td>
                <td className="px-6 py-4 whitespace-nowrap text-sm text-gray-500">{item.cantidad_minima}</td>
                <td className="px-6 py-4 whitespace-nowrap">
                  <span className={`px-2 inline-flex text-xs leading-5 font-semibold rounded-full ${
                    item.nivel_stock === 'CRÍTICO' ? 'bg-red-100 text-red-800' :
                    item.nivel_stock === 'BAJO' ? 'bg-yellow-100 text-yellow-800' :
                    'bg-green-100 text-green-800'
                  }`}>
                    {item.nivel_stock}
                  </span>
                </td>
                <td className="px-6 py-4 whitespace-nowrap text-sm space-x-3">
                  <button
                    onClick={() => {
                      setEditingProduct(item)
                      setShowEditModal(true)
                    }}
                    className="inline-flex items-center text-blue-600 hover:text-blue-900 font-medium"
                  >
                    <Edit className="w-4 h-4 mr-1" />
                    Editar
                  </button>
                  <button
                    onClick={async () => {
                      if (confirm(`¿Eliminar ${item.marca} ${item.modelo} de ${sucursal}?\n\nEsto eliminará el producto solo de esta sucursal.`)) {
                        try {
                          // Solo eliminar el inventario de esta sucursal
                          // El CASCADE de la base de datos se encargará del resto
                          const { error } = await supabase
                            .from('inventario')
                            .delete()
                            .eq('producto_id', item.producto_id)
                            .eq('ubicacion', sucursal)
                          
                          if (error) {
                            console.error('Error completo:', error)
                            throw error
                          }
                          
                          await fetchStock()
                          alert('✅ Producto eliminado correctamente de ' + sucursal)
                        } catch (error: any) {
                          console.error('Error eliminando producto:', error)
                          alert(`❌ Error: ${error.message || 'Error desconocido'}\n\nRevisa la consola (F12) para más detalles.`)
                        }
                      }
                    }}
                    className="inline-flex items-center text-red-600 hover:text-red-900 font-medium"
                  >
                    Eliminar
                  </button>
                </td>
              </tr>
            ))}
          </tbody>
        </table>
      </div>

      {showAddModal && (
        <div className="fixed inset-0 bg-gray-500 bg-opacity-75 flex items-center justify-center p-4 z-50">
          <div className="bg-white rounded-lg max-w-md w-full p-6">
            <h3 className="text-lg font-medium text-gray-900 mb-4">
              {tipoProducto === 'CELULAR' ? '📱 Ingresar Celular' : '🎮 Ingresar Otro Producto'}
            </h3>
            <div className="space-y-4">
              {tipoProducto === 'CELULAR' ? (
                // FORMULARIO PARA CELULARES
                <>
                  <input
                    type="text"
                    placeholder="Marca (ej: iPhone, Samsung)"
                    value={newProduct.marca}
                    onChange={(e) => setNewProduct({...newProduct, marca: e.target.value})}
                    className="w-full rounded-md border-gray-300 shadow-sm focus:border-blue-500 focus:ring-blue-500"
                  />
                  <input
                    type="text"
                    placeholder="Modelo (ej: 13 PRO MAX, S24 ULTRA)"
                    value={newProduct.modelo}
                    onChange={(e) => setNewProduct({...newProduct, modelo: e.target.value})}
                    className="w-full rounded-md border-gray-300 shadow-sm focus:border-blue-500 focus:ring-blue-500"
                  />
                  <input
                    type="text"
                    placeholder="Color (opcional)"
                    value={newProduct.color}
                    onChange={(e) => setNewProduct({...newProduct, color: e.target.value})}
                    className="w-full rounded-md border-gray-300 shadow-sm focus:border-blue-500 focus:ring-blue-500"
                  />
                  <input
                    type="text"
                    placeholder="Capacidad (ej: 128, 256, 512, 1T)"
                    value={newProduct.capacidad_gb}
                    onChange={(e) => setNewProduct({...newProduct, capacidad_gb: e.target.value})}
                    className="w-full rounded-md border-gray-300 shadow-sm focus:border-blue-500 focus:ring-blue-500"
                  />
                  <input
                    type="number"
                    min="0"
                    max="100"
                    placeholder="Batería % (ej: 85, 90, 95)"
                    value={newProduct.bateria_porcentaje}
                    onChange={(e) => setNewProduct({...newProduct, bateria_porcentaje: e.target.value})}
                    className="w-full rounded-md border-gray-300 shadow-sm focus:border-blue-500 focus:ring-blue-500"
                  />
                </>
              ) : (
                // FORMULARIO PARA OTROS PRODUCTOS
                <>
                  <input
                    type="text"
                    placeholder="Marca (ej: JBL, PlayStation, Sony)"
                    value={newProduct.marca}
                    onChange={(e) => setNewProduct({...newProduct, marca: e.target.value})}
                    className="w-full rounded-md border-gray-300 shadow-sm focus:border-blue-500 focus:ring-blue-500"
                  />
                  <input
                    type="text"
                    placeholder="Modelo (ej: Flip 6, PS5, AirPods Pro)"
                    value={newProduct.modelo}
                    onChange={(e) => setNewProduct({...newProduct, modelo: e.target.value})}
                    className="w-full rounded-md border-gray-300 shadow-sm focus:border-blue-500 focus:ring-blue-500"
                  />
                  <textarea
                    placeholder="Descripción (ej: Parlante Bluetooth resistente al agua, Consola con lector de discos)"
                    value={newProduct.descripcion}
                    onChange={(e) => setNewProduct({...newProduct, descripcion: e.target.value})}
                    rows={3}
                    className="w-full rounded-md border-gray-300 shadow-sm focus:border-blue-500 focus:ring-blue-500"
                  />
                  <input
                    type="text"
                    placeholder="Color (opcional)"
                    value={newProduct.color}
                    onChange={(e) => setNewProduct({...newProduct, color: e.target.value})}
                    className="w-full rounded-md border-gray-300 shadow-sm focus:border-blue-500 focus:ring-blue-500"
                  />
                </>
              )}
              <div>
                <label className="block text-sm font-medium text-gray-700 mb-1">
                  Cantidad Inicial
                </label>
                <input
                  type="number"
                  min="0"
                  placeholder="¿Cuántas unidades tienes?"
                  value={newProduct.cantidad_inicial}
                  onChange={(e) => setNewProduct({...newProduct, cantidad_inicial: parseInt(e.target.value) || 0})}
                  className="w-full rounded-md border-gray-300 shadow-sm focus:border-blue-500 focus:ring-blue-500"
                />
              </div>
              <div>
                <label className="block text-sm font-medium text-gray-700 mb-1">
                  Stock Mínimo (para alertas)
                </label>
                <input
                  type="number"
                  min="0"
                  placeholder="¿Cuándo alertar?"
                  value={newProduct.cantidad_minima}
                  onChange={(e) => setNewProduct({...newProduct, cantidad_minima: parseInt(e.target.value) || 0})}
                  className="w-full rounded-md border-gray-300 shadow-sm focus:border-blue-500 focus:ring-blue-500"
                />
              </div>
            </div>
            <div className="mt-6 flex justify-end space-x-3">
              <button
                onClick={() => setShowAddModal(false)}
                className="px-4 py-2 border border-gray-300 rounded-md text-sm font-medium text-gray-700 hover:bg-gray-50"
              >
                Cancelar
              </button>
              <button
                onClick={handleAddProduct}
                className="px-4 py-2 border border-transparent rounded-md shadow-sm text-sm font-medium text-white bg-blue-600 hover:bg-blue-700"
              >
                Agregar
              </button>
            </div>
          </div>
        </div>
      )}

      {/* Modal de Edición */}
      {showEditModal && editingProduct && (
        <div className="fixed inset-0 bg-gray-500 bg-opacity-75 flex items-center justify-center p-4 z-50">
          <div className="bg-white rounded-lg max-w-md w-full p-6">
            <h3 className="text-lg font-medium text-gray-900 mb-4">
              ✏️ Editar Producto
            </h3>
            <div className="space-y-4">
              <div>
                <label className="block text-sm font-medium text-gray-700 mb-1">Marca</label>
                <input
                  type="text"
                  value={editingProduct.marca}
                  onChange={(e) => setEditingProduct({...editingProduct, marca: e.target.value})}
                  className="w-full rounded-md border-gray-300 shadow-sm focus:border-blue-500 focus:ring-blue-500"
                />
              </div>
              <div>
                <label className="block text-sm font-medium text-gray-700 mb-1">Modelo</label>
                <input
                  type="text"
                  value={editingProduct.modelo}
                  onChange={(e) => setEditingProduct({...editingProduct, modelo: e.target.value})}
                  className="w-full rounded-md border-gray-300 shadow-sm focus:border-blue-500 focus:ring-blue-500"
                />
              </div>
              <div>
                <label className="block text-sm font-medium text-gray-700 mb-1">Color</label>
                <input
                  type="text"
                  value={editingProduct.color || ''}
                  onChange={(e) => setEditingProduct({...editingProduct, color: e.target.value})}
                  className="w-full rounded-md border-gray-300 shadow-sm focus:border-blue-500 focus:ring-blue-500"
                />
              </div>
              <div>
                <label className="block text-sm font-medium text-gray-700 mb-1">Capacidad (GB)</label>
                <input
                  type="text"
                  value={editingProduct.capacidad_gb}
                  onChange={(e) => setEditingProduct({...editingProduct, capacidad_gb: e.target.value})}
                  className="w-full rounded-md border-gray-300 shadow-sm focus:border-blue-500 focus:ring-blue-500"
                />
              </div>
              <div>
                <label className="block text-sm font-medium text-gray-700 mb-1">Batería %</label>
                <input
                  type="number"
                  min="0"
                  max="100"
                  value={editingProduct.bateria_porcentaje || ''}
                  onChange={(e) => setEditingProduct({...editingProduct, bateria_porcentaje: e.target.value ? parseInt(e.target.value) : null})}
                  className="w-full rounded-md border-gray-300 shadow-sm focus:border-blue-500 focus:ring-blue-500"
                />
              </div>
              <div>
                <label className="block text-sm font-medium text-gray-700 mb-1">
                  Stock Actual
                </label>
                <div className="flex items-center space-x-2">
                  <button
                    onClick={() => setEditingProduct({
                      ...editingProduct, 
                      cantidad_actual: Math.max(0, editingProduct.cantidad_actual - 1)
                    })}
                    className="px-3 py-2 bg-red-100 text-red-700 rounded-md hover:bg-red-200 font-bold"
                  >
                    -
                  </button>
                  <input
                    type="number"
                    min="0"
                    value={editingProduct.cantidad_actual}
                    onChange={(e) => setEditingProduct({
                      ...editingProduct, 
                      cantidad_actual: Math.max(0, parseInt(e.target.value) || 0)
                    })}
                    className="w-full text-center rounded-md border-gray-300 shadow-sm focus:border-blue-500 focus:ring-blue-500 font-bold text-lg"
                  />
                  <button
                    onClick={() => setEditingProduct({
                      ...editingProduct, 
                      cantidad_actual: editingProduct.cantidad_actual + 1
                    })}
                    className="px-3 py-2 bg-green-100 text-green-700 rounded-md hover:bg-green-200 font-bold"
                  >
                    +
                  </button>
                </div>
              </div>
              <div>
                <label className="block text-sm font-medium text-gray-700 mb-1">
                  Stock Mínimo (para alertas)
                </label>
                <input
                  type="number"
                  min="0"
                  value={editingProduct.cantidad_minima}
                  onChange={(e) => setEditingProduct({
                    ...editingProduct, 
                    cantidad_minima: parseInt(e.target.value) || 0
                  })}
                  className="w-full rounded-md border-gray-300 shadow-sm focus:border-blue-500 focus:ring-blue-500"
                />
              </div>
            </div>
            <div className="mt-6 flex justify-end space-x-3">
              <button
                onClick={() => {
                  setShowEditModal(false)
                  setEditingProduct(null)
                }}
                className="px-4 py-2 border border-gray-300 rounded-md text-sm font-medium text-gray-700 hover:bg-gray-50"
              >
                Cancelar
              </button>
              <button
                onClick={async () => {
                  try {
                    // Actualizar producto
                    const { error: prodError } = await supabase
                      .from('productos')
                      .update({
                        marca: editingProduct.marca,
                        modelo: editingProduct.modelo,
                        color: editingProduct.color,
                        capacidad_gb: editingProduct.capacidad_gb,
                        bateria_porcentaje: editingProduct.bateria_porcentaje,
                      })
                      .eq('id', editingProduct.producto_id)
                    
                    if (prodError) throw prodError

                    // Actualizar inventario
                    const { error: invError } = await supabase
                      .from('inventario')
                      .update({
                        cantidad_actual: editingProduct.cantidad_actual,
                        cantidad_minima: editingProduct.cantidad_minima,
                      })
                      .eq('producto_id', editingProduct.producto_id)
                      .eq('ubicacion', sucursal)
                    
                    if (invError) throw invError

                    alert('✅ Producto actualizado correctamente')
                    setShowEditModal(false)
                    setEditingProduct(null)
                    fetchStock()
                  } catch (error: any) {
                    console.error('Error actualizando producto:', error)
                    alert(`❌ Error: ${error.message}`)
                  }
                }}
                className="px-4 py-2 border border-transparent rounded-md shadow-sm text-sm font-medium text-white bg-blue-600 hover:bg-blue-700"
              >
                Guardar Cambios
              </button>
            </div>
          </div>
        </div>
      )}
    </div>
  )
}
