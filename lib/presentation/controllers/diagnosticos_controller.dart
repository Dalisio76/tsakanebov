import 'package:get/get.dart';
import 'package:flutter/material.dart';
import '../../data/models/diagnostico_prenhez_model.dart';
import '../../data/services/diagnostico_prenhez_service.dart';

class DiagnosticosController extends GetxController {
  final DiagnosticoPrenheService _diagnosticoService = DiagnosticoPrenheService();

  var diagnosticos = <DiagnosticoPrenheModel>[].obs;
  var isLoading = false.obs;

  // Filtros
  var filtroResultado = 'todos'.obs; // todos, prenha, vazia

  @override
  void onInit() {
    super.onInit();
    carregarDiagnosticos();
  }

  Future<void> carregarDiagnosticos() async {
    try {
      isLoading.value = true;
      diagnosticos.value = await _diagnosticoService.listarTodos();
    } catch (e) {
      Get.snackbar(
        'Erro',
        'Erro ao carregar diagnósticos: $e',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red.shade600,
        colorText: Colors.white,
      );
    } finally {
      isLoading.value = false;
    }
  }

  // Filtrar diagnósticos
  List<DiagnosticoPrenheModel> get diagnosticosFiltrados {
    var resultado = diagnosticos.toList();

    // Filtro por resultado
    if (filtroResultado.value == 'prenha') {
      resultado = resultado.where((d) => d.resultado == true).toList();
    } else if (filtroResultado.value == 'vazia') {
      resultado = resultado.where((d) => d.resultado == false).toList();
    }

    return resultado;
  }

  // Deletar diagnóstico
  Future<void> deletar(DiagnosticoPrenheModel diagnostico) async {
    try {
      final confirma = await Get.dialog<bool>(
        AlertDialog(
          title: Text('Confirmar Exclusão'),
          content: Text('Deseja realmente excluir este diagnóstico?'),
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
        await _diagnosticoService.deletar(diagnostico.id!);
        diagnosticos.remove(diagnostico);
        Get.snackbar(
          'Sucesso',
          'Diagnóstico excluído com sucesso!',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.green,
          colorText: Colors.white,
        );
      }
    } catch (e) {
      Get.snackbar(
        'Erro',
        'Erro ao excluir diagnóstico: $e',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red.shade600,
        colorText: Colors.white,
      );
    }
  }

  // Navegar para formulário
  void irParaFormulario([DiagnosticoPrenheModel? diagnostico]) async {
    final result = await Get.toNamed('/diagnostico-form', arguments: diagnostico);
    if (result == true) {
      carregarDiagnosticos();
    }
  }
}
