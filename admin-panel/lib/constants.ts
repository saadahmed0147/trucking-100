export const APP_NAME = "Trucking-100 Admin"
export const APP_DESCRIPTION = "Admin panel for Fuel Route trucking app"

export const TRIP_STATUS = {
  PLANNING: 'planning',
  ACTIVE: 'active',
  COMPLETED: 'completed',
  CANCELLED: 'cancelled',
} as const

export const SUBSCRIPTION_PLANS = {
  FREE: 'free',
  PREMIUM: 'premium',
  ENTERPRISE: 'enterprise',
} as const

export const SUBSCRIPTION_STATUS = {
  ACTIVE: 'active',
  CANCELLED: 'cancelled',
  EXPIRED: 'expired',
} as const

export const PAYMENT_STATUS = {
  COMPLETED: 'completed',
  PENDING: 'pending',
  FAILED: 'failed',
} as const

export const POI_TYPES = {
  FUEL: 'fuel',
  FOOD: 'food',
  REST: 'rest',
  MECHANIC: 'mechanic',
  WEIGH_STATION: 'weigh_station',
} as const

export const USER_PROVIDERS = {
  EMAIL: 'email',
  GOOGLE: 'google',
} as const
