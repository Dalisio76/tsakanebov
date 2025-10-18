import 'dart:typed_data';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import '../../core/services/cloudinary_service.dart';
import '../../data/models/animal_model.dart';
import '../../data/models/grupo_model.dart';
import '../../data/services/animal_service.dart';
import '../../data/services/grupo_service.dart';
// Imports condicionais para web
import 'dart:html' as html if (dart.library.io) 'dart:io';

class AnimalFormController extends GetxController {
  final AnimalService _animalService = AnimalService();
  final GrupoService _grupoService = GrupoService();

  // Controllers
  final brincoController = TextEditingController();
  final nomeController = TextEditingController();
  final racaController = TextEditingController();
  final tipoPeleController = TextEditingController();
  final pesoController = TextEditingController();
  final urlImagemController = TextEditingController();
  final observacoesController = TextEditingController();

  // Estado
  var isLoading = false.obs;
  var isEditMode = false.obs;
  var criarOutro = false.obs; // NOVO: flag para criar outro
  var isUploadingImage = false.obs;
  var imagemSelecionada = Rx<Uint8List?>(null);
  AnimalModel? animalOriginal;

  // Dropdowns
  var grupos = <GrupoModel>[].obs;
  var possiveisPais = <AnimalModel>[].obs;
  var possiveisMaes = <AnimalModel>[].obs;

  var grupoSelecionado = Rxn<String>();
  var sexoSelecionado = 'M'.obs;
  var statusSelecionado = 'ativo'.obs;
  var paiSelecionado = Rxn<String>();
  var maeSelecionada = Rxn<String>();
  var dataNascimento = Rxn<DateTime>();

  final sexos = ['M', 'F'];
  final statusOptions = ['ativo', 'vendido', 'morto', 'transferido', 'abate'];
  final racas = [
    'Nelore',
    'Angus',
    'Brahman',
    'Gir',
    'Guzerá',
    'Cruzado',
    'Outros'
  ];

  @override
  void onInit() {
    super.onInit();
    carregarDados();

    if (Get.arguments != null && Get.arguments is AnimalModel) {
      animalOriginal = Get.arguments;
      isEditMode.value = true;
      preencherFormulario(animalOriginal!);
    } else {
      dataNascimento.value = DateTime.now();
    }
  }

  Future<void> carregarDados() async {
    try {
      print('Carregando grupos...');
      grupos.value = await _grupoService.listarGrupos();
      print('Grupos carregados: ${grupos.length}');

      print('Carregando pais...');
      possiveisPais.value = await _animalService.listarPossiveisPais();
      print('Pais carregados: ${possiveisPais.length}');

      print('Carregando mães...');
      possiveisMaes.value = await _animalService.listarPossiveisMaes();
      print('Mães carregadas: ${possiveisMaes.length}');
    } catch (e) {
      print('ERRO DETALHADO: $e');
      Get.snackbar('Erro', 'Erro ao carregar dados: $e',
          snackPosition: SnackPosition.BOTTOM);
    }
  }

  void preencherFormulario(AnimalModel animal) {
    brincoController.text = animal.brinco;
    nomeController.text = animal.nome ?? '';
    racaController.text = animal.raca ?? '';
    tipoPeleController.text = animal.tipoPele ?? '';
    pesoController.text =
        animal.pesoAtualKg != null ? animal.pesoAtualKg.toString() : '';
    urlImagemController.text = animal.urlImagem ?? '';
    observacoesController.text = animal.observacoes ?? '';

    grupoSelecionado.value = animal.grupoId;
    sexoSelecionado.value = animal.sexo;
    statusSelecionado.value = animal.status ?? 'ativo';
    paiSelecionado.value = animal.paiId;
    maeSelecionada.value = animal.maeId;
    dataNascimento.value = animal.dataNascimento;
  }

  void limparFormulario() {
    brincoController.clear();
    nomeController.clear();
    racaController.clear();
    tipoPeleController.clear();
    pesoController.clear();
    urlImagemController.clear();
    observacoesController.clear();

    grupoSelecionado.value = null;
    sexoSelecionado.value = 'M';
    statusSelecionado.value = 'ativo';
    paiSelecionado.value = null;
    maeSelecionada.value = null;
    dataNascimento.value = DateTime.now();
    imagemSelecionada.value = null;
  }

