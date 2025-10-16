import 'package:get/get.dart';
import 'package:flutter/material.dart';
import '../../data/models/despesa_model.dart';
import '../../data/services/despesa_service.dart';

class RelatorioCustosController extends GetxController {
  final DespesaService _despesaService = DespesaService();

  var despesas = <DespesaModel>[].obs;
  var isLoading = false.obs;
  var periodoSelecionado = '30'.obs; // dias

  // Estatísticas
  var totalGeral = 0.0.obs;
  var estatisticasPorCategoria = <String, double>{}.obs;

  @override
  void onInit() {
    super.onInit();
    carregarDados();
  }

  Future<void> carregarDados() async {
    try {
      isLoading.value = true;
      await carregarDespesas();
      await carregarEstatisticas();
    } catch (e) {
      Get.snackbar(
        'Erro',
        'Erro ao carregar dados: $e',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red.shade600,
        colorText: Colors.white,
      );
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> carregarDespesas() async {
    final dias = int.tryParse(periodoSelecionado.value) ?? 30;
    final inicio = DateTime.now().subtract(Duration(days: dias));
    final fim = DateTime.now();

    despesas.value = await _despesaService.listarPorPeriodo(inicio, fim);

    // Calcular total
    totalGeral.value = despesas.fold(0.0, (sum, d) => sum + d.valor);
  }

  Future<void> carregarEstatisticas() async {
    final dias = int.tryParse(periodoSelecionado.value) ?? 30;
    final inicio = DateTime.now().subtract(Duration(days: dias));
    final fim = DateTime.now();

    estatisticasPorCategoria.value =
        await _despesaService.estatisticasPorCategoria(
      inicio: inicio,
      fim: fim,
    );
  }

  // Despesas agrupadas por categoria
  Map<String, List<DespesaModel>> get despesasAgrupadas {
    Map<String, List<DespesaModel>> agrupadas = {};

    for (var despesa in despesas) {
      final categoria = despesa.categoriaNome ?? 'Sem Categoria';
      if (!agrupadas.containsKey(categoria)) {
        agrupadas[categoria] = [];
      }
      agrupadas[categoria]!.add(despesa);
    }

    return agrupadas;
  }

  // Total formatado
  String get totalFormatado {
    return 'R\$ ${totalGeral.value.toStringAsFixed(2).replaceAll('.', ',')}';
  }

  // Mudar período
  void mudarPeriodo(String novoPeriodo) {
    periodoSelecionado.value = novoPeriodo;
    carregarDados();
  }

  // Exportar (placeholder para funcionalidade futura)
  void exportarRelatorio() {
    Get.snackbar(
      'Relatório',
      'Funcionalidade de exportação em desenvolvimento',
      snackPosition: SnackPosition.BOTTOM,
      duration: Duration(seconds: 2),
    );
  }
}
