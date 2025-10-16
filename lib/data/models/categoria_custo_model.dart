class CategoriaCustoModel {
  final String? id;
  final String nome;
  final String tipo; // nutricao, sanidade, infraestrutura, mao_obra, outros
  final String? descricao;

  CategoriaCustoModel({
    this.id,
    required this.nome,
    required this.tipo,
    this.descricao,
  });

  // Converte JSON para Model
  factory CategoriaCustoModel.fromJson(Map<String, dynamic> json) {
    return CategoriaCustoModel(
      id: json['id'],
      nome: json['nome'] ?? '',
      tipo: json['tipo'] ?? 'outros',
      descricao: json['descricao'],
    );
  }

  // Converte Model para JSON
  Map<String, dynamic> toJson() {
    return {
      if (id != null) 'id': id,
      'nome': nome,
      'tipo': tipo,
      if (descricao != null) 'descricao': descricao,
    };
  }

  // Helper: Ícone por tipo
  String get icone {
    switch (tipo) {
      case 'nutricao':
        return '🌾';
      case 'sanidade':
        return '💊';
      case 'infraestrutura':
        return '🔧';
      case 'mao_obra':
        return '👷';
      default:
        return '💰';
    }
  }

  // Helper: Nome do tipo formatado
  String get tipoFormatado {
    switch (tipo) {
      case 'nutricao':
        return 'Nutrição';
      case 'sanidade':
        return 'Sanidade';
      case 'infraestrutura':
        return 'Infraestrutura';
      case 'mao_obra':
        return 'Mão de Obra';
      default:
        return 'Outros';
    }
  }

  // Helper: Descrição completa com ícone
  String get nomeComIcone {
    return '$icone $nome';
  }
}
