# 🔐 SISTEMA DE LOGIN COMPLETO

## 📦 PARTE 1: CONFIGURAÇÃO SUPABASE

### A. SQL - Criar tabelas e políticas

**Executar no SQL Editor do Supabase:**

```sql
-- 1. Habilitar extensão para UUID
CREATE EXTENSION IF NOT EXISTS "uuid-ossp";

-- 2. Tabela de perfis de usuário
CREATE TABLE perfis_usuario (
  id UUID PRIMARY KEY REFERENCES auth.users(id) ON DELETE CASCADE,
  nome_completo VARCHAR(100) NOT NULL,
  email VARCHAR(255) UNIQUE NOT NULL,
  telefone VARCHAR(20),
  avatar_url TEXT,
  role VARCHAR(20) DEFAULT 'funcionario' CHECK (role IN ('admin', 'funcionario', 'veterinario')),
  fazenda_nome VARCHAR(100),
  ativo BOOLEAN DEFAULT TRUE,
  criado_em TIMESTAMP DEFAULT NOW(),
  atualizado_em TIMESTAMP DEFAULT NOW()
);

-- 3. Trigger para criar perfil automaticamente quando usuário se cadastra
CREATE OR REPLACE FUNCTION public.handle_new_user()
RETURNS TRIGGER AS $$
BEGIN
  INSERT INTO public.perfis_usuario (id, nome_completo, email)
  VALUES (
    new.id,
    COALESCE(new.raw_user_meta_data->>'nome_completo', 'Usuário'),
    new.email
  );
  RETURN new;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- Trigger que executa a função quando novo usuário é criado
DROP TRIGGER IF EXISTS on_auth_user_created ON auth.users;
CREATE TRIGGER on_auth_user_created
  AFTER INSERT ON auth.users
  FOR EACH ROW EXECUTE FUNCTION public.handle_new_user();

-- 4. RLS (Row Level Security) - Políticas de segurança
ALTER TABLE perfis_usuario ENABLE ROW LEVEL SECURITY;

-- Usuários podem ver seu próprio perfil
CREATE POLICY "Usuários podem ver próprio perfil"
ON perfis_usuario FOR SELECT
USING (auth.uid() = id);

-- Usuários podem atualizar seu próprio perfil
CREATE POLICY "Usuários podem atualizar próprio perfil"
ON perfis_usuario FOR UPDATE
USING (auth.uid() = id);

-- Admins podem ver todos os perfis
CREATE POLICY "Admins podem ver todos"
ON perfis_usuario FOR SELECT
USING (
  EXISTS (
    SELECT 1 FROM perfis_usuario
    WHERE id = auth.uid() AND role = 'admin'
  )
);

-- Admins podem atualizar qualquer perfil
CREATE POLICY "Admins podem atualizar todos"
ON perfis_usuario FOR UPDATE
USING (
  EXISTS (
    SELECT 1 FROM perfis_usuario
    WHERE id = auth.uid() AND role = 'admin'
  )
);

-- 5. Função para verificar se usuário é admin
CREATE OR REPLACE FUNCTION is_admin()
RETURNS BOOLEAN AS $$
BEGIN
  RETURN EXISTS (
    SELECT 1 FROM perfis_usuario
    WHERE id = auth.uid() AND role = 'admin'
  );
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- 6. Atualizar timestamp automaticamente
CREATE OR REPLACE FUNCTION update_updated_at_column()
RETURNS TRIGGER AS $$
BEGIN
   NEW.atualizado_em = NOW();
   RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER update_perfis_usuario_updated_at
BEFORE UPDATE ON perfis_usuario
FOR EACH ROW
EXECUTE FUNCTION update_updated_at_column();

-- 7. Criar primeiro admin (MUDE O EMAIL E SENHA)
-- Após cadastrar o primeiro usuário no app, execute:
-- UPDATE perfis_usuario SET role = 'admin' WHERE email = 'seu@email.com';
```

---

## 📦 PARTE 2: MODELS E SERVICES

