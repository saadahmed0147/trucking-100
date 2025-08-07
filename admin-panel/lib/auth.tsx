'use client'

import React, { createContext, useContext, useState, useEffect } from 'react'
import { useRouter } from 'next/navigation'

interface AuthContextType {
  isLoggedIn: boolean
  userEmail: string | null
  login: (email: string) => void
  logout: () => void
  checkAuth: () => boolean
}

const AuthContext = createContext<AuthContextType | undefined>(undefined)

export function AuthProvider({ children }: { children: React.ReactNode }) {
  const [isLoggedIn, setIsLoggedIn] = useState(false)
  const [userEmail, setUserEmail] = useState<string | null>(null)
  const [isLoading, setIsLoading] = useState(true)
  const router = useRouter()

  useEffect(() => {
    // Check if user is logged in on component mount
    const checkLoginStatus = () => {
      if (typeof window !== 'undefined') {
        const loggedIn = localStorage.getItem('isAdminLoggedIn') === 'true'
        const email = localStorage.getItem('adminEmail')
        
        if (loggedIn && email === 'admin@trucking.com') {
          setIsLoggedIn(true)
          setUserEmail(email)
        } else {
          // Clear invalid data
          localStorage.removeItem('isAdminLoggedIn')
          localStorage.removeItem('adminEmail')
          setIsLoggedIn(false)
          setUserEmail(null)
        }
      }
      setIsLoading(false)
    }

    checkLoginStatus()
  }, [])

  const login = (email: string) => {
    if (email.toLowerCase() === 'admin@trucking.com') {
      localStorage.setItem('isAdminLoggedIn', 'true')
      localStorage.setItem('adminEmail', email)
      setIsLoggedIn(true)
      setUserEmail(email)
    }
  }

  const logout = () => {
    localStorage.removeItem('isAdminLoggedIn')
    localStorage.removeItem('adminEmail')
    setIsLoggedIn(false)
    setUserEmail(null)
    router.push('/login')
  }

  const checkAuth = () => {
    if (typeof window !== 'undefined') {
      const loggedIn = localStorage.getItem('isAdminLoggedIn') === 'true'
      const email = localStorage.getItem('adminEmail')
      return loggedIn && email === 'admin@trucking.com'
    }
    return false
  }

  if (isLoading) {
    return (
      <div className="min-h-screen bg-gray-50 dark:bg-gray-900 flex items-center justify-center">
        <div className="animate-spin rounded-full h-12 w-12 border-b-2 border-blue-600"></div>
      </div>
    )
  }

  return (
    <AuthContext.Provider value={{ isLoggedIn, userEmail, login, logout, checkAuth }}>
      {children}
    </AuthContext.Provider>
  )
}

export function useAuth() {
  const context = useContext(AuthContext)
  if (context === undefined) {
    throw new Error('useAuth must be used within an AuthProvider')
  }
  return context
}
