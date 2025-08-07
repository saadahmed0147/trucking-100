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
className="relative z-10 flex-shrink-0 flex h-16 shadow-lg lg:z-30"          style={{ backgroundColor: '#ffffff', borderBottom: '1px solid #e2e8f0' }}
        >
          <button
            className="px-4 border-r border-gray-200 text-gray-500 focus:outline-none focus:ring-2 focus:ring-inset focus:ring-blue-500 lg:hidden dark:border-gray-700"
            onClick={() => setSidebarOpen(true)}
          >
            <Menu className="h-6 w-6" />
          </button>
          <div className="flex-1 px-4 flex justify-between">
            <div className="flex-1 flex">
              <div className="w-full flex md:ml-0">
                <div className="relative w-full text-gray-400 focus-within:text-gray-600">
                  {/* <div className="absolute inset-y-0 left-0 flex items-center pointer-events-none">
                    <Search className="h-5 w-5" />
                  </div>
                  <input
                    className="block w-full h-full pl-8 pr-3 py-2 border-transparent text-gray-900 placeholder-gray-500 focus:outline-none focus:placeholder-gray-400 focus:ring-0 focus:border-transparent dark:bg-gray-800 dark:text-white dark:placeholder-gray-400"
                    placeholder="Search..."
                    type="search"
                  /> */}
                </div>  
              </div>
            </div>
            <div className="ml-4 flex items-center md:ml-6">
              {/* <button
                onClick={toggleDarkMode}
                className="bg-gray-200 dark:bg-gray-600 p-1 rounded-full text-gray-400 hover:text-gray-500 focus:outline-none focus:ring-2 focus:ring-offset-2 focus:ring-blue-500 dark:text-gray-300 dark:hover:text-gray-200"
              >
                {darkMode ? <Sun className="h-6 w-6" /> : <Moon className="h-6 w-6" />}
              </button>
              <button className="bg-gray-200 dark:bg-gray-600 p-1 rounded-full text-gray-400 hover:text-gray-500 focus:outline-none focus:ring-2 focus:ring-offset-2 focus:ring-blue-500 ml-3 dark:text-gray-300 dark:hover:text-gray-200">
                <Bell className="h-6 w-6" />
              </button> */}
              
              {/* Direct Logout Button */}
              {/* <button
                onClick={handleLogout}
                className="ml-3 inline-flex items-center gap-2 px-3 py-2 border border-transparent text-sm leading-4 font-medium rounded-md text-white bg-red-600 hover:bg-red-700 focus:outline-none focus:ring-2 focus:ring-offset-2 focus:ring-red-500"
                title="Logout"
              >
                <LogOut className="h-4 w-4" />
                <span className="hidden sm:block">Logout</span>
              </button> */}
              {/* User Menu Dropdown */}
              <div className="ml-3 relative" ref={userMenuRef}>
                <button
                  onClick={() => setShowUserMenu(!showUserMenu)}
                  className="flex items-center gap-2 p-2 rounded-lg hover:bg-gray-100 transition-colors duration-200"
                >
                <div 
                  className="w-8 h-8 rounded-full flex items-center justify-center text-white font-medium"
                  style={{ background: 'linear-gradient(135deg, #3b82f6, #1e40af)' }}
                >
  <User className="h-5 w-5" />
</div>
                  <span className="hidden sm:block text-sm font-medium text-gray-700">
                    {user?.email || 'admin@trucking.com'}
                  </span>
                </button>
                
                {showUserMenu && (
                  <div 
                    className="absolute right-0 mt-2 w-48 rounded-lg shadow-lg border py-1 z-50 animate-in fade-in-0 zoom-in-95"
                    style={{ 
                      backgroundColor: '#ffffff',
                      borderColor: '#e2e8f0',
                      boxShadow: '0 20px 25px -5px rgba(0, 0, 0, 0.1), 0 10px 10px -5px rgba(0, 0, 0, 0.04)'
                    }}
                  >
                    <div className="px-4 py-2 border-b border-gray-200">
                      <p className="text-sm font-medium text-gray-900">Admin</p>
                      <p className="text-xs text-gray-500">{user?.email || 'admin@trucking.com'}</p>
                    </div>
                    
                    <button
                      onClick={handleSettingsClick}
                      className="flex items-center gap-2 w-full px-4 py-2 text-sm text-gray-700 hover:bg-gray-100 transition-colors duration-200"
                    >
                      <Settings className="h-4 w-4" />
                      Settings
                    </button>
                    
                    <button
                      onClick={() => {
                        setShowUserMenu(false)
                        handleLogout()
                      }}
                      className="flex items-center gap-2 w-full px-4 py-2 text-sm text-red-600 hover:bg-red-50 transition-colors duration-200"
                    >
                      <LogOut className="h-4 w-4" />
                      Logout
                    </button>
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
