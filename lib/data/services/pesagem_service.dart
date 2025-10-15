import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/pesagem_model.dart';

class PesagemService {
  final _supabase = Supabase.instance.client;

  // Criar nova pesagem
  Future<PesagemModel> criar(PesagemModel pesagem) async {
    try {
      final response = await _supabase
          .from('historico_peso')
          .insert(pesagem.toJson())
          .select('''
            *,
            animais(brinco, nome)
          ''')
          .single();

      return PesagemModel.fromJson(response);
    } catch (e) {
      throw Exception('Erro ao criar pesagem: $e');
    }
  }

  // Listar pesagens de um animal específico
  Future<List<PesagemModel>> listarPorAnimal(String animalId) async {
    try {
      final response = await _supabase
          .from('historico_peso')
          .select('''
            *,
            animais(brinco, nome)
          ''')
          .eq('animal_id', animalId)
          .order('data_pesagem', ascending: false);

      return (response as List)
          .map((json) => PesagemModel.fromJson(json))
          .toList();
    } catch (e) {
      throw Exception('Erro ao listar pesagens: $e');
    }
  }

  // Listar todas as pesagens recentes (últimos 30 dias)
  Future<List<PesagemModel>> listarRecentes({int dias = 30}) async {
    try {
      final dataLimite = DateTime.now().subtract(Duration(days: dias));

      final response = await _supabase
          .from('historico_peso')
          .select('''
            *,
            animais(brinco, nome)
          ''')
          .gte('data_pesagem', dataLimite.toIso8601String().split('T')[0])
          .order('data_pesagem', ascending: false);

      return (response as List)
          .map((json) => PesagemModel.fromJson(json))
          .toList();
    } catch (e) {
      throw Exception('Erro ao listar pesagens recentes: $e');
    }
  }

  // Buscar última pesagem de um animal
  Future<PesagemModel?> buscarUltimaPesagem(String animalId) async {
    try {
      final response = await _supabase
          .from('historico_peso')
          .select('''
            *,
            animais(brinco, nome)
          ''')
          .eq('animal_id', animalId)
          .order('data_pesagem', ascending: false)
          .limit(1)
          .maybeSingle();

      if (response == null) return null;
      return PesagemModel.fromJson(response);
    } catch (e) {
      throw Exception('Erro ao buscar última pesagem: $e');
    }
  }

  // Calcular GMD médio de um animal
  Future<double?> calcularGmdMedio(String animalId) async {
    try {
      final response = await _supabase
          .from('historico_peso')
          .select('gmd_kg')
          .eq('animal_id', animalId)
          .not('gmd_kg', 'is', null);

      if (response.isEmpty) return null;

      final gmds = (response as List)
          .map((item) => double.parse(item['gmd_kg'].toString()))
          .toList();

      return gmds.reduce((a, b) => a + b) / gmds.length;
    } catch (e) {
      return null;
    }
  }

  // Listar animais que não pesam há X dias
  Future<List<Map<String, dynamic>>> listarAnimaisParaPesar({int diasSemPesar = 30}) async {
    try {
      final dataLimite = DateTime.now().subtract(Duration(days: diasSemPesar));

      // Buscar todos os animais ativos
      final todosAnimais = await _supabase
          .from('animais')
          .select('id, brinco, nome, peso_atual_kg, data_ultima_pesagem')
          .eq('status', 'ativo')
          .order('brinco');

      // Filtrar os que não pesam há X dias
      final animaisParaPesar = (todosAnimais as List).where((animal) {
        if (animal['data_ultima_pesagem'] == null) return true;

        final ultimaPesagem = DateTime.parse(animal['data_ultima_pesagem']);
        return ultimaPesagem.isBefore(dataLimite);
      }).map((e) => e as Map<String, dynamic>).toList();

      return animaisParaPesar;
    } catch (e) {
      throw Exception('Erro ao listar animais para pesar: $e');
    }
  }

  // Estatísticas gerais
  Future<Map<String, dynamic>> obterEstatisticas() async {
    try {
      // Total de pesagens
      final totalPesagens = await _supabase
          .from('historico_peso')
          .select('id');

      // GMD médio geral (últimos 90 dias)
      final dataLimite = DateTime.now().subtract(const Duration(days: 90));
      final pesagensRecentes = await _supabase
          .from('historico_peso')
          .select('gmd_kg')
          .gte('data_pesagem', dataLimite.toIso8601String().split('T')[0])
          .not('gmd_kg', 'is', null);

      double? gmdMedio;
      if (pesagensRecentes.isNotEmpty) {
        final gmds = (pesagensRecentes as List)
            .map((item) => double.parse(item['gmd_kg'].toString()))
            .toList();
        gmdMedio = gmds.reduce((a, b) => a + b) / gmds.length;
      }

      return {
        'total_pesagens': (totalPesagens as List).length,
        'gmd_medio': gmdMedio,
      };
    } catch (e) {
      return {
        'total_pesagens': 0,
        'gmd_medio': null,
      };
    }
  }

  // Deletar pesagem (caso necessário)
  Future<void> deletar(String id) async {
    try {
      await _supabase.from('historico_peso').delete().eq('id', id);
    } catch (e) {
      throw Exception('Erro ao deletar pesagem: $e');
    }
  }
}
