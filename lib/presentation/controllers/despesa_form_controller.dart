import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import '../../data/models/despesa_model.dart';
import '../../data/models/categoria_custo_model.dart';
import '../../data/models/animal_model.dart';
import '../../data/models/grupo_model.dart';
import '../../data/services/despesa_service.dart';
import '../../data/services/categoria_custo_service.dart';
import '../../data/services/animal_service.dart';
import '../../data/services/grupo_service.dart';

class DespesaFormController extends GetxController {
  final DespesaService _despesaService = DespesaService();
  final CategoriaCustoService _categoriaService = CategoriaCustoService();
  final AnimalService _animalService = AnimalService();
  final GrupoService _grupoService = GrupoService();

  // Controllers
  final descricaoController = TextEditingController();
  final valorController = TextEditingController();
  final quantidadeController = TextEditingController();
  final unidadeController = TextEditingController();
  final fornecedorController = TextEditingController();
  final notaFiscalController = TextEditingController();

  // Observables
  var isLoading = false.obs;
  var isEditMode = false.obs;
  var dataDespesa = Rxn<DateTime>();
  var categoriaSelecionada = Rxn<String>();
  var animalSelecionado = Rxn<String>();
  var grupoSelecionado = Rxn<String>();
  var vinculacaoTipo = 'nenhum'.obs; // nenhum, animal, grupo

  // Listas
  var categorias = <CategoriaCustoModel>[].obs;
  var animais = <AnimalModel>[].obs;
  var grupos = <GrupoModel>[].obs;

  // Dados originais (para edição)
  DespesaModel? despesaOriginal;

  @override
  void onInit() {
    super.onInit();
    carregarDados();

    // Verificar se é edição
    if (Get.arguments != null && Get.arguments is DespesaModel) {
      despesaOriginal = Get.arguments;
      preencherFormulario(despesaOriginal!);
      isEditMode.value = true;
    } else {
      dataDespesa.value = DateTime.now();
    }
  }

  @override
  void onClose() {
    descricaoController.dispose();
    valorController.dispose();
    quantidadeController.dispose();
    unidadeController.dispose();
    fornecedorController.dispose();
    notaFiscalController.dispose();
    super.onClose();
  }

  Future<void> carregarDados() async {
    try {
      categorias.value = await _categoriaService.listarCategorias();
      animais.value = await _animalService.listarAnimais(apenasAtivos: true);
      grupos.value = await _grupoService.listarGrupos(apenasAtivos: true);
    } catch (e) {
      Get.snackbar(
        'Erro',
        'Erro ao carregar dados: $e',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red.shade600,
        colorText: Colors.white,
      );
    }
  }

  void preencherFormulario(DespesaModel despesa) {
    descricaoController.text = despesa.descricao;
    valorController.text = despesa.valor.toStringAsFixed(2);
    dataDespesa.value = despesa.dataDespesa;
    categoriaSelecionada.value = despesa.categoriaId;

    if (despesa.quantidade != null) {
      quantidadeController.text = despesa.quantidade!.toStringAsFixed(2);
    }
    if (despesa.unidade != null) {
      unidadeController.text = despesa.unidade!;
    }
    if (despesa.fornecedor != null) {
      fornecedorController.text = despesa.fornecedor!;
    }
    if (despesa.notaFiscal != null) {
      notaFiscalController.text = despesa.notaFiscal!;
    }

    if (despesa.animalId != null) {
      vinculacaoTipo.value = 'animal';
      animalSelecionado.value = despesa.animalId;
    } else if (despesa.grupoId != null) {
      vinculacaoTipo.value = 'grupo';
      grupoSelecionado.value = despesa.grupoId;
    }
  }

  Future<void> selecionarData() async {
    final data = await showDatePicker(
      context: Get.context!,
      initialDate: dataDespesa.value ?? DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime.now(),
      locale: Locale('pt', 'BR'),
    );

    if (data != null) {
      dataDespesa.value = data;
    }
  }

  void limparVinculacao() {
    animalSelecionado.value = null;
    grupoSelecionado.value = null;
  }

  bool validarFormulario() {
    if (descricaoController.text.trim().isEmpty) {
      Get.snackbar(
        'Atenção',
        'Preencha a descrição',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.orange,
        colorText: Colors.white,
      );
      return false;
    }

    if (valorController.text.trim().isEmpty) {
      Get.snackbar(
        'Atenção',
        'Preencha o valor',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.orange,
        colorText: Colors.white,
      );
      return false;
    }

    final valor = double.tryParse(valorController.text.trim());
    if (valor == null || valor <= 0) {
      Get.snackbar(
        'Atenção',
        'Valor deve ser maior que zero',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.orange,
        colorText: Colors.white,
      );
      return false;
    }

    if (dataDespesa.value == null) {
      Get.snackbar(
        'Atenção',
        'Selecione a data da despesa',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.orange,
        colorText: Colors.white,
      );
      return false;
    }

    return true;
  }

  Future<void> salvar() async {
    if (!validarFormulario()) return;

    try {
      isLoading.value = true;

      final despesa = DespesaModel(
        id: despesaOriginal?.id,
        categoriaId: categoriaSelecionada.value,
        descricao: descricaoController.text.trim(),
        valor: double.parse(valorController.text.trim()),
        dataDespesa: dataDespesa.value!,
        animalId: vinculacaoTipo.value == 'animal' ? animalSelecionado.value : null,
        grupoId: vinculacaoTipo.value == 'grupo' ? grupoSelecionado.value : null,
        quantidade: quantidadeController.text.trim().isEmpty
            ? null
            : double.tryParse(quantidadeController.text.trim()),
        unidade: unidadeController.text.trim().isEmpty
            ? null
            : unidadeController.text.trim(),
        fornecedor: fornecedorController.text.trim().isEmpty
            ? null
            : fornecedorController.text.trim(),
        notaFiscal: notaFiscalController.text.trim().isEmpty
            ? null
            : notaFiscalController.text.trim(),
      );

      if (isEditMode.value) {
        await _despesaService.atualizar(despesaOriginal!.id!, despesa);
      } else {
        await _despesaService.criar(despesa);
      }

      // Voltar para a tela anterior e mostrar mensagem
      Get.back(result: true);

      // Mostrar mensagem de sucesso após voltar
      Get.snackbar(
        'Sucesso',
        isEditMode.value
            ? 'Despesa atualizada com sucesso!'
            : 'Despesa registrada com sucesso!',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.green,
        colorText: Colors.white,
        duration: Duration(seconds: 3),
        margin: EdgeInsets.all(16),
        borderRadius: 8,
      );
    } catch (e) {
      Get.snackbar(
        'Erro',
        'Erro ao salvar despesa: $e',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red.shade600,
        colorText: Colors.white,
        duration: Duration(seconds: 3),
      );
    } finally {
      isLoading.value = false;
    }
  }
}
