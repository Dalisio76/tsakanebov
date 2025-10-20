class UserProfileModel {
  final String id;
  final String nomeCompleto;
  final String email;
  final String? telefone;
  final String? avatarUrl;
  final String role;
  final String? fazendaNome;
  final bool ativo;
  final DateTime? criadoEm;
  final DateTime? atualizadoEm;

  UserProfileModel({
    required this.id,
    required this.nomeCompleto,
    required this.email,
    this.telefone,
    this.avatarUrl,
    required this.role,
    this.fazendaNome,
    required this.ativo,
    this.criadoEm,
    this.atualizadoEm,
  });

  factory UserProfileModel.fromJson(Map<String, dynamic> json) {
    return UserProfileModel(
      id: json['id'],
      nomeCompleto: json['nome_completo'] ?? '',
      email: json['email'] ?? '',
      telefone: json['telefone'],
      avatarUrl: json['avatar_url'],
      role: json['role'] ?? 'funcionario',
      fazendaNome: json['fazenda_nome'],
      ativo: json['ativo'] ?? true,
      criadoEm: json['criado_em'] != null ? DateTime.parse(json['criado_em']) : null,
      atualizadoEm: json['atualizado_em'] != null ? DateTime.parse(json['atualizado_em']) : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'nome_completo': nomeCompleto,
      'email': email,
      'telefone': telefone,
      'avatar_url': avatarUrl,
      'role': role,
      'fazenda_nome': fazendaNome,
      'ativo': ativo,
    };
  }

  bool get isAdmin => role == 'admin';
  bool get isFuncionario => role == 'funcionario';
  bool get isVeterinario => role == 'veterinario';

  String get roleNome {
    switch (role) {
      case 'admin':
        return 'Administrador';
      case 'veterinario':
        return 'Veterinário';
      default:
        return 'Funcionário';
    }
  }

  String get iniciais {
    List<String> partes = nomeCompleto.split(' ');
    if (partes.length >= 2) {
      return '${partes[0][0]}${partes[1][0]}'.toUpperCase();
    }
    return nomeCompleto.isNotEmpty ? nomeCompleto[0].toUpperCase() : 'U';
  }

  UserProfileModel copyWith({
    String? id,
    String? nomeCompleto,
    String? email,
    String? telefone,
    String? avatarUrl,
    String? role,
    String? fazendaNome,
    bool? ativo,
    DateTime? criadoEm,
    DateTime? atualizadoEm,
  }) {
    return UserProfileModel(
      id: id ?? this.id,
      nomeCompleto: nomeCompleto ?? this.nomeCompleto,
      email: email ?? this.email,
      telefone: telefone ?? this.telefone,
      avatarUrl: avatarUrl ?? this.avatarUrl,
      role: role ?? this.role,
      fazendaNome: fazendaNome ?? this.fazendaNome,
      ativo: ativo ?? this.ativo,
      criadoEm: criadoEm ?? this.criadoEm,
      atualizadoEm: atualizadoEm ?? this.atualizadoEm,
    );
  }
}
