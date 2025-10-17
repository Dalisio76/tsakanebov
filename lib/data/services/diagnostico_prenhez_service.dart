import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/diagnostico_prenhez_model.dart';

class DiagnosticoPrenheService {
  final _supabase = Supabase.instance.client;

  // Criar diagnóstico
  Future<DiagnosticoPrenheModel> criar(DiagnosticoPrenheModel diagnostico) async {
    try {
      final response = await _supabase
          .from('diagnosticos_prenhez')
          .insert(diagnostico.toJson())
          .select('''
            *,
            femea:animais!femea_id(brinco),
            cobertura:coberturas(data_cobertura)
          ''')
          .single();

      return DiagnosticoPrenheModel.fromJson(response);
    } catch (e) {
      throw Exception('Erro ao criar diagnóstico: $e');
    }
  }

  // Atualizar diagnóstico
  Future<DiagnosticoPrenheModel> atualizar(
      String id, DiagnosticoPrenheModel diagnostico) async {
    try {
      final response = await _supabase
          .from('diagnosticos_prenhez')
          .update(diagnostico.toJson())
          .eq('id', id)
          .select('''
            *,
            femea:animais!femea_id(brinco),
            cobertura:coberturas(data_cobertura)
          ''')
          .single();

      return DiagnosticoPrenheModel.fromJson(response);
    } catch (e) {
      throw Exception('Erro ao atualizar diagnóstico: $e');
    }
  }

  // Deletar diagnóstico
  Future<void> deletar(String id) async {
    try {
      await _supabase.from('diagnosticos_prenhez').delete().eq('id', id);
    } catch (e) {
      throw Exception('Erro ao deletar diagnóstico: $e');
    }
  }

  // Listar todos
  Future<List<DiagnosticoPrenheModel>> listarTodos() async {
    try {
      final response = await _supabase
          .from('diagnosticos_prenhez')
          .select('''
            *,
            femea:animais!femea_id(brinco),
            cobertura:coberturas(data_cobertura)
          ''')
          .order('data_diagnostico', ascending: false);

      return (response as List)
          .map((json) => DiagnosticoPrenheModel.fromJson(json))
          .toList();
    } catch (e) {
      throw Exception('Erro ao listar diagnósticos: $e');
    }
  }

  // Listar prenhas (resultado = true)
  Future<List<DiagnosticoPrenheModel>> listarPrenhas() async {
    try {
      final response = await _supabase
          .from('diagnosticos_prenhez')
          .select('''
            *,
            femea:animais!femea_id(brinco),
            cobertura:coberturas(data_cobertura)
          ''')
          .eq('resultado', true)
          .order('data_prevista_parto', ascending: true);

      return (response as List)
          .map((json) => DiagnosticoPrenheModel.fromJson(json))
          .toList();
    } catch (e) {
      throw Exception('Erro ao listar prenhas: $e');
    }
  }

  // Listar partos próximos
  Future<List<DiagnosticoPrenheModel>> listarPartosProximos(int dias) async {
    try {
      final hoje = DateTime.now();
      final dataLimite = hoje.add(Duration(days: dias));

      final response = await _supabase
          .from('diagnosticos_prenhez')
          .select('''
            *,
            femea:animais!femea_id(brinco),
            cobertura:coberturas(data_cobertura)
          ''')
          .eq('resultado', true)
          .gte('data_prevista_parto', hoje.toIso8601String())
          .lte('data_prevista_parto', dataLimite.toIso8601String())
          .order('data_prevista_parto', ascending: true);

      return (response as List)
          .map((json) => DiagnosticoPrenheModel.fromJson(json))
          .toList();
    } catch (e) {
      throw Exception('Erro ao listar partos próximos: $e');
    }
  }

  // Listar por fêmea
  Future<List<DiagnosticoPrenheModel>> listarPorFemea(String femeaId) async {
    try {
      final response = await _supabase
          .from('diagnosticos_prenhez')
          .select('''
            *,
            femea:animais!femea_id(brinco),
            cobertura:coberturas(data_cobertura)
          ''')
          .eq('femea_id', femeaId)
          .order('data_diagnostico', ascending: false);

      return (response as List)
          .map((json) => DiagnosticoPrenheModel.fromJson(json))
          .toList();
    } catch (e) {
      throw Exception('Erro ao listar diagnósticos da fêmea: $e');
    }
  }

  // Calcular taxa de prenhez
  Future<double> calcularTaxaPrenhez({
    DateTime? inicio,
    DateTime? fim,
  }) async {
    try {
      var query = _supabase.from('diagnosticos_prenhez').select('resultado');

      if (inicio != null) {
        query = query.gte('data_diagnostico', inicio.toIso8601String());
      }
      if (fim != null) {
        query = query.lte('data_diagnostico', fim.toIso8601String());
      }

      final response = await query;

      if ((response as List).isEmpty) return 0.0;

      int total = response.length;
      int prenhas = response.where((item) => item['resultado'] == true).length;

      return (prenhas / total) * 100;
    } catch (e) {
      throw Exception('Erro ao calcular taxa de prenhez: $e');
    }
  }

  // Buscar por ID
  Future<DiagnosticoPrenheModel?> buscarPorId(String id) async {
    try {
      final response = await _supabase
          .from('diagnosticos_prenhez')
          .select('''
            *,
            femea:animais!femea_id(brinco),
            cobertura:coberturas(data_cobertura)
          ''')
          .eq('id', id)
          .maybeSingle();

      if (response == null) return null;
      return DiagnosticoPrenheModel.fromJson(response);
    } catch (e) {
      throw Exception('Erro ao buscar diagnóstico: $e');
    }
  }
}