  Future<void> salvar() async {
    if (!validarFormulario()) return;

    try {
      isLoading.value = true;

      final animal = AnimalModel(
        id: animalOriginal?.id,
        brinco: brincoController.text.trim(),
        nome: nomeController.text.trim().isEmpty
            ? null
            : nomeController.text.trim(),
        grupoId: grupoSelecionado.value,
        paiId: paiSelecionado.value,
        maeId: maeSelecionada.value,
        sexo: sexoSelecionado.value,
        tipoPele: tipoPeleController.text.trim().isEmpty
            ? null
            : tipoPeleController.text.trim(),
        raca: racaController.text.trim().isEmpty
            ? null
            : racaController.text.trim(),
        dataNascimento: dataNascimento.value!,
        pesoAtualKg: pesoController.text.trim().isEmpty
            ? null
            : double.tryParse(pesoController.text.trim()),
        dataUltimaPesagem:
            pesoController.text.trim().isEmpty ? null : DateTime.now(),
        urlImagem: urlImagemController.text.trim().isEmpty
            ? null
            : urlImagemController.text.trim(),
        observacoes: observacoesController.text.trim().isEmpty
            ? null
            : observacoesController.text.trim(),
        status: statusSelecionado.value,
      );

      if (isEditMode.value) {
        await _animalService.atualizar(animalOriginal!.id!, animal);
        Get.snackbar(
          '✅ Sucesso',
          'Animal atualizado com sucesso!',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.green,
          colorText: Colors.white,
          duration: const Duration(seconds: 2),
        );
        Get.back(result: true);
      } else {
        await _animalService.criar(animal);
        Get.snackbar(
          '✅ Sucesso',
          'Animal "${animal.brinco}" criado com sucesso!',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.green,
          colorText: Colors.white,
          duration: const Duration(seconds: 2),
        );

        // NOVO: Se marcou "criar outro", limpa form, senão volta
        if (criarOutro.value) {
          limparFormulario();
          Get.snackbar(
            '📝 Pronto',
            'Preencha os dados do próximo animal',
            snackPosition: SnackPosition.BOTTOM,
            duration: const Duration(seconds: 1),
          );
        } else {
          Get.back(result: true);
        }
      }
    } catch (e) {
      // Detectar erro de brinco duplicado
      String errorMessage = e.toString().toLowerCase();

      if (errorMessage.contains('duplicate') ||
          errorMessage.contains('unique') ||
          errorMessage.contains('brinco') ||
          errorMessage.contains('already exists')) {
        Get.snackbar(
          '❌ Erro',
          'Número de brinco repetido',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.red.shade600,
          colorText: Colors.white,
          duration: const Duration(seconds: 3),
          icon: const Icon(Icons.error_outline, color: Colors.white),
          margin: const EdgeInsets.all(16),
        );
      } else {
        // Outros erros
        Get.snackbar(
          '❌ Erro',
          'Erro ao salvar animal',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.red.shade600,
          colorText: Colors.white,
          duration: const Duration(seconds: 3),
        );
      }
    } finally {
      isLoading.value = false;
    }
  }

  bool validarFormulario() {
    if (brincoController.text.trim().isEmpty) {
      Get.snackbar('Atenção', 'Brinco é obrigatório',
          snackPosition: SnackPosition.BOTTOM);
      return false;
    }

    if (dataNascimento.value == null) {
      Get.snackbar('Atenção', 'Data de nascimento é obrigatória',
          snackPosition: SnackPosition.BOTTOM);
      return false;
    }

    return true;
  }

  Future<void> selecionarData(BuildContext context) async {
    final data = await showDatePicker(
      context: context,
      initialDate: dataNascimento.value ?? DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime.now(),
      locale: const Locale('pt', 'BR'),
    );

    if (data != null) {
      dataNascimento.value = data;
    }
  }

  String formatarData(DateTime? data) {
    if (data == null) return 'Selecione a data';
    return DateFormat('dd/MM/yyyy').format(data);
  }

