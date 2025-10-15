import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../data/models/grupo_model.dart';
import '../../data/services/grupo_service.dart';

class GrupoFormController extends GetxController {
  final GrupoService _service = GrupoService();

  // Controllers de texto
  final nomeController = TextEditingController();
  final descricaoController = TextEditingController();
  final finalidadeController = TextEditingController();

  // Estado
  var isLoading = false.obs;
  var isEditMode = false.obs;
  GrupoModel? grupoOriginal;

  // Opções de finalidade
  final finalidades = [
    'cria',
    'recria',
    'engorda',
    'reprodução',
  ];

  @override
  void onInit() {
    super.onInit();

    // Se veio um grupo como argumento, é modo edição
    if (Get.arguments != null && Get.arguments is GrupoModel) {
      grupoOriginal = Get.arguments;
      isEditMode.value = true;
      preencherFormulario(grupoOriginal!);
    }
  }

  void preencherFormulario(GrupoModel grupo) {
    nomeController.text = grupo.nome;
    descricaoController.text = grupo.descricao ?? '';
    finalidadeController.text = grupo.finalidade ?? '';
  }

  Future<void> salvar() async {
    // Validação
    if (nomeController.text.trim().isEmpty) {
      Get.snackbar(
        'Atenção',
        'Nome do grupo é obrigatório',
        snackPosition: SnackPosition.BOTTOM,
      );
      return;
    }

    try {
      isLoading.value = true;

      final grupo = GrupoModel(
        id: grupoOriginal?.id,
        nome: nomeController.text.trim(),
        descricao: descricaoController.text.trim().isEmpty
            ? null
            : descricaoController.text.trim(),
        finalidade: finalidadeController.text.trim().isEmpty
            ? null
            : finalidadeController.text.trim(),
        dataCriacao: grupoOriginal?.dataCriacao ?? DateTime.now(),
        ativo: true,
      );

      if (isEditMode.value) {
        await _service.atualizar(grupoOriginal!.id!, grupo);
        Get.snackbar(
          'Sucesso',
          'Grupo atualizado com sucesso',
          snackPosition: SnackPosition.BOTTOM,
        );
      } else {
        await _service.criar(grupo);
        Get.snackbar(
          'Sucesso',
          'Grupo criado com sucesso',
          snackPosition: SnackPosition.BOTTOM,
        );
      }

      Get.back(result: true); // Volta e indica sucesso
    } catch (e) {
      Get.snackbar(
        'Erro',
        'Erro ao salvar grupo: $e',
        snackPosition: SnackPosition.BOTTOM,
      );
    } finally {
      isLoading.value = false;
    }
  }

  @override
  void onClose() {
    nomeController.dispose();
    descricaoController.dispose();
    finalidadeController.dispose();
    super.onClose();
  }
}
