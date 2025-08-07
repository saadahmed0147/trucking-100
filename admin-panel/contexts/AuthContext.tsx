'use client'

import React, { createContext, useContext, useState, useEffect } from 'react'
import { useRouter } from 'next/navigation'

interface User {
  email: string
  role: 'admin'
  name: string
}

interface AuthContextType {
  user: User | null
  isLoading: boolean
  login: (email: string, password: string) => Promise<boolean>
  logout: () => void
  isAuthenticated: boolean
}

const AuthContext = createContext<AuthContextType | undefined>(undefined)

export function useAuth() {
  const context = useContext(AuthContext)
  if (context === undefined) {
    throw new Error('useAuth must be used within an AuthProvider')
  }
  return context
}

export function AuthProvider({ children }: { children: React.ReactNode }) {
  const [user, setUser] = useState<User | null>(null)
  const [isLoading, setIsLoading] = useState(true)
  const router = useRouter()

  const ADMIN_CREDENTIALS = {
    email: 'admin@trucking.com',
    password: 'admin123', // In production, this should be hashed and stored securely
    name: 'Admin User'
  }

  useEffect(() => {
    // Check if user is logged in on app start
    const checkAuth = () => {
      try {
        const storedUser = localStorage.getItem('admin_user')
        const authToken = localStorage.getItem('admin_token')
        
        if (storedUser && authToken) {
          const userData = JSON.parse(storedUser)
          if (userData.email === ADMIN_CREDENTIALS.email) {
            setUser(userData)
          } else {
            // Invalid user data, clear storage
            localStorage.removeItem('admin_user')
            localStorage.removeItem('admin_token')
          }
        }
      } catch (error) {
        console.error('Auth check error:', error)
        localStorage.removeItem('admin_user')
        localStorage.removeItem('admin_token')
      } finally {
        setIsLoading(false)
      }
    }

    checkAuth()
  }, [])

  const login = async (email: string, password: string): Promise<boolean> => {
    setIsLoading(true)
    
    try {
      // Simulate API call delay
      await new Promise(resolve => setTimeout(resolve, 1000))
      
      if (email === ADMIN_CREDENTIALS.email && password === ADMIN_CREDENTIALS.password) {
        const userData: User = {
          email: ADMIN_CREDENTIALS.email,
          role: 'admin',
          name: ADMIN_CREDENTIALS.name
        }
        
        // Generate a simple token (in production, use JWT or proper tokens)
        const token = btoa(`${email}:${Date.now()}`)
        
        // Store user data and token
        localStorage.setItem('admin_user', JSON.stringify(userData))
        localStorage.setItem('admin_token', token)
        
        setUser(userData)
        setIsLoading(false)
        return true
      } else {
        setIsLoading(false)
        return false
      }
    } catch (error) {
      console.error('Login error:', error)
      setIsLoading(false)
      return false
    }
  }

  const logout = () => {
    localStorage.removeItem('admin_user')
    localStorage.removeItem('admin_token')
    setUser(null)
    router.push('/login')
  }

  const value: AuthContextType = {
    user,
    isLoading,
    login,
    logout,
    isAuthenticated: !!user
  }

  return (
    <AuthContext.Provider value={value}>
      {children}
    </AuthContext.Provider>
  )
}
