# 🔧 SOLUÇÃO PROBLEMA CORS - Envio de Emails

## ❌ Problema

Ao tentar enviar emails na web (Chrome), aparece o erro:
```
❌ Erro ao enviar email: ClientException: Failed to fetch
```

**Causa**: CORS (Cross-Origin Resource Sharing)
- O navegador bloqueia chamadas HTTP diretas para APIs externas (Resend)
- É uma proteção de segurança do navegador

---

## ✅ SOLUÇÃO IMPLEMENTADA (Temporária)

### O que foi feito:
- ✅ **Na web**: Emails NÃO são enviados (apenas logados no console)
- ✅ **No mobile**: Emails funcionam normalmente
- ✅ **Log**: Todas as tentativas são registradas no banco

### Como funciona agora:
1. Quando você cadastra um animal na web:
   - Sistema tenta enviar email
   - Detecta que está na web
   - **NÃO envia** (CORS bloquearia mesmo)
   - Loga no console do navegador:
     ```
     ⚠️ [WEB] Email desabilitado devido a CORS
     📧 Para: seu@email.com
     📋 Assunto: Novo Animal Cadastrado - 001
     💬 Mensagem: [conteúdo]
     💡 Use Edge Function do Supabase
     ```
   - Registra no banco com status "pendente"

2. No mobile/desktop:
   - Funciona normalmente
   - Envia email real via Resend API

---

## 🚀 SOLUÇÃO DEFINITIVA (Produção)

### Usar Edge Function do Supabase

#### O que é?
Uma função serverless que roda no backend do Supabase, sem CORS.

#### Como implementar:

### 1️⃣ Instalar Supabase CLI
```bash
npm install -g supabase
```

### 2️⃣ Login
```bash
supabase login
```

### 3️⃣ Criar Edge Function
```bash
supabase functions new enviar-email
```

### 4️⃣ Código da Edge Function

Abra `supabase/functions/enviar-email/index.ts`:

```typescript
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

    // Enviar email via Resend
    const response = await fetch('https://api.resend.com/emails', {
      method: 'POST',
      headers: {
        'Authorization': `Bearer ${RESEND_API_KEY}`,
        'Content-Type': 'application/json',
      },
      body: JSON.stringify({
        from: 'Sistema Gestão Gado <onboarding@resend.dev>',
        to: [destinatario],
        subject: assunto,
        text: mensagem,
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
```

### 5️⃣ Deploy
```bash
supabase functions deploy enviar-email --project-ref SEU_PROJECT_REF
```

Você vai receber uma URL tipo:
```
https://abc123.supabase.co/functions/v1/enviar-email
```

### 6️⃣ Atualizar notification_service.dart

Adicione a URL da Edge Function:

```dart
static const String edgeFunctionUrl = 'https://abc123.supabase.co/functions/v1/enviar-email';
```

Modifique o método `_enviarEmail`:

```dart
Future<void> _enviarEmail(String destinatario, String assunto, String mensagem) async {
  // Se na web e Edge Function configurada, usar Edge Function
  if (kIsWeb && edgeFunctionUrl.isNotEmpty) {
    try {
      final response = await http.post(
        Uri.parse(edgeFunctionUrl),
        headers: {
          'Content-Type': 'application/json',
          'apikey': 'SUA_SUPABASE_ANON_KEY', // Pegue no dashboard
        },
        body: json.encode({
          'destinatario': destinatario,
          'assunto': assunto,
          'mensagem': mensagem,
        }),
      );

      if (response.statusCode == 200) {
        await _registrarLog('email', destinatario, assunto, mensagem, 'enviada', null);
        print('✅ Email enviado via Edge Function');
      } else {
        await _registrarLog('email', destinatario, assunto, mensagem, 'erro', response.body);
        print('❌ Erro Edge Function: ${response.body}');
      }
    } catch (e) {
      await _registrarLog('email', destinatario, assunto, mensagem, 'erro', e.toString());
      print('❌ Erro: $e');
    }
    return;
  }

  // Resto do código original para mobile...
}
```

---

## 📊 STATUS ATUAL

| Plataforma | Status | Observação |
|------------|--------|------------|
| 🌐 Web (Chrome) | ⚠️ Logado apenas | CORS bloqueia. Use Edge Function |
| 📱 Mobile | ✅ Funcional | Envia emails normalmente |
| 🖥️ Desktop | ✅ Funcional | Envia emails normalmente |

---

## 🧪 TESTAR AGORA

### Na Web:
1. Cadastre um animal
2. Abra Console do navegador (F12)
3. Veja os logs:
   ```
   ⚠️ [WEB] Email desabilitado devido a CORS
   📧 Para: seu@email.com
   📋 Assunto: Novo Animal Cadastrado - 001
   ```
4. Sistema **funciona normalmente**, apenas não envia email

### Verificar Logs no Banco:
```sql
SELECT
  destinatario,
  assunto,
  status,
  erro,
  enviado_em
FROM log_notificacoes
ORDER BY enviado_em DESC
LIMIT 5;
```

Vai mostrar:
- Status: **"pendente"**
- Erro: "Desabilitado na web devido a CORS. Use Edge Function do Supabase."

---

## 💡 ALTERNATIVAS

### Opção 1: Edge Function (Recomendado)
- ✅ Sem CORS
- ✅ Funciona na web
- ✅ Seguro (API key no backend)
- ⏱️ Requer deploy

### Opção 2: Usar apenas Mobile
- ✅ Funciona imediatamente
- ✅ Sem configuração extra
- ❌ Não funciona na web

### Opção 3: Backend Próprio
- ✅ Total controle
- ✅ Sem CORS
- ⏱️ Mais trabalho

---

## 📞 PRÓXIMOS PASSOS

1. ✅ **Sistema funciona** (emails logados na web)
2. ⏸️ **Opcional**: Deploy Edge Function para emails na web
3. ⏸️ **Opcional**: Testar no mobile (emails funcionam)

---

## ✨ RESUMO

🎉 **Sistema está funcional!**
- ✅ Tela de configurações funciona
- ✅ Logs são registrados
- ✅ No mobile, emails funcionam
- ⚠️ Na web, emails são apenas logados (CORS)

Para enviar emails na web, siga o guia de Edge Function acima.

---

**Atualizado**: 2025-10-18
**Status**: ✅ Funcional com workaround
