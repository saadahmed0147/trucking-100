// Firebase configuration and services
import { initializeApp } from 'firebase/app'
import { getDatabase, ref, get, onValue, DatabaseReference } from 'firebase/database'
import { firebaseConfig, DB_PATHS } from './firebase-config'

// Initialize Firebase
const app = initializeApp(firebaseConfig)
export const database = getDatabase(app)

// Types based on your Firebase data structure
export interface Trip {
  id: string
  createdAt: string
  currentLocationUpdatedAt?: string
  date: string
  destination: string
  destinationLat: number
  destinationLng: number
  distanceMiles: number
  duration: string
  estimatedFuel: number
  fuelCost: number
  pickup: string
  pickupLat: number
  pickupLng: number
  status: 'completed' | 'active' | 'planning' | 'cancelled'
  userEmail: string
  userName: string
}

export interface User {
  id: string
  uid?: string
  name?: string
  email?: string
  phone?: string
  role?: string
  status?: string
  joinDate?: string
  profilePicture?: string
  location?: {
    lat: number
    lng: number
    address: string
  }
  // Add more user fields as needed
}

export interface DashboardStats {
  totalUsers: number
  totalTrips: number
  activeTrips: number
  completedTrips: number
  totalRevenue: number
  totalFuelCost: number
  avgTripDistance: number
  revenueChange: number
  tripsChange: number
  usersChange: number
}

// Firebase service functions
export class FirebaseService {
  
  // Fetch all trips
  static async getTrips(): Promise<Trip[]> {
    try {
      const tripsRef = ref(database, DB_PATHS.TRIPS)
      const snapshot = await get(tripsRef)
      
      if (snapshot.exists()) {
        const tripsData = snapshot.val()
        return Object.keys(tripsData).map(key => ({
          id: key,
          ...tripsData[key]
        })).filter(trip => trip.userName) // Filter out incomplete trips
      }
      return []
    } catch (error) {
      console.error('Error fetching trips:', error)
      return []
    }
  }

  // Fetch all users
  static async getUsers(): Promise<User[]> {
    try {
      const usersRef = ref(database, DB_PATHS.USERS)
      const snapshot = await get(usersRef)
      
      if (snapshot.exists()) {
        const usersData = snapshot.val()
        return Object.keys(usersData).map(key => ({
          id: key,
          ...usersData[key]
        }))
      }
      return []
    } catch (error) {
      console.error('Error fetching users:', error)
      return []
    }
  }

  // Calculate dashboard statistics
  static calculateDashboardStats(trips: Trip[], users: User[]): DashboardStats {
    const totalTrips = trips.length
    const activeTrips = trips.filter(trip => trip.status === 'active').length
    const completedTrips = trips.filter(trip => trip.status === 'completed').length
    
    const totalRevenue = trips.reduce((sum, trip) => {
      return sum + (trip.fuelCost || 0)
    }, 0)
    
    const avgTripDistance = trips.reduce((sum, trip) => {
      return sum + (trip.distanceMiles || 0)
    }, 0) / totalTrips || 0

    // Calculate changes (mock for now - you can implement based on historical data)
    const revenueChange = 15.2
    const tripsChange = 8.5
    const usersChange = 12.3

    return {
      totalUsers: users.length,
      totalTrips,
      activeTrips,
      completedTrips,
      totalRevenue,
      totalFuelCost: totalRevenue,
      avgTripDistance,
      revenueChange,
      tripsChange,
      usersChange
    }
  }

  // Get recent activities from trips
  static getRecentActivities(trips: Trip[]): Array<{
    id: string
    type: string
    user: string
    description: string
    time: string
    status: string
    timestamp: Date
  }> {
    // Sort trips by creation date (most recent first)
    const sortedTrips = trips
      .filter(trip => trip.createdAt)
      .sort((a, b) => new Date(b.createdAt).getTime() - new Date(a.createdAt).getTime())
      .slice(0, 10) // Get last 10 activities

    return sortedTrips.map(trip => {
      const createdDate = new Date(trip.createdAt)
      const now = new Date()
      const diffHours = Math.floor((now.getTime() - createdDate.getTime()) / (1000 * 60 * 60))
      const diffDays = Math.floor(diffHours / 24)
      
      let timeAgo = ''
      if (diffDays > 0) {
        timeAgo = `${diffDays} day${diffDays > 1 ? 's' : ''} ago`
      } else if (diffHours > 0) {
        timeAgo = `${diffHours} hour${diffHours > 1 ? 's' : ''} ago`
      } else {
        timeAgo = 'Just now'
      }

      let activityType = 'trip_started'
      let description = `Started trip from ${trip.pickup} to ${trip.destination}`
      
      if (trip.status === 'completed') {
        activityType = 'trip_completed'
        description = `Completed trip from ${trip.pickup} to ${trip.destination}`
      } else if (trip.status === 'active') {
        activityType = 'trip_active'
        description = `Trip in progress from ${trip.pickup} to ${trip.destination}`
      }

      return {
        id: trip.id,
        type: activityType,
        user: trip.userName,
        description,
        time: timeAgo,
        status: trip.status,
        timestamp: createdDate
      }
    })
  }

  // Get monthly chart data
  static getMonthlyChartData(trips: Trip[]): Array<{
    month: string
    users: number
    trips: number
    revenue: number
  }> {
    const monthlyData: { [key: string]: { trips: number, revenue: number, users: Set<string> } } = {}
    
    trips.forEach(trip => {
      if (trip.createdAt) {
        const date = new Date(trip.createdAt)
        const monthKey = date.toLocaleDateString('en-US', { month: 'short', year: 'numeric' })
        
        if (!monthlyData[monthKey]) {
          monthlyData[monthKey] = { trips: 0, revenue: 0, users: new Set() }
        }
        
        monthlyData[monthKey].trips += 1
        monthlyData[monthKey].revenue += trip.fuelCost || 0
        monthlyData[monthKey].users.add(trip.userEmail)
      }
    })

    // Convert to array and sort by date
    return Object.keys(monthlyData)
      .map(month => ({
        month: month.split(' ')[0], // Just month name
        trips: monthlyData[month].trips,
        revenue: monthlyData[month].revenue,
        users: monthlyData[month].users.size
      }))
      .sort((a, b) => {
        const monthOrder = ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun', 'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec']
        return monthOrder.indexOf(a.month) - monthOrder.indexOf(b.month)
      })
  }

  // Listen to real-time updates
  static subscribeToTrips(callback: (trips: Trip[]) => void): () => void {
    const tripsRef = ref(database, DB_PATHS.TRIPS)
    const unsubscribe = onValue(tripsRef, (snapshot) => {
      if (snapshot.exists()) {
        const tripsData = snapshot.val()
        const trips = Object.keys(tripsData).map(key => ({
          id: key,
          ...tripsData[key]
        })).filter(trip => trip.userName)
        callback(trips)
      } else {
        callback([])
      }
    })
    return unsubscribe
  }

  static subscribeToUsers(callback: (users: User[]) => void): () => void {
    const usersRef = ref(database, DB_PATHS.USERS)
    const unsubscribe = onValue(usersRef, (snapshot) => {
      if (snapshot.exists()) {
        const usersData = snapshot.val()
        const users = Object.keys(usersData).map(key => ({
          id: key,
          ...usersData[key]
        }))
        callback(users)
      } else {
        callback([])
      }
    })
    return unsubscribe
  }
}
