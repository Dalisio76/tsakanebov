# 🔧 SOLUÇÃO ERRO 403 - RESEND API

## ❌ Problema

```
Erro Edge Function: 403 - validation_error
You can only send testing emails to your own email address (frentexeservicos@gmail.com)
```

---

## 📖 Explicação

A **Resend API** tem limitações em modo de teste:

| Modo | Remetente | Destinatário |
|------|-----------|--------------|
| **Teste** | `onboarding@resend.dev` | **Apenas** email cadastrado na conta |
| **Produção** | Seu domínio verificado | Qualquer email |

---

## ✅ SOLUÇÃO 1: MODO TESTE (Implementada)

### O que foi feito:

1. ✅ Modificado arquivo: `supabase/functions/enviar-email/index.ts`
2. ✅ Emails sempre vão para: `frentexeservicos@gmail.com`
3. ✅ No corpo do email, mostra o destinatário original

### Como testar:

1. Faça deploy da Edge Function atualizada:
```bash
cd C:\Users\Frentex\source\tsakanebov
supabase functions deploy enviar-email
```

2. Configure qualquer email na tela de notificações
3. Cadastre um animal
4. **O email chegará em `frentexeservicos@gmail.com`** com esta estrutura:

```
Assunto: Novo Animal Cadastrado - 001

Corpo:
DESTINATÁRIO ORIGINAL: email-que-voce-configurou@example.com

🐄 Novo animal cadastrado!

Brinco: 001
Nome: Mimosa
Data: 2025-10-18 12:30
```

---

## ✅ SOLUÇÃO 2: MODO PRODUÇÃO (Para o futuro)

### Passos para enviar para qualquer email:

### 1️⃣ Verificar um domínio no Resend

1. Acesse: https://resend.com/domains
2. Clique em **"Add Domain"**
3. Digite seu domínio (exemplo: `meusite.com`)
4. Copie os registros DNS fornecidos
5. Configure no seu provedor de domínio:
   - **MX** (para receber emails)
   - **TXT** (SPF e DKIM para autenticação)
6. Aguarde verificação (até 48h)

### 2️⃣ Atualizar Edge Function

Após o domínio ser verificado, modifique `supabase/functions/enviar-email/index.ts`:

```typescript
// ANTES (modo teste)
from: 'Sistema Gestão Gado <onboarding@resend.dev>',
to: ['frentexeservicos@gmail.com'],
text: `DESTINATÁRIO ORIGINAL: ${destinatario}\n\n${mensagem}`,

// DEPOIS (modo produção)
from: 'Sistema Gestão Gado <noreply@seudominio.com>',
to: [destinatario],
text: mensagem,
```

### 3️⃣ Deploy novamente

```bash
supabase functions deploy enviar-email
```

---

## 🎯 ALTERNATIVA: Usar Gmail SMTP (Grátis)

Se não tiver domínio, pode usar Gmail:

### 1️⃣ Criar App Password no Gmail

1. Vá em: https://myaccount.google.com/security
2. Ative verificação em 2 etapas
3. Procure "App Passwords"
4. Gere uma senha para "Mail"

### 2️⃣ Modificar Edge Function para usar SMTP

```typescript
// Usar nodemailer ou SMTP direto
const transporter = {
  host: 'smtp.gmail.com',
  port: 587,
  auth: {
    user: 'frentexeservicos@gmail.com',
    pass: 'sua-app-password-aqui'
  }
}
```

---

## 📊 COMPARAÇÃO DAS SOLUÇÕES

| Solução | Custo | Configuração | Destinatários | Status |
|---------|-------|--------------|---------------|--------|
| **Teste Resend** | Grátis | ✅ Pronta | Apenas 1 | ✅ Atual |
| **Resend + Domínio** | Grátis até 3k/mês | Requer domínio | Ilimitados | 🔄 Futuro |
| **Gmail SMTP** | Grátis até 500/dia | Média | Ilimitados | 🔄 Alternativa |

---

## 🚀 RECOMENDAÇÃO

### Para AGORA (desenvolvimento):
✅ **Usar Solução 1** - Emails vão para `frentexeservicos@gmail.com`
- Funciona imediatamente
- Grátis
- Perfeito para testes

### Para PRODUÇÃO (futuro):
🔄 **Verificar domínio no Resend**
- Enviar para qualquer email
- Profissional
- Grátis até 3.000 emails/mês

---

## 📞 PRÓXIMOS PASSOS

1. ✅ Deploy da Edge Function atualizada:
   ```bash
   supabase functions deploy enviar-email
   ```

2. ✅ Testar notificação cadastrando animal

3. ✅ Verificar email em `frentexeservicos@gmail.com`

4. ⏸️ (Futuro) Verificar domínio no Resend para produção

---

**Atualizado**: 2025-10-18
**Status**: ✅ Solução implementada