### A. Criar `lib/data/models/user_profile_model.dart`

```dart
class UserProfileModel {
  final String id;
  final String nomeCompleto;
  final String email;
  final String? telefone;
  final String? avatarUrl;
  final String role;
  final String? fazendaNome;
  final bool ativo;
  final DateTime? criadoEm;
  final DateTime? atualizadoEm;

  UserProfileModel({
    required this.id,
    required this.nomeCompleto,
    required this.email,
    this.telefone,
    this.avatarUrl,
    required this.role,
    this.fazendaNome,
    required this.ativo,
    this.criadoEm,
    this.atualizadoEm,
  });

  factory UserProfileModel.fromJson(Map<String, dynamic> json) {
    return UserProfileModel(
      id: json['id'],
      nomeCompleto: json['nome_completo'] ?? '',
      email: json['email'] ?? '',
      telefone: json['telefone'],
      avatarUrl: json['avatar_url'],
      role: json['role'] ?? 'funcionario',
      fazendaNome: json['fazenda_nome'],
      ativo: json['ativo'] ?? true,
      criadoEm: json['criado_em'] != null ? DateTime.parse(json['criado_em']) : null,
      atualizadoEm: json['atualizado_em'] != null ? DateTime.parse(json['atualizado_em']) : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'nome_completo': nomeCompleto,
      'email': email,
      'telefone': telefone,
      'avatar_url': avatarUrl,
      'role': role,
      'fazenda_nome': fazendaNome,
      'ativo': ativo,
    };
  }

  bool get isAdmin => role == 'admin';
  bool get isFuncionario => role == 'funcionario';
  bool get isVeterinario => role == 'veterinario';

  String get roleNome {
    switch (role) {
      case 'admin':
        return 'Administrador';
      case 'veterinario':
        return 'Veterinário';
      default:
        return 'Funcionário';
    }
  }

  String get iniciais {
    List<String> partes = nomeCompleto.split(' ');
    if (partes.length >= 2) {
      return '${partes[0][0]}${partes[1][0]}'.toUpperCase();
    }
    return nomeCompleto.isNotEmpty ? nomeCompleto[0].toUpperCase() : 'U';
  }
}
```

---

### B. Criar `lib/data/services/auth_service.dart`

```dart
import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/user_profile_model.dart';

class AuthService {
  final _supabase = Supabase.instance.client;

  // Obter usuário logado
  User? get currentUser => _supabase.auth.currentUser;

  // Stream de mudanças de autenticação
  Stream<AuthState> get authStateChanges => _supabase.auth.onAuthStateChange;

  // Login com email e senha
  Future<AuthResponse> login(String email, String senha) async {
    try {
      final response = await _supabase.auth.signInWithPassword(
        email: email,
        password: senha,
      );
      return response;
    } catch (e) {
      print('Erro no login: $e');
      rethrow;
    }
  }

  // Cadastro de novo usuário
  Future<AuthResponse> cadastrar({
    required String email,
    required String senha,
    required String nomeCompleto,
  }) async {
    try {
      final response = await _supabase.auth.signUp(
        email: email,
        password: senha,
        data: {
          'nome_completo': nomeCompleto,
        },
      );
      return response;
    } catch (e) {
      print('Erro no cadastro: $e');
      rethrow;
    }
  }

  // Recuperar senha
  Future<void> recuperarSenha(String email) async {
    try {
      await _supabase.auth.resetPasswordForEmail(
        email,
        redirectTo: 'io.supabase.gestaogado://reset-password',
      );
    } catch (e) {
      print('Erro ao recuperar senha: $e');
      rethrow;
    }
  }

  // Atualizar senha
  Future<void> atualizarSenha(String novaSenha) async {
    try {
      await _supabase.auth.updateUser(
        UserAttributes(password: novaSenha),
      );
    } catch (e) {
      print('Erro ao atualizar senha: $e');
      rethrow;
    }
  }

  // Buscar perfil do usuário
  Future<UserProfileModel?> buscarPerfil(String userId) async {
    try {
      final response = await _supabase
          .from('perfis_usuario')
          .select()
          .eq('id', userId)
          .single();

      return UserProfileModel.fromJson(response);
    } catch (e) {
      print('Erro ao buscar perfil: $e');
      return null;
    }
  }

  // Atualizar perfil
  Future<void> atualizarPerfil(UserProfileModel perfil) async {
    try {
      await _supabase
          .from('perfis_usuario')
          .update(perfil.toJson())
          .eq('id', perfil.id);
    } catch (e) {
      print('Erro ao atualizar perfil: $e');
      rethrow;
    }
  }

  // Logout
  Future<void> logout() async {
    try {
      await _supabase.auth.signOut();
    } catch (e) {
      print('Erro ao fazer logout: $e');
      rethrow;
    }
  }

  // Verificar se está logado
  bool get isLoggedIn => currentUser != null;

  // Listar todos os usuários (apenas admin)
  Future<List<UserProfileModel>> listarUsuarios() async {
    try {
      final response = await _supabase
          .from('perfis_usuario')
          .select()
          .order('criado_em', ascending: false);

      return (response as List)
          .map((json) => UserProfileModel.fromJson(json))
          .toList();
    } catch (e) {
      print('Erro ao listar usuários: $e');
      return [];
    }
  }
}
```

