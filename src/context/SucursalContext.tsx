import { createContext, useContext, useState, useEffect, ReactNode } from 'react'

export type Sucursal = 'RESISTENCIA' | 'CORRIENTES'

type SucursalContextType = {
  sucursal: Sucursal | null
  setSucursal: (sucursal: Sucursal) => void
  cerrarSesion: () => void
}

const SucursalContext = createContext<SucursalContextType | undefined>(undefined)

export function SucursalProvider({ children }: { children: ReactNode }) {
  const [sucursal, setSucursalState] = useState<Sucursal | null>(null)

  useEffect(() => {
    // Cargar sucursal guardada del localStorage
    const sucursalGuardada = localStorage.getItem('sucursal') as Sucursal | null
    if (sucursalGuardada) {
      setSucursalState(sucursalGuardada)
    }
  }, [])

  const setSucursal = (nuevaSucursal: Sucursal) => {
    setSucursalState(nuevaSucursal)
    localStorage.setItem('sucursal', nuevaSucursal)
  }

  const cerrarSesion = () => {
    setSucursalState(null)
    localStorage.removeItem('sucursal')
  }

  return (
    <SucursalContext.Provider value={{ sucursal, setSucursal, cerrarSesion }}>
      {children}
    </SucursalContext.Provider>
  )
}

export function useSucursal() {
  const context = useContext(SucursalContext)
  if (context === undefined) {
    throw new Error('useSucursal debe ser usado dentro de un SucursalProvider')
  }
  return context
}
