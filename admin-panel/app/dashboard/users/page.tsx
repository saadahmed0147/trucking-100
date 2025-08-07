'use client'

import React, { useState, useEffect } from 'react'
import { FirebaseService } from '@/lib/firebase'
import type { User } from '@/lib/firebase'
import {
  Users,
  Search,
  Filter,
  MoreVertical,
  UserPlus,
  Edit,
  Trash2,
  Eye,
  Mail,
  Phone,
  Calendar,
  Award
} from 'lucide-react'

export default function UsersPage() {
  const [users, setUsers] = useState<User[]>([])
  const [loading, setLoading] = useState(true)
  const [searchTerm, setSearchTerm] = useState('')
  const [filterStatus, setFilterStatus] = useState('all')

  useEffect(() => {
    const fetchUsers = async () => {
      try {
        setLoading(true)
        const usersData = await FirebaseService.getUsers()
        setUsers(usersData)
      } catch (error) {
        console.error('Error fetching users:', error)
      } finally {
        setLoading(false)
      }
    }

    fetchUsers()
  }, [])

  const filteredUsers = users.filter(user => {
    const matchesSearch = user.name?.toLowerCase().includes(searchTerm.toLowerCase()) ||
                         user.email?.toLowerCase().includes(searchTerm.toLowerCase())
    const matchesFilter = filterStatus === 'all' || user.status === filterStatus
    return matchesSearch && matchesFilter
  })

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
          <p className="text-gray-600 text-lg">Loading users...</p>
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
            <h1 className="text-3xl font-bold mb-2">User Management</h1>
            <p className="text-blue-100 text-lg">
              Manage user accounts, permissions, and activities
            </p>
          </div>
          <div className="hidden md:block">
            <Users className="w-16 h-16 text-blue-200" />
          </div>
        </div>
      </div>

      {/* Stats Cards */}
      <div className="grid grid-cols-1 md:grid-cols-4 gap-6">
        <div 
          className="rounded-xl p-6 shadow-lg border"
          style={{ backgroundColor: '#ffffff', borderColor: '#e2e8f0' }}
        >
          <div className="flex items-center justify-between">
            <div>
              <p className="text-sm font-medium text-gray-600">Total Users</p>
              <p className="text-2xl font-bold text-gray-900">{users.length}</p>
            </div>
            <div 
              className="p-3 rounded-xl"
              style={{ background: 'linear-gradient(135deg, #3b82f6, #1e40af)' }}
            >
              <Users className="w-6 h-6 text-white" />
            </div>
          </div>
        </div>

        <div 
          className="rounded-xl p-6 shadow-lg border"
          style={{ backgroundColor: '#ffffff', borderColor: '#e2e8f0' }}
        >
          <div className="flex items-center justify-between">
            <div>
              <p className="text-sm font-medium text-gray-600">Active Users</p>
              <p className="text-2xl font-bold text-gray-900">
                {users.filter(u => u.status === 'Active').length}
              </p>
            </div>
            <div 
              className="p-3 rounded-xl"
              style={{ backgroundColor: '#10b981' }}
            >
              <Award className="w-6 h-6 text-white" />
            </div>
          </div>
        </div>

        <div 
          className="rounded-xl p-6 shadow-lg border"
          style={{ backgroundColor: '#ffffff', borderColor: '#e2e8f0' }}
        >
          <div className="flex items-center justify-between">
            <div>
              <p className="text-sm font-medium text-gray-600">New This Month</p>
              <p className="text-2xl font-bold text-gray-900">+12</p>
            </div>
            <div 
              className="p-3 rounded-xl"
              style={{ backgroundColor: '#f59e0b' }}
            >
              <UserPlus className="w-6 h-6 text-white" />
            </div>
          </div>
        </div>

        <div 
          className="rounded-xl p-6 shadow-lg border"
          style={{ backgroundColor: '#ffffff', borderColor: '#e2e8f0' }}
        >
          <div className="flex items-center justify-between">
            <div>
              <p className="text-sm font-medium text-gray-600">Growth Rate</p>
              <p className="text-2xl font-bold text-gray-900">+23%</p>
            </div>
            <div 
              className="p-3 rounded-xl"
              style={{ backgroundColor: '#8b5cf6' }}
            >
              <Calendar className="w-6 h-6 text-white" />
            </div>
          </div>
        </div>
      </div>

      {/* Search and Filter Section */}
      <div 
        className="rounded-xl p-6 shadow-lg border"
        style={{ backgroundColor: '#ffffff', borderColor: '#e2e8f0' }}
      >
        <div className="flex flex-col sm:flex-row gap-4 items-center justify-between">
          <div className="relative flex-1 max-w-md">
            <Search className="absolute left-3 top-1/2 transform -translate-y-1/2 text-gray-400 w-5 h-5" />
            <input
              type="text"
              placeholder="Search users by name or email..."
              value={searchTerm}
              onChange={(e) => setSearchTerm(e.target.value)}
              className="w-full pl-10 pr-4 py-3 border border-gray-300 rounded-xl focus:ring-2 focus:ring-blue-500 focus:border-transparent"
            />
          </div>
          
          <div className="flex items-center gap-4">
            <div className="relative">
              <Filter className="absolute left-3 top-1/2 transform -translate-y-1/2 text-gray-400 w-5 h-5" />
              <select
                value={filterStatus}
                onChange={(e) => setFilterStatus(e.target.value)}
                className="pl-10 pr-8 py-3 border border-gray-300 rounded-xl focus:ring-2 focus:ring-blue-500 focus:border-transparent"
              >
                <option value="all">All Status</option>
                <option value="Active">Active</option>
                <option value="Inactive">Inactive</option>
              </select>
            </div>
            
            <button 
              className="px-6 py-3 rounded-xl font-medium text-white transition-colors duration-200 hover:opacity-90"
              style={{ background: 'linear-gradient(135deg, #3b82f6, #1e40af)' }}
            >
              <UserPlus className="w-5 h-5 mr-2 inline" />
              Add User
            </button>
          </div>
        </div>
      </div>

      {/* Users Table */}
      <div 
        className="rounded-xl shadow-lg border overflow-hidden"
        style={{ backgroundColor: '#ffffff', borderColor: '#e2e8f0' }}
      >
        <div className="px-6 py-4" style={{ borderBottom: '1px solid #e2e8f0' }}>
          <h3 className="text-lg font-semibold text-gray-900">
            Users ({filteredUsers.length})
          </h3>
        </div>
        
        <div className="overflow-x-auto">
          <table className="min-w-full divide-y divide-gray-200">
            <thead style={{ backgroundColor: '#f8fafc' }}>
              <tr>
                <th className="px-6 py-3 text-left text-xs font-medium text-gray-500 uppercase tracking-wider">
                  User
                </th>
                <th className="px-6 py-3 text-left text-xs font-medium text-gray-500 uppercase tracking-wider">
                  Contact
                </th>
                <th className="px-6 py-3 text-left text-xs font-medium text-gray-500 uppercase tracking-wider">
                  Role
                </th>
                <th className="px-6 py-3 text-left text-xs font-medium text-gray-500 uppercase tracking-wider">
                  Status
                </th>
                <th className="px-6 py-3 text-left text-xs font-medium text-gray-500 uppercase tracking-wider">
                  Join Date
                </th>
                <th className="px-6 py-3 text-left text-xs font-medium text-gray-500 uppercase tracking-wider">
                  Actions
                </th>
              </tr>
            </thead>
            <tbody className="bg-white divide-y divide-gray-200">
              {filteredUsers.length > 0 ? (
                filteredUsers.map((user) => (
                  <tr key={user.id} className="hover:bg-gray-50 transition-colors duration-200">
                    <td className="px-6 py-4 whitespace-nowrap">
                      <div className="flex items-center">
                        <div 
                          className="h-10 w-10 rounded-full flex items-center justify-center text-white font-medium"
                          style={{ background: 'linear-gradient(135deg, #3b82f6, #1e40af)' }}
                        >
                          {(user.name || user.email || 'U').charAt(0).toUpperCase()}
                        </div>
                        <div className="ml-4">
                          <div className="text-sm font-medium text-gray-900">
                            {user.name || 'No Name'}
                          </div>
                          <div className="text-sm text-gray-500">ID: {user.id}</div>
                        </div>
                      </div>
                    </td>
                    <td className="px-6 py-4 whitespace-nowrap">
                      <div className="flex flex-col space-y-1">
                        <div className="flex items-center text-sm text-gray-900">
                          <Mail className="w-4 h-4 mr-2 text-gray-400" />
                          {user.email || 'No Email'}
                        </div>
                        {user.phone && (
                          <div className="flex items-center text-sm text-gray-500">
                            <Phone className="w-4 h-4 mr-2 text-gray-400" />
                            {user.phone}
                          </div>
                        )}
                      </div>
                    </td>
                    <td className="px-6 py-4 whitespace-nowrap">
                      <span 
                        className="inline-flex items-center px-2.5 py-0.5 rounded-full text-xs font-medium"
                        style={{ backgroundColor: '#dbeafe', color: '#1e40af' }}
                      >
                        {user.role || 'User'}
                      </span>
                    </td>
                    <td className="px-6 py-4 whitespace-nowrap">
                      <span 
                        className={`inline-flex items-center px-2.5 py-0.5 rounded-full text-xs font-medium ${
                          user.status === 'Active' 
                            ? 'bg-green-100 text-green-800' 
                            : 'bg-red-100 text-red-800'
                        }`}
                      >
                        {user.status || 'Active'}
                      </span>
                    </td>
                    <td className="px-6 py-4 whitespace-nowrap text-sm text-gray-500">
                      <div className="flex items-center">
                        <Calendar className="w-4 h-4 mr-2 text-gray-400" />
                        {user.joinDate ? new Date(user.joinDate).toLocaleDateString() : 'Unknown'}
                      </div>
                    </td>
                    <td className="px-6 py-4 whitespace-nowrap text-sm font-medium">
                      <div className="flex items-center space-x-2">
                        <button 
                          className="p-2 rounded-lg transition-colors duration-200 hover:bg-blue-50 text-blue-600"
                          title="View User"
                        >
                          <Eye className="w-4 h-4" />
                        </button>
                        <button 
                          className="p-2 rounded-lg transition-colors duration-200 hover:bg-green-50 text-green-600"
                          title="Edit User"
                        >
                          <Edit className="w-4 h-4" />
                        </button>
                        <button 
                          className="p-2 rounded-lg transition-colors duration-200 hover:bg-red-50 text-red-600"
                          title="Delete User"
                        >
                          <Trash2 className="w-4 h-4" />
                        </button>
                      </div>
                    </td>
                  </tr>
                ))
              ) : (
                <tr>
                  <td colSpan={6} className="px-6 py-12 text-center">
                    <Users className="w-12 h-12 text-gray-300 mx-auto mb-4" />
                    <p className="text-gray-500 text-lg">No users found</p>
                    <p className="text-gray-400 text-sm">
                      {searchTerm ? 'Try adjusting your search terms' : 'Add some users to get started'}
                    </p>
                  </td>
                </tr>
              )}
            </tbody>
          </table>
        </div>
      </div>
    </div>
  )
}