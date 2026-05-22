export default function Home() {
  return (
    <main className="flex min-h-screen flex-col items-center justify-center p-24">
      <h1 className="text-4xl font-bold mb-4">
        Lunar Internet Service Broker
      </h1>
      <p className="text-lg text-gray-600 dark:text-gray-400">
        Marketplace for lunar communication relay capacity
      </p>
      <div className="mt-8 flex gap-4">
        <a
          href="/api/health"
          className="px-4 py-2 bg-lunar-600 text-white rounded-lg hover:bg-lunar-700"
        >
          Health Check
        </a>
      </div>
    </main>
  )
}
