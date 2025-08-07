'use client'

import React, { useState, useEffect } from 'react'
import { useRouter } from 'next/navigation'
import { FirebaseService } from '@/lib/firebase'
import type { Trip, User, DashboardStats } from '@/lib/firebase'
import {
  BarChart,
  Bar,
  XAxis,
  YAxis,
  CartesianGrid,
  Tooltip,
  ResponsiveContainer,
  LineChart,
  Line,
  PieChart,
  Pie,
  Cell,
} from 'recharts'
import {
  TrendingUp,
  DollarSign,
  Users,
  MapPin,
  Activity,
  Truck,
  Clock,
  Award
} from 'lucide-react'

export default function DashboardPage() {
  const [trips, setTrips] = useState<Trip[]>([])
  const [users, setUsers] = useState<User[]>([])
  const [stats, setStats] = useState<DashboardStats | null>(null)
  const [activities, setActivities] = useState<any[]>([])
  const [chartData, setChartData] = useState<any[]>([])
  const [loading, setLoading] = useState(true)
  const router = useRouter()

  useEffect(() => {
    const fetchData = async () => {
      try {
        setLoading(true)
        const [tripsData, usersData] = await Promise.all([
          FirebaseService.getTrips(),
          FirebaseService.getUsers()
        ])

        setTrips(tripsData)
        setUsers(usersData)
        
        const dashboardStats = FirebaseService.calculateDashboardStats(tripsData, usersData)
        setStats(dashboardStats)

        const recentActivities = FirebaseService.getRecentActivities(tripsData)
        setActivities(recentActivities)

        const monthlyData = FirebaseService.getMonthlyChartData(tripsData)
        setChartData(monthlyData)
      } catch (error) {
        console.error('Error fetching dashboard data:', error)
      } finally {
        setLoading(false)
      }
    }

    fetchData()
  }, [])

  if (loading) {
    return (
      <div 
        className="min-h-screen flex items-center justify-center"
        style={{ backgroundColor: '#f8fafc' }}
      >
        <div className="text-center">
          <div 
            className="w-16 h-16 border-4 border-t-4 rounded-full animate-spin mx-auto mb-4"
            style={{ borderColor: '#e2e8f0', borderTopColor: '#3b82f6' }}
          ></div>
          <p className="text-gray-600 text-lg">Loading dashboard...</p>
        </div>
      </div>
    )
  }

  return (
    <div className="space-y-8">
      {/* Dashboard Header */}
      <div 
        className="rounded-xl p-8 shadow-lg"
        style={{ 
          background: 'linear-gradient(135deg, #1e40af 0%, #3b82f6 50%, #60a5fa 100%)',
          color: 'white'
        }}
      >
        <div className="flex items-center justify-between">
          <div>
            <h1 className="text-3xl font-bold mb-2">Dashboard</h1>
            <p className="text-blue-100 text-lg">
              Welcome back! Here's what's happening with your trucking platform.
            </p>
          </div>
          <div className="hidden md:block">
            <Truck className="w-16 h-16 text-blue-200" />
          </div>
        </div>
      </div>

      {/* Statistics Cards */}
      <div className="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-4 gap-6">
        {/* Total Users Card */}
        <div 
          className="rounded-xl p-6 shadow-lg border transition-transform duration-200 hover:scale-105"
          style={{ backgroundColor: '#ffffff', borderColor: '#e2e8f0' }}
        >
          <div className="flex items-center justify-between">
            <div>
              <p className="text-sm font-medium text-gray-600">Total Users</p>
              <p className="text-3xl font-bold text-gray-900">
                {stats?.totalUsers || 0}
              </p>
              <div className="flex items-center mt-2">
                <span className="text-sm text-green-600 font-medium">+12.3%</span>
                <span className="text-xs text-gray-500 ml-1">from last month</span>
              </div>
            </div>
            <div 
              className="p-3 rounded-xl"
              style={{ background: 'linear-gradient(135deg, #3b82f6, #1e40af)' }}
            >
              <Users className="w-6 h-6 text-white" />
            </div>
          </div>
        </div>

        {/* Active Trips Card */}
        <div 
          className="rounded-xl p-6 shadow-lg border transition-transform duration-200 hover:scale-105"
          style={{ backgroundColor: '#ffffff', borderColor: '#e2e8f0' }}
        >
          <div className="flex items-center justify-between">
            <div>
              <p className="text-sm font-medium text-gray-600">Active Trips</p>
              <p className="text-3xl font-bold text-gray-900">
                {stats?.activeTrips || 0}
              </p>
              <div className="flex items-center mt-2">
                <span className="text-sm text-green-600 font-medium">+8.5%</span>
                <span className="text-xs text-gray-500 ml-1">from last week</span>
              </div>
            </div>
            <div 
              className="p-3 rounded-xl"
              style={{ background: 'linear-gradient(135deg, #3b82f6, #1e40af)' }}
            >
              <TrendingUp className="w-6 h-6 text-white" />
            </div>
          </div>
        </div>

        {/* Total Revenue Card */}
        <div 
          className="rounded-xl p-6 shadow-lg border transition-transform duration-200 hover:scale-105"
          style={{ backgroundColor: '#ffffff', borderColor: '#e2e8f0' }}
        >
          <div className="flex items-center justify-between">
            <div>
              <p className="text-sm font-medium text-gray-600">Total Revenue</p>
              <p className="text-3xl font-bold text-gray-900">
                ${stats?.totalRevenue?.toLocaleString() || '0'}
              </p>
              <div className="flex items-center mt-2">
                <span className="text-sm text-green-600 font-medium">+15.2%</span>
                <span className="text-xs text-gray-500 ml-1">from last month</span>
              </div>
            </div>
            <div 
              className="p-3 rounded-xl"
              style={{ background: 'linear-gradient(135deg, #3b82f6, #1e40af)' }}
            >
              <DollarSign className="w-6 h-6 text-white" />
            </div>
          </div>
        </div>

        {/* Average Distance Card */}
        <div 
          className="rounded-xl p-6 shadow-lg border transition-transform duration-200 hover:scale-105"
          style={{ backgroundColor: '#ffffff', borderColor: '#e2e8f0' }}
        >
          <div className="flex items-center justify-between">
            <div>
              <p className="text-sm font-medium text-gray-600">Avg Distance</p>
              <p className="text-3xl font-bold text-gray-900">
                {stats?.avgTripDistance?.toFixed(0) || 0} mi
              </p>
              <div className="flex items-center mt-2">
                <span className="text-sm text-green-600 font-medium">+5.2%</span>
                <span className="text-xs text-gray-500 ml-1">from last month</span>
              </div>
            </div>
            <div 
              className="p-3 rounded-xl"
              style={{ background: 'linear-gradient(135deg, #3b82f6, #1e40af)' }}
            >
              <MapPin className="w-6 h-6 text-white" />
            </div>
          </div>
        </div>
      </div>

      {/* Charts and Activities Row */}
      <div className="grid grid-cols-1 lg:grid-cols-3 gap-8">
        {/* Monthly Overview Chart */}
        <div 
          className="lg:col-span-2 rounded-xl p-6 shadow-lg border"
          style={{ backgroundColor: '#ffffff', borderColor: '#e2e8f0' }}
        >
          <div className="flex items-center justify-between mb-6">
            <div>
              <h3 className="text-xl font-bold text-gray-900">Monthly Overview</h3>
              <p className="text-sm text-gray-500 mt-1">
                Real-time data from Firebase
              </p>
            </div>
            <div className="text-center">
              <p className="text-sm text-gray-500">Latest</p>
              <p className="text-lg font-semibold text-gray-900">
                Users: {stats?.totalUsers} | Trips: {stats?.totalTrips} | Revenue: ${stats?.totalRevenue?.toLocaleString()}
              </p>
            </div>
          </div>
          
          <div className="h-80">
            <ResponsiveContainer width="100%" height="100%">
              <LineChart data={chartData}>
                <CartesianGrid strokeDasharray="3 3" stroke="#f1f5f9" />
                <XAxis 
                  dataKey="month" 
                  stroke="#64748b"
                  fontSize={12}
                />
                <YAxis stroke="#64748b" fontSize={12} />
                <Tooltip 
                  contentStyle={{
                    backgroundColor: '#ffffff',
                    border: '1px solid #e2e8f0',
                    borderRadius: '8px',
                    boxShadow: '0 4px 6px -1px rgba(0, 0, 0, 0.1)'
                  }}
                />
                <Line 
                  type="monotone" 
                  dataKey="trips" 
                  stroke="#3b82f6" 
                  strokeWidth={3}
                  dot={{ fill: '#3b82f6', strokeWidth: 2, r: 4 }}
                />
                <Line 
                  type="monotone" 
                  dataKey="revenue" 
                  stroke="#1e40af" 
                  strokeWidth={3}
                  dot={{ fill: '#1e40af', strokeWidth: 2, r: 4 }}
                />
              </LineChart>
            </ResponsiveContainer>
          </div>
        </div>

        {/* Recent Activity */}
        <div 
          className="rounded-xl p-6 shadow-lg border"
          style={{ backgroundColor: '#ffffff', borderColor: '#e2e8f0' }}
        >
          <div className="flex items-center justify-between mb-6">
            <h3 className="text-xl font-bold text-gray-900">Recent Activity</h3>
            <Activity className="w-5 h-5 text-gray-400" />
          </div>
          
          <div className="space-y-4 max-h-80 overflow-y-auto">
            {activities.length > 0 ? (
              activities.map((activity, index) => (
                <div key={activity.id || index} className="flex items-start space-x-3">
                  <div 
                    className="w-8 h-8 rounded-full flex items-center justify-center text-white text-xs font-medium"
                    style={{ 
                      backgroundColor: activity.status === 'completed' ? '#10b981' : 
                                     activity.status === 'active' ? '#3b82f6' : '#6b7280'
                    }}
                  >
                    {activity.user ? activity.user.charAt(0).toUpperCase() : 'U'}
                  </div>
                  <div className="flex-1 min-w-0">
                    <p className="text-sm font-medium text-gray-900">
                      {activity.user || 'Unknown User'}
                    </p>
                    <p className="text-sm text-gray-500 break-words">
                      {activity.description}
                    </p>
                    <div className="flex items-center mt-1">
                      <Clock className="w-3 h-3 text-gray-400 mr-1" />
                      <p className="text-xs text-gray-400">{activity.time}</p>
                    </div>
                  </div>
                </div>
              ))
            ) : (
              <div className="text-center py-8">
                <Activity className="w-12 h-12 text-gray-300 mx-auto mb-3" />
                <p className="text-gray-500">No recent activities</p>
              </div>
            )}
          </div>
        </div>
      </div>

      {/* Quick Actions */}
      <div 
        className="rounded-xl p-6 shadow-lg border"
        style={{ backgroundColor: '#ffffff', borderColor: '#e2e8f0' }}
      >
        <div className="flex items-center justify-between mb-6">
          <div>
            <h3 className="text-xl font-bold text-gray-900">Quick Actions</h3>
            <p className="text-sm text-gray-500 mt-1">
              Access key features with one click
            </p>
          </div>
          <div className="hidden sm:flex items-center space-x-2">
            <div className="w-2 h-2 bg-green-400 rounded-full animate-pulse"></div>
            <span className="text-xs text-gray-500">Live</span>
          </div>
        </div>
        
        <div className="grid grid-cols-1 sm:grid-cols-2 lg:grid-cols-3 gap-6">
          {/* Manage Users Card */}
          <button 
            onClick={() => router.push('/dashboard/users')}
            className="group relative p-6 border-2 rounded-xl hover:shadow-xl hover:scale-105 transition-all duration-300 ease-in-out overflow-hidden"
            style={{ 
              background: 'linear-gradient(135deg, #dbeafe 0%, #bfdbfe 100%)',
              borderColor: '#3b82f6'
            }}
          >
            <div className="relative z-10">
              <div className="flex items-center justify-between mb-4">
                <div 
                  className="p-3 rounded-xl shadow-lg"
                  style={{ backgroundColor: '#3b82f6' }}
                >
                  <Users className="w-8 h-8 text-white" />
                </div>
                <div className="text-right">
                  <span 
                    className="inline-flex items-center px-2.5 py-0.5 rounded-full text-xs font-medium"
                    style={{ backgroundColor: '#dbeafe', color: '#1e40af' }}
                  >
                    {stats?.totalUsers || 0} users
                  </span>
                </div>
              </div>
              
              <h4 className="text-lg font-bold text-gray-900 mb-2">
                Manage Users
              </h4>
              <p className="text-sm text-gray-600 leading-relaxed">
                View, edit, and manage user accounts and permissions
              </p>
              
              <div className="mt-4 flex items-center text-blue-600 opacity-0 group-hover:opacity-100 transition-opacity duration-300">
                <span className="text-sm font-medium">Open Users →</span>
              </div>
            </div>
          </button>

          {/* Analytics Card */}
          <button 
            onClick={() => router.push('/dashboard/analytics')}
            className="group relative p-6 border-2 rounded-xl hover:shadow-xl hover:scale-105 transition-all duration-300 ease-in-out overflow-hidden"
            style={{ 
              background: 'linear-gradient(135deg, #dbeafe 0%, #bfdbfe 100%)',
              borderColor: '#3b82f6'
            }}
          >
            <div className="relative z-10">
              <div className="flex items-center justify-between mb-4">
                <div 
                  className="p-3 rounded-xl shadow-lg"
                  style={{ backgroundColor: '#3b82f6' }}
                >
                  <Activity className="w-8 h-8 text-white" />
                </div>
                <div className="text-right">
                  <span 
                    className="inline-flex items-center px-2.5 py-0.5 rounded-full text-xs font-medium"
                    style={{ backgroundColor: '#dbeafe', color: '#1e40af' }}
                  >
                    Live Data
                  </span>
                </div>
              </div>
              
              <h4 className="text-lg font-bold text-gray-900 mb-2">
                Analytics
              </h4>
              <p className="text-sm text-gray-600 leading-relaxed">
                View detailed insights, reports, and performance metrics
              </p>
              
              <div className="mt-4 flex items-center text-blue-600 opacity-0 group-hover:opacity-100 transition-opacity duration-300">
                <span className="text-sm font-medium">View Analytics →</span>
              </div>
            </div>
          </button>

          {/* Revenue Card */}
          <button 
            onClick={() => router.push('/dashboard/payments')}
            className="group relative p-6 border-2 rounded-xl hover:shadow-xl hover:scale-105 transition-all duration-300 ease-in-out overflow-hidden"
            style={{ 
              background: 'linear-gradient(135deg, #dbeafe 0%, #bfdbfe 100%)',
              borderColor: '#3b82f6'
            }}
          >
            <div className="relative z-10">
              <div className="flex items-center justify-between mb-4">
                <div 
                  className="p-3 rounded-xl shadow-lg"
                  style={{ backgroundColor: '#3b82f6' }}
                >
                  <DollarSign className="w-8 h-8 text-white" />
                </div>
                <div className="text-right">
                  <span 
                    className="inline-flex items-center px-2.5 py-0.5 rounded-full text-xs font-medium"
                    style={{ backgroundColor: '#dbeafe', color: '#1e40af' }}
                  >
                    ${stats?.totalRevenue?.toLocaleString() || '0'}
                  </span>
                </div>
              </div>
              
              <h4 className="text-lg font-bold text-gray-900 mb-2">
                Revenue
              </h4>
              <p className="text-sm text-gray-600 leading-relaxed">
                Track payments, transactions, and financial performance
              </p>
              
              <div className="mt-4 flex items-center text-blue-600 opacity-0 group-hover:opacity-100 transition-opacity duration-300">
                <span className="text-sm font-medium">View Revenue →</span>
              </div>
            </div>
          </button>
        </div>
      </div>
    </div>
  )
}