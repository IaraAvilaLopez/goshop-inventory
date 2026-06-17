export type Sucursal = 'RESISTENCIA' | 'CORRIENTES'

export function getSucursalActual(): Sucursal {
  const sucursal = localStorage.getItem('sucursal') as Sucursal | null
  return sucursal || 'RESISTENCIA'
}
