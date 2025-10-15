class RegistroSaudeModel {
  final String? id;
  final String animalId;
  final String? animalBrinco; // Para exibição
  final String? animalNome;
  final String? tipoEventoId;
  final String? tipoEventoNome; // Para exibição
  final String? tipoEventoCategoria;
  final DateTime dataEvento;
  final String descricao;
  final String? veterinario;
  final double? custo;
  final DateTime? proximaAplicacao;
  final String? observacoes;
  final DateTime? criadoEm;

  RegistroSaudeModel({
    this.id,
    required this.animalId,
    this.animalBrinco,
    this.animalNome,
    this.tipoEventoId,
    this.tipoEventoNome,
    this.tipoEventoCategoria,
    required this.dataEvento,
    required this.descricao,
    this.veterinario,
    this.custo,
    this.proximaAplicacao,
    this.observacoes,
    this.criadoEm,
  });

  factory RegistroSaudeModel.fromJson(Map<String, dynamic> json) {
    return RegistroSaudeModel(
      id: json['id'],
      animalId: json['animal_id'],
      animalBrinco: json['animais'] != null ? json['animais']['brinco'] : null,
      animalNome: json['animais'] != null ? json['animais']['nome'] : null,
      tipoEventoId: json['tipo_evento_id'],
      tipoEventoNome: json['tipos_evento_saude'] != null
          ? json['tipos_evento_saude']['nome']
          : null,
      tipoEventoCategoria: json['tipos_evento_saude'] != null
          ? json['tipos_evento_saude']['categoria']
          : null,
      dataEvento: DateTime.parse(json['data_evento']),
      descricao: json['descricao'] ?? '',
      veterinario: json['veterinario'],
      custo: json['custo'] != null
          ? double.tryParse(json['custo'].toString())
          : null,
      proximaAplicacao: json['proxima_aplicacao'] != null
          ? DateTime.parse(json['proxima_aplicacao'])
          : null,
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
      'tipo_evento_id': tipoEventoId,
      'data_evento': dataEvento.toIso8601String().split('T')[0],
      'descricao': descricao,
      'veterinario': veterinario,
      'custo': custo,
      'proxima_aplicacao':
          proximaAplicacao?.toIso8601String().split('T')[0],
      'observacoes': observacoes,
    };
  }

  // Helper: Dias até próxima aplicação
  int? get diasAteProxima {
    if (proximaAplicacao == null) return null;
    return proximaAplicacao!.difference(DateTime.now()).inDays;
  }

  // Helper: Status do alerta
  String get statusAlerta {
    if (proximaAplicacao == null) return 'sem_agendamento';
    final dias = diasAteProxima!;
    if (dias < 0) return 'vencido'; // 🔴
    if (dias <= 7) return 'urgente'; // 🟡
    if (dias <= 30) return 'proximo'; // 🟢
    return 'futuro'; // ⚪
  }

  // Helper: Ícone do alerta
  String get iconeAlerta {
    switch (statusAlerta) {
      case 'vencido':
        return '🔴';
      case 'urgente':
        return '🟡';
      case 'proximo':
        return '🟢';
      default:
        return '⚪';
    }
  }

  // Helper: Cor do alerta
  String get corAlerta {
    switch (statusAlerta) {
      case 'vencido':
        return 'red';
      case 'urgente':
        return 'orange';
      case 'proximo':
        return 'green';
      default:
        return 'grey';
    }
  }

  // Helper: Ícone por categoria
  String get iconeCategoria {
    if (tipoEventoCategoria == null) return '📋';
    switch (tipoEventoCategoria) {
      case 'vacina':
        return '💉';
      case 'medicamento':
        return '💊';
      case 'cirurgia':
        return '🔪';
      case 'exame':
        return '🔬';
      case 'doenca':
        return '🦠';
      default:
        return '📋';
    }
  }
}
