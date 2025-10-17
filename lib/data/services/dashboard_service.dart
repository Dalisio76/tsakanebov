import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/dashboard_stats_model.dart';

class DashboardService {
  final _supabase = Supabase.instance.client;

  // Buscar estatísticas gerais
  Future<DashboardStatsModel> buscarEstatisticas() async {
    try {
      // 1. Contadores de animais
      final animaisResponse = await _supabase
          .from('animais')
          .select('status, sexo, peso_atual_kg');

      int totalAnimais = animaisResponse.length;
      int animaisAtivos = 0;
      int animaisVendidos = 0;
      int animaisMortos = 0;
      int totalMachos = 0;
      int totalFemeas = 0;
      double pesoTotalKg = 0;

      for (var animal in animaisResponse) {
        String status = animal['status'] ?? 'ativo';
        String sexo = animal['sexo'] ?? 'M';
        double? peso = animal['peso_atual_kg'] != null
            ? double.tryParse(animal['peso_atual_kg'].toString())
            : null;

        // Status
        if (status == 'ativo') animaisAtivos++;
        if (status == 'vendido') animaisVendidos++;
        if (status == 'morto') animaisMortos++;

        // Sexo (só contar ativos)
        if (status == 'ativo') {
          if (sexo == 'M') totalMachos++;
          if (sexo == 'F') totalFemeas++;
        }

        // Peso (só animais ativos com peso)
        if (status == 'ativo' && peso != null) {
          pesoTotalKg += peso;
        }
      }

      // 2. GMD Médio (últimos 30 dias)
      double gmdMedio = 0.0;
      try {
        final gmdResponse = await _supabase.rpc('calcular_gmd_medio_rebanho');
        gmdMedio = gmdResponse != null
            ? double.tryParse(gmdResponse.toString()) ?? 0.0
            : 0.0;
      } catch (e) {
        print('Erro ao calcular GMD: $e');
      }

      // 3. Valor da arroba (fixo ou buscar de API externa no futuro)
      double valorArrobaAtual = 300.0; // R$ 300 por arroba

      // 4. Valor total do rebanho
      double arrobasTotal = pesoTotalKg / 15;
      double valorTotalRebanho = arrobasTotal * valorArrobaAtual;

      // 5. Alertas de vacinas
      int vacinasVencidas = 0;
      int vacinasProximas = 0;
      try {
        final alertasResponse = await _supabase
            .from('registros_saude')
            .select('proxima_aplicacao')
            .not('proxima_aplicacao', 'is', null)
            .gte('proxima_aplicacao',
                DateTime.now().toIso8601String().split('T')[0]);

        for (var alerta in alertasResponse) {
          DateTime? proxima = alerta['proxima_aplicacao'] != null
              ? DateTime.tryParse(alerta['proxima_aplicacao'])
              : null;

          if (proxima != null) {
            int diasRestantes = proxima.difference(DateTime.now()).inDays;
            if (diasRestantes < 0) {
              vacinasVencidas++;
            } else if (diasRestantes <= 7) {
              vacinasProximas++;
            }
          }
        }
      } catch (e) {
        print('Erro ao buscar alertas de vacinas: $e');
      }

      // 6. Animais sem pesagem recente (mais de 30 dias)
      int animaisSemPesagem = 0;
      try {
        final semPesagemResponse = await _supabase
            .from('animais')
            .select('data_ultima_pesagem')
            .eq('status', 'ativo');

        DateTime dataLimite = DateTime.now().subtract(Duration(days: 30));

        for (var animal in semPesagemResponse) {
          DateTime? ultimaPesagem = animal['data_ultima_pesagem'] != null
              ? DateTime.tryParse(animal['data_ultima_pesagem'])
              : null;

          if (ultimaPesagem == null || ultimaPesagem.isBefore(dataLimite)) {
            animaisSemPesagem++;
          }
        }
      } catch (e) {
        print('Erro ao buscar animais sem pesagem: $e');
      }

      // 7. Reprodução - Fêmeas prenhas
      int femeasPrenhas = 0;
      try {
        final prenhasResponse = await _supabase
            .from('diagnosticos_prenhez')
            .select('resultado')
            .eq('resultado', true);

        femeasPrenhas = prenhasResponse.length;
      } catch (e) {
        print('Erro ao buscar fêmeas prenhas: $e');
      }

      // 8. Partos previstos próximos 30 dias
      int partosPrevistos30dias = 0;
      try {
        final partosResponse = await _supabase
            .from('diagnosticos_prenhez')
            .select('data_prevista_parto')
            .eq('resultado', true)
            .not('data_prevista_parto', 'is', null)
            .lte(
                'data_prevista_parto',
                DateTime.now()
                    .add(Duration(days: 30))
                    .toIso8601String()
                    .split('T')[0]);

        partosPrevistos30dias = partosResponse.length;
      } catch (e) {
        print('Erro ao buscar partos previstos: $e');
      }

      // 9. Custos totais (últimos 12 meses)
      double custoTotal = 0;
      try {
        final custosResponse = await _supabase.from('despesas').select('valor').gte(
            'data_despesa',
            DateTime.now()
                .subtract(Duration(days: 365))
                .toIso8601String()
                .split('T')[0]);

        for (var despesa in custosResponse) {
          custoTotal += double.tryParse(despesa['valor'].toString()) ?? 0;
        }
      } catch (e) {
        print('Erro ao buscar custos: $e');
      }

      double custoPorAnimal = animaisAtivos > 0 ? custoTotal / animaisAtivos : 0;
      double custoPorArroba = arrobasTotal > 0 ? custoTotal / arrobasTotal : 0;

      return DashboardStatsModel(
        totalAnimais: totalAnimais,
        animaisAtivos: animaisAtivos,
        animaisVendidos: animaisVendidos,
        animaisMortos: animaisMortos,
        pesoTotalKg: pesoTotalKg,
        gmdMedio: gmdMedio,
        valorArrobaAtual: valorArrobaAtual,
        valorTotalRebanho: valorTotalRebanho,
        totalMachos: totalMachos,
        totalFemeas: totalFemeas,
        vacinasVencidas: vacinasVencidas,
        vacinasProximas: vacinasProximas,
        animaisSemPesagem: animaisSemPesagem,
        femeasPrenhas: femeasPrenhas,
        partosPrevistos30dias: partosPrevistos30dias,
        custoTotal: custoTotal,
        custoPorAnimal: custoPorAnimal,
        custoPorArroba: custoPorArroba,
      );
    } catch (e) {
      print('Erro ao buscar estatísticas: $e');
      throw Exception('Erro ao carregar dashboard: $e');
    }
  }