---

## 📦 PARTE 3: CONTROLLERS

### A. Criar `lib/presentation/controllers/auth_controller.dart`

```dart
import 'package:get/get.dart';
import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../data/models/user_profile_model.dart';
import '../../data/services/auth_service.dart';

class AuthController extends GetxController {
  final _authService = AuthService();

  var isLoading = false.obs;
  var usuarioLogado = Rx<User?>(null);
  var perfilUsuario = Rx<UserProfileModel?>(null);

  @override
  void onInit() {
    super.onInit();
    _verificarLogin();
    _ouvirMudancasAuth();
  }

  void _verificarLogin() async {
    usuarioLogado.value = _authService.currentUser;
    
    if (usuarioLogado.value != null) {
      await carregarPerfil();
    }
  }

  void _ouvirMudancasAuth() {
    _authService.authStateChanges.listen((data) async {
      usuarioLogado.value = data.session?.user;
      
      if (data.session != null && usuarioLogado.value != null) {
        await carregarPerfil();
        Get.offAllNamed('/dashboard');
      } else {
        perfilUsuario.value = null;
        Get.offAllNamed('/login');
      }
    });
  }

  Future<void> carregarPerfil() async {
    if (usuarioLogado.value == null) return;
    
    try {
      final perfil = await _authService.buscarPerfil(usuarioLogado.value!.id);
      perfilUsuario.value = perfil;
    } catch (e) {
      print('Erro ao carregar perfil: $e');
    }
  }

  Future<void> login(String email, String senha) async {
    try {
      isLoading.value = true;
      
      await _authService.login(email, senha);
      
      Get.snackbar(
        '✅ Sucesso',
        'Login realizado com sucesso!',
        backgroundColor: Colors.green,
        colorText: Colors.white,
      );
    } on AuthException catch (e) {
      String mensagem = 'Erro ao fazer login';
      
      if (e.message.contains('Invalid login credentials')) {
        mensagem = 'Email ou senha incorretos';
      } else if (e.message.contains('Email not confirmed')) {
        mensagem = 'Confirme seu email antes de fazer login';
      }
      
      Get.snackbar(
        '❌ Erro',
        mensagem,
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    } catch (e) {
      Get.snackbar(
        '❌ Erro',
        'Erro ao fazer login: $e',
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> cadastrar(String email, String senha, String nomeCompleto) async {
    try {
      isLoading.value = true;
      
      await _authService.cadastrar(
        email: email,
        senha: senha,
        nomeCompleto: nomeCompleto,
      );
      
      Get.snackbar(
        '✅ Sucesso',
        'Cadastro realizado! Verifique seu email.',
        backgroundColor: Colors.green,
        colorText: Colors.white,
        duration: Duration(seconds: 5),
      );
      
      Get.offAllNamed('/login');
    } on AuthException catch (e) {
      String mensagem = 'Erro ao cadastrar';
      
      if (e.message.contains('already registered')) {
        mensagem = 'Este email já está cadastrado';
      } else if (e.message.contains('Password')) {
        mensagem = 'A senha deve ter no mínimo 6 caracteres';
      }
      
      Get.snackbar(
        '❌ Erro',
        mensagem,
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    } catch (e) {
      Get.snackbar(
        '❌ Erro',
        'Erro ao cadastrar: $e',
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> recuperarSenha(String email) async {
    try {
      isLoading.value = true;
      
      await _authService.recuperarSenha(email);
      
      Get.snackbar(
        '✅ Sucesso',
        'Email de recuperação enviado! Verifique sua caixa de entrada.',
        backgroundColor: Colors.green,
        colorText: Colors.white,
        duration: Duration(seconds: 5),
      );
      
      Get.back();
    } catch (e) {
      Get.snackbar(
        '❌ Erro',
        'Erro ao enviar email de recuperação: $e',
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> atualizarPerfil(UserProfileModel perfil) async {
    try {
      isLoading.value = true;
      
      await _authService.atualizarPerfil(perfil);
      perfilUsuario.value = perfil;
      
      Get.snackbar(
        '✅ Sucesso',
        'Perfil atualizado com sucesso!',
        backgroundColor: Colors.green,
        colorText: Colors.white,
      );
    } catch (e) {
      Get.snackbar(
        '❌ Erro',
        'Erro ao atualizar perfil: $e',
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> logout() async {
    try {
      await _authService.logout();
      
      Get.snackbar(
        '✅ Sucesso',
        'Logout realizado',
        backgroundColor: Colors.green,
        colorText: Colors.white,
      );
    } catch (e) {
      Get.snackbar(
        '❌ Erro',
        'Erro ao fazer logout: $e',
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    }
  }

  bool get isAdmin => perfilUsuario.value?.isAdmin ?? false;
  bool get isFuncionario => perfilUsuario.value?.isFuncionario ?? false;
  bool get isVeterinario => perfilUsuario.value?.isVeterinario ?? false;
}
```

