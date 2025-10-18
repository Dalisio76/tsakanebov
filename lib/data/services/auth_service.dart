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

  // Buscar perfil do usuário via Edge Function (bypass RLS)
  Future<UserProfileModel?> buscarPerfil(String userId) async {
    try {
      final response = await _supabase.functions.invoke(
        'get-perfil',
        queryParameters: {'userId': userId},
      );

      if (response.status == 200 && response.data != null) {
        return UserProfileModel.fromJson(response.data);
      } else {
        print('Erro ao buscar perfil: ${response.status} - ${response.data}');
        return null;
      }
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

  // Listar todos os usuários (apenas admin) via Edge Function
  Future<List<UserProfileModel>> listarUsuarios() async {
    try {
      final response = await _supabase.functions.invoke('listar-usuarios');

      if (response.status == 200 && response.data != null) {
        return (response.data as List)
            .map((json) => UserProfileModel.fromJson(json))
            .toList();
      } else {
        print('Erro ao listar usuários: ${response.status} - ${response.data}');
        return [];
      }
    } catch (e) {
      print('Erro ao listar usuários: $e');
      return [];
    }
  }
}
