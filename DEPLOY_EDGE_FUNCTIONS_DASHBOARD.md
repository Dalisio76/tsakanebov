# 🚀 DEPLOY EDGE FUNCTIONS - VIA DASHBOARD SUPABASE

## Sem usar CLI - Direto no navegador!

---

## 📦 EDGE FUNCTION 1: `get-perfil`

### 1. Acessar Edge Functions

1. Abra **Supabase Dashboard**: https://supabase.com/dashboard
2. Selecione seu projeto: **tsakanebov**
3. No menu lateral, clique em **Edge Functions**
4. Clique no botão **"Create a new function"** ou **"New Edge Function"**

### 2. Configurar a Function

- **Name**: `get-perfil`
- **Description**: `Buscar perfil de usuário (bypass RLS)`

### 3. Colar o Código

Cole este código no editor:

```typescript
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
```

### 4. Deploy

Clique em **"Deploy"** ou **"Save"**

✅ **Edge Function `get-perfil` criada!**

**URL**: `https://sbfzqpcnmcftzcgxpkrl.supabase.co/functions/v1/get-perfil`

---

## 📦 EDGE FUNCTION 2: `listar-usuarios`

### 1. Criar Nova Function

No menu **Edge Functions**, clique em **"Create a new function"** novamente

### 2. Configurar

- **Name**: `listar-usuarios`
- **Description**: `Listar todos os usuários (apenas admin)`

### 3. Colar o Código

Cole este código:

```typescript
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

    // Verificar se usuário é admin
    const { data: profile, error: profileError } = await supabaseAdmin
      .from('perfis_usuario')
      .select('role')
      .eq('id', user.id)
      .single()

    if (profileError || !profile || profile.role !== 'admin') {
      return new Response(
        JSON.stringify({ error: 'Acesso negado. Apenas administradores podem listar usuários.' }),
        {
          status: 403,
          headers: { ...corsHeaders, 'Content-Type': 'application/json' },
        }
      )
    }

    // Listar todos os usuários
    const { data: usuarios, error: listError } = await supabaseAdmin
      .from('perfis_usuario')
      .select('*')
      .order('criado_em', { ascending: false })

    if (listError) {
      return new Response(
        JSON.stringify({ error: 'Erro ao listar usuários', details: listError }),
        {
          status: 500,
          headers: { ...corsHeaders, 'Content-Type': 'application/json' },
        }
      )
    }

    return new Response(
      JSON.stringify(usuarios),
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
```

### 4. Deploy

Clique em **"Deploy"** ou **"Save"**

✅ **Edge Function `listar-usuarios` criada!**

**URL**: `https://sbfzqpcnmcftzcgxpkrl.supabase.co/functions/v1/listar-usuarios`

---

## ✅ Verificar se Funcionou

### No Dashboard Supabase:

1. Vá em **Edge Functions**
2. Deve ver 2 functions:
   - ✅ `get-perfil` (status: **Active**)
   - ✅ `listar-usuarios` (status: **Active**)

### Testar no App:

1. No terminal Flutter, pressione **`R`** para hot restart
2. Faça **login**
3. Vá em **"Meu Perfil"**
4. **Deve carregar sem erro!** 🎉

---

## 🐛 Se der erro no Deploy:

### Erro: "Import not found"
- As Edge Functions do Supabase usam **Deno**
- Os imports já estão corretos (usando URLs https://)
- Certifique-se de copiar o código EXATAMENTE como está

### Erro: "Service role key not found"
- As variáveis de ambiente (`SUPABASE_SERVICE_ROLE_KEY`, etc.) são **automáticas**
- Não precisa configurar nada
- O Supabase injeta automaticamente

### Erro no console do app
Se aparecer erro no app tipo:
```
Failed to invoke function: get-perfil
```

**Solução**:
1. Vá no Dashboard → Edge Functions
2. Clique na function `get-perfil`
3. Veja os **Logs** para identificar o erro
4. Me mostre o erro que aparece nos logs

---

## 📝 Resumo dos Passos:

1. ✅ **SQL Editor** → Execute `CORRIGIR_RLS_PERFIS_FINAL.sql`
2. ✅ **Edge Functions** → Crie `get-perfil` (copie código acima)
3. ✅ **Edge Functions** → Crie `listar-usuarios` (copie código acima)
4. ✅ **App** → Hot restart e teste!

---

## 🎯 URLs das Edge Functions:

Após criar, suas URLs serão:

- **get-perfil**: `https://sbfzqpcnmcftzcgxpkrl.supabase.co/functions/v1/get-perfil`
- **listar-usuarios**: `https://sbfzqpcnmcftzcgxpkrl.supabase.co/functions/v1/listar-usuarios`

O código Flutter (`auth_service.dart`) já está configurado para usar essas functions automaticamente! ✅

---

**Pronto!** Agora é só criar as 2 Edge Functions no Dashboard e testar! 🚀
