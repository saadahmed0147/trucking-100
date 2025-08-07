'use client'

import React, { useState, useEffect } from 'react'
import { 
  DollarSign, 
  CreditCard, 
  TrendingUp, 
  Calendar,
  Filter,
  Download,
  Search,
  CheckCircle,
  XCircle,
  Clock,
  Eye,
  MoreHorizontal
} from 'lucide-react'

interface Payment {
  id: string
  tripId: string
  userEmail: string
  userName: string
  amount: number
  status: 'completed' | 'pending' | 'failed' | 'refunded'
  method: 'credit_card' | 'debit_card' | 'paypal' | 'bank_transfer'
  transactionId: string
  date: string
  description: string
}

interface PaymentStats {
  totalRevenue: number
  totalTransactions: number
  successfulPayments: number
  pendingPayments: number
  failedPayments: number
  refundedPayments: number
  averageTransactionValue: number
  monthlyGrowth: number
}

export default function PaymentsPage() {
  const [payments, setPayments] = useState<Payment[]>([])
  const [stats, setStats] = useState<PaymentStats | null>(null)
  const [loading, setLoading] = useState(true)
  const [searchTerm, setSearchTerm] = useState('')
  const [statusFilter, setStatusFilter] = useState<string>('all')
  const [dateFilter, setDateFilter] = useState<string>('all')

  useEffect(() => {
    fetchPaymentsData()
  }, [])

  const fetchPaymentsData = async () => {
    try {
      setLoading(true)
      // Simulate API call - replace with actual data fetching
      await new Promise(resolve => setTimeout(resolve, 1000))
      
      const mockPayments: Payment[] = [
        {
          id: 'pay_001',
          tripId: 'trip_001',
          userEmail: 'saad@example.com',
          userName: 'Saad Ahmed',
          amount: 1200.50,
          status: 'completed',
          method: 'credit_card',
          transactionId: 'txn_abc123',
          date: new Date().toISOString(),
          description: 'Trip payment from NY to LA'
        },
        {
          id: 'pay_002',
          tripId: 'trip_002',
          userEmail: 'naseer@example.com',
          userName: 'Naseer Khan',
          amount: 850.75,
          status: 'pending',
          method: 'paypal',
          transactionId: 'txn_def456',
          date: new Date(Date.now() - 86400000).toISOString(),
          description: 'Trip payment from Chicago to Miami'
        },
        {
          id: 'pay_003',
          tripId: 'trip_003',
          userEmail: 'ali@example.com',
          userName: 'Ali Hassan',
          amount: 650.25,
          status: 'failed',
          method: 'debit_card',
          transactionId: 'txn_ghi789',
          date: new Date(Date.now() - 172800000).toISOString(),
          description: 'Trip payment from Houston to Dallas'
        },
        {
          id: 'pay_004',
          tripId: 'trip_004',
          userEmail: 'fatima@example.com',
          userName: 'Fatima Sheikh',
          amount: 920.00,
          status: 'completed',
          method: 'bank_transfer',
          transactionId: 'txn_jkl012',
          date: new Date(Date.now() - 259200000).toISOString(),
          description: 'Trip payment from Phoenix to Denver'
        },
        {
          id: 'pay_005',
          tripId: 'trip_005',
          userEmail: 'ahmed@example.com',
          userName: 'Ahmed Ali',
          amount: 1100.80,
          status: 'refunded',
          method: 'credit_card',
          transactionId: 'txn_mno345',
          date: new Date(Date.now() - 345600000).toISOString(),
          description: 'Trip payment from Seattle to Portland'
        }
      ]

      const mockStats: PaymentStats = {
        totalRevenue: mockPayments.reduce((sum, payment) => 
          payment.status === 'completed' ? sum + payment.amount : sum, 0
        ),
        totalTransactions: mockPayments.length,
        successfulPayments: mockPayments.filter(p => p.status === 'completed').length,
        pendingPayments: mockPayments.filter(p => p.status === 'pending').length,
        failedPayments: mockPayments.filter(p => p.status === 'failed').length,
        refundedPayments: mockPayments.filter(p => p.status === 'refunded').length,
        averageTransactionValue: mockPayments.reduce((sum, p) => sum + p.amount, 0) / mockPayments.length,
        monthlyGrowth: 15.8
      }

      setPayments(mockPayments)
      setStats(mockStats)
    } catch (error) {
      console.error('Error fetching payments:', error)
    } finally {
      setLoading(false)
    }
  }

  const getStatusIcon = (status: string) => {
    switch (status) {
      case 'completed':
        return <CheckCircle className="h-5 w-5 text-green-500" />
      case 'pending':
        return <Clock className="h-5 w-5 text-yellow-500" />
      case 'failed':
        return <XCircle className="h-5 w-5 text-red-500" />
      case 'refunded':
        return <XCircle className="h-5 w-5 text-orange-500" />
      default:
        return <Clock className="h-5 w-5 text-gray-500" />
    }
  }

  const getStatusBadge = (status: string) => {
    const baseClasses = "inline-flex items-center px-2.5 py-0.5 rounded-full text-xs font-medium"
    switch (status) {
      case 'completed':
        return `${baseClasses} bg-green-100 text-green-800`
      case 'pending':
        return `${baseClasses} bg-yellow-100 text-yellow-800`
      case 'failed':
        return `${baseClasses} bg-red-100 text-red-800`
      case 'refunded':
        return `${baseClasses} bg-orange-100 text-orange-800`
      default:
        return `${baseClasses} bg-gray-100 text-gray-800`
    }
  }

  const filteredPayments = payments.filter(payment => {
    const matchesSearch = payment.userName.toLowerCase().includes(searchTerm.toLowerCase()) ||
                         payment.userEmail.toLowerCase().includes(searchTerm.toLowerCase()) ||
                         payment.transactionId.toLowerCase().includes(searchTerm.toLowerCase())
    
    const matchesStatus = statusFilter === 'all' || payment.status === statusFilter
    
    return matchesSearch && matchesStatus
  })

  if (loading) {
    return (
      <div 
        className="flex items-center justify-center min-h-screen"
        style={{ backgroundColor: '#f8fafc' }}
      >
        <div className="text-center">
          <div 
            className="inline-block animate-spin rounded-full h-12 w-12 border-b-2"
            style={{ borderColor: '#3b82f6' }}
          ></div>
          <p className="mt-4 text-gray-600">Loading payments...</p>
        </div>
      </div>
    )
  }

  return (
    <div className="space-y-8">
      {/* Page Header */}
      <div 
        className="rounded-xl p-8 shadow-lg"
        style={{ 
          background: 'linear-gradient(135deg, #1e40af 0%, #3b82f6 50%, #60a5fa 100%)',
          color: 'white'
        }}
      >
        <div className="flex items-center justify-between">
          <div>
            <div className="flex items-center mb-4">
              <div 
                className="p-3 rounded-xl mr-4"
                style={{ backgroundColor: 'rgba(255, 255, 255, 0.2)', backdropFilter: 'blur(10px)' }}
              >
                <DollarSign className="h-8 w-8 text-white" />
              </div>
              <div>
                <h1 className="text-3xl font-bold">Payment Management</h1>
                <p className="text-blue-100 text-lg mt-1">
                  Track all transactions and revenue from your trucking platform
                </p>
              </div>
            </div>
          </div>
          <div className="hidden lg:flex items-center space-x-4">
            <button
              className="flex items-center gap-2 px-4 py-2 rounded-lg text-white border border-white border-opacity-30 hover:bg-white hover:bg-opacity-20 transition-colors duration-200"
            >
              <Download className="h-4 w-4" />
              Export
            </button>
            <button
              className="flex items-center gap-2 px-4 py-2 rounded-lg bg-white text-blue-600 hover:bg-blue-50 transition-colors duration-200"
            >
              <Filter className="h-4 w-4" />
              Advanced Filter
            </button>
          </div>
        </div>
      </div>

      {/* Payment Statistics */}
      <div className="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-4 gap-6">
        {/* Total Revenue */}
        <div 
          className="rounded-xl p-6 shadow-lg border"
          style={{ backgroundColor: '#ffffff', borderColor: '#e2e8f0' }}
        >
          <div className="flex items-center justify-between">
            <div>
              <p className="text-sm font-medium text-gray-600">Total Revenue</p>
              <p className="text-3xl font-bold text-gray-900">
                ${stats?.totalRevenue?.toLocaleString() || '0'}
              </p>
              <div className="flex items-center mt-2">
                <span className="text-sm text-green-600 font-medium">+{stats?.monthlyGrowth}%</span>
                <span className="text-xs text-gray-500 ml-1">from last month</span>
              </div>
            </div>
            <div 
              className="p-3 rounded-xl"
              style={{ background: 'linear-gradient(135deg, #059669, #10b981)' }}
            >
              <DollarSign className="w-6 h-6 text-white" />
            </div>
          </div>
        </div>

        {/* Total Transactions */}
        <div 
          className="rounded-xl p-6 shadow-lg border"
          style={{ backgroundColor: '#ffffff', borderColor: '#e2e8f0' }}
        >
          <div className="flex items-center justify-between">
            <div>
              <p className="text-sm font-medium text-gray-600">Total Transactions</p>
              <p className="text-3xl font-bold text-gray-900">
                {stats?.totalTransactions || 0}
              </p>
              <div className="flex items-center mt-2">
                <span className="text-sm text-blue-600 font-medium">+12.3%</span>
                <span className="text-xs text-gray-500 ml-1">from last month</span>
              </div>
            </div>
            <div 
              className="p-3 rounded-xl"
              style={{ background: 'linear-gradient(135deg, #3b82f6, #1e40af)' }}
            >
              <CreditCard className="w-6 h-6 text-white" />
            </div>
          </div>
        </div>

        {/* Successful Payments */}
        <div 
          className="rounded-xl p-6 shadow-lg border"
          style={{ backgroundColor: '#ffffff', borderColor: '#e2e8f0' }}
        >
          <div className="flex items-center justify-between">
            <div>
              <p className="text-sm font-medium text-gray-600">Successful</p>
              <p className="text-3xl font-bold text-gray-900">
                {stats?.successfulPayments || 0}
              </p>
              <div className="flex items-center mt-2">
                <span className="text-sm text-green-600 font-medium">98.5%</span>
                <span className="text-xs text-gray-500 ml-1">success rate</span>
              </div>
            </div>
            <div 
              className="p-3 rounded-xl"
              style={{ background: 'linear-gradient(135deg, #059669, #10b981)' }}
            >
              <CheckCircle className="w-6 h-6 text-white" />
            </div>
          </div>
        </div>

        {/* Average Transaction */}
        <div 
          className="rounded-xl p-6 shadow-lg border"
          style={{ backgroundColor: '#ffffff', borderColor: '#e2e8f0' }}
        >
          <div className="flex items-center justify-between">
            <div>
              <p className="text-sm font-medium text-gray-600">Avg Transaction</p>
              <p className="text-3xl font-bold text-gray-900">
                ${stats?.averageTransactionValue?.toFixed(0) || '0'}
              </p>
              <div className="flex items-center mt-2">
                <span className="text-sm text-purple-600 font-medium">+5.2%</span>
                <span className="text-xs text-gray-500 ml-1">from last month</span>
              </div>
            </div>
            <div 
              className="p-3 rounded-xl"
              style={{ background: 'linear-gradient(135deg, #7c3aed, #5b21b6)' }}
            >
              <TrendingUp className="w-6 h-6 text-white" />
            </div>
          </div>
        </div>
      </div>

      {/* Filters and Search */}
      <div 
        className="rounded-xl p-6 shadow-lg border"
        style={{ backgroundColor: '#ffffff', borderColor: '#e2e8f0' }}
      >
        <div className="flex flex-col sm:flex-row gap-4">
          {/* Search */}
          <div className="flex-1">
            <div className="relative">
              <Search className="absolute left-3 top-1/2 transform -translate-y-1/2 h-4 w-4 text-gray-400" />
              <input
                type="text"
                placeholder="Search by user, email, or transaction ID..."
                value={searchTerm}
                onChange={(e) => setSearchTerm(e.target.value)}
                className="w-full pl-10 pr-4 py-2 border border-gray-300 rounded-lg focus:ring-2 focus:ring-blue-500 focus:border-transparent"
              />
            </div>
          </div>

          {/* Status Filter */}
          <div>
            <select
              value={statusFilter}
              onChange={(e) => setStatusFilter(e.target.value)}
              className="px-4 py-2 border border-gray-300 rounded-lg focus:ring-2 focus:ring-blue-500 focus:border-transparent"
            >
              <option value="all">All Status</option>
              <option value="completed">Completed</option>
              <option value="pending">Pending</option>
              <option value="failed">Failed</option>
              <option value="refunded">Refunded</option>
            </select>
          </div>

          {/* Date Filter */}
          <div>
            <select
              value={dateFilter}
              onChange={(e) => setDateFilter(e.target.value)}
              className="px-4 py-2 border border-gray-300 rounded-lg focus:ring-2 focus:ring-blue-500 focus:border-transparent"
            >
              <option value="all">All Time</option>
              <option value="today">Today</option>
              <option value="week">This Week</option>
              <option value="month">This Month</option>
              <option value="quarter">This Quarter</option>
            </select>
          </div>
        </div>
      </div>

      {/* Payments Table */}
      <div 
        className="rounded-xl shadow-lg border overflow-hidden"
        style={{ backgroundColor: '#ffffff', borderColor: '#e2e8f0' }}
      >
        <div className="px-6 py-4 border-b border-gray-200">
          <h3 className="text-lg font-semibold text-gray-900">Recent Transactions</h3>
          <p className="text-sm text-gray-500 mt-1">
            {filteredPayments.length} transactions found
          </p>
        </div>

        <div className="overflow-x-auto">
          <table className="w-full">
            <thead style={{ backgroundColor: '#f8fafc' }}>
              <tr>
                <th className="px-6 py-3 text-left text-xs font-medium text-gray-500 uppercase tracking-wider">
                  Transaction
                </th>
                <th className="px-6 py-3 text-left text-xs font-medium text-gray-500 uppercase tracking-wider">
                  User
                </th>
                <th className="px-6 py-3 text-left text-xs font-medium text-gray-500 uppercase tracking-wider">
                  Amount
                </th>
                <th className="px-6 py-3 text-left text-xs font-medium text-gray-500 uppercase tracking-wider">
                  Status
                </th>
                <th className="px-6 py-3 text-left text-xs font-medium text-gray-500 uppercase tracking-wider">
                  Method
                </th>
                <th className="px-6 py-3 text-left text-xs font-medium text-gray-500 uppercase tracking-wider">
                  Date
                </th>
                <th className="px-6 py-3 text-left text-xs font-medium text-gray-500 uppercase tracking-wider">
                  Actions
                </th>
              </tr>
            </thead>
            <tbody className="divide-y divide-gray-200">
              {filteredPayments.map((payment) => (
                <tr key={payment.id} className="hover:bg-gray-50 transition-colors duration-200">
                  <td className="px-6 py-4 whitespace-nowrap">
                    <div>
                      <div className="text-sm font-medium text-gray-900">
                        {payment.transactionId}
                      </div>
                      <div className="text-sm text-gray-500">
                        {payment.description}
                      </div>
                    </div>
                  </td>
                  <td className="px-6 py-4 whitespace-nowrap">
                    <div>
                      <div className="text-sm font-medium text-gray-900">
                        {payment.userName}
                      </div>
                      <div className="text-sm text-gray-500">
                        {payment.userEmail}
                      </div>
                    </div>
                  </td>
                  <td className="px-6 py-4 whitespace-nowrap">
                    <div className="text-sm font-bold text-gray-900">
                      ${payment.amount.toLocaleString()}
                    </div>
                  </td>
                  <td className="px-6 py-4 whitespace-nowrap">
                    <div className="flex items-center">
                      {getStatusIcon(payment.status)}
                      <span className={`ml-2 ${getStatusBadge(payment.status)}`}>
                        {payment.status.charAt(0).toUpperCase() + payment.status.slice(1)}
                      </span>
                    </div>
                  </td>
                  <td className="px-6 py-4 whitespace-nowrap">
                    <div className="text-sm text-gray-900 capitalize">
                      {payment.method.replace('_', ' ')}
                    </div>
                  </td>
                  <td className="px-6 py-4 whitespace-nowrap">
                    <div className="text-sm text-gray-900">
                      {new Date(payment.date).toLocaleDateString()}
                    </div>
                    <div className="text-sm text-gray-500">
                      {new Date(payment.date).toLocaleTimeString()}
                    </div>
                  </td>
                  <td className="px-6 py-4 whitespace-nowrap text-right text-sm font-medium">
                    <div className="flex items-center space-x-2">
                      <button
                        className="text-blue-600 hover:text-blue-900 transition-colors duration-200"
                        title="View Details"
                      >
                        <Eye className="h-4 w-4" />
                      </button>
                      <button
                        className="text-gray-400 hover:text-gray-600 transition-colors duration-200"
                        title="More Actions"
                      >
                        <MoreHorizontal className="h-4 w-4" />
                      </button>
                    </div>
                  </td>
                </tr>
              ))}
            </tbody>
          </table>
        </div>

        {/* Empty State */}
        {filteredPayments.length === 0 && (
          <div className="text-center py-12">
            <DollarSign className="h-12 w-12 text-gray-400 mx-auto mb-4" />
            <h3 className="text-lg font-medium text-gray-900 mb-2">No transactions found</h3>
            <p className="text-gray-500">Try adjusting your search or filter criteria.</p>
          </div>
        )}
      </div>

      {/* Pagination */}
      {filteredPayments.length > 0 && (
        <div 
          className="rounded-xl p-4 shadow-lg border flex items-center justify-between"
          style={{ backgroundColor: '#ffffff', borderColor: '#e2e8f0' }}
        >
          <div className="text-sm text-gray-700">
            Showing 1 to {filteredPayments.length} of {filteredPayments.length} results
          </div>
          <div className="flex items-center space-x-2">
            <button
              className="px-3 py-1 border border-gray-300 rounded-md text-sm font-medium text-gray-700 hover:bg-gray-50 disabled:opacity-50"
              disabled
            >
              Previous
            </button>
            <button
              className="px-3 py-1 bg-blue-600 text-white rounded-md text-sm font-medium hover:bg-blue-700"
            >
              1
            </button>
            <button
              className="px-3 py-1 border border-gray-300 rounded-md text-sm font-medium text-gray-700 hover:bg-gray-50 disabled:opacity-50"
              disabled
            >
              Next
            </button>
          </div>
        </div>
      )}
    </div>
  )
}