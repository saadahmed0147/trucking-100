'use client'

import React, { useState, useMemo } from 'react'
import { 
  Search, 
  Filter, 
  Download, 
  Eye, 
  MapPin, 
  Clock,
  Fuel,
  DollarSign,
  Calendar,
  Route,
  Navigation,
  CheckCircle,
  XCircle,
  Pause,
  Play
} from 'lucide-react'

// Mock trip data
const mockTrips = [
  {
    id: '1',
    userId: '1',
    userName: 'John Driver',
    userEmail: 'john@example.com',
    pickup: 'Los Angeles, CA',
    destination: 'Phoenix, AZ',
    pickupCoords: [34.0522, -118.2437],
    destinationCoords: [33.4484, -112.0740],
    distance: 372,
    estimatedFuel: 52.8,
    fuelCost: 185.12,
    duration: '5h 30m',
    status: 'completed',
    startDate: new Date('2024-06-01T08:00:00'),
    endDate: new Date('2024-06-01T13:30:00'),
    createdAt: new Date('2024-05-30T10:00:00'),
  },
  {
    id: '2',
    userId: '2',
    userName: 'Sarah Johnson',
    userEmail: 'sarah@example.com',
    pickup: 'Houston, TX',
    destination: 'Dallas, TX',
    pickupCoords: [29.7604, -95.3698],
    destinationCoords: [32.7767, -96.7970],
    distance: 240,
    estimatedFuel: 34.3,
    fuelCost: 120.05,
    duration: '3h 45m',
    status: 'active',
    startDate: new Date('2024-06-15T09:00:00'),
    endDate: undefined,
    createdAt: new Date('2024-06-14T16:00:00'),
  },
  {
    id: '3',
    userId: '3',
    userName: 'Mike Wilson',
    userEmail: 'mike@example.com',
    pickup: 'Chicago, IL',
    destination: 'Detroit, MI',
    pickupCoords: [41.8781, -87.6298],
    destinationCoords: [42.3314, -83.0458],
    distance: 283,
    estimatedFuel: 40.4,
    fuelCost: 141.40,
    duration: '4h 20m',
    status: 'planning',
    startDate: new Date('2024-06-20T07:00:00'),
    endDate: undefined,
    createdAt: new Date('2024-06-15T11:00:00'),
  },
]

const getStatusBadgeColor = (status: string) => {
  switch (status) {
    case 'completed':
      return 'bg-green-100 text-green-800 dark:bg-green-900 dark:text-green-200'
    case 'active':
      return 'bg-blue-100 text-blue-800 dark:bg-blue-900 dark:text-blue-200'
    case 'planning':
      return 'bg-yellow-100 text-yellow-800 dark:bg-yellow-900 dark:text-yellow-200'
    case 'cancelled':
      return 'bg-red-100 text-red-800 dark:bg-red-900 dark:text-red-200'
    default:
      return 'bg-gray-100 text-gray-800 dark:bg-gray-700 dark:text-gray-200'
  }
}

const getStatusIcon = (status: string) => {
  switch (status) {
    case 'completed':
      return <CheckCircle className="w-4 h-4" />
    case 'active':
      return <Play className="w-4 h-4" />
    case 'planning':
      return <Pause className="w-4 h-4" />
    case 'cancelled':
      return <XCircle className="w-4 h-4" />
    default:
      return <Clock className="w-4 h-4" />
  }
}

