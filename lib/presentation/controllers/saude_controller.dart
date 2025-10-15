import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import '../../data/models/animal_model.dart';
import '../../data/models/tipo_evento_saude_model.dart';
import '../../data/models/registro_saude_model.dart';
import '../../data/services/animal_service.dart';
import '../../data/services/tipo_evento_saude_service.dart';
import '../../data/services/registro_saude_service.dart';

class SaudeController extends GetxController {
  final AnimalService _animalService = AnimalService();
  final TipoEventoSaudeService _tipoService = TipoEventoSaudeService();
  final RegistroSaudeService _saudeService = RegistroSaudeService();

  // Controllers
  final brincoController = TextEditingController();
  final descricaoController = TextEditingController();
  final veterinarioController = TextEditingController();
  final custoController = TextEditingController();
  final observacoesController = TextEditingController();

  // Estado
  var isLoading = false.obs;
  var isBuscandoAnimal = false.obs;
  var animalSelecionado = Rxn<AnimalModel>();
  var tiposEvento = <TipoEventoSaudeModel>[].obs;
  var tipoSelecionado = Rxn<String>();
  var dataEvento = Rxn<DateTime>();
  var proximaAplicacao = Rxn<DateTime>();
  var temProximaDose = false.obs;

  @override
  void onInit() {
    super.onInit();
    dataEvento.value = DateTime.now();
    carregarTiposEvento();
  }

  Future<void> carregarTiposEvento() async {
    try {
      tiposEvento.value = await _tipoService.listarTodos();
    } catch (e) {
      Get.snackbar('Erro', 'Erro ao carregar tipos de evento: $e',
          snackPosition: SnackPosition.BOTTOM);
    }
  }

  // Buscar animal por brinco
  Future<void> buscarAnimal() async {
    final brinco = brincoController.text.trim();
    if (brinco.isEmpty) {
      Get.snackbar('Atenção', 'Digite o brinco do animal',
          snackPosition: SnackPosition.BOTTOM);
      return;
    }

    try {
      isBuscandoAnimal.value = true;
      final animais = await _animalService.buscarPorBrinco(brinco);

      if (animais.isEmpty) {
        Get.snackbar(
          '❌ Não encontrado',
          'Animal com brinco "$brinco" não foi encontrado',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.orange.shade100,
        );
        animalSelecionado.value = null;
        return;
      }

      final animalExato =
          animais.firstWhereOrNull((a) => a.brinco == brinco);
      if (animalExato != null) {
        animalSelecionado.value = animalExato;
        Get.snackbar(
          '✅ Animal encontrado',
          '${animalExato.brinco}${animalExato.nome != null ? " (${animalExato.nome})" : ""}',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.green.shade100,
          duration: const Duration(seconds: 2),
        );
      } else {
        animalSelecionado.value = animais.first;
      }
    } catch (e) {
      Get.snackbar('Erro', 'Erro ao buscar animal: $e',
          snackPosition: SnackPosition.BOTTOM);
    } finally {
      isBuscandoAnimal.value = false;
    }
  }

  // Registrar evento
  Future<void> registrarEvento() async {
    if (!validarFormulario()) return;

    try {
      isLoading.value = true;

      final registro = RegistroSaudeModel(
        animalId: animalSelecionado.value!.id!,
        tipoEventoId: tipoSelecionado.value,
        dataEvento: dataEvento.value!,
        descricao: descricaoController.text.trim(),
        veterinario: veterinarioController.text.trim().isEmpty
            ? null
            : veterinarioController.text.trim(),
        custo: custoController.text.trim().isEmpty
            ? null
            : double.tryParse(custoController.text.trim()),
        proximaAplicacao: temProximaDose.value ? proximaAplicacao.value : null,
        observacoes: observacoesController.text.trim().isEmpty
            ? null
            : observacoesController.text.trim(),
      );

      await _saudeService.criar(registro);

      Get.snackbar(
        '✅ Sucesso',
        'Evento registrado com sucesso!',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.green,
        colorText: Colors.white,
        duration: const Duration(seconds: 2),
      );

      limparFormulario();
    } catch (e) {
      Get.snackbar(
        '❌ Erro',
        'Erro ao registrar evento: $e',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    } finally {
      isLoading.value = false;
    }
  }

  bool validarFormulario() {
    if (animalSelecionado.value == null) {
      Get.snackbar('Atenção', 'Busque um animal primeiro',
          snackPosition: SnackPosition.BOTTOM);
      return false;
    }

    if (tipoSelecionado.value == null) {
      Get.snackbar('Atenção', 'Selecione o tipo de evento',
          snackPosition: SnackPosition.BOTTOM);
      return false;
    }

    if (descricaoController.text.trim().isEmpty) {
      Get.snackbar('Atenção', 'Digite a descrição',
          snackPosition: SnackPosition.BOTTOM);
      return false;
    }

    if (dataEvento.value == null) {
      Get.snackbar('Atenção', 'Selecione a data do evento',
          snackPosition: SnackPosition.BOTTOM);
      return false;
    }

    if (temProximaDose.value && proximaAplicacao.value == null) {
      Get.snackbar('Atenção', 'Selecione a data da próxima aplicação',
          snackPosition: SnackPosition.BOTTOM);
      return false;
    }

    return true;
  }

  void limparFormulario() {
    brincoController.clear();
    descricaoController.clear();
    veterinarioController.clear();
    custoController.clear();
    observacoesController.clear();
    animalSelecionado.value = null;
    tipoSelecionado.value = null;
    dataEvento.value = DateTime.now();
    proximaAplicacao.value = null;
    temProximaDose.value = false;
  }

  Future<void> selecionarDataEvento(BuildContext context) async {
    final data = await showDatePicker(
      context: context,
      initialDate: dataEvento.value ?? DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime.now(),
      locale: const Locale('pt', 'BR'),
    );

    if (data != null) {
      dataEvento.value = data;
    }
  }

  Future<void> selecionarProximaAplicacao(BuildContext context) async {
    final data = await showDatePicker(
      context: context,
      initialDate: proximaAplicacao.value ??
          DateTime.now().add(const Duration(days: 30)),
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 365)),
      locale: const Locale('pt', 'BR'),
    );

    if (data != null) {
      proximaAplicacao.value = data;
    }
  }

  String formatarData(DateTime? data) {
    if (data == null) return 'Selecione';
    return DateFormat('dd/MM/yyyy').format(data);
  }

  @override
  void onClose() {
    brincoController.dispose();
    descricaoController.dispose();
    veterinarioController.dispose();
    custoController.dispose();
    observacoesController.dispose();
    super.onClose();
  }
}
