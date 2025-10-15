import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../data/models/animal_model.dart';
import '../../data/models/pesagem_model.dart';
import '../../data/services/pesagem_service.dart';

class HistoricoPesagemController extends GetxController {
  final PesagemService _service = PesagemService();

  var pesagens = <PesagemModel>[].obs;
  var isLoading = false.obs;
  AnimalModel? animal;
  var gmdMedio = Rxn<double>();

  @override
  void onInit() {
    super.onInit();
    if (Get.arguments != null && Get.arguments is AnimalModel) {
      animal = Get.arguments;
      carregarHistorico();
    }
  }

  Future<void> carregarHistorico() async {
    if (animal == null) return;

    try {
      isLoading.value = true;
      pesagens.value = await _service.listarPorAnimal(animal!.id!);
      gmdMedio.value = await _service.calcularGmdMedio(animal!.id!);
    } catch (e) {
      Get.snackbar(
        'Erro',
        'Erro ao carregar histórico: $e',
        snackPosition: SnackPosition.BOTTOM,
      );
    } finally {
      isLoading.value = false;
    }
  }
}
