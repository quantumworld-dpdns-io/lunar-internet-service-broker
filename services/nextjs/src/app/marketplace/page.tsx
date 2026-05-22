'use client'

import { useState } from 'react'
import { Search, Filter } from 'lucide-react'

interface Offer {
  id: string
  provider: string
  bandwidth_mbps: number
  price_per_mbps: number
  zone: string
  available_from: string
  available_until: string
}

export default function Marketplace() {
  const [search, setSearch] = useState('')
  const [zoneFilter, setZoneFilter] = useState('all')

  return (
    <div className="min-h-screen bg-gray-50 dark:bg-gray-900">
      <header className="bg-white dark:bg-gray-800 shadow">
        <div className="max-w-7xl mx-auto px-4 py-6">
          <h1 className="text-3xl font-bold text-gray-900 dark:text-white">
            Marketplace
          </h1>
        </div>
      </header>

      <main className="max-w-7xl mx-auto px-4 py-8">
        <div className="flex gap-4 mb-6">
          <div className="flex-1 relative">
            <Search className="absolute left-3 top-3 h-5 w-5 text-gray-400" />
            <input
              type="text"
              placeholder="Search offers..."
              value={search}
              onChange={(e) => setSearch(e.target.value)}
              className="w-full pl-10 pr-4 py-2 rounded-lg border border-gray-300 dark:border-gray-600 bg-white dark:bg-gray-800 text-gray-900 dark:text-white"
            />
          </div>
          <select
            value={zoneFilter}
            onChange={(e) => setZoneFilter(e.target.value)}
            className="px-4 py-2 rounded-lg border border-gray-300 dark:border-gray-600 bg-white dark:bg-gray-800 text-gray-900 dark:text-white"
          >
            <option value="all">All Zones</option>
            <option value="nearside">Nearside</option>
            <option value="farside">Farside</option>
            <option value="north_pole">North Pole</option>
            <option value="south_pole">South Pole</option>
            <option value="equatorial">Equatorial</option>
          </select>
          <button className="px-4 py-2 bg-lunar-600 text-white rounded-lg hover:bg-lunar-700 flex items-center gap-2">
            <Filter className="h-5 w-5" />
            Filters
          </button>
        </div>

        <div className="bg-white dark:bg-gray-800 rounded-lg shadow">
          <div className="px-6 py-4 border-b border-gray-200 dark:border-gray-700">
            <h2 className="text-lg font-semibold">
              Capacity Offers
            </h2>
          </div>
          <div className="p-6">
            <p className="text-gray-500 dark:text-gray-400 text-center py-8">
              No offers currently available.
            </p>
          </div>
        </div>
      </main>
    </div>
  )
}