---

## 📦 PARTE 4: VIEWS

### A. Criar `lib/presentation/views/login_view.dart`

```dart
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/auth_controller.dart';

class LoginView extends GetView<AuthController> {
  final emailController = TextEditingController();
  final senhaController = TextEditingController();
  final _formKey = GlobalKey<FormState>();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Colors.green.shade700, Colors.green.shade400],
          ),
        ),
        child: Center(
          child: SingleChildScrollView(
            padding: EdgeInsets.all(32),
            child: Container(
              constraints: BoxConstraints(maxWidth: 400),
              child: Card(
                elevation: 8,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Padding(
                  padding: EdgeInsets.all(32),
                  child: Form(
                    key: _formKey,
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        // Logo
                        Text('🐄', style: TextStyle(fontSize: 80)),
                        SizedBox(height: 16),
                        Text(
                          'Gestão de Gado',
                          style: TextStyle(
                            fontSize: 28,
                            fontWeight: FontWeight.bold,
                            color: Colors.green.shade800,
                          ),
                        ),
                        Text(
                          'Sistema Completo',
                          style: TextStyle(
                            fontSize: 14,
                            color: Colors.grey.shade600,
                          ),
                        ),
                        SizedBox(height: 32),

                        // Email
                        TextFormField(
                          controller: emailController,
                          decoration: InputDecoration(
                            labelText: 'Email',
                            hintText: 'seu@email.com',
                            prefixIcon: Icon(Icons.email),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                          keyboardType: TextInputType.emailAddress,
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Informe o email';
                            }
                            if (!value.contains('@')) {
                              return 'Email inválido';
                            }
                            return null;
                          },
                        ),
                        SizedBox(height: 16),

                        // Senha
                        Obx(() => TextFormField(
                          controller: senhaController,
                          obscureText: true,
                          decoration: InputDecoration(
                            labelText: 'Senha',
                            hintText: '••••••',
                            prefixIcon: Icon(Icons.lock),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Informe a senha';
                            }
                            if (value.length < 6) {
                              return 'Senha deve ter no mínimo 6 caracteres';
                            }
                            return null;
                          },
                        )),
                        SizedBox(height: 8),

                        // Esqueci senha
                        Align(
                          alignment: Alignment.centerRight,
                          child: TextButton(
                            onPressed: () => Get.toNamed('/recuperar-senha'),
                            child: Text('Esqueci minha senha'),
                          ),
                        ),
                        SizedBox(height: 24),

                        // Botão entrar
                        Obx(() => SizedBox(
                          width: double.infinity,
                          height: 50,
                          child: ElevatedButton(
                            onPressed: controller.isLoading.value
                                ? null
                                : () {
                                    if (_formKey.currentState!.validate()) {
                                      controller.login(
                                        emailController.text.trim(),
                                        senhaController.text,
                                      );
                                    }
                                  },
                            style: ElevatedButton.styleFrom(
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                            ),
                            child: controller.isLoading.value
                                ? CircularProgressIndicator(color: Colors.white)
                                : Text(
                                    'Entrar',
                                    style: TextStyle(fontSize: 18),
                                  ),
                          ),
                        )),
                        SizedBox(height: 16),

                        // Cadastrar
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text('Não tem conta?'),
                            TextButton(
                              onPressed: () => Get.toNamed('/cadastro'),
                              child: Text('Cadastre-se'),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
```

