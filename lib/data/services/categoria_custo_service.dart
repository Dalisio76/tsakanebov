import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/categoria_custo_model.dart';

class CategoriaCustoService {
  final _supabase = Supabase.instance.client;

  // Listar todas as categorias
  Future<List<CategoriaCustoModel>> listarCategorias() async {
    try {
      final response = await _supabase
          .from('categorias_custo')
          .select()
          .order('nome');

      return (response as List)
          .map((json) => CategoriaCustoModel.fromJson(json))
          .toList();
    } catch (e) {
      throw Exception('Erro ao listar categorias: $e');
    }
  }

  // Listar por tipo
  Future<List<CategoriaCustoModel>> listarPorTipo(String tipo) async {
    try {
      final response = await _supabase
          .from('categorias_custo')
          .select()
          .eq('tipo', tipo)
          .order('nome');

      return (response as List)
          .map((json) => CategoriaCustoModel.fromJson(json))
          .toList();
    } catch (e) {
      throw Exception('Erro ao listar categorias por tipo: $e');
    }
  }

  // Buscar por ID
  Future<CategoriaCustoModel?> buscarPorId(String id) async {
    try {
      final response = await _supabase
          .from('categorias_custo')
          .select()
          .eq('id', id)
          .maybeSingle();

      if (response == null) return null;
      return CategoriaCustoModel.fromJson(response);
    } catch (e) {
      throw Exception('Erro ao buscar categoria: $e');
    }
  }

  // Listar tipos disponíveis
  List<Map<String, String>> listarTipos() {
    return [
      {'valor': 'nutricao', 'nome': 'Nutrição', 'icone': '🌾'},
      {'valor': 'sanidade', 'nome': 'Sanidade', 'icone': '💊'},
      {'valor': 'infraestrutura', 'nome': 'Infraestrutura', 'icone': '🔧'},
      {'valor': 'mao_obra', 'nome': 'Mão de Obra', 'icone': '👷'},
      {'valor': 'outros', 'nome': 'Outros', 'icone': '💰'},
    ];
  }
}
