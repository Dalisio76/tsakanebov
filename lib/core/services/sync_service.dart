import 'package:get/get.dart';
import '../database/local_database.dart';
import '../../data/services/animal_service.dart';
import '../../data/services/pesagem_service.dart';
import '../../data/services/registro_saude_service.dart';
import '../../data/models/animal_model.dart';
import '../../data/models/pesagem_model.dart';
import '../../data/models/registro_saude_model.dart';
import 'connectivity_service.dart';

class SyncService extends GetxService {
  final LocalDatabase _localDB = LocalDatabase.instance;
  final AnimalService _animalService = AnimalService();
  final PesagemService _pesagemService = PesagemService();
  final RegistroSaudeService _registroSaudeService = RegistroSaudeService();

  var isSyncing = false.obs;
  var syncProgress = 0.0.obs;
  var dadosNaoSincronizados = 0.obs;

  @override
  void onInit() {
    super.onInit();
    atualizarContadorNaoSincronizados();
  }

  Future<void> atualizarContadorNaoSincronizados() async {
    try {
      final contadores = await _localDB.contarTodosNaoSincronizados();
      dadosNaoSincronizados.value =
          contadores['pesagens']! +
          contadores['animais']! +
          contadores['saude']!;
    } catch (e) {
      print('❌ Erro ao contar dados não sincronizados: $e');
    }
  }

  Future<void> sincronizarTudo() async {
    final connectivityService = Get.find<ConnectivityService>();

    if (!connectivityService.isOnline) {
      print('⚠️ Sem conexão. Sincronização adiada.');
      return;
    }

    if (isSyncing.value) {
      print('⚠️ Sincronização já em andamento');
      return;
    }

    try {
      isSyncing.value = true;
      syncProgress.value = 0.0;

      print('🔄 Iniciando sincronização...');

      // 1. Sincronizar animais
      await _sincronizarAnimais();
      syncProgress.value = 0.33;

      // 2. Sincronizar pesagens
      await _sincronizarPesagens();
      syncProgress.value = 0.66;

      // 3. Sincronizar eventos de saúde
      await _sincronizarSaude();
      syncProgress.value = 1.0;

      // Limpar dados já sincronizados
      await _localDB.limparDadosSincronizados();

      // Atualizar contador
      await atualizarContadorNaoSincronizados();

      print('✅ Sincronização completa!');

      Get.snackbar(
        '✅ Sincronização Completa',
        'Todos os dados foram sincronizados com sucesso',
        snackPosition: SnackPosition.BOTTOM,
        duration: const Duration(seconds: 3),
      );
    } catch (e) {
      print('❌ Erro na sincronização: $e');
      Get.snackbar(
        '❌ Erro na Sincronização',
        'Erro: $e',
        snackPosition: SnackPosition.BOTTOM,
        duration: const Duration(seconds: 5),
      );
    } finally {
      isSyncing.value = false;
      syncProgress.value = 0.0;
    }
  }

  Future<void> _sincronizarAnimais() async {
    final animaisOffline = await _localDB.listarAnimaisNaoSincronizados();

    if (animaisOffline.isEmpty) {
      print('✅ Nenhum animal para sincronizar');
      return;
    }

    print('🔄 Sincronizando ${animaisOffline.length} animais...');

    for (var animalData in animaisOffline) {
      try {
        final animal = AnimalModel(
          brinco: animalData['brinco'],
          nome: animalData['nome'],
          grupoId: animalData['grupo_id'],
          paiId: animalData['pai_id'],
          maeId: animalData['mae_id'],
          sexo: animalData['sexo'],
          tipoPele: animalData['tipo_pele'],
          raca: animalData['raca'],
          dataNascimento: DateTime.parse(animalData['data_nascimento']),
          pesoAtualKg: animalData['peso_atual_kg'],
          urlImagem: animalData['url_imagem'],
          observacoes: animalData['observacoes'],
          status: animalData['status'] ?? 'ativo',
        );

        await _animalService.criar(animal);
        await _localDB.marcarAnimalComoSincronizado(animalData['local_id']);

        print('✅ Animal sincronizado: ${animal.brinco}');
      } catch (e) {
        print('❌ Erro ao sincronizar animal ${animalData['brinco']}: $e');
      }
    }
  }

  Future<void> _sincronizarPesagens() async {
    final pesagensOffline = await _localDB.listarPesagensNaoSincronizadas();

    if (pesagensOffline.isEmpty) {
      print('✅ Nenhuma pesagem para sincronizar');
      return;
    }

    print('🔄 Sincronizando ${pesagensOffline.length} pesagens...');

    for (var pesagemData in pesagensOffline) {
      try {
        final pesagem = PesagemModel(
          animalId: pesagemData['animal_id'],
          pesoKg: pesagemData['peso_kg'],
          dataPesagem: DateTime.parse(pesagemData['data_pesagem']),
          tipoPesagem: pesagemData['tipo_pesagem'],
          observacoes: pesagemData['observacoes'],
        );

        await _pesagemService.criar(pesagem);
        await _localDB.marcarPesagemComoSincronizada(pesagemData['local_id']);

        print('✅ Pesagem sincronizada: ${pesagemData['animal_brinco']}');
      } catch (e) {
        print('❌ Erro ao sincronizar pesagem ${pesagemData['animal_brinco']}: $e');
      }
    }
  }

  Future<void> _sincronizarSaude() async {
    final saudeOffline = await _localDB.listarSaudeNaoSincronizado();

    if (saudeOffline.isEmpty) {
      print('✅ Nenhum evento de saúde para sincronizar');
      return;
    }

    print('🔄 Sincronizando ${saudeOffline.length} eventos de saúde...');

    for (var saudeData in saudeOffline) {
      try {
        final registro = RegistroSaudeModel(
          animalId: saudeData['animal_id'],
          tipoEventoId: saudeData['tipo_evento_id'],
          dataEvento: DateTime.parse(saudeData['data_evento']),
          descricao: saudeData['descricao'] ?? '',
          veterinario: saudeData['veterinario'],
          observacoes: saudeData['observacoes'],
          custo: saudeData['custo'] != null
              ? double.tryParse(saudeData['custo'].toString())
              : null,
          proximaAplicacao: saudeData['proxima_aplicacao'] != null
              ? DateTime.parse(saudeData['proxima_aplicacao'])
              : null,
        );

        await _registroSaudeService.criar(registro);
        await _localDB.marcarSaudeComoSincronizado(saudeData['local_id']);

        print('✅ Evento de saúde sincronizado');
      } catch (e) {
        print('❌ Erro ao sincronizar saúde: $e');
      }
    }
  }

  Future<void> cacheAnimaisParaOffline() async {
    try {
      print('📥 Baixando animais para cache offline...');

      final animais = await _animalService.listarAnimaisAtivos();

      final animaisParaCache = animais.map((animal) => {
        'id': animal.id,
        'brinco': animal.brinco,
        'nome': animal.nome,
        'sexo': animal.sexo,
        'peso_atual_kg': animal.pesoAtualKg,
        'grupo_nome': animal.grupoNome,
        'data_nascimento': animal.dataNascimento.toIso8601String(),
        'idade_meses': animal.idadeMeses,
        'atualizado_em': DateTime.now().toIso8601String(),
      }).toList();

      await _localDB.salvarAnimaisNoCache(animaisParaCache);

      print('✅ ${animais.length} animais salvos no cache');
    } catch (e) {
      print('❌ Erro ao cachear animais: $e');
    }
  }
}
