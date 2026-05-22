import { serve } from 'https://deno.land/std@0.208.0/http/server.ts'
import { createClient } from 'https://esm.sh/@supabase/supabase-js@2.39.0'

serve(async (req) => {
  const supabase = createClient(
    Deno.env.get('SUPABASE_URL')!,
    Deno.env.get('SUPABASE_SERVICE_ROLE_KEY')!
  )

  const { data, error } = await supabase.from('profiles').select('count')

  return new Response(
    JSON.stringify({
      status: 'ok',
      service: 'lunar-broker-edge',
      profiles_count: data?.[0]?.count ?? 0,
    }),
    { headers: { 'Content-Type': 'application/json' } }
  )
})
