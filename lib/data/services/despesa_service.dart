import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/despesa_model.dart';

class DespesaService {
  final _supabase = Supabase.instance.client;

  // Criar despesa
  Future<DespesaModel> criar(DespesaModel despesa) async {
    try {
      final response = await _supabase
          .from('despesas')
          .insert(despesa.toJson())
          .select('''
            *,
            categorias_custo(nome),
            animais(brinco),
            grupos(nome)
          ''')
          .single();

      return DespesaModel.fromJson(response);
    } catch (e) {
      throw Exception('Erro ao criar despesa: $e');
    }
  }

  // Atualizar despesa
  Future<DespesaModel> atualizar(String id, DespesaModel despesa) async {
    try {
      final response = await _supabase
          .from('despesas')
          .update(despesa.toJson())
          .eq('id', id)
          .select('''
            *,
            categorias_custo(nome),
            animais(brinco),
            grupos(nome)
          ''')
          .single();

      return DespesaModel.fromJson(response);
    } catch (e) {
      throw Exception('Erro ao atualizar despesa: $e');
    }
  }

  // Deletar despesa
  Future<void> deletar(String id) async {
    try {
      await _supabase.from('despesas').delete().eq('id', id);
    } catch (e) {
      throw Exception('Erro ao deletar despesa: $e');
    }
  }

  // Listar todas as despesas com joins
  Future<List<DespesaModel>> listarTodas() async {
    try {
      final response = await _supabase
          .from('despesas')
          .select('''
            *,
            categorias_custo(nome),
            animais(brinco),
            grupos(nome)
          ''')
          .order('data_despesa', ascending: false);

      return (response as List)
          .map((json) => DespesaModel.fromJson(json))
          .toList();
    } catch (e) {
      throw Exception('Erro ao listar despesas: $e');
    }
  }

  // Listar por período
  Future<List<DespesaModel>> listarPorPeriodo(
      DateTime inicio, DateTime fim) async {
    try {
      final response = await _supabase
          .from('despesas')
          .select('''
            *,
            categorias_custo(nome),
            animais(brinco),
            grupos(nome)
          ''')
          .gte('data_despesa', inicio.toIso8601String())
          .lte('data_despesa', fim.toIso8601String())
          .order('data_despesa', ascending: false);

      return (response as List)
          .map((json) => DespesaModel.fromJson(json))
          .toList();
    } catch (e) {
      throw Exception('Erro ao listar despesas por período: $e');
    }
  }

  // Listar por animal
  Future<List<DespesaModel>> listarPorAnimal(String animalId) async {
    try {
      final response = await _supabase
          .from('despesas')
          .select('''
            *,
            categorias_custo(nome),
            animais(brinco),
            grupos(nome)
          ''')
          .eq('animal_id', animalId)
          .order('data_despesa', ascending: false);

      return (response as List)
          .map((json) => DespesaModel.fromJson(json))
          .toList();
    } catch (e) {
      throw Exception('Erro ao listar despesas do animal: $e');
    }
  }

  // Listar por grupo
  Future<List<DespesaModel>> listarPorGrupo(String grupoId) async {
    try {
      final response = await _supabase
          .from('despesas')
          .select('''
            *,
            categorias_custo(nome),
            animais(brinco),
            grupos(nome)
          ''')
          .eq('grupo_id', grupoId)
          .order('data_despesa', ascending: false);

      return (response as List)
          .map((json) => DespesaModel.fromJson(json))
          .toList();
    } catch (e) {
      throw Exception('Erro ao listar despesas do grupo: $e');
    }
  }

  // Listar por categoria
  Future<List<DespesaModel>> listarPorCategoria(String categoriaId) async {
    try {
      final response = await _supabase
          .from('despesas')
          .select('''
            *,
            categorias_custo(nome),
            animais(brinco),
            grupos(nome)
          ''')
          .eq('categoria_id', categoriaId)
          .order('data_despesa', ascending: false);

      return (response as List)
          .map((json) => DespesaModel.fromJson(json))
          .toList();
    } catch (e) {
      throw Exception('Erro ao listar despesas da categoria: $e');
    }
  }

  // Calcular total de despesas
  Future<double> calcularTotal({
    DateTime? inicio,
    DateTime? fim,
    String? categoriaId,
    String? animalId,
    String? grupoId,
  }) async {
    try {
      var query = _supabase.from('despesas').select('valor');

      if (inicio != null) {
        query = query.gte('data_despesa', inicio.toIso8601String());
      }
      if (fim != null) {
        query = query.lte('data_despesa', fim.toIso8601String());
      }
      if (categoriaId != null) {
        query = query.eq('categoria_id', categoriaId);
      }
      if (animalId != null) {
        query = query.eq('animal_id', animalId);
      }
      if (grupoId != null) {
        query = query.eq('grupo_id', grupoId);
      }

      final response = await query;

      double total = 0.0;
      for (var item in response as List) {
        total += double.tryParse(item['valor'].toString()) ?? 0.0;
      }

      return total;
    } catch (e) {
      throw Exception('Erro ao calcular total: $e');
    }
  }

  // Estatísticas por categoria
  Future<Map<String, double>> estatisticasPorCategoria({
    DateTime? inicio,
    DateTime? fim,
  }) async {
    try {
      var query = _supabase.from('despesas').select('''
        valor,
        categorias_custo(nome)
      ''');

      if (inicio != null) {
        query = query.gte('data_despesa', inicio.toIso8601String());
      }
      if (fim != null) {
        query = query.lte('data_despesa', fim.toIso8601String());
      }

      final response = await query;

      Map<String, double> stats = {};
      for (var item in response as List) {
        String categoria = item['categorias_custo']?['nome'] ?? 'Sem Categoria';
        double valor = double.tryParse(item['valor'].toString()) ?? 0.0;
        stats[categoria] = (stats[categoria] ?? 0.0) + valor;
      }

      return stats;
    } catch (e) {
      throw Exception('Erro ao calcular estatísticas: $e');
    }
  }

  // Buscar por ID
  Future<DespesaModel?> buscarPorId(String id) async {
    try {
      final response = await _supabase
          .from('despesas')
          .select('''
            *,
            categorias_custo(nome),
            animais(brinco),
            grupos(nome)
          ''')
          .eq('id', id)
          .maybeSingle();

      if (response == null) return null;
      return DespesaModel.fromJson(response);
    } catch (e) {
      throw Exception('Erro ao buscar despesa: $e');
    }
  }
}