export default function TripsPage() {
  const [searchTerm, setSearchTerm] = useState('')
  const [selectedStatus, setSelectedStatus] = useState('all')
  const [dateRange, setDateRange] = useState('all')

  const filteredTrips = useMemo(() => {
    return mockTrips.filter(trip => {
      const matchesSearch = trip.pickup.toLowerCase().includes(searchTerm.toLowerCase()) ||
                           trip.destination.toLowerCase().includes(searchTerm.toLowerCase()) ||
                           trip.userName.toLowerCase().includes(searchTerm.toLowerCase())
      const matchesStatus = selectedStatus === 'all' || trip.status === selectedStatus
      
      let matchesDate = true
      if (dateRange !== 'all') {
        const now = new Date()
        const tripDate = trip.startDate
        
        switch (dateRange) {
          case 'today':
            matchesDate = tripDate.toDateString() === now.toDateString()
            break
          case 'week':
            const weekAgo = new Date(now.getTime() - 7 * 24 * 60 * 60 * 1000)
            matchesDate = tripDate >= weekAgo
            break
          case 'month':
            const monthAgo = new Date(now.getTime() - 30 * 24 * 60 * 60 * 1000)
            matchesDate = tripDate >= monthAgo
            break
        }
      }
      
      return matchesSearch && matchesStatus && matchesDate
    })
  }, [searchTerm, selectedStatus, dateRange])

  const tripStats = useMemo(() => {
    const total = filteredTrips.length
    const completed = filteredTrips.filter(t => t.status === 'completed').length
    const active = filteredTrips.filter(t => t.status === 'active').length
    const planning = filteredTrips.filter(t => t.status === 'planning').length
    const totalDistance = filteredTrips.reduce((sum, trip) => sum + trip.distance, 0)
    const totalFuel = filteredTrips.reduce((sum, trip) => sum + trip.estimatedFuel, 0)
    const totalCost = filteredTrips.reduce((sum, trip) => sum + trip.fuelCost, 0)

    return {
      total,
      completed,
      active,
      planning,
      totalDistance,
      totalFuel,
      totalCost,
    }
  }, [filteredTrips])

  return (
    <div className="space-y-6">
      {/* Page header */}
      <div>
        <h1 className="text-2xl font-bold text-gray-900 dark:text-white">Trips</h1>
        <p className="mt-1 text-sm text-gray-500 dark:text-gray-400">
          Monitor and manage all trucking trips across your platform.
        </p>
      </div>

      {/* Trip stats */}
      <div className="grid grid-cols-1 gap-5 sm:grid-cols-2 lg:grid-cols-4">
        <div className="bg-white dark:bg-gray-800 overflow-hidden shadow rounded-lg">
          <div className="p-5">
            <div className="flex items-center">
              <div className="flex-shrink-0">
                <Route className="h-6 w-6 text-gray-400" />
              </div>
              <div className="ml-5 w-0 flex-1">
                <dl>
                  <dt className="text-sm font-medium text-gray-500 dark:text-gray-400 truncate">
                    Total Trips
                  </dt>
                  <dd className="text-lg font-medium text-gray-900 dark:text-white">
                    {tripStats.total}
                  </dd>
                </dl>
              </div>
            </div>
          </div>
        </div>

        <div className="bg-white dark:bg-gray-800 overflow-hidden shadow rounded-lg">
          <div className="p-5">
            <div className="flex items-center">
              <div className="flex-shrink-0">
                <MapPin className="h-6 w-6 text-gray-400" />
              </div>
              <div className="ml-5 w-0 flex-1">
                <dl>
                  <dt className="text-sm font-medium text-gray-500 dark:text-gray-400 truncate">
                    Total Distance
                  </dt>
                  <dd className="text-lg font-medium text-gray-900 dark:text-white">
                    {tripStats.totalDistance.toLocaleString()} mi
                  </dd>
                </dl>
              </div>
            </div>
          </div>
        </div>

        <div className="bg-white dark:bg-gray-800 overflow-hidden shadow rounded-lg">
          <div className="p-5">
            <div className="flex items-center">
              <div className="flex-shrink-0">
                <Fuel className="h-6 w-6 text-gray-400" />
              </div>
              <div className="ml-5 w-0 flex-1">
                <dl>
                  <dt className="text-sm font-medium text-gray-500 dark:text-gray-400 truncate">
                    Total Fuel
                  </dt>
                  <dd className="text-lg font-medium text-gray-900 dark:text-white">
                    {tripStats.totalFuel.toFixed(1)} gal
                  </dd>
                </dl>
              </div>
            </div>
          </div>
        </div>

        <div className="bg-white dark:bg-gray-800 overflow-hidden shadow rounded-lg">
          <div className="p-5">
            <div className="flex items-center">
              <div className="flex-shrink-0">
                <DollarSign className="h-6 w-6 text-gray-400" />
              </div>
              <div className="ml-5 w-0 flex-1">
                <dl>
                  <dt className="text-sm font-medium text-gray-500 dark:text-gray-400 truncate">
                    Total Cost
                  </dt>
                  <dd className="text-lg font-medium text-gray-900 dark:text-white">
                    ${tripStats.totalCost.toFixed(2)}
                  </dd>
                </dl>
              </div>
            </div>
          </div>
        </div>
      </div>

      {/* Filters */}
      <div className="bg-white dark:bg-gray-800 shadow rounded-lg p-6">
        <div className="grid grid-cols-1 md:grid-cols-4 gap-4">
          <div className="relative">
            <div className="absolute inset-y-0 left-0 pl-3 flex items-center pointer-events-none">
              <Search className="h-5 w-5 text-gray-400" />
            </div>
            <input
              type="text"
              placeholder="Search trips..."
              className="block w-full pl-10 pr-3 py-2 border border-gray-300 dark:border-gray-600 rounded-md leading-5 bg-white dark:bg-gray-700 placeholder-gray-500 dark:placeholder-gray-400 focus:outline-none focus:placeholder-gray-400 focus:ring-1 focus:ring-blue-500 focus:border-blue-500 text-gray-900 dark:text-white"
              value={searchTerm}
              onChange={(e) => setSearchTerm(e.target.value)}
            />
          </div>

          <select
            className="block w-full px-3 py-2 border border-gray-300 dark:border-gray-600 rounded-md bg-white dark:bg-gray-700 text-gray-900 dark:text-white focus:outline-none focus:ring-1 focus:ring-blue-500 focus:border-blue-500"
            value={selectedStatus}
            onChange={(e) => setSelectedStatus(e.target.value)}
          >
            <option value="all">All Status</option>
            <option value="planning">Planning</option>
            <option value="active">Active</option>
            <option value="completed">Completed</option>
            <option value="cancelled">Cancelled</option>
          </select>

          <select
            className="block w-full px-3 py-2 border border-gray-300 dark:border-gray-600 rounded-md bg-white dark:bg-gray-700 text-gray-900 dark:text-white focus:outline-none focus:ring-1 focus:ring-blue-500 focus:border-blue-500"
            value={dateRange}
            onChange={(e) => setDateRange(e.target.value)}
          >
            <option value="all">All Time</option>
            <option value="today">Today</option>
            <option value="week">This Week</option>
            <option value="month">This Month</option>
          </select>

          <button className="bg-gray-100 dark:bg-gray-700 hover:bg-gray-200 dark:hover:bg-gray-600 text-gray-700 dark:text-gray-300 px-4 py-2 rounded-lg flex items-center space-x-2">
            <Download className="w-4 h-4" />
            <span>Export</span>
          </button>
        </div>
      </div>

      {/* Status summary */}
      <div className="bg-white dark:bg-gray-800 shadow rounded-lg p-6">
        <h3 className="text-lg font-medium text-gray-900 dark:text-white mb-4">Trip Status Summary</h3>
        <div className="grid grid-cols-1 sm:grid-cols-4 gap-4">
          <div className="text-center">
            <div className="text-2xl font-bold text-blue-600 dark:text-blue-400">{tripStats.active}</div>
            <div className="text-sm text-gray-500 dark:text-gray-400">Active</div>
          </div>
          <div className="text-center">
            <div className="text-2xl font-bold text-yellow-600 dark:text-yellow-400">{tripStats.planning}</div>
            <div className="text-sm text-gray-500 dark:text-gray-400">Planning</div>
          </div>
          <div className="text-center">
            <div className="text-2xl font-bold text-green-600 dark:text-green-400">{tripStats.completed}</div>
            <div className="text-sm text-gray-500 dark:text-gray-400">Completed</div>
          </div>
          <div className="text-center">
            <div className="text-2xl font-bold text-gray-600 dark:text-gray-400">{tripStats.total}</div>
            <div className="text-sm text-gray-500 dark:text-gray-400">Total</div>
          </div>
        </div>
      </div>

      {/* Trips table */}
      <div className="bg-white dark:bg-gray-800 shadow rounded-lg overflow-hidden">
        <div className="px-6 py-4 border-b border-gray-200 dark:border-gray-700">
          <h3 className="text-lg font-medium text-gray-900 dark:text-white">
            Trips ({filteredTrips.length})
          </h3>
        </div>

        <div className="overflow-x-auto">
          <table className="min-w-full divide-y divide-gray-200 dark:divide-gray-700">
            <thead className="bg-gray-50 dark:bg-gray-900">
              <tr>
                <th className="px-6 py-3 text-left text-xs font-medium text-gray-500 dark:text-gray-400 uppercase tracking-wider">
                  Trip Details
                </th>
                <th className="px-6 py-3 text-left text-xs font-medium text-gray-500 dark:text-gray-400 uppercase tracking-wider">
                  Driver
                </th>
                <th className="px-6 py-3 text-left text-xs font-medium text-gray-500 dark:text-gray-400 uppercase tracking-wider">
                  Route
                </th>
                <th className="px-6 py-3 text-left text-xs font-medium text-gray-500 dark:text-gray-400 uppercase tracking-wider">
                  Metrics
                </th>
                <th className="px-6 py-3 text-left text-xs font-medium text-gray-500 dark:text-gray-400 uppercase tracking-wider">
                  Status
                </th>
                <th className="px-6 py-3 text-left text-xs font-medium text-gray-500 dark:text-gray-400 uppercase tracking-wider">
                  Actions
                </th>
              </tr>
            </thead>
            <tbody className="bg-white dark:bg-gray-800 divide-y divide-gray-200 dark:divide-gray-700">
              {filteredTrips.map((trip) => (
                <tr key={trip.id} className="hover:bg-gray-50 dark:hover:bg-gray-700">
                  <td className="px-6 py-4 whitespace-nowrap">
                    <div className="flex flex-col">
                      <div className="text-sm font-medium text-gray-900 dark:text-white">
                        Trip #{trip.id}
                      </div>
                      <div className="text-sm text-gray-500 dark:text-gray-400 flex items-center">
                        <Calendar className="w-3 h-3 mr-1" />
                        {trip.startDate.toLocaleDateString()}
                      </div>
                      <div className="text-sm text-gray-500 dark:text-gray-400 flex items-center">
                        <Clock className="w-3 h-3 mr-1" />
                        {trip.duration}
                      </div>
                    </div>
                  </td>
                  <td className="px-6 py-4 whitespace-nowrap">
                    <div className="flex items-center">
                      <div className="h-8 w-8 rounded-full bg-gray-300 dark:bg-gray-600 flex items-center justify-center">
                        <span className="text-xs font-medium text-gray-700 dark:text-gray-300">
                          {trip.userName.charAt(0).toUpperCase()}
                        </span>
                      </div>
                      <div className="ml-3">
                        <div className="text-sm font-medium text-gray-900 dark:text-white">
                          {trip.userName}
                        </div>
                        <div className="text-sm text-gray-500 dark:text-gray-400">
                          {trip.userEmail}
                        </div>
                      </div>
                    </div>
                  </td>
                  <td className="px-6 py-4 whitespace-nowrap">
                    <div className="flex flex-col space-y-1">
                      <div className="text-sm text-gray-900 dark:text-white flex items-center">
                        <MapPin className="w-3 h-3 mr-1 text-green-500" />
                        {trip.pickup}
                      </div>
                      <div className="text-sm text-gray-900 dark:text-white flex items-center">
                        <MapPin className="w-3 h-3 mr-1 text-red-500" />
                        {trip.destination}
                      </div>
                      <div className="text-xs text-gray-500 dark:text-gray-400">
                        {trip.distance} miles
                      </div>
                    </div>
                  </td>
                  <td className="px-6 py-4 whitespace-nowrap text-sm text-gray-500 dark:text-gray-400">
                    <div className="flex flex-col space-y-1">
                      <div className="flex items-center">
                        <Fuel className="w-3 h-3 mr-1" />
                        {trip.estimatedFuel.toFixed(1)} gal
                      </div>
                      <div className="flex items-center">
                        <DollarSign className="w-3 h-3 mr-1" />
                        ${trip.fuelCost.toFixed(2)}
                      </div>
                    </div>
                  </td>
                  <td className="px-6 py-4 whitespace-nowrap">
                    <span className={`inline-flex items-center px-2.5 py-0.5 rounded-full text-xs font-medium capitalize ${getStatusBadgeColor(trip.status)}`}>
                      {getStatusIcon(trip.status)}
                      <span className="ml-1">{trip.status}</span>
                    </span>
                  </td>
                  <td className="px-6 py-4 whitespace-nowrap text-sm font-medium">
                    <div className="flex items-center space-x-2">
                      <button className="text-blue-600 dark:text-blue-400 hover:text-blue-900 dark:hover:text-blue-200">
                        <Eye className="w-4 h-4" />
                      </button>
                      <button className="text-green-600 dark:text-green-400 hover:text-green-900 dark:hover:text-green-200">
                        <Navigation className="w-4 h-4" />
                      </button>
                    </div>
                  </td>
                </tr>
              ))}
            </tbody>
          </table>
        </div>

        {filteredTrips.length === 0 && (
          <div className="text-center py-12">
            <Route className="mx-auto h-12 w-12 text-gray-400" />
            <h3 className="mt-2 text-sm font-medium text-gray-900 dark:text-white">No trips found</h3>
            <p className="mt-1 text-sm text-gray-500 dark:text-gray-400">
              No trips match your current filter criteria.
            </p>
          </div>
        )}
      </div>
    </div>
  )
}
