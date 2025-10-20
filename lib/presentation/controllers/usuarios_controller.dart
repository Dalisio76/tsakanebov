import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../data/models/user_profile_model.dart';
import '../../data/services/auth_service.dart';

class UsuariosController extends GetxController {
  final AuthService _authService = AuthService();

  // Controllers
  final nomeCompletoController = TextEditingController();
  final telefoneController = TextEditingController();

  // Estado
  var isLoading = false.obs;
  var usuarios = <UserProfileModel>[].obs;
  var usuarioEditando = Rxn<UserProfileModel>();
  var roleEditando = 'funcionario'.obs;
  var ativoEditando = true.obs;

  @override
  void onInit() {
    super.onInit();
    carregarUsuarios();

    // Se recebeu argumentos (usuário para editar)
    if (Get.arguments != null && Get.arguments is UserProfileModel) {
      preencherFormulario(Get.arguments as UserProfileModel);
    }
  }

  Future<void> carregarUsuarios() async {
    try {
      isLoading.value = true;
      final lista = await _authService.listarUsuarios();
      usuarios.value = lista;
    } catch (e) {
      Get.snackbar(
        'Erro',
        'Erro ao carregar usuários: $e',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    } finally {
      isLoading.value = false;
    }
  }

  void preencherFormulario(UserProfileModel usuario) {
    usuarioEditando.value = usuario;
    nomeCompletoController.text = usuario.nomeCompleto;
    telefoneController.text = usuario.telefone ?? '';
    roleEditando.value = usuario.role;
    ativoEditando.value = usuario.ativo;
  }

  Future<void> salvarEdicao() async {
    if (!validarFormulario()) return;

    try {
      isLoading.value = true;

      final usuarioAtualizado = usuarioEditando.value!.copyWith(
        nomeCompleto: nomeCompletoController.text.trim(),
        telefone: telefoneController.text.trim().isEmpty
            ? null
            : telefoneController.text.trim(),
        role: roleEditando.value,
        ativo: ativoEditando.value,
      );

      await _authService.atualizarPerfil(usuarioAtualizado);

      Get.snackbar(
        'Sucesso',
        'Usuário atualizado com sucesso!',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.green,
        colorText: Colors.white,
      );

      Get.back(result: true);
      carregarUsuarios();
    } catch (e) {
      Get.snackbar(
        'Erro',
        'Erro ao salvar: $e',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    } finally {
      isLoading.value = false;
    }
  }

  bool validarFormulario() {
    if (nomeCompletoController.text.trim().isEmpty) {
      Get.snackbar(
        'Atenção',
        'Nome completo é obrigatório',
        snackPosition: SnackPosition.BOTTOM,
      );
      return false;
    }

    return true;
  }

  @override
  void onClose() {
    nomeCompletoController.dispose();
    telefoneController.dispose();
    super.onClose();
  }
}