---

### B. Criar `lib/presentation/views/cadastro_view.dart`

```dart
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/auth_controller.dart';

class CadastroView extends GetView<AuthController> {
  final nomeController = TextEditingController();
  final emailController = TextEditingController();
  final senhaController = TextEditingController();
  final confirmarSenhaController = TextEditingController();
  final _formKey = GlobalKey<FormState>();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Criar Conta'),
        backgroundColor: Colors.green,
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Colors.green.shade50, Colors.white],
          ),
        ),
        child: Center(
          child: SingleChildScrollView(
            padding: EdgeInsets.all(32),
            child: Container(
              constraints: BoxConstraints(maxWidth: 400),
              child: Card(
                elevation: 8,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Padding(
                  padding: EdgeInsets.all(32),
                  child: Form(
                    key: _formKey,
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text('🐄', style: TextStyle(fontSize: 60)),
                        SizedBox(height: 16),
                        Text(
                          'Criar Conta',
                          style: TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        SizedBox(height: 24),

                        // Nome
                        TextFormField(
                          controller: nomeController,
                          decoration: InputDecoration(
                            labelText: 'Nome Completo',
                            prefixIcon: Icon(Icons.person),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Informe o nome';
                            }
                            return null;
                          },
                        ),
                        SizedBox(height: 16),

                        // Email
                        TextFormField(
                          controller: emailController,
                          decoration: InputDecoration(
                            labelText: 'Email',
                            prefixIcon: Icon(Icons.email),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                          keyboardType: TextInputType.emailAddress,
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Informe o email';
                            }
                            if (!value.contains('@')) {
                              return 'Email inválido';
                            }
                            return null;
                          },
                        ),
                        SizedBox(height: 16),

                        // Senha
                        TextFormField(
                          controller: senhaController,
                          obscureText: true,
                          decoration: InputDecoration(
                            labelText: 'Senha',
                            prefixIcon: Icon(Icons.lock),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Informe a senha';
                            }
                            if (value.length < 6) {
                              return 'Senha deve ter no mínimo 6 caracteres';
                            }
                            return null;
                          },
                        ),
                        SizedBox(height: 16),

                        // Confirmar senha
                        TextFormField(
                          controller: confirmarSenhaController,
                          obscureText: true,
                          decoration: InputDecoration(
                            labelText: 'Confirmar Senha',
                            prefixIcon: Icon(Icons.lock_outline),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                          validator: (value) {
                            if (value != senhaController.text) {
                              return 'Senhas não conferem';
                            }
                            return null;
                          },
                        ),
                        SizedBox(height: 24),

                        // Botão cadastrar
                        Obx(() => SizedBox(
                          width: double.infinity,
                          height: 50,
                          child: ElevatedButton(
                            onPressed: controller.isLoading.value
                                ? null
                                : () {
                                    if (_formKey.currentState!.validate()) {
                                      controller.cadastrar(
                                        emailController.text.trim(),
                                        senhaController.text,
                                        nomeController.text.trim(),
                                      );
                                    }
                                  },
                            style: ElevatedButton.styleFrom(
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                            ),
                            child: controller.isLoading.value
                                ? CircularProgressIndicator(color: Colors.white)
                                : Text(
                                    'Criar Conta',
                                    style: TextStyle(fontSize: 18),
                                  ),
                          ),
                        )),
                        SizedBox(height: 16),

                        // Já tem conta
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text('Já tem conta?'),
                            TextButton(
                              onPressed: () => Get.back(),
                              child: Text('Fazer Login'),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
```

