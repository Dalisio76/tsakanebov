import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/tipo_evento_saude_model.dart';

class TipoEventoSaudeService {
  final _supabase = Supabase.instance.client;

  // Listar todos os tipos
  Future<List<TipoEventoSaudeModel>> listarTodos() async {
    try {
      final response = await _supabase
          .from('tipos_evento_saude')
          .select()
          .order('categoria')
          .order('nome');

      return (response as List)
          .map((json) => TipoEventoSaudeModel.fromJson(json))
          .toList();
    } catch (e) {
      throw Exception('Erro ao listar tipos de evento: $e');
    }
  }

  // Listar por categoria
  Future<List<TipoEventoSaudeModel>> listarPorCategoria(
      String categoria) async {
    try {
      final response = await _supabase
          .from('tipos_evento_saude')
          .select()
          .eq('categoria', categoria)
          .order('nome');

      return (response as List)
          .map((json) => TipoEventoSaudeModel.fromJson(json))
          .toList();
    } catch (e) {
      throw Exception('Erro ao listar tipos de evento: $e');
    }
  }

  // Buscar por ID
  Future<TipoEventoSaudeModel?> buscarPorId(String id) async {
    try {
      final response = await _supabase
          .from('tipos_evento_saude')
          .select()
          .eq('id', id)
          .single();

      return TipoEventoSaudeModel.fromJson(response);
    } catch (e) {
      return null;
    }
  }
}
