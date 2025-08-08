'use client';

import React, { useState, useEffect, useContext, createContext } from 'react';
import { useRouter } from 'next/navigation';
import {
  signInWithEmailAndPassword,
  signOut,
  onAuthStateChanged,
  User as FirebaseUser,
} from 'firebase/auth';
import { auth } from '@/lib/firebase';

interface AuthContextType {
  user: FirebaseUser | null;
  isLoading: boolean;
  error: string | null;
  isAuthenticated: boolean;
  login: (email: string, password: string) => Promise<{ success: boolean; error?: string }>;
  logout: () => Promise<void>;
  clearError: () => void;
}

const AuthContext = createContext<AuthContextType | undefined>(undefined);

export function useAuth() {
  const context = useContext(AuthContext);
  if (!context) throw new Error('useAuth must be used within AuthProvider');
  return context;
}

export function AuthProvider({ children }: { children: React.ReactNode }) {
  const [user, setUser] = useState<FirebaseUser | null>(null);
  const [isLoading, setIsLoading] = useState(true);
  const [error, setError] = useState<string | null>(null);
  const router = useRouter();

  // Monitor user authentication state
  useEffect(() => {
    const unsubscribe = onAuthStateChanged(auth, (firebaseUser) => {
      setUser(firebaseUser);
      setIsLoading(false);
    });
    return () => unsubscribe();
  }, []);

  // Handle login
  const login = async (email: string, password: string) => {
    setIsLoading(true);
    setError(null);
    try {
      if (email.toLowerCase() !== 'admin@trucking.com') {
        throw new Error('Access denied: Only admin can log in.');
      }

      await signInWithEmailAndPassword(auth, email, password);
      router.push('/dashboard');
      return { success: true };
    } catch (err: any) {
      const message =
        err.code === 'auth/invalid-credential'
          ? 'Invalid email or password.'
          : err.message || 'Login failed.';
      setError(message);
      return { success: false, error: message };
    } finally {
      setIsLoading(false);
    }
  };

  // Handle logout
  const logout = async () => {
    setIsLoading(true);
    await signOut(auth);
    setUser(null);
    setIsLoading(false);
    router.push('/login');
  };

  const clearError = () => setError(null);

  const isAuthenticated = !!user;

  return (
    <AuthContext.Provider
      value={{ user, isLoading, error, isAuthenticated, login, logout, clearError }}
    >
      {children}
    </AuthContext.Provider>
  );
}