---

### C. Criar `lib/presentation/views/recuperar_senha_view.dart`

```dart
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/auth_controller.dart';

class RecuperarSenhaView extends GetView<AuthController> {
  final emailController = TextEditingController();
  final _formKey = GlobalKey<FormState>();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Recuperar Senha'),
        backgroundColor: Colors.green,
      ),
      body: Center(
        child: SingleChildScrollView(
          padding: EdgeInsets.all(32),
          child: Container(
            constraints: BoxConstraints(maxWidth: 400),
            child: Card(
              elevation: 8,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              child: Padding(
                padding: EdgeInsets.all(32),
                child: Form(
                  key: _formKey,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        Icons.lock_reset,
                        size: 80,
                        color: Colors.green,
                      ),
                      SizedBox(height: 16),
                      Text(
                        'Recuperar Senha',
                        style: TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      SizedBox(height: 8),
                      Text(
                        'Digite seu email para receber instruções de recuperação',
                        textAlign: TextAlign.center,
                        style: TextStyle(color: Colors.grey.shade600),
                      ),
                      SizedBox(height: 24),

                      // Email
                      TextFormField(
                        controller: emailController,
                        decoration: InputDecoration(
                          labelText: 'Email',
                          prefixIcon: Icon(Icons.email),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        keyboardType: TextInputType.emailAddress,
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Informe o email';
                          }
                          if (!value.contains('@')) {
                            return 'Email inválido';
                          }
                          return null;
                        },
                      ),
                      SizedBox(height: 24),

                      // Botão enviar
                      Obx(() => SizedBox(
                        width: double.infinity,
                        height: 50,
                        child: ElevatedButton(
                          onPressed: controller.isLoading.value
                              ? null
                              : () {
                                  if (_formKey.currentState!.validate()) {
                                    controller.recuperarSenha(
                                      emailController.text.trim(),
                                    );
                                  }
                                },
                          style: ElevatedButton.styleFrom(
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                          child: controller.isLoading.value
                              ? CircularProgressIndicator(color: Colors.white)
                              : Text(
                                  'Enviar Email',
                                  style: TextStyle(fontSize: 18),
                                ),
                        ),
                      )),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
```

---

### D. Criar `lib/presentation/views/perfil_view.dart`

