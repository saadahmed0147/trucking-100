'use client'

import React from 'react'
import { MapPin } from 'lucide-react'

export default function POIPage() {
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
                <MapPin className="h-8 w-8 text-white" />
              </div>
              <div>
                <h1 className="text-3xl font-bold">Points of Interest</h1>
                <p className="text-blue-100 text-lg mt-1">
                  Manage fuel stations and rest stops along trucking routes
                </p>
              </div>
            </div>
          </div>
        </div>
      </div>

      {/* Content */}
      <div 
        className="rounded-xl p-6 shadow-lg border"
        style={{ backgroundColor: '#ffffff', borderColor: '#e2e8f0' }}
      >
        <div className="text-center py-12">
          <MapPin className="h-12 w-12 text-gray-400 mx-auto mb-4" />
          <h3 className="text-lg font-medium text-gray-900 mb-2">POI Management</h3>
          <p className="text-gray-500">Points of Interest management coming soon.</p>
        </div>
      </div>
    </div>
  )
}