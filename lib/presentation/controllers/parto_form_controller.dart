import 'package:get/get.dart';
import 'package:flutter/material.dart';
import '../../data/models/parto_model.dart';
import '../../data/models/cobertura_model.dart';
import '../../data/models/animal_model.dart';
import '../../data/services/parto_service.dart';
import '../../data/services/cobertura_service.dart';
import '../../data/services/animal_service.dart';

class PartoFormController extends GetxController {
  final PartoService _partoService = PartoService();
  final CoberturaService _coberturaService = CoberturaService();
  final AnimalService _animalService = AnimalService();

  var isEditMode = false.obs;
  var isLoading = false.obs;
  var isLoadingDados = true.obs;

  // Dados do formulário
  var coberturaSelecionada = Rxn<String>();
  var maeSelecionada = Rxn<String>();
  var dataParto = Rxn<DateTime>();
  var tipoPartoSelecionado = Rxn<String>();
  var condicaoMaeSelecionada = Rxn<String>();

  // Controllers
  final bezerrosVivosController = TextEditingController(text: '1');
  final bezerrosMortosController = TextEditingController(text: '0');
  final complicacoesController = TextEditingController();
  final veterinarioController = TextEditingController();
  final observacoesController = TextEditingController();

  // Listas
  var coberturas = <CoberturaModel>[].obs;
  var femeas = <AnimalModel>[].obs;

  PartoModel? _partoEditando;

  @override
  void onInit() {
    super.onInit();
    _carregarDados();
    _carregarDadosEdicao();
  }

  @override
  void onClose() {
    bezerrosVivosController.dispose();
    bezerrosMortosController.dispose();
    complicacoesController.dispose();
    veterinarioController.dispose();
    observacoesController.dispose();
    super.onClose();
  }

  Future<void> _carregarDados() async {
    try {
      isLoadingDados.value = true;
      coberturas.value = await _coberturaService.listarTodas();
      final todosAnimais = await _animalService.listarAnimais(apenasAtivos: true);
      femeas.value = todosAnimais.where((a) => a.sexo == 'F').toList();
    } catch (e) {
      Get.snackbar(
        'Erro',
        'Erro ao carregar dados: $e',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red.shade600,
        colorText: Colors.white,
      );
    } finally {
      isLoadingDados.value = false;
    }
  }

  void _carregarDadosEdicao() {
    final parto = Get.arguments as PartoModel?;
    if (parto != null) {
      isEditMode.value = true;
      _partoEditando = parto;
      coberturaSelecionada.value = parto.coberturaId;
      maeSelecionada.value = parto.maeId;
      dataParto.value = parto.dataParto;
      tipoPartoSelecionado.value = parto.tipoParto;
      condicaoMaeSelecionada.value = parto.condicaoMae;
      bezerrosVivosController.text = parto.bezerrosVivos.toString();
      bezerrosMortosController.text = parto.bezerrosMortos.toString();
      complicacoesController.text = parto.complicacoes ?? '';
      veterinarioController.text = parto.veterinario ?? '';
      observacoesController.text = parto.observacoes ?? '';
    } else {
      dataParto.value = DateTime.now();
      tipoPartoSelecionado.value = 'normal';
      condicaoMaeSelecionada.value = 'boa';
    }
  }

  Future<void> selecionarData() async {
    final data = await showDatePicker(
      context: Get.context!,
      initialDate: dataParto.value ?? DateTime.now(),
      firstDate: DateTime(2020),
      lastDate: DateTime.now(),
    );

    if (data != null) {
      dataParto.value = data;
    }
  }

  Future<void> salvar() async {
    if (!_validarDados()) return;

    try {
      isLoading.value = true;

      // Se não selecionou mae diretamente, pega da cobertura
      String maeId;
      if (maeSelecionada.value != null) {
        maeId = maeSelecionada.value!;
      } else if (coberturaSelecionada.value != null) {
        final cobertura = coberturas.firstWhere(
          (c) => c.id == coberturaSelecionada.value,
        );
        maeId = cobertura.femeaId;
      } else {
        Get.snackbar(
          'Atenção',
          'Selecione uma cobertura ou mãe',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.orange,
          colorText: Colors.white,
        );
        return;
      }

      final parto = PartoModel(
        id: _partoEditando?.id,
        coberturaId: coberturaSelecionada.value,
        maeId: maeId,
        dataParto: dataParto.value!,
        tipoParto: tipoPartoSelecionado.value,
        bezerrosVivos: int.tryParse(bezerrosVivosController.text) ?? 1,
        bezerrosMortos: int.tryParse(bezerrosMortosController.text) ?? 0,
        condicaoMae: condicaoMaeSelecionada.value,
        complicacoes: complicacoesController.text.isNotEmpty
            ? complicacoesController.text
            : null,
        veterinario: veterinarioController.text.isNotEmpty
            ? veterinarioController.text
            : null,
        observacoes: observacoesController.text.isNotEmpty
            ? observacoesController.text
            : null,
      );

      if (isEditMode.value) {
        await _partoService.atualizar(_partoEditando!.id!, parto);
      } else {
        await _partoService.criar(parto);
      }

      Get.back(result: true);

      Get.snackbar(
        'Sucesso',
        isEditMode.value
            ? 'Parto atualizado com sucesso!'
            : 'Parto registrado com sucesso!',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.green,
        colorText: Colors.white,
        margin: EdgeInsets.all(16),
        borderRadius: 8,
      );
    } catch (e) {
      Get.snackbar(
        'Erro',
        'Erro ao salvar parto: $e',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red.shade600,
        colorText: Colors.white,
      );
    } finally {
      isLoading.value = false;
    }
  }

  bool _validarDados() {
    if (dataParto.value == null) {
      Get.snackbar(
        'Atenção',
        'Selecione a data do parto',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.orange,
        colorText: Colors.white,
      );
      return false;
    }

    final bezerrosVivos = int.tryParse(bezerrosVivosController.text);
    if (bezerrosVivos == null || bezerrosVivos < 0) {
      Get.snackbar(
        'Atenção',
        'Informe a quantidade de bezerros vivos',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.orange,
        colorText: Colors.white,
      );
      return false;
    }

    return true;
  }
}
