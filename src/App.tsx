import { useState } from 'react'
import Dashboard from './components/Dashboard'
import Inventario from './components/Inventario'
import Transacciones from './components/Transacciones'
import Alertas from './components/Alertas'
import VentasDia from './components/VentasDia'
import CierreDia from './components/CierreDiaNuevo'
import AlertaPopup from './components/AlertaPopup'
import SeleccionSucursal from './components/SeleccionSucursal'
import { useSucursal } from './context/SucursalContext'
import { Package, ShoppingCart, AlertTriangle, Calendar, LayoutDashboard, DollarSign, LogOut, MapPin } from 'lucide-react'

type View = 'dashboard' | 'inventario' | 'transacciones' | 'alertas' | 'ventas' | 'cierre'

function App() {
  const { sucursal, setSucursal, cerrarSesion } = useSucursal()
  const [currentView, setCurrentView] = useState<View>('dashboard')

  // Si no hay sucursal seleccionada, mostrar pantalla de selección
  if (!sucursal) {
    return <SeleccionSucursal onSelectSucursal={setSucursal} />
  }

  const navigation = [
    { id: 'dashboard' as View, name: 'Inicio', icon: LayoutDashboard },
    { id: 'inventario' as View, name: 'Stock', icon: Package },
    { id: 'ventas' as View, name: 'Ventas', icon: DollarSign },
    { id: 'cierre' as View, name: 'Cierre', icon: Calendar },
    { id: 'transacciones' as View, name: 'Historial', icon: ShoppingCart },
    { id: 'alertas' as View, name: 'Alertas', icon: AlertTriangle },
  ]

  return (
    <div className="min-h-screen bg-gray-50">
      <nav className="shadow-sm border-b" style={{ backgroundColor: '#6B7456' }}>
        <div className="max-w-7xl mx-auto px-4 sm:px-6 lg:px-8">
          <div className="flex justify-between h-16">
            <div className="flex">
              <div className="flex-shrink-0 flex items-center gap-3">
                <div className="w-12 h-12 rounded-full flex items-center justify-center" style={{ backgroundColor: '#6B7456' }}>
                  <span className="text-2xl font-bold text-white">go</span>
                </div>
                <div>
                  <h1 className="text-2xl font-bold text-white">shop</h1>
                  <div className="flex items-center gap-1 text-xs text-green-100">
                    <MapPin className="w-3 h-3" />
                    <span>{sucursal}</span>
                  </div>
                </div>
              </div>
              <div className="hidden sm:ml-6 sm:flex sm:space-x-8">
                {navigation.map((item) => {
                  const Icon = item.icon
                  return (
                    <button
                      key={item.id}
                      onClick={() => setCurrentView(item.id)}
                      className={`inline-flex items-center px-1 pt-1 border-b-2 text-sm font-medium ${
                        currentView === item.id
                          ? 'border-white text-white'
                          : 'border-transparent text-gray-200 hover:border-gray-300 hover:text-white'
                      }`}
                    >
                      <Icon className="w-4 h-4 mr-2" />
                      {item.name}
                    </button>
                  )
                })}
              </div>
            </div>
            <div className="flex items-center">
              <button
                onClick={cerrarSesion}
                className="inline-flex items-center px-3 py-2 text-sm font-medium text-white hover:bg-green-700 rounded-md transition-colors"
                title="Cambiar sucursal"
              >
                <LogOut className="w-4 h-4 mr-2" />
                Cambiar Sucursal
              </button>
            </div>
          </div>
        </div>
      </nav>

      <main className="max-w-7xl mx-auto py-6 sm:px-6 lg:px-8">
        {currentView === 'dashboard' && <Dashboard />}
        {currentView === 'inventario' && <Inventario />}
        {currentView === 'ventas' && <VentasDia />}
        {currentView === 'cierre' && <CierreDia />}
        {currentView === 'transacciones' && <Transacciones />}
        {currentView === 'alertas' && <Alertas />}
      </main>

      {/* Badge de alertas en esquina inferior derecha */}
      <AlertaPopup 
        onNavigateToAlertas={() => setCurrentView('alertas')} 
        currentView={currentView}
      />
    </div>
  )
}

export default App
