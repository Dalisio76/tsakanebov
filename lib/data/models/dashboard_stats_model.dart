class DashboardStatsModel {
  final int totalAnimais;
  final int animaisAtivos;
  final int animaisVendidos;
  final int animaisMortos;
  final double pesoTotalKg;
  final double gmdMedio;
  final double valorArrobaAtual;
  final double valorTotalRebanho;

  // Distribuição por sexo
  final int totalMachos;
  final int totalFemeas;

  // Alertas
  final int vacinasVencidas;
  final int vacinasProximas;
  final int animaisSemPesagem;

  // Reprodução
  final int femeasPrenhas;
  final int partosPrevistos30dias;

  // Custos
  final double custoTotal;
  final double custoPorAnimal;
  final double custoPorArroba;

  DashboardStatsModel({
    required this.totalAnimais,
    required this.animaisAtivos,
    required this.animaisVendidos,
    required this.animaisMortos,
    required this.pesoTotalKg,
    required this.gmdMedio,
    required this.valorArrobaAtual,
    required this.valorTotalRebanho,
    required this.totalMachos,
    required this.totalFemeas,
    required this.vacinasVencidas,
    required this.vacinasProximas,
    required this.animaisSemPesagem,
    required this.femeasPrenhas,
    required this.partosPrevistos30dias,
    required this.custoTotal,
    required this.custoPorAnimal,
    required this.custoPorArroba,
  });

  // Helpers
  double get pesoMedioKg => totalAnimais > 0 ? pesoTotalKg / totalAnimais : 0;
  double get arrobasTotal => pesoTotalKg / 15; // 1 arroba = 15kg
  String get percentualMachos => totalAnimais > 0
      ? ((totalMachos / totalAnimais) * 100).toStringAsFixed(1)
      : '0';
  String get percentualFemeas => totalAnimais > 0
      ? ((totalFemeas / totalAnimais) * 100).toStringAsFixed(1)
      : '0';
}

// Dados para gráficos
class GrupoStatsModel {
  final String grupoId;
  final String grupoNome;
  final int totalAnimais;
  final double pesoTotalKg;

  GrupoStatsModel({
    required this.grupoId,
    required this.grupoNome,
    required this.totalAnimais,
    required this.pesoTotalKg,
  });

  factory GrupoStatsModel.fromJson(Map<String, dynamic> json) {
    return GrupoStatsModel(
      grupoId: json['grupo_id'] ?? '',
      grupoNome: json['grupo_nome'] ?? 'Sem Grupo',
      totalAnimais: json['total_animais'] ?? 0,
      pesoTotalKg: json['peso_total_kg'] != null
          ? double.tryParse(json['peso_total_kg'].toString()) ?? 0.0
          : 0.0,
    );
  }
}

class EvolucaoPesoModel {
  final DateTime data;
  final double pesoMedio;
  final double gmdMedio;

  EvolucaoPesoModel({
    required this.data,
    required this.pesoMedio,
    required this.gmdMedio,
  });
}
