class PesagemModel {
  final String? id;
  final String animalId;
  final String? animalBrinco; // Para exibição
  final String? animalNome;
  final double pesoKg;
  final DateTime dataPesagem;
  final int? diasDesdeUltima;
  final double? ganhoPeriodoKg;
  final double? gmdKg; // Ganho Médio Diário
  final String? tipoPesagem;
  final String? observacoes;
  final DateTime? criadoEm;

  PesagemModel({
    this.id,
    required this.animalId,
    this.animalBrinco,
    this.animalNome,
    required this.pesoKg,
    required this.dataPesagem,
    this.diasDesdeUltima,
    this.ganhoPeriodoKg,
    this.gmdKg,
    this.tipoPesagem,
    this.observacoes,
    this.criadoEm,
  });

  factory PesagemModel.fromJson(Map<String, dynamic> json) {
    return PesagemModel(
      id: json['id'],
      animalId: json['animal_id'],
      animalBrinco: json['animais'] != null ? json['animais']['brinco'] : null,
      animalNome: json['animais'] != null ? json['animais']['nome'] : null,
      pesoKg: double.parse(json['peso_kg'].toString()),
      dataPesagem: DateTime.parse(json['data_pesagem']),
      diasDesdeUltima: json['dias_desde_ultima'],
      ganhoPeriodoKg: json['ganho_periodo_kg'] != null
          ? double.tryParse(json['ganho_periodo_kg'].toString())
          : null,
      gmdKg: json['gmd_kg'] != null
          ? double.tryParse(json['gmd_kg'].toString())
          : null,
      tipoPesagem: json['tipo_pesagem'],
      observacoes: json['observacoes'],
      criadoEm: json['criado_em'] != null
          ? DateTime.parse(json['criado_em'])
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      if (id != null) 'id': id,
      'animal_id': animalId,
      'peso_kg': pesoKg,
      'data_pesagem': dataPesagem.toIso8601String().split('T')[0],
      'tipo_pesagem': tipoPesagem ?? 'rotina',
      'observacoes': observacoes,
    };
  }

  // Helper: Formatar GMD
  String get gmdFormatado {
    if (gmdKg == null) return '-';
    return '${gmdKg!.toStringAsFixed(3)} kg/dia';
  }

  // Helper: Cor do GMD (bom/médio/ruim)
  String get gmdCor {
    if (gmdKg == null) return 'grey';
    if (gmdKg! >= 0.8) return 'green'; // Excelente
    if (gmdKg! >= 0.5) return 'orange'; // Médio
    return 'red'; // Baixo
  }

  // Helper: Ícone do GMD
  String get gmdIcone {
    if (gmdKg == null) return '➖';
    if (gmdKg! >= 0.8) return '🟢'; // Excelente
    if (gmdKg! >= 0.5) return '🟡'; // Médio
    if (gmdKg! > 0) return '🟠'; // Baixo mas positivo
    return '🔴'; // Negativo (perdeu peso)
  }
}
