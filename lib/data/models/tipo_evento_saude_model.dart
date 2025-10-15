class TipoEventoSaudeModel {
  final String id;
  final String nome;
  final String categoria;
  final String? descricao;
  final bool obrigatorio;

  TipoEventoSaudeModel({
    required this.id,
    required this.nome,
    required this.categoria,
    this.descricao,
    this.obrigatorio = false,
  });

  factory TipoEventoSaudeModel.fromJson(Map<String, dynamic> json) {
    return TipoEventoSaudeModel(
      id: json['id'],
      nome: json['nome'] ?? '',
      categoria: json['categoria'] ?? 'medicamento',
      descricao: json['descricao'],
      obrigatorio: json['obrigatorio'] ?? false,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'nome': nome,
      'categoria': categoria,
      'descricao': descricao,
      'obrigatorio': obrigatorio,
    };
  }

  // Helper: Ícone por categoria
  String get icone {
    switch (categoria) {
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

  // Helper: Cor por categoria
  String get cor {
    switch (categoria) {
      case 'vacina':
        return 'blue';
      case 'medicamento':
        return 'green';
      case 'cirurgia':
        return 'red';
      case 'exame':
        return 'purple';
      case 'doenca':
        return 'orange';
      default:
        return 'grey';
    }
  }
}
