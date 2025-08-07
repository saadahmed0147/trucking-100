'use client'

import { createContext, useContext, useState, useEffect, ReactNode } from 'react'
import { useRouter } from 'next/navigation'

export interface User {
  email: string
  role: 'admin'
  name: string
  id: string
}

export interface AuthState {
  user: User | null
  isLoading: boolean
  isAuthenticated: boolean
  error: string | null
}

export interface AuthContextType extends AuthState {
  login: (email: string, password: string) => Promise<{ success: boolean; error?: string }>
  logout: () => void
  clearError: () => void
}

const AuthContext = createContext<AuthContextType | undefined>(undefined)

export function useAuth(): AuthContextType {
  const context = useContext(AuthContext)
  if (context === undefined) {
    throw new Error('useAuth must be used within an AuthProvider')
  }
  return context
}

interface AuthProviderProps {
  children: ReactNode
}

// Admin credentials (in production, this should come from environment variables)
const ADMIN_CREDENTIALS = {
  email: 'admin@trucking.com',
  password: 'admin123',
  name: 'Admin User',
  role: 'admin' as const,
  id: 'admin-001'
}

const STORAGE_KEYS = {
  USER: 'trucking_admin_user',
  TOKEN: 'trucking_admin_token',
  EXPIRES_AT: 'trucking_admin_expires_at'
}

export function AuthProvider({ children }: AuthProviderProps) {
  const [authState, setAuthState] = useState<AuthState>({
    user: null,
    isLoading: true,
    isAuthenticated: false,
    error: null
  })

  const router = useRouter()

  // Check for existing session on mount
  useEffect(() => {
    checkExistingSession()
  }, [])

  const checkExistingSession = async () => {
    try {
      if (typeof window === 'undefined') {
        setAuthState(prev => ({ ...prev, isLoading: false }))
        return
      }

      const storedUser = localStorage.getItem(STORAGE_KEYS.USER)
      const storedToken = localStorage.getItem(STORAGE_KEYS.TOKEN)
      const expiresAt = localStorage.getItem(STORAGE_KEYS.EXPIRES_AT)

      if (!storedUser || !storedToken || !expiresAt) {
        setAuthState(prev => ({ ...prev, isLoading: false }))
        return
      }

      // Check if session has expired
      if (Date.now() > parseInt(expiresAt)) {
        clearStoredSession()
        setAuthState(prev => ({ ...prev, isLoading: false }))
        return
      }

      const userData: User = JSON.parse(storedUser)
      
      // Validate user data
      if (userData.email === ADMIN_CREDENTIALS.email && userData.role === 'admin') {
        setAuthState({
          user: userData,
          isLoading: false,
          isAuthenticated: true,
          error: null
        })
      } else {
        clearStoredSession()
        setAuthState(prev => ({ ...prev, isLoading: false }))
      }
    } catch (error) {
      console.error('Session check error:', error)
      clearStoredSession()
      setAuthState(prev => ({ ...prev, isLoading: false, error: 'Session validation failed' }))
    }
  }

  const login = async (email: string, password: string): Promise<{ success: boolean; error?: string }> => {
    setAuthState(prev => ({ ...prev, isLoading: true, error: null }))

    try {
      // Simulate API call delay
      await new Promise(resolve => setTimeout(resolve, 1000))

      // Validate credentials
      if (email.toLowerCase() !== ADMIN_CREDENTIALS.email.toLowerCase()) {
        setAuthState(prev => ({ ...prev, isLoading: false }))
        return { success: false, error: 'Access denied. Only admin@trucking.com is allowed.' }
      }

      if (password !== ADMIN_CREDENTIALS.password) {
        setAuthState(prev => ({ ...prev, isLoading: false }))
        return { success: false, error: 'Invalid password. Please try again.' }
      }

      // Create user session
      const userData: User = {
        email: ADMIN_CREDENTIALS.email,
        role: ADMIN_CREDENTIALS.role,
        name: ADMIN_CREDENTIALS.name,
        id: ADMIN_CREDENTIALS.id
      }

      const token = generateToken(userData)
      const expiresAt = Date.now() + (24 * 60 * 60 * 1000) // 24 hours

      // Store in localStorage
      localStorage.setItem(STORAGE_KEYS.USER, JSON.stringify(userData))
      localStorage.setItem(STORAGE_KEYS.TOKEN, token)
      localStorage.setItem(STORAGE_KEYS.EXPIRES_AT, expiresAt.toString())

      setAuthState({
        user: userData,
        isLoading: false,
        isAuthenticated: true,
        error: null
      })

      return { success: true }
    } catch (error) {
      console.error('Login error:', error)
      setAuthState(prev => ({ 
        ...prev, 
        isLoading: false, 
        error: 'Login failed. Please try again.' 
      }))
      return { success: false, error: 'Login failed. Please try again.' }
    }
  }

  const logout = () => {
    clearStoredSession()
    setAuthState({
      user: null,
      isLoading: false,
      isAuthenticated: false,
      error: null
    })
    router.push('/login')
  }

  const clearError = () => {
    setAuthState(prev => ({ ...prev, error: null }))
  }

  const clearStoredSession = () => {
    if (typeof window !== 'undefined') {
      localStorage.removeItem(STORAGE_KEYS.USER)
      localStorage.removeItem(STORAGE_KEYS.TOKEN)
      localStorage.removeItem(STORAGE_KEYS.EXPIRES_AT)
    }
  }

  const generateToken = (user: User): string => {
    return btoa(`${user.email}:${user.id}:${Date.now()}:${Math.random()}`)
  }

  const contextValue: AuthContextType = {
    ...authState,
    login,
    logout,
    clearError
  }

  return (
    <AuthContext.Provider value={contextValue}>
      {children}
    </AuthContext.Provider>
  )
}