  // Método para selecionar e fazer upload da foto
  Future<void> selecionarEUploadFoto() async {
    try {
      if (kIsWeb) {
        // Usar HTML file input para web
        await _selecionarImagemWeb();
      } else {
        // Usar image_picker para mobile
        final picker = ImagePicker();
        final image = await picker.pickImage(
          source: ImageSource.gallery,
          maxWidth: 1920,
          maxHeight: 1080,
          imageQuality: 85,
        );

        if (image == null) {
          print('❌ Nenhuma imagem selecionada');
          return;
        }

        print('📸 Imagem selecionada: ${image.name}');
        final bytes = await image.readAsBytes();
        await _fazerUploadImagem(bytes);
      }
    } catch (e) {
      print('❌ Erro ao selecionar foto: $e');
      imagemSelecionada.value = null;

      Get.snackbar(
        '❌ Erro',
        'Erro ao selecionar foto: $e',
        backgroundColor: Colors.red,
        colorText: Colors.white,
        snackPosition: SnackPosition.BOTTOM,
      );
    }
  }

  // Método específico para web usando HTML file input
  Future<void> _selecionarImagemWeb() async {
    final uploadInput = html.FileUploadInputElement();
    uploadInput.accept = 'image/*';
    uploadInput.click();

    await uploadInput.onChange.first;

    final files = uploadInput.files;
    if (files == null || files.isEmpty) {
      print('❌ Nenhuma imagem selecionada');
      return;
    }

    final file = files[0];
    final reader = html.FileReader();
    reader.readAsArrayBuffer(file);

    await reader.onLoad.first;

    final bytes = reader.result as Uint8List;
    await _fazerUploadImagem(bytes);
  }

  // Método compartilhado para fazer upload
  Future<void> _fazerUploadImagem(Uint8List bytes) async {
    try {
      imagemSelecionada.value = bytes;
      isUploadingImage.value = true;

      Get.snackbar(
        '⏳ Enviando',
        'Fazendo upload da imagem...',
        snackPosition: SnackPosition.BOTTOM,
        duration: const Duration(seconds: 2),
      );

      // Upload para Cloudinary
      final filename = '${DateTime.now().millisecondsSinceEpoch}.jpg';
      final url = await CloudinaryService.uploadImagem(
        bytes: bytes,
        filename: filename,
      );

      if (url != null) {
        urlImagemController.text = url;

        Get.snackbar(
          '✅ Sucesso',
          'Foto enviada com sucesso!',
          backgroundColor: Colors.green,
          colorText: Colors.white,
          snackPosition: SnackPosition.BOTTOM,
        );
      } else {
        imagemSelecionada.value = null;

        Get.snackbar(
          '❌ Erro',
          'Erro ao enviar foto. Tente novamente.',
          backgroundColor: Colors.red,
          colorText: Colors.white,
          snackPosition: SnackPosition.BOTTOM,
        );
      }
    } finally {
      isUploadingImage.value = false;
    }
  }

  // Método para tirar foto com câmera
  Future<void> tirarFoto() async {
    try {
      if (kIsWeb) {
        // Na web, usar file input (não há acesso direto à câmera)
        await _selecionarImagemWeb();
      } else {
        // No mobile, usar câmera
        final picker = ImagePicker();
        final image = await picker.pickImage(
          source: ImageSource.camera,
          maxWidth: 1920,
          maxHeight: 1080,
          imageQuality: 85,
        );

        if (image == null) return;

        final bytes = await image.readAsBytes();
        await _fazerUploadImagem(bytes);
      }
    } catch (e) {
      print('❌ Erro ao tirar foto: $e');
      imagemSelecionada.value = null;

      Get.snackbar(
        '❌ Erro',
        'Erro: $e',
        backgroundColor: Colors.red,
        colorText: Colors.white,
        snackPosition: SnackPosition.BOTTOM,
      );
    }
  }

  // Remover imagem selecionada
  void removerImagem() {
    imagemSelecionada.value = null;
    urlImagemController.clear();
  }

  @override
  void onClose() {
    brincoController.dispose();
    nomeController.dispose();
    racaController.dispose();
    tipoPeleController.dispose();
    pesoController.dispose();
    urlImagemController.dispose();
    observacoesController.dispose();
    super.onClose();
  }
}
