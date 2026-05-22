import { serve } from 'https://deno.land/std@0.208.0/http/server.ts'

serve(async (req) => {
  const payload = await req.json()

  // Relay on-chain events to the database
  const { event, data } = payload

  switch (event) {
    case 'commitment_created':
      // Update commitment status in database
      break
    case 'commitment_fulfilled':
      // Mark commitment as fulfilled
      break
    case 'dispute_opened':
      // Create dispute record
      break
  }

  return new Response(
    JSON.stringify({ received: true }),
    { headers: { 'Content-Type': 'application/json' } }
  )
})
