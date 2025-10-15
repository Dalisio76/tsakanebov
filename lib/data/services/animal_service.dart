import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/animal_model.dart';

class AnimalService {
  final _supabase = Supabase.instance.client;

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

      final response = await query.order('brinco');

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

  // Buscar por brinco
  Future<List<AnimalModel>> buscarPorBrinco(String brinco) async {
    try {
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

  // Criar
  Future<AnimalModel> criar(AnimalModel animal) async {
    try {
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
