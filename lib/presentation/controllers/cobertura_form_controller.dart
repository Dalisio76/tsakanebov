import 'package:get/get.dart';
import 'package:flutter/material.dart';
import '../../data/models/cobertura_model.dart';
import '../../data/models/animal_model.dart';
import '../../data/services/cobertura_service.dart';
import '../../data/services/animal_service.dart';

class CoberturaFormController extends GetxController {
  final CoberturaService _coberturaService = CoberturaService();
  final AnimalService _animalService = AnimalService();

  var isEditMode = false.obs;
  var isLoading = false.obs;
  var isLoadingAnimais = true.obs;

  // Dados do formulário
  var femeaSelecionada = Rxn<String>();
  var machoSelecionado = Rxn<String>();
  var tipoSelecionado = 'monta_natural'.obs;
  var dataCobertura = Rxn<DateTime>();

  // Controllers
  final touroSemenController = TextEditingController();
  final racaTouroController = TextEditingController();
  final observacoesController = TextEditingController();

  // Listas
  var femeas = <AnimalModel>[].obs;
  var machos = <AnimalModel>[].obs;

  CoberturaModel? _coberturaEditando;

  @override
  void onInit() {
    super.onInit();
    _carregarAnimais();
    _carregarDadosEdicao();
  }

  @override
  void onClose() {
    touroSemenController.dispose();
    racaTouroController.dispose();
    observacoesController.dispose();
    super.onClose();
  }

  Future<void> _carregarAnimais() async {
    try {
      isLoadingAnimais.value = true;
      final todosAnimais = await _animalService.listarAnimais(apenasAtivos: true);
      femeas.value = todosAnimais.where((a) => a.sexo == 'F').toList();
      machos.value = todosAnimais.where((a) => a.sexo == 'M').toList();
    } catch (e) {
      Get.snackbar(
        'Erro',
        'Erro ao carregar animais: $e',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red.shade600,
        colorText: Colors.white,
      );
    } finally {
      isLoadingAnimais.value = false;
    }
  }

  void _carregarDadosEdicao() {
    final cobertura = Get.arguments as CoberturaModel?;
    if (cobertura != null) {
      isEditMode.value = true;
      _coberturaEditando = cobertura;
      femeaSelecionada.value = cobertura.femeaId;
      machoSelecionado.value = cobertura.machoId;
      tipoSelecionado.value = cobertura.tipo;
      dataCobertura.value = cobertura.dataCobertura;
      touroSemenController.text = cobertura.touroSemen ?? '';
      racaTouroController.text = cobertura.racaTouro ?? '';
      observacoesController.text = cobertura.observacoes ?? '';
    } else {
      dataCobertura.value = DateTime.now();
    }
  }

  Future<void> selecionarData() async {
    final data = await showDatePicker(
      context: Get.context!,
      initialDate: dataCobertura.value ?? DateTime.now(),
      firstDate: DateTime(2020),
      lastDate: DateTime.now(),
    );

    if (data != null) {
      dataCobertura.value = data;
    }
  }

  Future<void> salvar() async {
    if (!_validarDados()) return;

    try {
      isLoading.value = true;

      final cobertura = CoberturaModel(
        id: _coberturaEditando?.id,
        femeaId: femeaSelecionada.value!,
        machoId: machoSelecionado.value,
        dataCobertura: dataCobertura.value!,
        tipo: tipoSelecionado.value,
        touroSemen: touroSemenController.text.isNotEmpty
            ? touroSemenController.text
            : null,
        racaTouro: racaTouroController.text.isNotEmpty
            ? racaTouroController.text
            : null,
        observacoes: observacoesController.text.isNotEmpty
            ? observacoesController.text
            : null,
      );

      if (isEditMode.value) {
        await _coberturaService.atualizar(_coberturaEditando!.id!, cobertura);
      } else {
        await _coberturaService.criar(cobertura);
      }

      Get.back(result: true);

      Get.snackbar(
        'Sucesso',
        isEditMode.value
            ? 'Cobertura atualizada com sucesso!'
            : 'Cobertura registrada com sucesso!',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.green,
        colorText: Colors.white,
        margin: EdgeInsets.all(16),
        borderRadius: 8,
      );
    } catch (e) {
      Get.snackbar(
        'Erro',
        'Erro ao salvar cobertura: $e',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red.shade600,
        colorText: Colors.white,
      );
    } finally {
      isLoading.value = false;
    }
  }

  bool _validarDados() {
    if (femeaSelecionada.value == null) {
      Get.snackbar(
        'Atenção',
        'Selecione uma fêmea',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.orange,
        colorText: Colors.white,
      );
      return false;
    }

    if (tipoSelecionado.value == 'monta_natural' &&
        machoSelecionado.value == null) {
      Get.snackbar(
        'Atenção',
        'Selecione um macho para monta natural',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.orange,
        colorText: Colors.white,
      );
      return false;
    }

    if (tipoSelecionado.value == 'inseminacao' &&
        touroSemenController.text.isEmpty) {
      Get.snackbar(
        'Atenção',
        'Informe o touro/sêmen para inseminação',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.orange,
        colorText: Colors.white,
      );
      return false;
    }

    if (dataCobertura.value == null) {
      Get.snackbar(
        'Atenção',
        'Selecione a data da cobertura',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.orange,
        colorText: Colors.white,
      );
      return false;
    }

    return true;
  }
}
