import 'package:intl/intl.dart';

class DiagnosticoPrenheModel {
  final String? id;
  final String coberturaId;
  final String femeaId;
  final DateTime dataDiagnostico;
  final bool resultado; // true = prenha, false = vazia
  final String? metodo; // palpacao, ultrassom
  final int? diasGestacao;
  final DateTime? dataPrevistaParto;
  final String? veterinario;
  final String? observacoes;
  final DateTime? criadoEm;

  // Dados relacionados (joins)
  final String? femeaBrinco;
  final DateTime? dataCobertura;

  DiagnosticoPrenheModel({
    this.id,
    required this.coberturaId,
    required this.femeaId,
    required this.dataDiagnostico,
    required this.resultado,
    this.metodo,
    this.diasGestacao,
    this.dataPrevistaParto,
    this.veterinario,
    this.observacoes,
    this.criadoEm,
    this.femeaBrinco,
    this.dataCobertura,
  });

  factory DiagnosticoPrenheModel.fromJson(Map<String, dynamic> json) {
    return DiagnosticoPrenheModel(
      id: json['id'],
      coberturaId: json['cobertura_id'],
      femeaId: json['femea_id'],
      dataDiagnostico: json['data_diagnostico'] != null
          ? DateTime.parse(json['data_diagnostico'])
          : DateTime.now(),
      resultado: json['resultado'] ?? false,
      metodo: json['metodo'],
      diasGestacao: json['dias_gestacao'],
      dataPrevistaParto: json['data_prevista_parto'] != null
          ? DateTime.parse(json['data_prevista_parto'])
          : null,
      veterinario: json['veterinario'],
      observacoes: json['observacoes'],
      criadoEm: json['criado_em'] != null
          ? DateTime.parse(json['criado_em'])
          : null,
      // Joins
      femeaBrinco: json['femea'] != null ? json['femea']['brinco'] : null,
      dataCobertura: json['cobertura'] != null &&
              json['cobertura']['data_cobertura'] != null
          ? DateTime.parse(json['cobertura']['data_cobertura'])
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      if (id != null) 'id': id,
      'cobertura_id': coberturaId,
      'femea_id': femeaId,
      'data_diagnostico': DateFormat('yyyy-MM-dd').format(dataDiagnostico),
      'resultado': resultado,
      if (metodo != null) 'metodo': metodo,
      if (diasGestacao != null) 'dias_gestacao': diasGestacao,
      if (dataPrevistaParto != null)
        'data_prevista_parto':
            DateFormat('yyyy-MM-dd').format(dataPrevistaParto!),
      if (veterinario != null) 'veterinario': veterinario,
      if (observacoes != null) 'observacoes': observacoes,
    };
  }

  // Helpers
  String get dataFormatada {
    return DateFormat('dd/MM/yyyy').format(dataDiagnostico);
  }

  String get dataPrevistaFormatada {
    if (dataPrevistaParto == null) return '-';
    return DateFormat('dd/MM/yyyy').format(dataPrevistaParto!);
  }

  String get resultadoTexto {
    return resultado ? '✅ Prenha' : '❌ Vazia';
  }

  String get statusAlerta {
    if (!resultado || dataPrevistaParto == null) return '';

    final hoje = DateTime.now();
    final diasRestantes = dataPrevistaParto!.difference(hoje).inDays;

    if (diasRestantes < 0) {
      return '🔴 Atrasado (${diasRestantes.abs()} dias)';
    } else if (diasRestantes <= 7) {
      return '🟡 Urgente ($diasRestantes dias)';
    } else if (diasRestantes <= 30) {
      return '🟢 Próximo ($diasRestantes dias)';
    }
    return '⚪ $diasRestantes dias';
  }

  int? get diasRestantes {
    if (dataPrevistaParto == null) return null;
    return dataPrevistaParto!.difference(DateTime.now()).inDays;
  }
}
