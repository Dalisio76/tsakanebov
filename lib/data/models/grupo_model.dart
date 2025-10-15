class GrupoModel {
  final String? id;
  final String nome;
  final String? descricao;
  final String? finalidade;
  final DateTime? dataCriacao;
  final bool ativo;
  final DateTime? criadoEm;
  final DateTime? atualizadoEm;

  GrupoModel({
    this.id,
    required this.nome,
    this.descricao,
    this.finalidade,
    this.dataCriacao,
    this.ativo = true,
    this.criadoEm,
    this.atualizadoEm,
  });

  // Converter do JSON do Supabase para o Model
  factory GrupoModel.fromJson(Map<String, dynamic> json) {
    return GrupoModel(
      id: json['id'],
      nome: json['nome'] ?? '',
      descricao: json['descricao'],
      finalidade: json['finalidade'],
      dataCriacao: json['data_criacao'] != null
          ? DateTime.parse(json['data_criacao'])
          : null,
      ativo: json['ativo'] ?? true,
      criadoEm: json['criado_em'] != null
          ? DateTime.parse(json['criado_em'])
          : null,
      atualizadoEm: json['atualizado_em'] != null
          ? DateTime.parse(json['atualizado_em'])
          : null,
    );
  }

  // Converter do Model para JSON (para enviar ao Supabase)
  Map<String, dynamic> toJson() {
    return {
      if (id != null) 'id': id,
      'nome': nome,
      'descricao': descricao,
      'finalidade': finalidade,
      'data_criacao': dataCriacao?.toIso8601String(),
      'ativo': ativo,
    };
  }

  // Criar cópia com mudanças
  GrupoModel copyWith({
    String? id,
    String? nome,
    String? descricao,
    String? finalidade,
    DateTime? dataCriacao,
    bool? ativo,
    DateTime? criadoEm,
    DateTime? atualizadoEm,
  }) {
    return GrupoModel(
      id: id ?? this.id,
      nome: nome ?? this.nome,
      descricao: descricao ?? this.descricao,
      finalidade: finalidade ?? this.finalidade,
      dataCriacao: dataCriacao ?? this.dataCriacao,
      ativo: ativo ?? this.ativo,
      criadoEm: criadoEm ?? this.criadoEm,
      atualizadoEm: atualizadoEm ?? this.atualizadoEm,
    );
  }
}
