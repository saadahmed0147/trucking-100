import { generateId } from './utils'

export interface User {
  id: string;
  email: string;
  name: string;
  phone?: string;
  provider: 'email' | 'google';
  subscription: {
    plan: 'free' | 'premium' | 'enterprise';
    status: 'active' | 'cancelled' | 'expired';
    tripsRemaining: number;
  };
  totalTrips: number;
  totalDistance: number;
  totalFuelUsed: number;
  createdAt: Date;
  lastActive: Date;
}

export interface Trip {
  id: string;
  userId: string;
  userName: string;
  userEmail: string;
  pickup: string;
  destination: string;
  pickupCoords: [number, number];
  destinationCoords: [number, number];
  distance: number;
  estimatedFuel: number;
  fuelCost: number;
  duration: string;
  status: 'planning' | 'active' | 'completed' | 'cancelled';
  startDate: Date;
  endDate?: Date;
  createdAt: Date;
}

export interface Payment {
  id: string;
  userId: string;
  amount: number;
  status: 'completed' | 'pending' | 'failed';
  plan: string;
  paymentMethod: string;
  transactionId: string;
  createdAt: Date;
}

export interface POICategory {
  id: string;
  name: string;
  icon: string;
  type: 'fuel' | 'food' | 'rest' | 'mechanic' | 'weigh_station';
  usageCount: number;
  isActive: boolean;
}

// Mock data generation
const generateUsers = (count: number): User[] => {
  const users: User[] = []
  const providers: ('email' | 'google')[] = ['email', 'google']
  const plans: ('free' | 'premium' | 'enterprise')[] = ['free', 'premium', 'enterprise']
  const statuses: ('active' | 'cancelled' | 'expired')[] = ['active', 'cancelled', 'expired']

  for (let i = 0; i < count; i++) {
    const createdAt = new Date(Date.now() - Math.random() * 365 * 24 * 60 * 60 * 1000)
    users.push({
      id: generateId(),
      email: `user${i + 1}@example.com`,
      name: `User ${i + 1}`,
      phone: Math.random() > 0.3 ? `+1${Math.floor(Math.random() * 9000000000) + 1000000000}` : undefined,
      provider: providers[Math.floor(Math.random() * providers.length)],
      subscription: {
        plan: plans[Math.floor(Math.random() * plans.length)],
        status: statuses[Math.floor(Math.random() * statuses.length)],
        tripsRemaining: Math.floor(Math.random() * 50),
      },
      totalTrips: Math.floor(Math.random() * 100),
      totalDistance: Math.floor(Math.random() * 10000),
      totalFuelUsed: Math.floor(Math.random() * 1000),
      createdAt,
      lastActive: new Date(createdAt.getTime() + Math.random() * (Date.now() - createdAt.getTime())),
    })
  }
  return users
}

const generateTrips = (users: User[], count: number): Trip[] => {
  const trips: Trip[] = []
  const statuses: ('planning' | 'active' | 'completed' | 'cancelled')[] = ['planning', 'active', 'completed', 'cancelled']
  const cities = [
    'New York, NY', 'Los Angeles, CA', 'Chicago, IL', 'Houston, TX', 'Phoenix, AZ',
    'Philadelphia, PA', 'San Antonio, TX', 'San Diego, CA', 'Dallas, TX', 'San Jose, CA'
  ]

  for (let i = 0; i < count; i++) {
    const user = users[Math.floor(Math.random() * users.length)]
    const pickup = cities[Math.floor(Math.random() * cities.length)]
    const destination = cities[Math.floor(Math.random() * cities.length)]
    const distance = Math.floor(Math.random() * 2000) + 100
    const estimatedFuel = distance / (Math.random() * 3 + 6) // 6-9 MPG
    const createdAt = new Date(Date.now() - Math.random() * 30 * 24 * 60 * 60 * 1000)

    trips.push({
      id: generateId(),
      userId: user.id,
      userName: user.name,
      userEmail: user.email,
      pickup,
      destination,
      pickupCoords: [Math.random() * 180 - 90, Math.random() * 360 - 180],
      destinationCoords: [Math.random() * 180 - 90, Math.random() * 360 - 180],
      distance,
      estimatedFuel,
      fuelCost: estimatedFuel * (Math.random() * 2 + 3), // $3-5 per gallon
      duration: `${Math.floor(distance / (Math.random() * 20 + 50))}h ${Math.floor(Math.random() * 60)}m`,
      status: statuses[Math.floor(Math.random() * statuses.length)],
      startDate: createdAt,
      endDate: Math.random() > 0.5 ? new Date(createdAt.getTime() + Math.random() * 7 * 24 * 60 * 60 * 1000) : undefined,
      createdAt,
    })
  }
  return trips
}

