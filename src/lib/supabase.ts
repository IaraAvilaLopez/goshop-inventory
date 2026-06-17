import { createClient } from '@supabase/supabase-js'

const supabaseUrl = import.meta.env.VITE_SUPABASE_URL || ''
const supabaseAnonKey = import.meta.env.VITE_SUPABASE_ANON_KEY || ''

export const supabase = createClient(supabaseUrl, supabaseAnonKey)

export type Producto = {
  id: string
  modelo: string
  marca: string
  color: string | null
  capacidad_gb: string
  created_at: string
  updated_at: string
}

export type Inventario = {
  id: string
  producto_id: string
  cantidad_actual: number
  cantidad_minima: number
  ubicacion: string
  estado: string
  created_at: string
  updated_at: string
}

export type Transaccion = {
  id: string
  producto_id: string
  tipo_transaccion: 'COMPRA' | 'VENTA' | 'CANJE_ENTRADA' | 'CANJE_SALIDA' | 'AJUSTE' | 'TRANSFERENCIA' | 'CIERRE_DIA'
  cantidad: number
  precio_unitario: number | null
  precio_total: number | null
  fecha_transaccion: string
  observaciones: string | null
  usuario: string | null
  ubicacion: string
  created_at: string
}

export type AlertaStock = {
  id: string
  producto_id: string
  inventario_id: string
  cantidad_actual: number
  cantidad_minima: number
  estado_alerta: 'ACTIVA' | 'RESUELTA' | 'IGNORADA'
  fecha_alerta: string
  fecha_resolucion: string | null
  created_at: string
}

export type CierreDia = {
  id: string
  fecha_cierre: string
  ubicacion: string
  total_ventas: number
  total_ingresos: number
  observaciones: string | null
  usuario: string | null
  created_at: string
}

export type StockActual = {
  producto_id: string
  modelo: string
  marca: string
  color: string | null
  capacidad_gb: string
  cantidad_actual: number
  cantidad_minima: number
  ubicacion: string
  estado: string
  nivel_stock: 'CRÍTICO' | 'BAJO' | 'NORMAL'
  ultima_actualizacion: string
}
