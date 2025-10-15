import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import '../../data/models/animal_model.dart';
import '../../data/models/pesagem_model.dart';
import '../../data/services/animal_service.dart';
import '../../data/services/pesagem_service.dart';

class PesagemController extends GetxController {
  final AnimalService _animalService = AnimalService();
  final PesagemService _pesagemService = PesagemService();

  // Controllers
  final brincoController = TextEditingController();
  final pesoController = TextEditingController();
  final observacoesController = TextEditingController();

  // Estado
  var isLoading = false.obs;
  var isBuscandoAnimal = false.obs;
  var animalSelecionado = Rxn<AnimalModel>();
  var dataPesagem = Rxn<DateTime>();
  var tipoPesagem = 'rotina'.obs;

  final tiposPesagem = ['nascimento', 'rotina', 'venda'];

  @override
  void onInit() {
    super.onInit();
    dataPesagem.value = DateTime.now();
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

      // Se encontrou exatamente, seleciona
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

        // Buscar última pesagem para referência
        final ultimaPesagem =
            await _pesagemService.buscarUltimaPesagem(animalExato.id!);
        if (ultimaPesagem != null) {
          Get.snackbar(
            '📊 Última pesagem',
            '${ultimaPesagem.pesoKg.toStringAsFixed(1)} kg em ${DateFormat('dd/MM/yyyy').format(ultimaPesagem.dataPesagem)}',
            snackPosition: SnackPosition.BOTTOM,
            duration: const Duration(seconds: 3),
          );
        }
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

  // Registrar pesagem
  Future<void> registrarPesagem() async {
    if (!validarFormulario()) return;

    try {
      isLoading.value = true;

      final pesagem = PesagemModel(
        animalId: animalSelecionado.value!.id!,
        pesoKg: double.parse(pesoController.text.trim()),
        dataPesagem: dataPesagem.value!,
        tipoPesagem: tipoPesagem.value,
        observacoes: observacoesController.text.trim().isEmpty
            ? null
            : observacoesController.text.trim(),
      );

      final resultado = await _pesagemService.criar(pesagem);

      // Mensagem de sucesso com GMD
      String mensagem =
          'Peso: ${resultado.pesoKg.toStringAsFixed(1)} kg registrado!';
      if (resultado.gmdKg != null) {
        mensagem +=
            '\nGMD: ${resultado.gmdKg!.toStringAsFixed(3)} kg/dia ${resultado.gmdIcone}';
      }

      Get.snackbar(
        '✅ Sucesso',
        mensagem,
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.green,
        colorText: Colors.white,
        duration: const Duration(seconds: 3),
      );

      limparFormulario();
    } catch (e) {
      Get.snackbar(
        '❌ Erro',
        'Erro ao registrar pesagem: $e',
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

    if (pesoController.text.trim().isEmpty) {
      Get.snackbar('Atenção', 'Digite o peso',
          snackPosition: SnackPosition.BOTTOM);
      return false;
    }

    final peso = double.tryParse(pesoController.text.trim());
    if (peso == null || peso <= 0) {
      Get.snackbar('Atenção', 'Peso inválido',
          snackPosition: SnackPosition.BOTTOM);
      return false;
    }

    if (dataPesagem.value == null) {
      Get.snackbar('Atenção', 'Selecione a data',
          snackPosition: SnackPosition.BOTTOM);
      return false;
    }

    return true;
  }

  void limparFormulario() {
    brincoController.clear();
    pesoController.clear();
    observacoesController.clear();
    animalSelecionado.value = null;
    dataPesagem.value = DateTime.now();
    tipoPesagem.value = 'rotina';
  }

  Future<void> selecionarData(BuildContext context) async {
    final data = await showDatePicker(
      context: context,
      initialDate: dataPesagem.value ?? DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime.now(),
      locale: const Locale('pt', 'BR'),
    );

    if (data != null) {
      dataPesagem.value = data;
    }
  }

  String formatarData(DateTime? data) {
    if (data == null) return 'Selecione';
    return DateFormat('dd/MM/yyyy').format(data);
  }

  @override
  void onClose() {
    brincoController.dispose();
    pesoController.dispose();
    observacoesController.dispose();
    super.onClose();
  }
}
