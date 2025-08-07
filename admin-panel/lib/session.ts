import { NextRequest, NextResponse } from 'next/server'

export interface SessionData {
  user: {
    email: string
    role: string
    name: string
  }
  token: string
  expiresAt: number
}

export class SessionManager {
  private static COOKIE_NAME = 'admin_session'
  private static TOKEN_EXPIRY = 24 * 60 * 60 * 1000 // 24 hours

  static createSession(userData: { email: string; role: string; name: string }): SessionData {
    const expiresAt = Date.now() + this.TOKEN_EXPIRY
    const token = this.generateToken(userData.email, expiresAt)
    
    return {
      user: userData,
      token,
      expiresAt
    }
  }

  static setSessionCookie(response: NextResponse, sessionData: SessionData) {
    response.cookies.set(this.COOKIE_NAME, JSON.stringify(sessionData), {
      httpOnly: true,
      secure: process.env.NODE_ENV === 'production',
      sameSite: 'strict',
      maxAge: this.TOKEN_EXPIRY / 1000,
      path: '/'
    })
  }

  static getSessionFromRequest(request: NextRequest): SessionData | null {
    try {
      const sessionCookie = request.cookies.get(this.COOKIE_NAME)?.value
      if (!sessionCookie) return null

      const sessionData: SessionData = JSON.parse(sessionCookie)
      
      // Check if session has expired
      if (Date.now() > sessionData.expiresAt) {
        return null
      }

      return sessionData
    } catch (error) {
      return null
    }
  }

  static clearSession(response: NextResponse) {
    response.cookies.delete(this.COOKIE_NAME)
  }

  static isValidAdmin(sessionData: SessionData | null): boolean {
    return sessionData?.user?.email === 'admin@trucking.com' && 
           sessionData?.user?.role === 'admin'
  }

  private static generateToken(email: string, expiresAt: number): string {
    // Simple token generation (in production, use proper JWT or similar)
    return btoa(`${email}:${expiresAt}:${Math.random()}`)
  }
}
