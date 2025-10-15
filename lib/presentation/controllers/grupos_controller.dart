import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../data/models/grupo_model.dart';
import '../../data/services/grupo_service.dart';

class GruposController extends GetxController {
  final GrupoService _service = GrupoService();

  // Estado
  var grupos = <GrupoModel>[].obs;
  var isLoading = false.obs;
  var errorMessage = ''.obs;

  @override
  void onInit() {
    super.onInit();
    carregarGrupos();
  }

  // Carregar lista de grupos
  Future<void> carregarGrupos() async {
    try {
      isLoading.value = true;
      errorMessage.value = '';

      grupos.value = await _service.listarGrupos();
    } catch (e) {
      errorMessage.value = e.toString();
      Get.snackbar(
        'Erro',
        'Erro ao carregar grupos: $e',
        snackPosition: SnackPosition.BOTTOM,
      );
    } finally {
      isLoading.value = false;
    }
  }

  // Buscar por nome
  Future<void> buscarPorNome(String nome) async {
    if (nome.isEmpty) {
      carregarGrupos();
      return;
    }

    try {
      isLoading.value = true;
      grupos.value = await _service.buscarPorNome(nome);
    } catch (e) {
      Get.snackbar(
        'Erro',
        'Erro ao buscar: $e',
        snackPosition: SnackPosition.BOTTOM,
      );
    } finally {
      isLoading.value = false;
    }
  }

  // Deletar grupo
  Future<void> deletarGrupo(GrupoModel grupo) async {
    try {
      final confirmado = await Get.dialog<bool>(
        AlertDialog(
          title: const Text('Confirmar'),
          content: Text('Deseja realmente excluir "${grupo.nome}"?'),
          actions: [
            TextButton(
              onPressed: () => Get.back(result: false),
              child: const Text('Cancelar'),
            ),
            TextButton(
              onPressed: () => Get.back(result: true),
              child: const Text('Excluir', style: TextStyle(color: Colors.red)),
            ),
          ],
        ),
      );

      if (confirmado == true) {
        await _service.deletar(grupo.id!);
        Get.snackbar(
          'Sucesso',
          'Grupo excluído com sucesso',
          snackPosition: SnackPosition.BOTTOM,
        );
        carregarGrupos();
      }
    } catch (e) {
      Get.snackbar(
        'Erro',
        'Erro ao excluir grupo: $e',
        snackPosition: SnackPosition.BOTTOM,
      );
    }
  }

  // Navegar para formulário de criação
  void irParaCriar() {
    Get.toNamed('/grupos/form');
  }

  // Navegar para formulário de edição
  void irParaEditar(GrupoModel grupo) {
    Get.toNamed('/grupos/form', arguments: grupo);
  }
}
