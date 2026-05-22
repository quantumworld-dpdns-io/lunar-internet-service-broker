'use client'

import { useEffect, useState } from 'react'

interface DashboardStats {
  activeOffers: number
  openRequests: number
  completedMatches: number
  totalVolume: number
}

export default function Dashboard() {
  const [stats, setStats] = useState<DashboardStats>({
    activeOffers: 0,
    openRequests: 0,
    completedMatches: 0,
    totalVolume: 0,
  })

  useEffect(() => {
    async function fetchStats() {
      try {
        const res = await fetch('/api/v1/analytics/stats')
        const data = await res.json()
        setStats(data)
      } catch (err) {
        console.error('Failed to fetch stats:', err)
      }
    }
    fetchStats()
    const interval = setInterval(fetchStats, 30000)
    return () => clearInterval(interval)
  }, [])

  return (
    <div className="min-h-screen bg-gray-50 dark:bg-gray-900">
      <header className="bg-white dark:bg-gray-800 shadow">
        <div className="max-w-7xl mx-auto px-4 py-6">
          <h1 className="text-3xl font-bold text-gray-900 dark:text-white">
            Dashboard
          </h1>
        </div>
      </header>

      <main className="max-w-7xl mx-auto px-4 py-8">
        <div className="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-4 gap-6">
          <StatCard
            title="Active Offers"
            value={stats.activeOffers}
            color="blue"
          />
          <StatCard
            title="Open Requests"
            value={stats.openRequests}
            color="green"
          />
          <StatCard
            title="Completed Matches"
            value={stats.completedMatches}
            color="purple"
          />
          <StatCard
            title="Total Volume"
            value={`$${stats.totalVolume.toLocaleString()}`}
            color="orange"
          />
        </div>

        <div className="mt-8 grid grid-cols-1 lg:grid-cols-2 gap-6">
          <div className="bg-white dark:bg-gray-800 rounded-lg shadow p-6">
            <h2 className="text-xl font-semibold mb-4">Recent Activity</h2>
            <p className="text-gray-500 dark:text-gray-400">
              Activity feed will appear here.
            </p>
          </div>
          <div className="bg-white dark:bg-gray-800 rounded-lg shadow p-6">
            <h2 className="text-xl font-semibold mb-4">Market Overview</h2>
            <p className="text-gray-500 dark:text-gray-400">
              Market charts will appear here.
            </p>
          </div>
        </div>
      </main>
    </div>
  )
}

function StatCard({
  title,
  value,
  color,
}: {
  title: string
  value: string | number
  color: string
}) {
  const colorClasses: Record<string, string> = {
    blue: 'bg-blue-50 dark:bg-blue-900/20 border-blue-200 dark:border-blue-800',
    green: 'bg-green-50 dark:bg-green-900/20 border-green-200 dark:border-green-800',
    purple: 'bg-purple-50 dark:bg-purple-900/20 border-purple-200 dark:border-purple-800',
    orange: 'bg-orange-50 dark:bg-orange-900/20 border-orange-200 dark:border-orange-800',
  }

  return (
    <div
      className={`rounded-lg border p-6 ${colorClasses[color] ?? ''}`}
    >
      <h3 className="text-sm font-medium text-gray-500 dark:text-gray-400">
        {title}
      </h3>
      <p className="mt-2 text-3xl font-bold text-gray-900 dark:text-white">
        {value}
      </p>
    </div>
  )
}
