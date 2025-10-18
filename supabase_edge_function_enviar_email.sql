-- ============================================
-- SUPABASE EDGE FUNCTION - ENVIAR EMAIL
-- ============================================

-- 1. No Supabase Dashboard, vá em "Edge Functions"
-- 2. Crie uma nova função chamada: "enviar-email"
-- 3. Cole o código TypeScript abaixo

/*
=== CÓDIGO DA EDGE FUNCTION (TypeScript) ===

// supabase/functions/enviar-email/index.ts

import { serve } from "https://deno.land/std@0.168.0/http/server.ts"

const RESEND_API_KEY = "re_H2GjTXHA_FgtFJNK8pi8TWkLxSs4Ke2vR"

serve(async (req) => {
  // CORS Headers
  const corsHeaders = {
    'Access-Control-Allow-Origin': '*',
    'Access-Control-Allow-Headers': 'authorization, x-client-info, apikey, content-type',
  }

  // Handle CORS preflight
  if (req.method === 'OPTIONS') {
    return new Response('ok', { headers: corsHeaders })
  }

  try {
    const { destinatario, assunto, mensagem } = await req.json()

    // Validar dados
    if (!destinatario || !assunto || !mensagem) {
      return new Response(
        JSON.stringify({ error: 'Dados incompletos' }),
        { status: 400, headers: { ...corsHeaders, 'Content-Type': 'application/json' } }
      )
    }

    // IMPORTANTE: Em modo de teste, Resend só envia para o email cadastrado
    // Para produção, verifique um domínio em resend.com/domains
    const emailDestino = destinatario || 'frentexeservicos@gmail.com';

    // Enviar email via Resend
    const response = await fetch('https://api.resend.com/emails', {
      method: 'POST',
      headers: {
        'Authorization': `Bearer ${RESEND_API_KEY}`,
        'Content-Type': 'application/json',
      },
      body: JSON.stringify({
        from: 'Sistema Gestão Gado <onboarding@resend.dev>',
        to: [emailDestino],
        subject: assunto,
        text: `DESTINATÁRIO ORIGINAL: ${destinatario}\n\n${mensagem}`,
      }),
    })

    const data = await response.json()

    if (response.ok) {
      return new Response(
        JSON.stringify({ success: true, data }),
        { status: 200, headers: { ...corsHeaders, 'Content-Type': 'application/json' } }
      )
    } else {
      return new Response(
        JSON.stringify({ error: 'Erro ao enviar email', details: data }),
        { status: response.status, headers: { ...corsHeaders, 'Content-Type': 'application/json' } }
      )
    }
  } catch (error) {
    return new Response(
      JSON.stringify({ error: error.message }),
      { status: 500, headers: { ...corsHeaders, 'Content-Type': 'application/json' } }
    )
  }
})

*/

-- ============================================
-- INSTRUÇÕES DE DEPLOY
-- ============================================

/*
1. Instale o Supabase CLI:
   npm install -g supabase

2. Faça login:
   supabase login

3. Crie a função:
   supabase functions new enviar-email

4. Cole o código TypeScript acima em:
   supabase/functions/enviar-email/index.ts

5. Deploy:
   supabase functions deploy enviar-email --project-ref SEU_PROJECT_REF

6. A URL da função será:
   https://SEU_PROJECT_ID.supabase.co/functions/v1/enviar-email
*/

-- Após deploy, atualize o notification_service.dart
-- para usar a URL da Edge Function em vez de chamar Resend diretamente
