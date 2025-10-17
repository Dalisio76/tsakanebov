import 'package:intl/intl.dart';

class PartoModel {
  final String? id;
  final String? coberturaId;
  final String maeId;
  final DateTime dataParto;
  final String? tipoParto; // normal, assistido, cesariana
  final int bezerrosVivos;
  final int bezerrosMortos;
  final String? condicaoMae; // boa, regular, ruim
  final String? complicacoes;
  final String? veterinario;
  final String? observacoes;
  final DateTime? criadoEm;

  // Dados relacionados (joins)
  final String? maeBrinco;
  final DateTime? dataCobertura;

  PartoModel({
    this.id,
    this.coberturaId,
    required this.maeId,
    required this.dataParto,
    this.tipoParto,
    this.bezerrosVivos = 1,
    this.bezerrosMortos = 0,
    this.condicaoMae,
    this.complicacoes,
    this.veterinario,
    this.observacoes,
    this.criadoEm,
    this.maeBrinco,
    this.dataCobertura,
  });

  factory PartoModel.fromJson(Map<String, dynamic> json) {
    return PartoModel(
      id: json['id'],
      coberturaId: json['cobertura_id'],
      maeId: json['mae_id'],
      dataParto: json['data_parto'] != null
          ? DateTime.parse(json['data_parto'])
          : DateTime.now(),
      tipoParto: json['tipo_parto'],
      bezerrosVivos: json['bezerros_vivos'] ?? 1,
      bezerrosMortos: json['bezerros_mortos'] ?? 0,
      condicaoMae: json['condicao_mae'],
      complicacoes: json['complicacoes'],
      veterinario: json['veterinario'],
      observacoes: json['observacoes'],
      criadoEm: json['criado_em'] != null
          ? DateTime.parse(json['criado_em'])
          : null,
      // Joins
      maeBrinco: json['mae'] != null ? json['mae']['brinco'] : null,
      dataCobertura: json['cobertura'] != null &&
              json['cobertura']['data_cobertura'] != null
          ? DateTime.parse(json['cobertura']['data_cobertura'])
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      if (id != null) 'id': id,
      if (coberturaId != null) 'cobertura_id': coberturaId,
      'mae_id': maeId,
      'data_parto': DateFormat('yyyy-MM-dd').format(dataParto),
      if (tipoParto != null) 'tipo_parto': tipoParto,
      'bezerros_vivos': bezerrosVivos,
      'bezerros_mortos': bezerrosMortos,
      if (condicaoMae != null) 'condicao_mae': condicaoMae,
      if (complicacoes != null) 'complicacoes': complicacoes,
      if (veterinario != null) 'veterinario': veterinario,
      if (observacoes != null) 'observacoes': observacoes,
    };
  }

  // Helpers
  String get dataFormatada {
    return DateFormat('dd/MM/yyyy').format(dataParto);
  }

  String get tipoPartoFormatado {
    switch (tipoParto) {
      case 'normal':
        return '✅ Normal';
      case 'assistido':
        return '🤝 Assistido';
      case 'cesariana':
        return '🔪 Cesariana';
      default:
        return '-';
    }
  }

  String get condicaoMaeFormatada {
    switch (condicaoMae) {
      case 'boa':
        return '🟢 Boa';
      case 'regular':
        return '🟡 Regular';
      case 'ruim':
        return '🔴 Ruim';
      default:
        return '-';
    }
  }

  String get resultadoTexto {
    if (bezerrosVivos == 0 && bezerrosMortos > 0) {
      return '❌ ${bezerrosMortos} morto(s)';
    } else if (bezerrosVivos > 0 && bezerrosMortos == 0) {
      return '✅ ${bezerrosVivos} vivo(s)';
    } else if (bezerrosVivos > 0 && bezerrosMortos > 0) {
      return '⚠️ $bezerrosVivos vivo(s), $bezerrosMortos morto(s)';
    }
    return '-';
  }

  int get totalBezerros {
    return bezerrosVivos + bezerrosMortos;
  }

  int? get diasGestacao {
    if (dataCobertura == null) return null;
    return dataParto.difference(dataCobertura!).inDays;
  }
}
