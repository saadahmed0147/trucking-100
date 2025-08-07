'use client'

import React, { useState, useEffect, useMemo } from 'react'
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
  AreaChart,
  Area
} from 'recharts'
import {
  TrendingUp,
  DollarSign,
  Users,
  Calendar,
  Activity,
  BarChart3,
  Target,
  Award
} from 'lucide-react'

export default function AnalyticsPage() {
  const [timeRange, setTimeRange] = useState('30d')
  const [loading, setLoading] = useState(true)

  useEffect(() => {
    const timer = setTimeout(() => setLoading(false), 1000)
    return () => clearTimeout(timer)
  }, [])

  const analyticsData = useMemo(() => ({
    revenue: [
      { month: 'Jan', amount: 45000, trips: 120, users: 85 },
      { month: 'Feb', amount: 52000, trips: 145, users: 92 },
      { month: 'Mar', amount: 48000, trips: 132, users: 88 },
      { month: 'Apr', amount: 61000, trips: 168, users: 105 },
      { month: 'May', amount: 55000, trips: 155, users: 98 },
      { month: 'Jun', amount: 67000, trips: 185, users: 115 }
    ],
    tripsByStatus: [
      { name: 'Completed', value: 456, color: '#10b981' },
      { name: 'Active', value: 89, color: '#3b82f6' },
      { name: 'Cancelled', value: 23, color: '#ef4444' },
      { name: 'Planning', value: 67, color: '#f59e0b' }
    ],
    userGrowth: [
      { month: 'Jan', new: 25, total: 180 },
      { month: 'Feb', new: 32, total: 212 },
      { month: 'Mar', new: 28, total: 240 },
      { month: 'Apr', new: 45, total: 285 },
      { month: 'May', new: 38, total: 323 },
      { month: 'Jun', new: 42, total: 365 }
    ]
  }), [])

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
          <p className="text-gray-600 text-lg">Loading analytics...</p>
        </div>
      </div>
    )
  }

  return (
    <div className="space-y-8">
      {/* Analytics Header */}
      <div 
        className="rounded-xl p-8 shadow-lg"
        style={{ 
          background: 'linear-gradient(135deg, #1e40af 0%, #3b82f6 50%, #60a5fa 100%)',
          color: 'white'
        }}
      >
        <div className="flex items-center justify-between">
          <div>
            <h1 className="text-3xl font-bold mb-2">Analytics Dashboard</h1>
            <p className="text-blue-100 text-lg">
              Comprehensive insights and performance metrics
            </p>
          </div>
          <div className="hidden md:block">
            <BarChart3 className="w-16 h-16 text-blue-200" />
          </div>
        </div>
      </div>

      {/* Time Range Filter */}
      <div 
        className="rounded-xl p-6 shadow-lg border"
        style={{ backgroundColor: '#ffffff', borderColor: '#e2e8f0' }}
      >
        <div className="flex items-center justify-between">
          <h3 className="text-lg font-semibold text-gray-900">Time Period</h3>
          <div className="flex space-x-2">
            {['7d', '30d', '90d', '1y'].map((range) => (
              <button
                key={range}
                onClick={() => setTimeRange(range)}
                className={`px-4 py-2 rounded-lg font-medium transition-colors duration-200 ${
                  timeRange === range
                    ? 'text-white'
                    : 'text-gray-600 hover:bg-gray-100'
                }`}
                style={timeRange === range ? { 
                  background: 'linear-gradient(135deg, #3b82f6, #1e40af)' 
                } : {}}
              >
                {range === '7d' ? '7 Days' : 
                 range === '30d' ? '30 Days' : 
                 range === '90d' ? '90 Days' : '1 Year'}
              </button>
            ))}
          </div>
        </div>
      </div>

      {/* Key Metrics */}
      <div className="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-4 gap-6">
        <div 
          className="rounded-xl p-6 shadow-lg border transition-transform duration-200 hover:scale-105"
          style={{ backgroundColor: '#ffffff', borderColor: '#e2e8f0' }}
        >
          <div className="flex items-center justify-between">
            <div>
              <p className="text-sm font-medium text-gray-600">Total Revenue</p>
              <p className="text-3xl font-bold text-gray-900">$328,000</p>
              <div className="flex items-center mt-2">
                <TrendingUp className="w-4 h-4 text-green-500 mr-1" />
                <span className="text-sm text-green-600 font-medium">+18.5%</span>
              </div>
            </div>
            <div 
              className="p-3 rounded-xl"
              style={{ background: 'linear-gradient(135deg, #10b981, #059669)' }}
            >
              <DollarSign className="w-6 h-6 text-white" />
            </div>
          </div>
        </div>

        <div 
          className="rounded-xl p-6 shadow-lg border transition-transform duration-200 hover:scale-105"
          style={{ backgroundColor: '#ffffff', borderColor: '#e2e8f0' }}
        >
          <div className="flex items-center justify-between">
            <div>
              <p className="text-sm font-medium text-gray-600">Total Trips</p>
              <p className="text-3xl font-bold text-gray-900">1,205</p>
              <div className="flex items-center mt-2">
                <TrendingUp className="w-4 h-4 text-green-500 mr-1" />
                <span className="text-sm text-green-600 font-medium">+12.3%</span>
              </div>
            </div>
            <div 
              className="p-3 rounded-xl"
              style={{ background: 'linear-gradient(135deg, #3b82f6, #1e40af)' }}
            >
              <Activity className="w-6 h-6 text-white" />
            </div>
          </div>
        </div>

        <div 
          className="rounded-xl p-6 shadow-lg border transition-transform duration-200 hover:scale-105"
          style={{ backgroundColor: '#ffffff', borderColor: '#e2e8f0' }}
        >
          <div className="flex items-center justify-between">
            <div>
              <p className="text-sm font-medium text-gray-600">Active Users</p>
              <p className="text-3xl font-bold text-gray-900">365</p>
              <div className="flex items-center mt-2">
                <TrendingUp className="w-4 h-4 text-green-500 mr-1" />
                <span className="text-sm text-green-600 font-medium">+8.2%</span>
              </div>
            </div>
            <div 
              className="p-3 rounded-xl"
              style={{ background: 'linear-gradient(135deg, #8b5cf6, #7c3aed)' }}
            >
              <Users className="w-6 h-6 text-white" />
            </div>
          </div>
        </div>

        <div 
          className="rounded-xl p-6 shadow-lg border transition-transform duration-200 hover:scale-105"
          style={{ backgroundColor: '#ffffff', borderColor: '#e2e8f0' }}
        >
          <div className="flex items-center justify-between">
            <div>
              <p className="text-sm font-medium text-gray-600">Avg Trip Value</p>
              <p className="text-3xl font-bold text-gray-900">$272</p>
              <div className="flex items-center mt-2">
                <TrendingUp className="w-4 h-4 text-green-500 mr-1" />
                <span className="text-sm text-green-600 font-medium">+5.7%</span>
              </div>
            </div>
            <div 
              className="p-3 rounded-xl"
              style={{ background: 'linear-gradient(135deg, #f59e0b, #d97706)' }}
            >
              <Target className="w-6 h-6 text-white" />
            </div>
          </div>
        </div>
      </div>

      {/* Charts Row */}
      <div className="grid grid-cols-1 lg:grid-cols-2 gap-8">
        {/* Revenue Trend */}
        <div 
          className="rounded-xl p-6 shadow-lg border"
          style={{ backgroundColor: '#ffffff', borderColor: '#e2e8f0' }}
        >
          <div className="flex items-center justify-between mb-6">
            <h3 className="text-xl font-bold text-gray-900">Revenue Trend</h3>
            <div className="flex items-center space-x-2">
              <div className="w-3 h-3 rounded-full" style={{ backgroundColor: '#3b82f6' }}></div>
              <span className="text-sm text-gray-600">Monthly Revenue</span>
            </div>
          </div>
          
          <div className="h-80">
            <ResponsiveContainer width="100%" height="100%">
              <AreaChart data={analyticsData.revenue}>
                <defs>
                  <linearGradient id="revenueGradient" x1="0" y1="0" x2="0" y2="1">
                    <stop offset="5%" stopColor="#3b82f6" stopOpacity={0.3}/>
                    <stop offset="95%" stopColor="#3b82f6" stopOpacity={0}/>
                  </linearGradient>
                </defs>
                <CartesianGrid strokeDasharray="3 3" stroke="#f1f5f9" />
                <XAxis dataKey="month" stroke="#64748b" fontSize={12} />
                <YAxis stroke="#64748b" fontSize={12} />
                <Tooltip 
                  contentStyle={{
                    backgroundColor: '#ffffff',
                    border: '1px solid #e2e8f0',
                    borderRadius: '8px',
                    boxShadow: '0 4px 6px -1px rgba(0, 0, 0, 0.1)'
                  }}
                />
                <Area 
                  type="monotone" 
                  dataKey="amount" 
                  stroke="#3b82f6" 
                  fillOpacity={1} 
                  fill="url(#revenueGradient)"
                  strokeWidth={3}
                />
              </AreaChart>
            </ResponsiveContainer>
          </div>
        </div>

        {/* Trip Status Distribution */}
        <div 
          className="rounded-xl p-6 shadow-lg border"
          style={{ backgroundColor: '#ffffff', borderColor: '#e2e8f0' }}
        >
          <div className="flex items-center justify-between mb-6">
            <h3 className="text-xl font-bold text-gray-900">Trip Status Distribution</h3>
            <Award className="w-6 h-6 text-gray-400" />
          </div>
          
          <div className="h-80">
            <ResponsiveContainer width="100%" height="100%">
              <PieChart>
                <Pie
                  data={analyticsData.tripsByStatus}
                  cx="50%"
                  cy="50%"
                  labelLine={false}
                  label={({ name, percent }) => `${name} ${(percent * 100).toFixed(0)}%`}
                  outerRadius={80}
                  fill="#8884d8"
                  dataKey="value"
                >
                  {analyticsData.tripsByStatus.map((entry, index) => (
                    <Cell key={`cell-${index}`} fill={entry.color} />
                  ))}
                </Pie>
                <Tooltip />
              </PieChart>
            </ResponsiveContainer>
          </div>
          
          <div className="mt-6 space-y-2">
            {analyticsData.tripsByStatus.map((item, index) => (
              <div key={index} className="flex items-center justify-between">
                <div className="flex items-center">
                  <div 
                    className="w-3 h-3 rounded-full mr-3"
                    style={{ backgroundColor: item.color }}
                  ></div>
                  <span className="text-sm text-gray-600">{item.name}</span>
                </div>
                <span className="text-sm font-medium text-gray-900">{item.value}</span>
              </div>
            ))}
          </div>
        </div>
      </div>

      {/* User Growth Chart */}
      <div 
        className="rounded-xl p-6 shadow-lg border"
        style={{ backgroundColor: '#ffffff', borderColor: '#e2e8f0' }}
      >
        <div className="flex items-center justify-between mb-6">
          <div>
            <h3 className="text-xl font-bold text-gray-900">User Growth</h3>
            <p className="text-sm text-gray-500 mt-1">New users vs Total users over time</p>
          </div>
          <div className="flex items-center space-x-4">
            <div className="flex items-center space-x-2">
              <div className="w-3 h-3 rounded-full" style={{ backgroundColor: '#3b82f6' }}></div>
              <span className="text-sm text-gray-600">New Users</span>
            </div>
            <div className="flex items-center space-x-2">
              <div className="w-3 h-3 rounded-full" style={{ backgroundColor: '#10b981' }}></div>
              <span className="text-sm text-gray-600">Total Users</span>
            </div>
          </div>
        </div>
        
        <div className="h-80">
          <ResponsiveContainer width="100%" height="100%">
            <BarChart data={analyticsData.userGrowth}>
              <CartesianGrid strokeDasharray="3 3" stroke="#f1f5f9" />
              <XAxis dataKey="month" stroke="#64748b" fontSize={12} />
              <YAxis stroke="#64748b" fontSize={12} />
              <Tooltip 
                contentStyle={{
                  backgroundColor: '#ffffff',
                  border: '1px solid #e2e8f0',
                  borderRadius: '8px',
                  boxShadow: '0 4px 6px -1px rgba(0, 0, 0, 0.1)'
                }}
              />
              <Bar dataKey="new" fill="#3b82f6" radius={[4, 4, 0, 0]} />
              <Bar dataKey="total" fill="#10b981" radius={[4, 4, 0, 0]} />
            </BarChart>
          </ResponsiveContainer>
        </div>
      </div>
    </div>
  )
}