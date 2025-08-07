import { NextResponse } from 'next/server'
import type { NextRequest } from 'next/server'

export function middleware(request: NextRequest) {
  // Check if the request is for dashboard routes
  if (request.nextUrl.pathname.startsWith('/dashboard')) {
    // For server-side, we'll handle authentication check in the layout
    // This middleware will just ensure the routes are accessible
    return NextResponse.next()
  }

  return NextResponse.next()
}

export const config = {
  matcher: ['/dashboard/:path*']
}
