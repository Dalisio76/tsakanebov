import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/grupo_model.dart';

class GrupoService {
  final _supabase = Supabase.instance.client;

  // Listar todos os grupos ativos
  Future<List<GrupoModel>> listarGrupos({bool? apenasAtivos = true}) async {
    try {
      final response = apenasAtivos == true
          ? await _supabase
                .from('grupos')
                .select()
                .eq('ativo', true)
                .order('criado_em', ascending: false)
          : await _supabase.from('grupos').select().order('criado_em', ascending: false);

      return (response as List)
          .map((json) => GrupoModel.fromJson(json))
          .toList();
    } catch (e) {
      throw Exception('Erro ao listar grupos: $e');
    }
  }

  // Buscar grupo por ID
  Future<GrupoModel?> buscarPorId(String id) async {
    try {
      final response = await _supabase
          .from('grupos')
          .select()
          .eq('id', id)
          .single();

      return GrupoModel.fromJson(response);
    } catch (e) {
      throw Exception('Erro ao buscar grupo: $e');
    }
  }

  // Buscar grupos por nome (busca parcial)
  Future<List<GrupoModel>> buscarPorNome(String nome) async {
    try {
      final response = await _supabase
          .from('grupos')
          .select()
          .ilike('nome', '%$nome%')
          .eq('ativo', true)
          .order('criado_em', ascending: false);

      return (response as List)
          .map((json) => GrupoModel.fromJson(json))
          .toList();
    } catch (e) {
      throw Exception('Erro ao buscar grupos: $e');
    }
  }

  // Criar novo grupo
  Future<GrupoModel> criar(GrupoModel grupo) async {
    try {
      final response = await _supabase
          .from('grupos')
          .insert(grupo.toJson())
          .select()
          .single();

      return GrupoModel.fromJson(response);
    } catch (e) {
      throw Exception('Erro ao criar grupo: $e');
    }
  }

  // Atualizar grupo existente
  Future<GrupoModel> atualizar(String id, GrupoModel grupo) async {
    try {
      final response = await _supabase
          .from('grupos')
          .update(grupo.toJson())
          .eq('id', id)
          .select()
          .single();

      return GrupoModel.fromJson(response);
    } catch (e) {
      throw Exception('Erro ao atualizar grupo: $e');
    }
  }

  // Deletar (soft delete - marcar como inativo)
  Future<void> deletar(String id) async {
    try {
      await _supabase.from('grupos').update({'ativo': false}).eq('id', id);
    } catch (e) {
      throw Exception('Erro ao deletar grupo: $e');
    }
  }

  // Deletar permanentemente (use com cuidado!)
  Future<void> deletarPermanente(String id) async {
    try {
      await _supabase.from('grupos').delete().eq('id', id);
    } catch (e) {
      throw Exception('Erro ao deletar grupo permanentemente: $e');
    }
  }
}
