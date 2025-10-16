import 'package:get/get.dart';
import 'package:flutter/material.dart';
import '../../data/models/despesa_model.dart';
import '../../data/services/despesa_service.dart';

class DespesasController extends GetxController {
  final DespesaService _despesaService = DespesaService();

  var despesas = <DespesaModel>[].obs;
  var isLoading = false.obs;
  var buscaController = TextEditingController();

  // Filtros
  var categoriaFiltro = Rxn<String>();
  var periodoSelecionado = '30'.obs; // dias

  @override
  void onInit() {
    super.onInit();
    carregarDespesas();
  }

  @override
  void onClose() {
    buscaController.dispose();
    super.onClose();
  }

  Future<void> carregarDespesas() async {
    try {
      isLoading.value = true;
      despesas.value = await _despesaService.listarTodas();
    } catch (e) {
      Get.snackbar(
        'Erro',
        'Erro ao carregar despesas: $e',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red.shade600,
        colorText: Colors.white,
      );
    } finally {
      isLoading.value = false;
    }
  }

  // Filtrar despesas
  List<DespesaModel> get despesasFiltradas {
    var resultado = despesas.toList();

    // Busca por descrição
    if (buscaController.text.isNotEmpty) {
      resultado = resultado
          .where((d) => d.descricao
              .toLowerCase()
              .contains(buscaController.text.toLowerCase()))
          .toList();
    }

    // Filtro por categoria
    if (categoriaFiltro.value != null) {
      resultado = resultado
          .where((d) => d.categoriaId == categoriaFiltro.value)
          .toList();
    }

    // Filtro por período
    final dias = int.tryParse(periodoSelecionado.value) ?? 30;
    final dataLimite = DateTime.now().subtract(Duration(days: dias));
    resultado = resultado
        .where((d) => d.dataDespesa.isAfter(dataLimite))
        .toList();

    return resultado;
  }

  // Calcular total filtrado
  String get totalFiltrado {
    final total = despesasFiltradas.fold(0.0, (sum, d) => sum + d.valor);
    return 'R\$ ${total.toStringAsFixed(2).replaceAll('.', ',')}';
  }

  // Limpar filtros
  void limparFiltros() {
    categoriaFiltro.value = null;
    periodoSelecionado.value = '30';
    buscaController.clear();
    update();
  }

  // Deletar despesa
  Future<void> deletar(DespesaModel despesa) async {
    try {
      final confirma = await Get.dialog<bool>(
        AlertDialog(
          title: Text('Confirmar Exclusão'),
          content: Text('Deseja realmente excluir esta despesa?'),
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
        await _despesaService.deletar(despesa.id!);
        despesas.remove(despesa);
        Get.snackbar(
          'Sucesso',
          'Despesa excluída com sucesso!',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.green,
          colorText: Colors.white,
        );
      }
    } catch (e) {
      Get.snackbar(
        'Erro',
        'Erro ao excluir despesa: $e',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red.shade600,
        colorText: Colors.white,
      );
    }
  }

  // Navegar para formulário
  void irParaFormulario([DespesaModel? despesa]) async {
    final result = await Get.toNamed('/despesa-form', arguments: despesa);
    if (result == true) {
      carregarDespesas();
    }
  }

  // Navegar para relatório
  void irParaRelatorio() {
    Get.toNamed('/relatorio-custos');
  }
}
