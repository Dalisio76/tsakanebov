import 'package:intl/intl.dart';

class CoberturaModel {
  final String? id;
  final String femeaId;
  final String? machoId;
  final DateTime dataCobertura;
  final String tipo; // monta_natural, inseminacao
  final String? touroSemen;
  final String? racaTouro;
  final String? observacoes;
  final DateTime? criadoEm;

  // Dados relacionados (joins)
  final String? femeaBrinco;
  final String? machoBrinco;

  CoberturaModel({
    this.id,
    required this.femeaId,
    this.machoId,
    required this.dataCobertura,
    required this.tipo,
    this.touroSemen,
    this.racaTouro,
    this.observacoes,
    this.criadoEm,
    this.femeaBrinco,
    this.machoBrinco,
  });

  factory CoberturaModel.fromJson(Map<String, dynamic> json) {
    return CoberturaModel(
      id: json['id'],
      femeaId: json['femea_id'],
      machoId: json['macho_id'],
      dataCobertura: json['data_cobertura'] != null
          ? DateTime.parse(json['data_cobertura'])
          : DateTime.now(),
      tipo: json['tipo'] ?? 'monta_natural',
      touroSemen: json['touro_semen'],
      racaTouro: json['raca_touro'],
      observacoes: json['observacoes'],
      criadoEm: json['criado_em'] != null
          ? DateTime.parse(json['criado_em'])
          : null,
      // Joins
      femeaBrinco: json['femea'] != null ? json['femea']['brinco'] : null,
      machoBrinco: json['macho'] != null ? json['macho']['brinco'] : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      if (id != null) 'id': id,
      'femea_id': femeaId,
      if (machoId != null) 'macho_id': machoId,
      'data_cobertura': DateFormat('yyyy-MM-dd').format(dataCobertura),
      'tipo': tipo,
      if (touroSemen != null) 'touro_semen': touroSemen,
      if (racaTouro != null) 'raca_touro': racaTouro,
      if (observacoes != null) 'observacoes': observacoes,
    };
  }

  // Helpers
  String get dataFormatada {
    return DateFormat('dd/MM/yyyy').format(dataCobertura);
  }

  String get tipoFormatado {
    return tipo == 'monta_natural' ? 'Monta Natural' : 'Inseminação';
  }

  String get icone {
    return tipo == 'monta_natural' ? '🐂' : '💉';
  }

  String get reproducaoInfo {
    if (tipo == 'monta_natural' && machoBrinco != null) {
      return '🐂 Macho: $machoBrinco';
    } else if (tipo == 'inseminacao' && touroSemen != null) {
      return '💉 Sêmen: $touroSemen';
    }
    return icone;
  }
}
