import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../data/models/animal_model.dart';
import '../../data/models/grupo_model.dart';
import '../../data/services/animal_service.dart';
import '../../data/services/grupo_service.dart';

class AnimaisController extends GetxController {
  final AnimalService _animalService = AnimalService();
  final GrupoService _grupoService = GrupoService();

  var animais = <AnimalModel>[].obs;
  var grupos = <GrupoModel>[].obs;
  var isLoading = false.obs;
  var errorMessage = ''.obs;

  // Filtros
  var grupoSelecionado = Rxn<String>();
  var sexoSelecionado = Rxn<String>();

  @override
  void onInit() {
    super.onInit();
    carregarGrupos();
    carregarAnimais();
  }

  Future<void> carregarGrupos() async {
    try {
      grupos.value = await _grupoService.listarGrupos();
    } catch (e) {
      // Silencioso, não é crítico
    }
  }

  Future<void> carregarAnimais() async {
    try {
      isLoading.value = true;
      errorMessage.value = '';

      animais.value = await _animalService.listarAnimais(
        grupoId: grupoSelecionado.value,
        sexo: sexoSelecionado.value,
      );
    } catch (e) {
      errorMessage.value = e.toString();
      Get.snackbar(
        'Erro',
        'Erro ao carregar animais: $e',
        snackPosition: SnackPosition.BOTTOM,
      );
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> buscarPorBrinco(String brinco) async {
    if (brinco.isEmpty) {
      carregarAnimais();
      return;
    }

    try {
      isLoading.value = true;
      animais.value = await _animalService.buscarPorBrinco(brinco);
    } catch (e) {
      Get.snackbar('Erro', 'Erro ao buscar: $e',
          snackPosition: SnackPosition.BOTTOM);
    } finally {
      isLoading.value = false;
    }
  }

  void aplicarFiltros() {
    carregarAnimais();
  }

  void limparFiltros() {
    grupoSelecionado.value = null;
    sexoSelecionado.value = null;
    carregarAnimais();
  }

  Future<void> deletarAnimal(AnimalModel animal) async {
    try {
      final confirmado = await Get.dialog<bool>(
        AlertDialog(
          title: const Text('Confirmar'),
          content: Text(
              'Deseja realmente marcar "${animal.brinco}" como morto?'),
          actions: [
            TextButton(
              onPressed: () => Get.back(result: false),
              child: const Text('Cancelar'),
            ),
            TextButton(
              onPressed: () => Get.back(result: true),
              child: const Text('Confirmar', style: TextStyle(color: Colors.red)),
            ),
          ],
        ),
      );

      if (confirmado == true) {
        await _animalService.deletar(animal.id!);
        Get.snackbar(
          'Sucesso',
          'Animal marcado como morto',
          snackPosition: SnackPosition.BOTTOM,
        );
        carregarAnimais();
      }
    } catch (e) {
      Get.snackbar(
        'Erro',
        'Erro ao deletar animal: $e',
        snackPosition: SnackPosition.BOTTOM,
      );
    }
  }

  void irParaCriar() {
    Get.toNamed('/animais/form');
  }

  void irParaEditar(AnimalModel animal) {
    Get.toNamed('/animais/form', arguments: animal);
  }

  void irParaDetalhes(AnimalModel animal) {
    Get.toNamed('/animais/detalhes', arguments: animal);
  }

  Future<void> marcarParaAbate(AnimalModel animal) async {
    try {
      await _animalService.atualizar(
        animal.id!,
        animal.copyWith(status: 'abate'),
      );
      Get.snackbar(
        '✅ Sucesso',
        'Animal marcado para abate',
        backgroundColor: Colors.brown,
        colorText: Colors.white,
        snackPosition: SnackPosition.BOTTOM,
      );
      carregarAnimais();
    } catch (e) {
      Get.snackbar(
        '❌ Erro',
        'Erro ao marcar animal: $e',
        backgroundColor: Colors.red,
        colorText: Colors.white,
        snackPosition: SnackPosition.BOTTOM,
      );
    }
  }
}
