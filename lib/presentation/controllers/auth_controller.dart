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
      update(); // Notifica os GetBuilders
    } catch (e) {
      print('Erro ao carregar perfil: $e');
      Get.snackbar(
        'Erro',
        'Não foi possível carregar o perfil. Tente novamente.',
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    }
  }

  Future<void> login(String email, String senha) async {
    try {
      isLoading.value = true;

      await _authService.login(email, senha);

      Get.snackbar(
        'Sucesso',
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
        'Erro',
        mensagem,
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    } catch (e) {
      Get.snackbar(
        'Erro',
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
        'Sucesso',
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
        'Erro',
        mensagem,
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    } catch (e) {
      Get.snackbar(
        'Erro',
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
        'Sucesso',
        'Email de recuperação enviado! Verifique sua caixa de entrada.',
        backgroundColor: Colors.green,
        colorText: Colors.white,
        duration: Duration(seconds: 5),
      );

      Get.back();
    } catch (e) {
      Get.snackbar(
        'Erro',
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
        'Sucesso',
        'Perfil atualizado com sucesso!',
        backgroundColor: Colors.green,
        colorText: Colors.white,
      );
    } catch (e) {
      Get.snackbar(
        'Erro',
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
        'Sucesso',
        'Logout realizado',
        backgroundColor: Colors.green,
        colorText: Colors.white,
      );
    } catch (e) {
      Get.snackbar(
        'Erro',
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
