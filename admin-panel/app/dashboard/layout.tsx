'use client'

import React, { useState, useEffect, useRef } from 'react'
import { useRouter } from 'next/navigation'
import { useAuth } from '@/hooks/useAuth'
import ProtectedRoute from '@/components/ProtectedRoute'
import { Menu, X, Bell, Search, User, Settings, LogOut, Sun, Moon, Icon } from 'lucide-react'

interface DashboardLayoutProps {
  children: React.ReactNode
}

const navigation = [
  { name: 'Dashboard', href: '/dashboard', icon: '📊' },
  { name: 'Users', href: '/dashboard/users', icon: '👥' },
//   { name: 'Trips', href: '/dashboard/trips', icon: '🚛' },
  { name: 'Analytics', href: '/dashboard/analytics', icon: '📈' },
  { name: 'Payments', href: '/dashboard/payments', icon: '💳' },
//   { name: 'POI Management', href: '/dashboard/poi', icon: '📍' },
  { name: 'Settings', href: '/dashboard/settings', icon: '⚙️' },
]

export default function DashboardLayout({ children }: DashboardLayoutProps) {
  const [sidebarOpen, setSidebarOpen] = useState(false)
  const [darkMode, setDarkMode] = useState(false)
  const [showUserMenu, setShowUserMenu] = useState(false)
  const userMenuRef = useRef<HTMLDivElement>(null)
  
  const { user, logout } = useAuth()
  const router = useRouter()

  // Close user menu when clicking outside
  useEffect(() => {
    const handleClickOutside = (event: MouseEvent) => {
      if (userMenuRef.current && !userMenuRef.current.contains(event.target as Node)) {
        setShowUserMenu(false)
      }
    }

    if (showUserMenu) {
      document.addEventListener('mousedown', handleClickOutside)
    }

    return () => {
      document.removeEventListener('mousedown', handleClickOutside)
    }
  }, [showUserMenu])

  const handleLogout = async () => {
    try {
      await logout()
      router.push('/login')
    } catch (error) {
      console.error('Logout error:', error)
    }
  }

  const handleSettingsClick = () => {
    setShowUserMenu(false)
    router.push('/dashboard/settings')
  }

  const toggleDarkMode = () => {
    setDarkMode(!darkMode)
    document.documentElement.classList.toggle('dark')
  }

  return (
    <ProtectedRoute>
      <div 
        className="min-h-screen"
        style={{ backgroundColor: '#f8fafc' }}
      >
      {/* Mobile sidebar */}
      <div className={`fixed inset-0 z-50 lg:hidden ${sidebarOpen ? 'block' : 'hidden'}`}>
        <div className="fixed inset-0 bg-gray-900 bg-opacity-50 backdrop-blur-sm" onClick={() => setSidebarOpen(false)} />
        <div 
          className="relative flex-1 flex flex-col max-w-xs w-full shadow-2xl z-50"
          style={{ background: 'linear-gradient(135deg, #1e40af 0%, #3b82f6 50%, #60a5fa 100%)' }}
        >
          <div className="absolute top-0 right-0 -mr-12 pt-2">
            <button
              className="ml-1 flex items-center justify-center h-10 w-10 rounded-full text-white hover:bg-white hover:bg-opacity-20 transition-colors duration-200 shadow-lg"
           onClick={() => setSidebarOpen(false)}
            >
              <X className="h-6 w-6" />
            </button>
          </div>
          <div className="flex-1 h-0 pt-5 pb-4 overflow-y-auto">
            <div className="flex-shrink-0 flex items-center px-6 mb-8">
              <div className="flex items-center space-x-3">
                <div 
                  className="w-10 h-10 rounded-xl flex items-center justify-center shadow-lg"
                  style={{ backgroundColor: 'rgba(255, 255, 255, 0.2)', backdropFilter: 'blur(10px)' }}
                >
                  <span className="text-white font-bold text-lg">🚛</span>
                </div>
                <div>
                  <h1 className="text-xl font-bold text-white">Trucking-100</h1>
                  <p className="text-sm text-blue-200">Admin Panel</p>
                </div>
              </div>
            </div>
            <nav className="px-4 space-y-2">
              {navigation.map((item) => (
                <a
                  key={item.name}
                  href={item.href}
                  className="group flex items-center px-4 py-3 text-base font-medium rounded-xl text-white hover:bg-white hover:bg-opacity-20 transition-all duration-200"
                  style={{ backdropFilter: 'blur(10px)' }}
                >
                  <span className="mr-4 text-xl">{item.icon}</span>
                  {item.name}
                </a>
              ))}
            </nav>
          </div>
        </div>
      </div>

      {/* Desktop sidebar */}
<div className="hidden lg:flex lg:w-64 lg:flex-col lg:fixed lg:inset-y-0 lg:z-40">        <div 
          className="flex-1 flex flex-col min-h-0 shadow-xl border-r"
          style={{ 
            background: 'linear-gradient(135deg, #1e40af 0%, #3b82f6 50%, #60a5fa 100%)',
            borderColor: '#3b82f6'                                                                            
          }}
        >
          <div className="flex-1 flex flex-col pt-6 pb-4 overflow-y-auto">
            <div className="flex items-center flex-shrink-0 px-6 mb-8">
              <div className="flex items-center space-x-3">
                <div 
                  className="w-12 h-12 rounded-xl flex items-center justify-center shadow-lg"
                  style={{ backgroundColor: 'rgba(255, 255, 255, 0.2)', backdropFilter: 'blur(10px)' }}
                >
                  <span className="text-white font-bold text-xl">🚛</span>
                </div>
                <div>
                  <h1 className="text-xl font-bold text-white">Trucking-100</h1>
                  <p className="text-sm text-blue-200">Admin Panel</p>
                </div>
              </div>
            </div>
            <nav className="flex-1 px-4 space-y-2">
              {navigation.map((item) => (
                <a
                  key={item.name}
                  href={item.href}
                  className="group flex items-center px-4 py-3 text-sm font-medium rounded-xl text-white hover:bg-white hover:bg-opacity-20 transition-all duration-200 hover:shadow-lg"
                  style={{ backdropFilter: 'blur(10px)' }}
                >
                  <span className="mr-4 text-lg">{item.icon}</span>
                  {item.name}
                </a>
              ))}
            </nav>
          </div>
        </div>
      </div>

      {/* Main content */}
      <div className="lg:pl-64 flex flex-col flex-1">
        {/* Top navigation */}
        <div 
          className="relative z-10 flex-shrink-0 flex h-20 shadow-xl lg:z-30 backdrop-blur-md"
          style={{ 
            background: 'linear-gradient(135deg, rgba(255, 255, 255, 0.95) 0%, rgba(248, 250, 252, 0.98) 100%)', 
            borderBottom: '1px solid rgba(59, 130, 246, 0.1)',
            boxShadow: '0 10px 25px -5px rgba(0, 0, 0, 0.1), 0 8px 10px -6px rgba(0, 0, 0, 0.1)'
          }}
        >
          <button
            className="px-6 border-r border-blue-100 text-blue-600 hover:text-blue-700 hover:bg-blue-50 focus:outline-none focus:ring-2 focus:ring-inset focus:ring-blue-500 lg:hidden transition-all duration-200 rounded-r-lg"
            onClick={() => setSidebarOpen(true)}
          >
            <Menu className="h-6 w-6" />
          </button>
          <div className="flex-1 px-6 flex justify-between items-center">
            <div className="flex-1 flex items-center">
              <div className="w-full flex md:ml-0">
                {/* <div className="relative w-full max-w-lg">
                  <div className="absolute inset-y-0 left-0 flex items-center pointer-events-none pl-4">
                    <Search className="h-5 w-5 text-blue-400" />
                  </div>
                  <input
                    className="block w-full h-12 pl-12 pr-4 py-3 border border-blue-200 rounded-xl text-gray-900 placeholder-blue-300 focus:outline-none focus:ring-2 focus:ring-blue-500 focus:border-transparent transition-all duration-200 bg-white/70 backdrop-blur-sm shadow-sm hover:shadow-md"
                    placeholder="Search dashboard..."
                    type="search"
                  />
                </div>   */}
              </div>
            </div>
            <div className="ml-6 flex items-center space-x-4">
              {/* Notifications */}
              {/* <button className="relative p-3 rounded-xl text-blue-600 hover:text-blue-700 hover:bg-blue-50 focus:outline-none focus:ring-2 focus:ring-blue-500 transition-all duration-200 shadow-sm hover:shadow-md bg-white/70 backdrop-blur-sm">
                <Bell className="h-6 w-6" />
                <span className="absolute top-2 right-2 h-3 w-3 bg-red-500 rounded-full border-2 border-white shadow-sm"></span>
              </button> */}
              
              {/* Dark Mode Toggle */}
              {/* <button
                onClick={toggleDarkMode}
                className="p-3 rounded-xl text-blue-600 hover:text-blue-700 hover:bg-blue-50 focus:outline-none focus:ring-2 focus:ring-blue-500 transition-all duration-200 shadow-sm hover:shadow-md bg-white/70 backdrop-blur-sm"
              >
                {darkMode ? <Sun className="h-6 w-6" /> : <Moon className="h-6 w-6" />}
              </button> */}
              
              {/* User Menu Dropdown */}
              <div className="relative" ref={userMenuRef}>
                <button
                  onClick={() => setShowUserMenu(!showUserMenu)}
                  className="flex items-center gap-3 p-3 rounded-xl hover:bg-blue-50 transition-all duration-200 shadow-sm hover:shadow-md bg-white/70 backdrop-blur-sm border border-blue-100"
                >
                  <div 
                    className="w-10 h-10 rounded-xl flex items-center justify-center text-white font-medium shadow-lg"
                    style={{ background: 'linear-gradient(135deg, #3b82f6, #1e40af)' }}
                  >
                    <User className="h-5 w-5" />
                  </div>
                  <div className="hidden sm:block text-left">
                    <p className="text-sm font-semibold text-gray-900">Admin</p>
                    <p className="text-xs text-blue-600">{user?.email || 'admin@trucking.com'}</p>
                  </div>
                  <div className="ml-2 text-blue-400">
                    <svg className="w-4 h-4" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                      <path strokeLinecap="round" strokeLinejoin="round" strokeWidth={2} d="M19 9l-7 7-7-7" />
                    </svg>
                  </div>
                </button>
                
                {showUserMenu && (
                  <div 
                    className="absolute right-0 mt-3 w-64 rounded-2xl shadow-2xl border py-2 z-50 animate-in fade-in-0 zoom-in-95"
                    style={{ 
                      background: 'linear-gradient(135deg, rgba(255, 255, 255, 0.98) 0%, rgba(248, 250, 252, 0.95) 100%)',
                      borderColor: 'rgba(59, 130, 246, 0.2)',
                      boxShadow: '0 25px 50px -12px rgba(0, 0, 0, 0.25), 0 0 0 1px rgba(59, 130, 246, 0.1)',
                      backdropFilter: 'blur(20px)'
                    }}
                  >
                    <div className="px-5 py-3 border-b border-blue-100">
                      <div className="flex items-center gap-3">
                        <div 
                          className="w-12 h-12 rounded-xl flex items-center justify-center text-white font-medium shadow-lg"
                          style={{ background: 'linear-gradient(135deg, #3b82f6, #1e40af)' }}
                        >
                          <User className="h-6 w-6" />
                        </div>
                        <div>
                          <p className="text-sm font-semibold text-gray-900">Admin User</p>
                          <p className="text-xs text-blue-600">{user?.email || 'admin@trucking.com'}</p>
                        </div>
                      </div>
                    </div>
                    
                    <div className="py-2">
                      <button
                        onClick={handleSettingsClick}
                        className="flex items-center gap-3 w-full px-5 py-3 text-sm text-gray-700 hover:bg-blue-50 hover:text-blue-700 transition-all duration-200 font-medium"
                      >
                        <div className="w-8 h-8 rounded-lg bg-blue-100 flex items-center justify-center">
                          <Settings className="h-4 w-4 text-blue-600" />
                        </div>
                        Account Settings
                      </button>
                      
                      <button
                        onClick={() => {
                          setShowUserMenu(false)
                          handleLogout()
                        }}
                        className="flex items-center gap-3 w-full px-5 py-3 text-sm text-red-600 hover:bg-red-50 hover:text-red-700 transition-all duration-200 font-medium"
                      >
                        <div className="w-8 h-8 rounded-lg bg-red-100 flex items-center justify-center">
                          <LogOut className="h-4 w-4 text-red-600" />
                        </div>
                        Sign Out
                      </button>
                    </div>
                  </div>
                )}
              </div>
            </div>
          </div>
        </div>

        {/* Page content */}
        <main className="flex-1 relative overflow-y-auto focus:outline-none">
          <div className="py-6">
            <div className="max-w-7xl mx-auto px-4 sm:px-6 md:px-8">
              {children}
            </div>
          </div>
        </main>
      </div>
    </div>
    </ProtectedRoute>
  )
}