```dart
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/auth_controller.dart';
import '../widgets/app_drawer.dart';

class PerfilView extends GetView<AuthController> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Meu Perfil'),
        actions: [
          IconButton(
            icon: Icon(Icons.exit_to_app),
            onPressed: () {
              Get.defaultDialog(
                title: 'Sair',
                middleText: 'Deseja realmente sair?',
                textConfirm: 'Sim',
                textCancel: 'Não',
                confirmTextColor: Colors.white,
                onConfirm: () {
                  Get.back();
                  controller.logout();
                },
              );
            },
            tooltip: 'Sair',
          ),
        ],
      ),
      drawer: AppDrawer(),
      body: Obx(() {
        final perfil = controller.perfilUsuario.value;

        if (perfil == null) {
          return Center(child: CircularProgressIndicator());
        }

        return SingleChildScrollView(
          padding: EdgeInsets.all(16),
          child: Column(
            children: [
              // Avatar
              Container(
                width: 120,
                height: 120,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: LinearGradient(
                    colors: [Colors.green.shade700, Colors.green.shade400],
                  ),
                ),
                child: Center(
                  child: Text(
                    perfil.iniciais,
                    style: TextStyle(
                      fontSize: 48,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
              SizedBox(height: 16),

              // Nome
              Text(
                perfil.nomeCompleto,
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),
              SizedBox(height: 8),

              // Role
              Container(
                padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                decoration: BoxDecoration(
                  color: Colors.green.shade100,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  perfil.roleNome,
                  style: TextStyle(
                    color: Colors.green.shade800,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              SizedBox(height: 32),

              // Informações
              Card(
                child: Column(
                  children: [
                    ListTile(
                      leading: Icon(Icons.email, color: Colors.green),
                      title: Text('Email'),
                      subtitle: Text(perfil.email),
                    ),
                    Divider(height: 1),
                    if (perfil.telefone != null)
                      ListTile(
                        leading: Icon(Icons.phone, color: Colors.green),
                        title: Text('Telefone'),
                        subtitle: Text(perfil.telefone!),
                      ),
                    if (perfil.fazendaNome != null) ...[
                      Divider(height: 1),
                      ListTile(
                        leading: Icon(Icons.home, color: Colors.green),
                        title: Text('Fazenda'),
                        subtitle: Text(perfil.fazendaNome!),
                      ),
                    ],
                    Divider(height: 1),
                    ListTile(
                      leading: Icon(Icons.shield, color: Colors.green),
                      title: Text('Status'),
                      subtitle: Text(perfil.ativo ? 'Ativo' : 'Inativo'),
                    ),
                  ],
                ),
              ),
              SizedBox(height: 16),

              // Botão editar
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: () {
                    // TODO: Implementar edição de perfil
                    Get.snackbar('Em breve', 'Funcionalidade em desenvolvimento');
                  },
                  icon: Icon(Icons.edit),
                  label: Text('Editar Perfil'),
                  style: ElevatedButton.styleFrom(
                    padding: EdgeInsets.symmetric(vertical: 16),
                  ),
                ),
              ),
            ],
          ),
        );
      }),
    );
  }
}
```

---

## 📦 PARTE 5: BINDINGS E ROTAS

### A. Criar `lib/presentation/bindings/auth_binding.dart`

```dart
import 'package:get/get.dart';
import '../controllers/auth_controller.dart';

class AuthBinding extends Bindings {
  @override
  void dependencies() {
    Get.put<AuthController>(AuthController(), permanent: true);
  }
}
```

---

### B. Editar `lib/routes/app_routes.dart`

```dart
class AppRoutes {
  // Auth
  static const LOGIN = '/login';
  static const CADASTRO = '/cadastro';
  static const RECUPERAR_SENHA = '/recuperar-senha';
  static const PERFIL = '/perfil';
  
  // ... outras rotas existentes
}
```

---

### C. Editar `lib/routes/app_pages.dart`

```dart
// Adicionar imports
import '../presentation/views/login_view.dart';
import '../presentation/views/cadastro_view.dart';
import '../presentation/views/recuperar_senha_view.dart';
import '../presentation/views/perfil_view.dart';
import '../presentation/bindings/auth_binding.dart';

class AppPages {
  static final routes = [
    // Auth
    GetPage(
      name: AppRoutes.LOGIN,
      page: () => LoginView(),
      binding: AuthBinding(),
    ),
    GetPage(
      name: AppRoutes.CADASTRO,
      page: () => CadastroView(),
      binding: AuthBinding(),
    ),
    GetPage(
      name: AppRoutes.RECUPERAR_SENHA,
      page: () => RecuperarSenhaView(),
      binding: AuthBinding(),
    ),
    GetPage(
      name: AppRoutes.PERFIL,
      page: () => PerfilView(),
      binding: AuthBinding(),
    ),
    
    // ... outras rotas existentes
  ];
}
```

