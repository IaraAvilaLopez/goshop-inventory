import { Building2, MapPin } from 'lucide-react'

type Sucursal = 'RESISTENCIA' | 'CORRIENTES'

type SeleccionSucursalProps = {
  onSelectSucursal: (sucursal: Sucursal) => void
}

export default function SeleccionSucursal({ onSelectSucursal }: SeleccionSucursalProps) {
  return (
    <div className="min-h-screen flex items-center justify-center p-4" style={{ backgroundColor: '#6B7456' }}>
      <div className="max-w-4xl w-full">
        {/* Header */}
        <div className="text-center mb-12">
          <div className="flex items-center justify-center gap-3 mb-4">
            <div className="w-16 h-16 rounded-full bg-white flex items-center justify-center">
              <span className="text-3xl font-bold" style={{ color: '#6B7456' }}>go</span>
            </div>
            <h1 className="text-4xl font-bold text-white">shop</h1>
          </div>
          <p className="text-xl text-white opacity-90">Sistema de Gestión de Inventario</p>
        </div>

        {/* Selección de Sucursal */}
        <div className="bg-white rounded-2xl shadow-2xl p-8">
          <h2 className="text-2xl font-bold text-gray-900 text-center mb-8">
            Selecciona tu Sucursal
          </h2>

          <div className="grid grid-cols-1 md:grid-cols-2 gap-6">
            {/* Sucursal Resistencia */}
            <button
              onClick={() => onSelectSucursal('RESISTENCIA')}
              className="group relative bg-gradient-to-br from-green-500 to-green-600 hover:from-green-600 hover:to-green-700 text-white rounded-xl p-8 transition-all duration-300 transform hover:scale-105 hover:shadow-2xl"
            >
              <div className="flex flex-col items-center text-center">
                <div className="bg-white rounded-full p-4 mb-4 group-hover:scale-110 transition-transform">
                  <Building2 className="w-12 h-12 text-green-600" />
                </div>
                <h3 className="text-2xl font-bold mb-2">Sucursal Resistencia</h3>
                <div className="flex items-center gap-2 text-green-100">
                  <MapPin className="w-4 h-4" />
                  <span className="text-sm">Chaco</span>
                </div>
              </div>
            </button>

            {/* Sucursal Corrientes */}
            <button
              onClick={() => onSelectSucursal('CORRIENTES')}
              className="group relative bg-gradient-to-br from-blue-500 to-blue-600 hover:from-blue-600 hover:to-blue-700 text-white rounded-xl p-8 transition-all duration-300 transform hover:scale-105 hover:shadow-2xl"
            >
              <div className="flex flex-col items-center text-center">
                <div className="bg-white rounded-full p-4 mb-4 group-hover:scale-110 transition-transform">
                  <Building2 className="w-12 h-12 text-blue-600" />
                </div>
                <h3 className="text-2xl font-bold mb-2">Sucursal Corrientes</h3>
                <div className="flex items-center gap-2 text-blue-100">
                  <MapPin className="w-4 h-4" />
                  <span className="text-sm">Corrientes</span>
                </div>
              </div>
            </button>
          </div>

          <div className="mt-8 text-center text-sm text-gray-500">
            <p>Selecciona la sucursal desde la cual vas a trabajar</p>
          </div>
        </div>

        {/* Footer */}
        <div className="mt-8 text-center text-sm text-white opacity-75">
          <p>© 2026 GoShop - Sistema de Gestión de Inventario</p>
        </div>
      </div>
    </div>
  )
}
