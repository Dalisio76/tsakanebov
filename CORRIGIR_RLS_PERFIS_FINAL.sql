-- ============================================
-- SOLUÇÃO DEFINITIVA: Remover Recursão RLS
-- ============================================

-- 1. REMOVER todas as políticas
DROP POLICY IF EXISTS "Usuários podem ver próprio perfil" ON perfis_usuario;
DROP POLICY IF EXISTS "Usuários podem atualizar próprio perfil" ON perfis_usuario;
DROP POLICY IF EXISTS "Admins podem ver todos" ON perfis_usuario;
DROP POLICY IF EXISTS "Admins podem atualizar todos" ON perfis_usuario;
DROP POLICY IF EXISTS "usuarios_podem_ver_proprio_perfil" ON perfis_usuario;
DROP POLICY IF EXISTS "usuarios_podem_atualizar_proprio_perfil" ON perfis_usuario;
DROP POLICY IF EXISTS "admins_podem_ver_todos" ON perfis_usuario;
DROP POLICY IF EXISTS "admins_podem_atualizar_todos" ON perfis_usuario;

-- 2. REMOVER função is_admin
DROP FUNCTION IF EXISTS is_admin() CASCADE;

-- 3. CRIAR nova função que usa SECURITY DEFINER para bypass RLS
CREATE OR REPLACE FUNCTION get_user_role(user_id UUID)
RETURNS TEXT AS $$
BEGIN
  RETURN (SELECT role FROM perfis_usuario WHERE id = user_id LIMIT 1);
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- 4. CRIAR políticas SIMPLES sem recursão

-- Usuários podem ver seu próprio perfil
CREATE POLICY "select_own_profile"
ON perfis_usuario
FOR SELECT
USING (auth.uid() = id);

-- Usuários podem atualizar seu próprio perfil
CREATE POLICY "update_own_profile"
ON perfis_usuario
FOR UPDATE
USING (auth.uid() = id);

-- 5. GARANTIR que RLS está ativo
ALTER TABLE perfis_usuario ENABLE ROW LEVEL SECURITY;

-- ============================================
-- TESTE: Agora deve funcionar sem recursão!
-- ============================================