  // Buscar dados por grupo (para gráfico de pizza)
  Future<List<GrupoStatsModel>> buscarDadosPorGrupo() async {
    try {
      final response = await _supabase.rpc('stats_por_grupo');

      if (response == null) return [];

      return (response as List)
          .map((json) => GrupoStatsModel.fromJson(json))
          .toList();
    } catch (e) {
      print('Erro ao buscar dados por grupo: $e');

      // Fallback: query manual
      try {
        final animaisResponse = await _supabase
            .from('animais')
            .select('grupo_id, grupos(nome), peso_atual_kg')
            .eq('status', 'ativo');

        Map<String, GrupoStatsModel> gruposMap = {};

        for (var animal in animaisResponse) {
          String grupoId = animal['grupo_id'] ?? 'sem_grupo';
          String grupoNome = animal['grupos'] != null
              ? animal['grupos']['nome'] ?? 'Sem Grupo'
              : 'Sem Grupo';
          double peso = animal['peso_atual_kg'] != null
              ? double.tryParse(animal['peso_atual_kg'].toString()) ?? 0.0
              : 0.0;

          if (gruposMap.containsKey(grupoId)) {
            gruposMap[grupoId] = GrupoStatsModel(
              grupoId: grupoId,
              grupoNome: grupoNome,
              totalAnimais: gruposMap[grupoId]!.totalAnimais + 1,
              pesoTotalKg: gruposMap[grupoId]!.pesoTotalKg + peso,
            );
          } else {
            gruposMap[grupoId] = GrupoStatsModel(
              grupoId: grupoId,
              grupoNome: grupoNome,
              totalAnimais: 1,
              pesoTotalKg: peso,
            );
          }
        }

        return gruposMap.values.toList();
      } catch (e2) {
        print('Erro no fallback: $e2');
        return [];
      }
    }
  }

  // Evolução de peso (últimos 6 meses)
  Future<List<EvolucaoPesoModel>> buscarEvolucaoPeso() async {
    try {
      // Buscar dados dos últimos 6 meses agrupados por mês
      final response = await _supabase
          .from('historico_peso')
          .select('data_pesagem, peso_kg, gmd_kg')
          .gte(
              'data_pesagem',
              DateTime.now()
                  .subtract(Duration(days: 180))
                  .toIso8601String()
                  .split('T')[0])
          .order('data_pesagem');

      Map<String, List<double>> pesosPorMes = {};
      Map<String, List<double>> gmdPorMes = {};

      for (var registro in response) {
        DateTime data = DateTime.parse(registro['data_pesagem']);
        String mesAno = '${data.year}-${data.month.toString().padLeft(2, '0')}';

        double peso = double.tryParse(registro['peso_kg'].toString()) ?? 0;
        double? gmd = registro['gmd_kg'] != null
            ? double.tryParse(registro['gmd_kg'].toString())
            : null;

        if (!pesosPorMes.containsKey(mesAno)) {
          pesosPorMes[mesAno] = [];
          gmdPorMes[mesAno] = [];
        }

        pesosPorMes[mesAno]!.add(peso);
        if (gmd != null && gmd > 0) {
          gmdPorMes[mesAno]!.add(gmd);
        }
      }

      List<EvolucaoPesoModel> evolucao = [];

      pesosPorMes.forEach((mesAno, pesos) {
        List<String> partes = mesAno.split('-');
        DateTime data = DateTime(int.parse(partes[0]), int.parse(partes[1]));

        double pesoMedio = pesos.reduce((a, b) => a + b) / pesos.length;

        List<double> gmds = gmdPorMes[mesAno] ?? [];
        double gmdMedio =
            gmds.isEmpty ? 0 : gmds.reduce((a, b) => a + b) / gmds.length;

        evolucao.add(EvolucaoPesoModel(
          data: data,
          pesoMedio: pesoMedio,
          gmdMedio: gmdMedio,
        ));
      });

      evolucao.sort((a, b) => a.data.compareTo(b.data));
      return evolucao;
    } catch (e) {
      print('Erro ao buscar evolução de peso: $e');
      return [];
    }
  }
}