---

### D. Editar `lib/main.dart`

```dart
void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  await Supabase.initialize(
    url: SupabaseConfig.url,
    anonKey: SupabaseConfig.anonKey,
  );
  
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      title: 'Gestão de Gado',
      theme: ThemeData(
        primarySwatch: Colors.green,
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      debugShowCheckedModeBanner: false,
      initialBinding: AuthBinding(), // ← ADICIONAR
      initialRoute: AppRoutes.LOGIN, // ← MUDAR PARA LOGIN
      getPages: AppPages.routes,
    );
  }
}
```

---

### E. Adicionar no menu `app_drawer.dart`

```dart
// No header, após o nome do sistema:
Obx(() {
  final auth = Get.find<AuthController>();
  final perfil = auth.perfilUsuario.value;
  
  return Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Text('🐄', style: TextStyle(fontSize: 48)),
      SizedBox(height: 8),
      Text(
        'Gestão de Gado',
        style: TextStyle(
          fontSize: 20,
          fontWeight: FontWeight.bold,
          color: Colors.white,
        ),
      ),
      if (perfil != null) ...[
        SizedBox(height: 4),
        Text(
          perfil.nomeCompleto,
          style: TextStyle(
            fontSize: 14,
            color: Colors.white.withOpacity(0.9),
          ),
        ),
        Text(
          perfil.roleNome,
          style: TextStyle(
            fontSize: 12,
            color: Colors.white.withOpacity(0.7),
          ),
        ),
      ],
    ],
  );
}),

// Adicionar antes de Configurações:
_buildMenuItem(
  icon: Icons.person,
  titulo: 'Meu Perfil',
  rota: '/perfil',
  cor: Colors.blue,
),
```

---

## ✅ CHECKLIST COMPLETO

### SQL:
- [ ] Executar SQL completo no Supabase
- [ ] Verificar se trigger foi criado

### Models e Services:
- [ ] Criar `user_profile_model.dart`
- [ ] Criar `auth_service.dart`

### Controllers:
- [ ] Criar `auth_controller.dart`

### Views:
- [ ] Criar `login_view.dart`
- [ ] Criar `cadastro_view.dart`
- [ ] Criar `recuperar_senha_view.dart`
- [ ] Criar `perfil_view.dart`

### Config:
- [ ] Criar `auth_binding.dart`
- [ ] Editar `app_routes.dart`
- [ ] Editar `app_pages.dart`
- [ ] Editar `main.dart` (initialRoute e binding)
- [ ] Editar `app_drawer.dart` (header e item perfil)

### Teste:
- [ ] `flutter run -d chrome`

---

## 🧪 FLUXO DE TESTE

### 1. Cadastro:
- Abrir app → Tela de login
- "Cadastre-se"
- Preencher dados
- Criar conta ✅
- Verificar email (Supabase envia)

### 2. Login:
- Email + senha
- Entrar ✅
- Vai para Dashboard

### 3. Perfil:
- Menu → Meu Perfil
- Ver informações ✅

### 4. Criar Admin:
- SQL Editor:
```sql
UPDATE perfis_usuario 
SET role = 'admin' 
WHERE email = 'seu@email.com';
```

### 5. Logout:
- Perfil → Sair
- Volta para login ✅

---

## 🎉 FUNCIONALIDADES

✅ Login completo
✅ Cadastro com validação
✅ Recuperação de senha
✅ Perfis de usuário
✅ Roles (admin, funcionário, veterinário)
✅ Proteção automática de rotas
✅ Persistência de sessão
✅ Logout
✅ Menu com info do usuário
✅ Trigger automático de perfil

---

## 💬 QUANDO TERMINAR

Me avise:

> "Login implementado! Testado e funcionando!"

Ou:

> "Erro em [parte]: [mensagem]"

Implemente e teste! 🔐✨