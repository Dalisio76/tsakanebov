class AnimalModel {
  final String? id;
  final String brinco;
  final String? nome;
  final String? grupoId;
  final String? grupoNome; // Para exibição
  final String? paiId;
  final String? paiBrinco; // Para exibição
  final String? maeId;
  final String? maeBrinco; // Para exibição
  final String sexo;
  final String? tipoPele;
  final String? raca;
  final DateTime dataNascimento;
  final int? idadeMeses; // Calculado
  final double? pesoAtualKg;
  final DateTime? dataUltimaPesagem;
  final String status;
  final String? observacoes;
  final String? urlImagem;
  final DateTime? criadoEm;
  final DateTime? atualizadoEm;

  AnimalModel({
    this.id,
    required this.brinco,
    this.nome,
    this.grupoId,
    this.grupoNome,
    this.paiId,
    this.paiBrinco,
    this.maeId,
    this.maeBrinco,
    required this.sexo,
    this.tipoPele,
    this.raca,
    required this.dataNascimento,
    this.idadeMeses,
    this.pesoAtualKg,
    this.dataUltimaPesagem,
    this.status = 'ativo',
    this.observacoes,
    this.urlImagem,
    this.criadoEm,
    this.atualizadoEm,
  });

  factory AnimalModel.fromJson(Map<String, dynamic> json) {
    // Calcular idade em meses
    int? calcularIdade(String? dataNasc) {
      if (dataNasc == null) return null;
      try {
        final nasc = DateTime.parse(dataNasc);
        final hoje = DateTime.now();
        return (hoje.year - nasc.year) * 12 + (hoje.month - nasc.month);
      } catch (e) {
        return null;
      }
    }

    return AnimalModel(
      id: json['id'],
      brinco: json['brinco'] ?? '',
      nome: json['nome'],
      grupoId: json['grupo_id'],
      // Proteger contra null antes de acessar propriedades aninhadas
      grupoNome: json['grupos'] != null ? json['grupos']['nome'] : null,
      paiId: json['pai_id'],
      paiBrinco: json['pai'] != null ? json['pai']['brinco'] : null,
      maeId: json['mae_id'],
      maeBrinco: json['mae'] != null ? json['mae']['brinco'] : null,
      sexo: json['sexo'] ?? 'M',
      tipoPele: json['tipo_pele'],
      raca: json['raca'],
      // Proteger contra data_nascimento null
      dataNascimento: json['data_nascimento'] != null
          ? DateTime.parse(json['data_nascimento'])
          : DateTime.now(),
      idadeMeses: calcularIdade(json['data_nascimento']),
      pesoAtualKg: json['peso_atual_kg'] != null
          ? double.tryParse(json['peso_atual_kg'].toString())
          : null,
      dataUltimaPesagem: json['data_ultima_pesagem'] != null
          ? DateTime.parse(json['data_ultima_pesagem'])
          : null,
      status: json['status'] ?? 'ativo',
      observacoes: json['observacoes'],
      urlImagem: json['url_imagem'],
      criadoEm: json['criado_em'] != null
          ? DateTime.parse(json['criado_em'])
          : null,
      atualizadoEm: json['atualizado_em'] != null
          ? DateTime.parse(json['atualizado_em'])
          : null,
    );
  }

  // Factory simplificado para listas de seleção (pai/mãe)
  factory AnimalModel.fromJsonSimple(Map<String, dynamic> json) {
    return AnimalModel(
      id: json['id'],
      brinco: json['brinco'] ?? '',
      nome: json['nome'],
      sexo: json['sexo'] ?? 'M',
      dataNascimento: DateTime.now(), // Não importa para seleção
    );
  }

  Map<String, dynamic> toJson() {
    return {
      if (id != null) 'id': id,
      'brinco': brinco,
      'nome': nome,
      'grupo_id': grupoId,
      'pai_id': paiId,
      'mae_id': maeId,
      'sexo': sexo,
      'tipo_pele': tipoPele,
      'raca': raca,
      'data_nascimento': dataNascimento.toIso8601String().split('T')[0],
      'peso_atual_kg': pesoAtualKg,
      'data_ultima_pesagem': dataUltimaPesagem?.toIso8601String().split('T')[0],
      'status': status,
      'observacoes': observacoes,
      'url_imagem': urlImagem,
    };
  }

  AnimalModel copyWith({
    String? id,
    String? brinco,
    String? nome,
    String? grupoId,
    String? paiId,
    String? maeId,
    String? sexo,
    String? tipoPele,
    String? raca,
    DateTime? dataNascimento,
    double? pesoAtualKg,
    DateTime? dataUltimaPesagem,
    String? status,
    String? observacoes,
    String? urlImagem,
  }) {
    return AnimalModel(
      id: id ?? this.id,
      brinco: brinco ?? this.brinco,
      nome: nome ?? this.nome,
      grupoId: grupoId ?? this.grupoId,
      paiId: paiId ?? this.paiId,
      maeId: maeId ?? this.maeId,
      sexo: sexo ?? this.sexo,
      tipoPele: tipoPele ?? this.tipoPele,
      raca: raca ?? this.raca,
      dataNascimento: dataNascimento ?? this.dataNascimento,
      pesoAtualKg: pesoAtualKg ?? this.pesoAtualKg,
      dataUltimaPesagem: dataUltimaPesagem ?? this.dataUltimaPesagem,
      status: status ?? this.status,
      observacoes: observacoes ?? this.observacoes,
      urlImagem: urlImagem ?? this.urlImagem,
    );
  }

  // Helper: Ícone de sexo
  String get sexoIcone => sexo == 'M' ? '♂️' : '♀️';

  // Helper: Cor por sexo
  String get sexoCor => sexo == 'M' ? 'blue' : 'pink';
}
