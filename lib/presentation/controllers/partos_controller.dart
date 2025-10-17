import 'package:get/get.dart';
import 'package:flutter/material.dart';
import '../../data/models/parto_model.dart';
import '../../data/services/parto_service.dart';

class PartosController extends GetxController {
  final PartoService _partoService = PartoService();

  var partos = <PartoModel>[].obs;
  var isLoading = false.obs;

  @override
  void onInit() {
    super.onInit();
    carregarPartos();
  }

  Future<void> carregarPartos() async {
    try {
      isLoading.value = true;
      partos.value = await _partoService.listarTodos();
    } catch (e) {
      Get.snackbar(
        'Erro',
        'Erro ao carregar partos: $e',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red.shade600,
        colorText: Colors.white,
      );
    } finally {
      isLoading.value = false;
    }
  }

  // Filtrar partos
  List<PartoModel> get partosFiltrados {
    return partos.toList();
  }

  // Deletar parto
  Future<void> deletar(PartoModel parto) async {
    try {
      final confirma = await Get.dialog<bool>(
        AlertDialog(
          title: Text('Confirmar Exclusão'),
          content: Text('Deseja realmente excluir este parto?'),
          actions: [
            TextButton(
              onPressed: () => Get.back(result: false),
              child: Text('Cancelar'),
            ),
            ElevatedButton(
              onPressed: () => Get.back(result: true),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red,
              ),
              child: Text('Excluir'),
            ),
          ],
        ),
      );

      if (confirma == true) {
        await _partoService.deletar(parto.id!);
        partos.remove(parto);
        Get.snackbar(
          'Sucesso',
          'Parto excluído com sucesso!',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.green,
          colorText: Colors.white,
        );
      }
    } catch (e) {
      Get.snackbar(
        'Erro',
        'Erro ao excluir parto: $e',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red.shade600,
        colorText: Colors.white,
      );
    }
  }

  // Navegar para formulário
  void irParaFormulario([PartoModel? parto]) async {
    final result = await Get.toNamed('/parto-form', arguments: parto);
    if (result == true) {
      carregarPartos();
    }
  }
}
