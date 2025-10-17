import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/cobertura_model.dart';

class CoberturaService {
  final _supabase = Supabase.instance.client;

  // Criar cobertura
  Future<CoberturaModel> criar(CoberturaModel cobertura) async {
    try {
      final response = await _supabase
          .from('coberturas')
          .insert(cobertura.toJson())
          .select('''
            *,
            femea:animais!femea_id(brinco),
            macho:animais!macho_id(brinco)
          ''')
          .single();

      return CoberturaModel.fromJson(response);
    } catch (e) {
      throw Exception('Erro ao criar cobertura: $e');
    }
  }

  // Atualizar cobertura
  Future<CoberturaModel> atualizar(String id, CoberturaModel cobertura) async {
    try {
      final response = await _supabase
          .from('coberturas')
          .update(cobertura.toJson())
          .eq('id', id)
          .select('''
            *,
            femea:animais!femea_id(brinco),
            macho:animais!macho_id(brinco)
          ''')
          .single();

      return CoberturaModel.fromJson(response);
    } catch (e) {
      throw Exception('Erro ao atualizar cobertura: $e');
    }
  }

  // Deletar cobertura
  Future<void> deletar(String id) async {
    try {
      await _supabase.from('coberturas').delete().eq('id', id);
    } catch (e) {
      throw Exception('Erro ao deletar cobertura: $e');
    }
  }

  // Listar todas as coberturas
  Future<List<CoberturaModel>> listarTodas() async {
    try {
      final response = await _supabase
          .from('coberturas')
          .select('''
            *,
            femea:animais!femea_id(brinco),
            macho:animais!macho_id(brinco)
          ''')
          .order('data_cobertura', ascending: false);

      return (response as List)
          .map((json) => CoberturaModel.fromJson(json))
          .toList();
    } catch (e) {
      throw Exception('Erro ao listar coberturas: $e');
    }
  }

  // Listar coberturas por fêmea
  Future<List<CoberturaModel>> listarPorFemea(String femeaId) async {
    try {
      final response = await _supabase
          .from('coberturas')
          .select('''
            *,
            femea:animais!femea_id(brinco),
            macho:animais!macho_id(brinco)
          ''')
          .eq('femea_id', femeaId)
          .order('data_cobertura', ascending: false);

      return (response as List)
          .map((json) => CoberturaModel.fromJson(json))
          .toList();
    } catch (e) {
      throw Exception('Erro ao listar coberturas da fêmea: $e');
    }
  }

  // Listar coberturas por período
  Future<List<CoberturaModel>> listarPorPeriodo(
      DateTime inicio, DateTime fim) async {
    try {
      final response = await _supabase
          .from('coberturas')
          .select('''
            *,
            femea:animais!femea_id(brinco),
            macho:animais!macho_id(brinco)
          ''')
          .gte('data_cobertura', inicio.toIso8601String())
          .lte('data_cobertura', fim.toIso8601String())
          .order('data_cobertura', ascending: false);

      return (response as List)
          .map((json) => CoberturaModel.fromJson(json))
          .toList();
    } catch (e) {
      throw Exception('Erro ao listar coberturas por período: $e');
    }
  }

  // Buscar por ID
  Future<CoberturaModel?> buscarPorId(String id) async {
    try {
      final response = await _supabase
          .from('coberturas')
          .select('''
            *,
            femea:animais!femea_id(brinco),
            macho:animais!macho_id(brinco)
          ''')
          .eq('id', id)
          .maybeSingle();

      if (response == null) return null;
      return CoberturaModel.fromJson(response);
    } catch (e) {
      throw Exception('Erro ao buscar cobertura: $e');
    }
  }

  // Contar coberturas por tipo
  Future<Map<String, int>> contarPorTipo({
    DateTime? inicio,
    DateTime? fim,
  }) async {
    try {
      var query = _supabase.from('coberturas').select('tipo');

      if (inicio != null) {
        query = query.gte('data_cobertura', inicio.toIso8601String());
      }
      if (fim != null) {
        query = query.lte('data_cobertura', fim.toIso8601String());
      }

      final response = await query;

      Map<String, int> contagem = {
        'monta_natural': 0,
        'inseminacao': 0,
      };

      for (var item in response as List) {
        final tipo = item['tipo'] ?? 'monta_natural';
        contagem[tipo] = (contagem[tipo] ?? 0) + 1;
      }

      return contagem;
    } catch (e) {
      throw Exception('Erro ao contar coberturas: $e');
    }
  }
}
