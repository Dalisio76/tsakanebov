import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:get/get.dart';
import '../models/animal_model.dart';
import '../../core/database/local_database.dart';
import '../../core/services/connectivity_service.dart';
import '../../core/services/sync_service.dart';

class AnimalService {
  final _supabase = Supabase.instance.client;
  final _localDB = LocalDatabase.instance;

  // Listar animais com joins
  Future<List<AnimalModel>> listarAnimais({
    bool? apenasAtivos = true,
    String? grupoId,
    String? sexo,
  }) async {
    try {
      var query = _supabase.from('animais').select('''
            *,
            grupos(nome),
            pai:pai_id(brinco),
            mae:mae_id(brinco)
          ''');

      if (apenasAtivos == true) {
        query = query.eq('status', 'ativo');
      }

      if (grupoId != null && grupoId.isNotEmpty) {
        query = query.eq('grupo_id', grupoId);
      }

      if (sexo != null && sexo.isNotEmpty) {
        query = query.eq('sexo', sexo);
      }

      final response = await query.order('criado_em', ascending: false);

      return (response as List)
          .map((json) => AnimalModel.fromJson(json))
          .toList();
    } catch (e) {
      throw Exception('Erro ao listar animais: $e');
    }
  }

  // Buscar por ID
  Future<AnimalModel?> buscarPorId(String id) async {
    try {
      final response = await _supabase
          .from('animais')
          .select('''
            *,
            grupos(nome),
            pai:pai_id(brinco),
            mae:mae_id(brinco)
          ''')
          .eq('id', id)
          .single();

      return AnimalModel.fromJson(response);
    } catch (e) {
      throw Exception('Erro ao buscar animal: $e');
    }
  }

  // Buscar por brinco (com suporte offline)
  Future<List<AnimalModel>> buscarPorBrinco(String brinco) async {
    try {
      final connectivityService = Get.find<ConnectivityService>();

      if (!connectivityService.isOnline) {
        // MODO OFFLINE - Buscar no cache local
        print('📴 OFFLINE: Buscando animal no cache local');

        final resultados = await _localDB.buscarAnimaisNoCache(brinco);

        if (resultados.isEmpty) {
          return [];
        }

        // Converter dados do cache para AnimalModel
        return resultados.map((data) {
          return AnimalModel(
            id: data['id'],
            brinco: data['brinco'],
            nome: data['nome'],
            sexo: data['sexo'],
            pesoAtualKg: data['peso_atual_kg'],
            dataNascimento: DateTime.parse(data['data_nascimento']),
            idadeMeses: data['idade_meses'],
            grupoNome: data['grupo_nome'],
          );
        }).toList();
      }

      // MODO ONLINE - Buscar no Supabase
      print('🌐 ONLINE: Buscando animal no Supabase');
      final response = await _supabase
          .from('animais')
          .select('''
            *,
            grupos(nome),
            pai:pai_id(brinco),
            mae:mae_id(brinco)
          ''')
          .ilike('brinco', '%$brinco%')
          .eq('status', 'ativo')
          .order('brinco');

      return (response as List)
          .map((json) => AnimalModel.fromJson(json))
          .toList();
    } catch (e) {
      throw Exception('Erro ao buscar animais: $e');
    }
  }

  // Listar possíveis pais (machos ativos)
  Future<List<AnimalModel>> listarPossiveisPais() async {
    try {
      final response = await _supabase
          .from('animais')
          .select('id, brinco, nome, sexo')
          .eq('sexo', 'M')
          .eq('status', 'ativo')
          .order('brinco');

      return (response as List)
          .map((json) => AnimalModel.fromJsonSimple(json))
          .toList();
    } catch (e) {
      print('Erro ao listar pais: $e'); // Debug
      throw Exception('Erro ao listar pais: $e');
    }
  }

  // Listar possíveis mães (fêmeas ativas)
  Future<List<AnimalModel>> listarPossiveisMaes() async {
    try {
      final response = await _supabase
          .from('animais')
          .select('id, brinco, nome, sexo')
          .eq('sexo', 'F')
          .eq('status', 'ativo')
          .order('brinco');

      return (response as List)
          .map((json) => AnimalModel.fromJsonSimple(json))
          .toList();
    } catch (e) {
      print('Erro ao listar mães: $e'); // Debug
      throw Exception('Erro ao listar mães: $e');
    }
  }

  // Criar (com suporte offline)
  Future<AnimalModel> criar(AnimalModel animal) async {
    try {
      final connectivityService = Get.find<ConnectivityService>();

      if (!connectivityService.isOnline) {
        // MODO OFFLINE - Salvar localmente
        print('📴 OFFLINE: Salvando animal localmente');

        final localId = DateTime.now().millisecondsSinceEpoch.toString();
        await _localDB.inserirAnimalOffline({
          'local_id': localId,
          'brinco': animal.brinco,
          'nome': animal.nome,
          'grupo_id': animal.grupoId,
          'pai_id': animal.paiId,
          'mae_id': animal.maeId,
          'sexo': animal.sexo,
          'tipo_pele': animal.tipoPele,
          'raca': animal.raca,
          'data_nascimento': animal.dataNascimento.toIso8601String(),
          'peso_atual_kg': animal.pesoAtualKg,
          'url_imagem': animal.urlImagem,
          'observacoes': animal.observacoes,
          'status': animal.status ?? 'ativo',
          'criado_em': DateTime.now().toIso8601String(),
          'sincronizado': 0,
        });

        // Atualizar contador de dados não sincronizados
        if (Get.isRegistered<SyncService>()) {
          Get.find<SyncService>().atualizarContadorNaoSincronizados();
        }

        return animal;
      }

      // MODO ONLINE - Salvar no Supabase
      print('🌐 ONLINE: Salvando animal no Supabase');
      final response = await _supabase
          .from('animais')
          .insert(animal.toJson())
          .select('''
            *,
            grupos(nome),
            pai:pai_id(brinco),
            mae:mae_id(brinco)
          ''')
          .single();

      return AnimalModel.fromJson(response);
    } catch (e) {
      throw Exception('Erro ao criar animal: $e');
    }
  }

  // Método auxiliar para listar animais ativos (usado para cache)
  Future<List<AnimalModel>> listarAnimaisAtivos() async {
    return await listarAnimais(apenasAtivos: true);
  }

  // Atualizar
  Future<AnimalModel> atualizar(String id, AnimalModel animal) async {
    try {
      final response = await _supabase
          .from('animais')
          .update(animal.toJson())
          .eq('id', id)
          .select('''
            *,
            grupos(nome),
            pai:pai_id(brinco),
            mae:mae_id(brinco)
          ''')
          .single();

      return AnimalModel.fromJson(response);
    } catch (e) {
      throw Exception('Erro ao atualizar animal: $e');
    }
  }

  // Deletar (soft delete)
  Future<void> deletar(String id) async {
    try {
      await _supabase
          .from('animais')
          .update({'status': 'morto'})
          .eq('id', id);
    } catch (e) {
      throw Exception('Erro ao deletar animal: $e');
    }
  }
}
