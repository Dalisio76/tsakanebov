import 'package:get/get.dart';
import 'package:flutter/material.dart';
import '../../data/models/diagnostico_prenhez_model.dart';
import '../../data/models/cobertura_model.dart';
import '../../data/services/diagnostico_prenhez_service.dart';
import '../../data/services/cobertura_service.dart';

class DiagnosticoFormController extends GetxController {
  final DiagnosticoPrenheService _diagnosticoService = DiagnosticoPrenheService();
  final CoberturaService _coberturaService = CoberturaService();

  var isEditMode = false.obs;
  var isLoading = false.obs;
  var isLoadingCoberturas = true.obs;

  // Dados do formulário
  var coberturaSelecionada = Rxn<String>();
  var dataDiagnostico = Rxn<DateTime>();
  var resultado = false.obs;
  var metodoSelecionado = Rxn<String>();
  var dataPrevistaParto = Rxn<DateTime>();

  // Controllers
  final veterinarioController = TextEditingController();
  final observacoesController = TextEditingController();

  // Listas
  var coberturas = <CoberturaModel>[].obs;

  DiagnosticoPrenheModel? _diagnosticoEditando;

  @override
  void onInit() {
    super.onInit();
    _carregarCoberturas();
    _carregarDadosEdicao();
  }

  @override
  void onClose() {
    veterinarioController.dispose();
    observacoesController.dispose();
    super.onClose();
  }

  Future<void> _carregarCoberturas() async {
    try {
      isLoadingCoberturas.value = true;
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
      isLoadingCoberturas.value = false;
    }
  }

  void _carregarDadosEdicao() {
    final diagnostico = Get.arguments as DiagnosticoPrenheModel?;
    if (diagnostico != null) {
      isEditMode.value = true;
      _diagnosticoEditando = diagnostico;
      coberturaSelecionada.value = diagnostico.coberturaId;
      dataDiagnostico.value = diagnostico.dataDiagnostico;
      resultado.value = diagnostico.resultado;
      metodoSelecionado.value = diagnostico.metodo;
      dataPrevistaParto.value = diagnostico.dataPrevistaParto;
      veterinarioController.text = diagnostico.veterinario ?? '';
      observacoesController.text = diagnostico.observacoes ?? '';
    } else {
      dataDiagnostico.value = DateTime.now();
      metodoSelecionado.value = 'palpacao';
    }
  }

  Future<void> selecionarDataDiagnostico() async {
    final data = await showDatePicker(
      context: Get.context!,
      initialDate: dataDiagnostico.value ?? DateTime.now(),
      firstDate: DateTime(2020),
      lastDate: DateTime.now(),
    );

    if (data != null) {
      dataDiagnostico.value = data;
    }
  }

  Future<void> selecionarDataPrevista() async {
    final data = await showDatePicker(
      context: Get.context!,
      initialDate: dataPrevistaParto.value ??
          DateTime.now().add(Duration(days: 280)),
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(Duration(days: 365)),
    );

    if (data != null) {
      dataPrevistaParto.value = data;
    }
  }

  Future<void> salvar() async {
    if (!_validarDados()) return;

    try {
      isLoading.value = true;

      // Encontrar femea_id da cobertura selecionada
      final cobertura = coberturas.firstWhere(
        (c) => c.id == coberturaSelecionada.value,
      );

      final diagnostico = DiagnosticoPrenheModel(
        id: _diagnosticoEditando?.id,
        coberturaId: coberturaSelecionada.value!,
        femeaId: cobertura.femeaId,
        dataDiagnostico: dataDiagnostico.value!,
        resultado: resultado.value,
        metodo: metodoSelecionado.value,
        dataPrevistaParto: dataPrevistaParto.value,
        veterinario: veterinarioController.text.isNotEmpty
            ? veterinarioController.text
            : null,
        observacoes: observacoesController.text.isNotEmpty
            ? observacoesController.text
            : null,
      );

      if (isEditMode.value) {
        await _diagnosticoService.atualizar(
            _diagnosticoEditando!.id!, diagnostico);
      } else {
        await _diagnosticoService.criar(diagnostico);
      }

      Get.back(result: true);

      Get.snackbar(
        'Sucesso',
        isEditMode.value
            ? 'Diagnóstico atualizado com sucesso!'
            : 'Diagnóstico registrado com sucesso!',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.green,
        colorText: Colors.white,
        margin: EdgeInsets.all(16),
        borderRadius: 8,
      );
    } catch (e) {
      Get.snackbar(
        'Erro',
        'Erro ao salvar diagnóstico: $e',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red.shade600,
        colorText: Colors.white,
      );
    } finally {
      isLoading.value = false;
    }
  }

  bool _validarDados() {
    if (coberturaSelecionada.value == null) {
      Get.snackbar(
        'Atenção',
        'Selecione uma cobertura',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.orange,
        colorText: Colors.white,
      );
      return false;
    }

    if (dataDiagnostico.value == null) {
      Get.snackbar(
        'Atenção',
        'Selecione a data do diagnóstico',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.orange,
        colorText: Colors.white,
      );
      return false;
    }

    if (resultado.value && dataPrevistaParto.value == null) {
      Get.snackbar(
        'Atenção',
        'Informe a data prevista do parto para diagnóstico prenha',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.orange,
        colorText: Colors.white,
      );
      return false;
    }

    return true;
  }
}