const generatePayments = (users: User[], count: number): Payment[] => {
  const payments: Payment[] = []
  const statuses: ('completed' | 'pending' | 'failed')[] = ['completed', 'pending', 'failed']
  const plans = ['Free Trial', 'Premium Monthly', 'Enterprise Annual']
  const paymentMethods = ['Credit Card', 'PayPal', 'Bank Transfer']

  for (let i = 0; i < count; i++) {
    const user = users[Math.floor(Math.random() * users.length)]
    payments.push({
      id: generateId(),
      userId: user.id,
      amount: Math.floor(Math.random() * 500) + 10,
      status: statuses[Math.floor(Math.random() * statuses.length)],
      plan: plans[Math.floor(Math.random() * plans.length)],
      paymentMethod: paymentMethods[Math.floor(Math.random() * paymentMethods.length)],
      transactionId: `txn_${generateId()}`,
      createdAt: new Date(Date.now() - Math.random() * 30 * 24 * 60 * 60 * 1000),
    })
  }
  return payments
}

const generatePOICategories = (): POICategory[] => {
  return [
    {
      id: generateId(),
      name: 'Fuel Stations',
      icon: '⛽',
      type: 'fuel',
      usageCount: 1250,
      isActive: true,
    },
    {
      id: generateId(),
      name: 'Restaurants',
      icon: '🍔',
      type: 'food',
      usageCount: 850,
      isActive: true,
    },
    {
      id: generateId(),
      name: 'Rest Areas',
      icon: '🛌',
      type: 'rest',
      usageCount: 620,
      isActive: true,
    },
    {
      id: generateId(),
      name: 'Mechanic Shops',
      icon: '🔧',
      type: 'mechanic',
      usageCount: 340,
      isActive: true,
    },
    {
      id: generateId(),
      name: 'Weigh Stations',
      icon: '⚖️',
      type: 'weigh_station',
      usageCount: 280,
      isActive: true,
    },
  ]
}

// Generate mock data
export const mockUsers = generateUsers(50)
export const mockTrips = generateTrips(mockUsers, 200)
export const mockPayments = generatePayments(mockUsers, 100)
export const mockPOICategories = generatePOICategories()

// Analytics data
export const mockAnalytics = {
  userGrowth: [
    { month: 'Jan', users: 120 },
    { month: 'Feb', users: 150 },
    { month: 'Mar', users: 180 },
    { month: 'Apr', users: 220 },
    { month: 'May', users: 280 },
    { month: 'Jun', users: 350 },
  ],
  tripVolume: [
    { month: 'Jan', trips: 320 },
    { month: 'Feb', trips: 420 },
    { month: 'Mar', trips: 580 },
    { month: 'Apr', trips: 680 },
    { month: 'May', trips: 820 },
    { month: 'Jun', trips: 1020 },
  ],
  revenue: [
    { month: 'Jan', revenue: 12000 },
    { month: 'Feb', revenue: 15500 },
    { month: 'Mar', revenue: 18200 },
    { month: 'Apr', revenue: 22800 },
    { month: 'May', revenue: 28500 },
    { month: 'Jun', revenue: 35200 },
  ],
  fuelEfficiency: [
    { category: 'Excellent (>8 MPG)', value: 25 },
    { category: 'Good (6-8 MPG)', value: 45 },
    { category: 'Average (4-6 MPG)', value: 25 },
    { category: 'Poor (<4 MPG)', value: 5 },
  ],
}
