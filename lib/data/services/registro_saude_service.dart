import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/registro_saude_model.dart';

class RegistroSaudeService {
  final _supabase = Supabase.instance.client;

  // Criar registro
  Future<RegistroSaudeModel> criar(RegistroSaudeModel registro) async {
    try {
      final response = await _supabase
          .from('registros_saude')
          .insert(registro.toJson())
          .select('''
            *,
            animais(brinco, nome),
            tipos_evento_saude(nome, categoria)
          ''')
          .single();

      return RegistroSaudeModel.fromJson(response);
    } catch (e) {
      throw Exception('Erro ao criar registro: $e');
    }
  }

  // Listar por animal
  Future<List<RegistroSaudeModel>> listarPorAnimal(String animalId) async {
    try {
      final response = await _supabase
          .from('registros_saude')
          .select('''
            *,
            animais(brinco, nome),
            tipos_evento_saude(nome, categoria)
          ''')
          .eq('animal_id', animalId)
          .order('data_evento', ascending: false);

      return (response as List)
          .map((json) => RegistroSaudeModel.fromJson(json))
          .toList();
    } catch (e) {
      throw Exception('Erro ao listar registros: $e');
    }
  }

  // Listar recentes (últimos 30 dias)
  Future<List<RegistroSaudeModel>> listarRecentes({int dias = 30}) async {
    try {
      final dataLimite = DateTime.now().subtract(Duration(days: dias));

      final response = await _supabase
          .from('registros_saude')
          .select('''
            *,
            animais(brinco, nome),
            tipos_evento_saude(nome, categoria)
          ''')
          .gte('data_evento', dataLimite.toIso8601String().split('T')[0])
          .order('data_evento', ascending: false);

      return (response as List)
          .map((json) => RegistroSaudeModel.fromJson(json))
          .toList();
    } catch (e) {
      throw Exception('Erro ao listar registros recentes: $e');
    }
  }

  // Listar alertas (vacinas vencendo)
  Future<List<RegistroSaudeModel>> listarAlertas({int dias = 30}) async {
    try {
      final hoje = DateTime.now();
      final dataLimite = hoje.add(Duration(days: dias));

      final response = await _supabase
          .from('registros_saude')
          .select('''
            *,
            animais(brinco, nome, status),
            tipos_evento_saude(nome, categoria)
          ''')
          .not('proxima_aplicacao', 'is', null)
          .gte('proxima_aplicacao', hoje.toIso8601String().split('T')[0])
          .lte('proxima_aplicacao',
              dataLimite.toIso8601String().split('T')[0])
          .order('proxima_aplicacao');

      // Filtrar apenas animais ativos
      final registros = (response as List)
          .map((json) => RegistroSaudeModel.fromJson(json))
          .toList();

      return registros;
    } catch (e) {
      throw Exception('Erro ao listar alertas: $e');
    }
  }

  // Calcular custo total de saúde por animal
  Future<double> calcularCustoTotal(String animalId) async {
    try {
      final response = await _supabase
          .from('registros_saude')
          .select('custo')
          .eq('animal_id', animalId)
          .not('custo', 'is', null);

      if (response.isEmpty) return 0.0;

      return (response as List).fold<double>(0.0, (sum, item) {
        return sum + double.parse(item['custo'].toString());
      });
    } catch (e) {
      return 0.0;
    }
  }

  // Estatísticas
  Future<Map<String, dynamic>> obterEstatisticas() async {
    try {
      // Total de registros
      final totalRegistros = await _supabase
          .from('registros_saude')
          .select('id');

      // Custo total
      final custosResponse =
          await _supabase.from('registros_saude').select('custo');

      double custoTotal = 0.0;
      if (custosResponse.isNotEmpty) {
        custoTotal = (custosResponse as List).fold<double>(0.0, (sum, item) {
          if (item['custo'] != null) {
            return sum + double.parse(item['custo'].toString());
          }
          return sum;
        });
      }

      // Alertas pendentes
      final alertas = await listarAlertas(dias: 30);

      return {
        'total_registros': (totalRegistros as List).length,
        'custo_total': custoTotal,
        'alertas_pendentes': alertas.length,
      };
    } catch (e) {
      return {
        'total_registros': 0,
        'custo_total': 0.0,
        'alertas_pendentes': 0,
      };
    }
  }

  // Atualizar registro
  Future<RegistroSaudeModel> atualizar(
      String id, RegistroSaudeModel registro) async {
    try {
      final response = await _supabase
          .from('registros_saude')
          .update(registro.toJson())
          .eq('id', id)
          .select('''
            *,
            animais(brinco, nome),
            tipos_evento_saude(nome, categoria)
          ''')
          .single();

      return RegistroSaudeModel.fromJson(response);
    } catch (e) {
      throw Exception('Erro ao atualizar registro: $e');
    }
  }

  // Deletar registro
  Future<void> deletar(String id) async {
    try {
      await _supabase.from('registros_saude').delete().eq('id', id);
    } catch (e) {
      throw Exception('Erro ao deletar registro: $e');
    }
  }
}
