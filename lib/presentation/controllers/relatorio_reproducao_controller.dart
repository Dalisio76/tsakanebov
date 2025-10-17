import 'package:get/get.dart';
import 'package:flutter/material.dart';
import '../../data/models/diagnostico_prenhez_model.dart';
import '../../data/services/cobertura_service.dart';
import '../../data/services/diagnostico_prenhez_service.dart';
import '../../data/services/parto_service.dart';

class RelatorioReproducaoController extends GetxController {
  final CoberturaService _coberturaService = CoberturaService();
  final DiagnosticoPrenheService _diagnosticoService = DiagnosticoPrenheService();
  final PartoService _partoService = PartoService();

  var isLoading = false.obs;
  var periodoSelecionado = '30'.obs; // dias

  // Estatísticas
  var totalCoberturas = 0.obs;
  var montaNatural = 0.obs;
  var inseminacao = 0.obs;
  var taxaPrenhez = 0.0.obs;
  var prenhasAtivas = <DiagnosticoPrenheModel>[].obs;
  var estatisticasPartos = <String, dynamic>{}.obs;

  @override
  void onInit() {
    super.onInit();
    carregarDados();
  }

  Future<void> carregarDados() async {
    try {
      isLoading.value = true;

      final dias = int.tryParse(periodoSelecionado.value) ?? 30;
      final dataInicio = DateTime.now().subtract(Duration(days: dias));
      final dataFim = DateTime.now();

      // Coberturas
      final coberturas = await _coberturaService.listarPorPeriodo(
        dataInicio,
        dataFim,
      );
      totalCoberturas.value = coberturas.length;

      // Contar por tipo
      final contagem = await _coberturaService.contarPorTipo(
        inicio: dataInicio,
        fim: dataFim,
      );
      montaNatural.value = contagem['monta_natural'] ?? 0;
      inseminacao.value = contagem['inseminacao'] ?? 0;

      // Taxa de prenhez
      taxaPrenhez.value = await _diagnosticoService.calcularTaxaPrenhez(
        inicio: dataInicio,
        fim: dataFim,
      );

      // Prenhas ativas
      prenhasAtivas.value = await _diagnosticoService.listarPrenhas();

      // Estatísticas de partos
      estatisticasPartos.value = await _partoService.calcularEstatisticas(
        inicio: dataInicio,
        fim: dataFim,
      );
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

  void mudarPeriodo(String periodo) {
    periodoSelecionado.value = periodo;
    carregarDados();
  }

  String get taxaPrenheFormatada {
    return '${taxaPrenhez.value.toStringAsFixed(1)}%';
  }

  String get taxaSobrevivenciaFormatada {
    if (estatisticasPartos.isEmpty) return '0%';
    final taxa = estatisticasPartos['taxa_sobrevivencia'] ?? 0.0;
    return '${taxa.toStringAsFixed(1)}%';
  }
}
