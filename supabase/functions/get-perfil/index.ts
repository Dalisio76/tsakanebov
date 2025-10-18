import { serve } from "https://deno.land/std@0.168.0/http/server.ts"
import { createClient } from 'https://esm.sh/@supabase/supabase-js@2'

const corsHeaders = {
  'Access-Control-Allow-Origin': '*',
  'Access-Control-Allow-Headers': 'authorization, x-client-info, apikey, content-type',
}

serve(async (req) => {
  // Handle CORS preflight
  if (req.method === 'OPTIONS') {
    return new Response('ok', { headers: corsHeaders })
  }

  try {
    // Criar cliente Supabase com service role (bypass RLS)
    const supabaseAdmin = createClient(
      Deno.env.get('SUPABASE_URL') ?? '',
      Deno.env.get('SUPABASE_SERVICE_ROLE_KEY') ?? '',
      {
        auth: {
          autoRefreshToken: false,
          persistSession: false
        }
      }
    )

    // Criar cliente normal para verificar usuário autenticado
    const authHeader = req.headers.get('Authorization')!
    const supabaseClient = createClient(
      Deno.env.get('SUPABASE_URL') ?? '',
      Deno.env.get('SUPABASE_ANON_KEY') ?? '',
      {
        global: {
          headers: { Authorization: authHeader },
        },
        auth: {
          autoRefreshToken: false,
          persistSession: false
        }
      }
    )

    // Verificar usuário autenticado
    const {
      data: { user },
      error: userError,
    } = await supabaseClient.auth.getUser()

    if (userError || !user) {
      return new Response(
        JSON.stringify({ error: 'Não autenticado' }),
        {
          status: 401,
          headers: { ...corsHeaders, 'Content-Type': 'application/json' },
        }
      )
    }

    // Pegar userId da query string (opcional, se admin quiser ver outro perfil)
    const url = new URL(req.url)
    const requestedUserId = url.searchParams.get('userId')
    const targetUserId = requestedUserId || user.id

    // Buscar perfil do usuário logado (para verificar se é admin)
    const { data: currentUserProfile, error: currentProfileError } = await supabaseAdmin
      .from('perfis_usuario')
      .select('*')
      .eq('id', user.id)
      .single()

    if (currentProfileError) {
      return new Response(
        JSON.stringify({ error: 'Perfil não encontrado', details: currentProfileError }),
        {
          status: 404,
          headers: { ...corsHeaders, 'Content-Type': 'application/json' },
        }
      )
    }

    // Verificar permissão
    const isAdmin = currentUserProfile.role === 'admin'
    const isOwnProfile = targetUserId === user.id

    if (!isOwnProfile && !isAdmin) {
      return new Response(
        JSON.stringify({ error: 'Sem permissão para ver este perfil' }),
        {
          status: 403,
          headers: { ...corsHeaders, 'Content-Type': 'application/json' },
        }
      )
    }

    // Buscar perfil solicitado
    const { data: profile, error: profileError } = await supabaseAdmin
      .from('perfis_usuario')
      .select('*')
      .eq('id', targetUserId)
      .single()

    if (profileError) {
      return new Response(
        JSON.stringify({ error: 'Perfil não encontrado', details: profileError }),
        {
          status: 404,
          headers: { ...corsHeaders, 'Content-Type': 'application/json' },
        }
      )
    }

    return new Response(
      JSON.stringify(profile),
      {
        status: 200,
        headers: { ...corsHeaders, 'Content-Type': 'application/json' },
      }
    )
  } catch (error) {
    return new Response(
      JSON.stringify({ error: error.message }),
      {
        status: 500,
        headers: { ...corsHeaders, 'Content-Type': 'application/json' },
      }
    )
  }
})
