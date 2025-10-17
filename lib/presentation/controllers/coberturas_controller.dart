import 'package:get/get.dart';
import 'package:flutter/material.dart';
import '../../data/models/cobertura_model.dart';
import '../../data/services/cobertura_service.dart';

class CoberturasController extends GetxController {
  final CoberturaService _coberturaService = CoberturaService();

  var coberturas = <CoberturaModel>[].obs;
  var isLoading = false.obs;
  var buscaController = TextEditingController();

  // Filtros
  var tipoFiltro = 'todos'.obs; // todos, monta_natural, inseminacao

  @override
  void onInit() {
    super.onInit();
    carregarCoberturas();
  }

  @override
  void onClose() {
    buscaController.dispose();
    super.onClose();
  }

  Future<void> carregarCoberturas() async {
    try {
      isLoading.value = true;
      coberturas.value = await _coberturaService.listarTodas();
    } catch (e) {
      Get.snackbar(
        'Erro',
        'Erro ao carregar coberturas: $e',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red.shade600,
        colorText: Colors.white,
      );
    } finally {
      isLoading.value = false;
    }
  }

  // Filtrar coberturas
  List<CoberturaModel> get coberturasFiltradas {
    var resultado = coberturas.toList();

    // Busca por fêmea
    if (buscaController.text.isNotEmpty) {
      resultado = resultado
          .where((c) =>
              c.femeaBrinco
                  ?.toLowerCase()
                  .contains(buscaController.text.toLowerCase()) ??
              false)
          .toList();
    }

    // Filtro por tipo
    if (tipoFiltro.value != 'todos') {
      resultado = resultado.where((c) => c.tipo == tipoFiltro.value).toList();
    }

    return resultado;
  }

  // Deletar cobertura
  Future<void> deletar(CoberturaModel cobertura) async {
    try {
      final confirma = await Get.dialog<bool>(
        AlertDialog(
          title: Text('Confirmar Exclusão'),
          content: Text('Deseja realmente excluir esta cobertura?'),
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
        await _coberturaService.deletar(cobertura.id!);
        coberturas.remove(cobertura);
        Get.snackbar(
          'Sucesso',
          'Cobertura excluída com sucesso!',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.green,
          colorText: Colors.white,
        );
      }
    } catch (e) {
      Get.snackbar(
        'Erro',
        'Erro ao excluir cobertura: $e',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red.shade600,
        colorText: Colors.white,
      );
    }
  }

  // Navegar para formulário
  void irParaFormulario([CoberturaModel? cobertura]) async {
    final result = await Get.toNamed('/cobertura-form', arguments: cobertura);
    if (result == true) {
      carregarCoberturas();
    }
  }

  // Navegar para diagnósticos
  void irParaDiagnosticos() {
    Get.toNamed('/diagnosticos');
  }

  // Navegar para partos
  void irParaPartos() {
    Get.toNamed('/partos');
  }

  // Navegar para relatório
  void irParaRelatorio() {
    Get.toNamed('/relatorio-reproducao');
  }
}
