import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/parto_model.dart';

class PartoService {
  final _supabase = Supabase.instance.client;

  // Criar parto
  Future<PartoModel> criar(PartoModel parto) async {
    try {
      final response = await _supabase
          .from('partos')
          .insert(parto.toJson())
          .select('''
            *,
            mae:animais!mae_id(brinco),
            cobertura:coberturas(data_cobertura)
          ''')
          .single();

      return PartoModel.fromJson(response);
    } catch (e) {
      throw Exception('Erro ao criar parto: $e');
    }
  }

  // Atualizar parto
  Future<PartoModel> atualizar(String id, PartoModel parto) async {
    try {
      final response = await _supabase
          .from('partos')
          .update(parto.toJson())
          .eq('id', id)
          .select('''
            *,
            mae:animais!mae_id(brinco),
            cobertura:coberturas(data_cobertura)
          ''')
          .single();

      return PartoModel.fromJson(response);
    } catch (e) {
      throw Exception('Erro ao atualizar parto: $e');
    }
  }

  // Deletar parto
  Future<void> deletar(String id) async {
    try {
      await _supabase.from('partos').delete().eq('id', id);
    } catch (e) {
      throw Exception('Erro ao deletar parto: $e');
    }
  }

  // Listar todos
  Future<List<PartoModel>> listarTodos() async {
    try {
      final response = await _supabase
          .from('partos')
          .select('''
            *,
            mae:animais!mae_id(brinco),
            cobertura:coberturas(data_cobertura)
          ''')
          .order('data_parto', ascending: false);

      return (response as List)
          .map((json) => PartoModel.fromJson(json))
          .toList();
    } catch (e) {
      throw Exception('Erro ao listar partos: $e');
    }
  }

  // Listar por mãe
  Future<List<PartoModel>> listarPorMae(String maeId) async {
    try {
      final response = await _supabase
          .from('partos')
          .select('''
            *,
            mae:animais!mae_id(brinco),
            cobertura:coberturas(data_cobertura)
          ''')
          .eq('mae_id', maeId)
          .order('data_parto', ascending: false);

      return (response as List)
          .map((json) => PartoModel.fromJson(json))
          .toList();
    } catch (e) {
      throw Exception('Erro ao listar partos da mãe: $e');
    }
  }

  // Listar por período
  Future<List<PartoModel>> listarPorPeriodo(
      DateTime inicio, DateTime fim) async {
    try {
      final response = await _supabase
          .from('partos')
          .select('''
            *,
            mae:animais!mae_id(brinco),
            cobertura:coberturas(data_cobertura)
          ''')
          .gte('data_parto', inicio.toIso8601String())
          .lte('data_parto', fim.toIso8601String())
          .order('data_parto', ascending: false);

      return (response as List)
          .map((json) => PartoModel.fromJson(json))
          .toList();
    } catch (e) {
      throw Exception('Erro ao listar partos por período: $e');
    }
  }

  // Estatísticas de partos
  Future<Map<String, dynamic>> calcularEstatisticas({
    DateTime? inicio,
    DateTime? fim,
  }) async {
    try {
      var query = _supabase.from('partos').select('*');

      if (inicio != null) {
        query = query.gte('data_parto', inicio.toIso8601String());
      }
      if (fim != null) {
        query = query.lte('data_parto', fim.toIso8601String());
      }

      final response = await query;
      final partos = response as List;

      int totalPartos = partos.length;
      int bezerrosVivos = 0;
      int bezerrosMortos = 0;
      int partosNormais = 0;
      int partosAssistidos = 0;
      int partosCesariana = 0;

      for (var parto in partos) {
        bezerrosVivos += (parto['bezerros_vivos'] ?? 0) as int;
        bezerrosMortos += (parto['bezerros_mortos'] ?? 0) as int;

        switch (parto['tipo_parto']) {
          case 'normal':
            partosNormais++;
            break;
          case 'assistido':
            partosAssistidos++;
            break;
          case 'cesariana':
            partosCesariana++;
            break;
        }
      }

      double taxaSobrevivencia = bezerrosVivos + bezerrosMortos > 0
          ? (bezerrosVivos / (bezerrosVivos + bezerrosMortos)) * 100
          : 0.0;

      return {
        'total_partos': totalPartos,
        'bezerros_vivos': bezerrosVivos,
        'bezerros_mortos': bezerrosMortos,
        'taxa_sobrevivencia': taxaSobrevivencia,
        'partos_normais': partosNormais,
        'partos_assistidos': partosAssistidos,
        'partos_cesariana': partosCesariana,
      };
    } catch (e) {
      throw Exception('Erro ao calcular estatísticas: $e');
    }
  }

  // Buscar por ID
  Future<PartoModel?> buscarPorId(String id) async {
    try {
      final response = await _supabase
          .from('partos')
          .select('''
            *,
            mae:animais!mae_id(brinco),
            cobertura:coberturas(data_cobertura)
          ''')
          .eq('id', id)
          .maybeSingle();

      if (response == null) return null;
      return PartoModel.fromJson(response);
    } catch (e) {
      throw Exception('Erro ao buscar parto: $e');
    }
  }
}
