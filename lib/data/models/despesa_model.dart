import 'package:intl/intl.dart';

class DespesaModel {
  final String? id;
  final String? categoriaId;
  final String descricao;
  final double valor;
  final DateTime dataDespesa;
  final String? animalId;
  final String? grupoId;
  final double? quantidade;
  final String? unidade;
  final String? fornecedor;
  final String? notaFiscal;
  final DateTime? criadoEm;

  // Dados relacionados (joins)
  final String? categoriaNome;
  final String? animalBrinco;
  final String? grupoNome;

  DespesaModel({
    this.id,
    this.categoriaId,
    required this.descricao,
    required this.valor,
    required this.dataDespesa,
    this.animalId,
    this.grupoId,
    this.quantidade,
    this.unidade,
    this.fornecedor,
    this.notaFiscal,
    this.criadoEm,
    this.categoriaNome,
    this.animalBrinco,
    this.grupoNome,
  });

  factory DespesaModel.fromJson(Map<String, dynamic> json) {
    return DespesaModel(
      id: json['id'],
      categoriaId: json['categoria_id'],
      descricao: json['descricao'] ?? '',
      valor: json['valor'] != null
          ? double.tryParse(json['valor'].toString()) ?? 0.0
          : 0.0,
      dataDespesa: json['data_despesa'] != null
          ? DateTime.parse(json['data_despesa'])
          : DateTime.now(),
      animalId: json['animal_id'],
      grupoId: json['grupo_id'],
      quantidade: json['quantidade'] != null
          ? double.tryParse(json['quantidade'].toString())
          : null,
      unidade: json['unidade'],
      fornecedor: json['fornecedor'],
      notaFiscal: json['nota_fiscal'],
      criadoEm: json['criado_em'] != null
          ? DateTime.parse(json['criado_em'])
          : null,
      // Joins
      categoriaNome: json['categorias_custo'] != null
          ? json['categorias_custo']['nome']
          : null,
      animalBrinco:
          json['animais'] != null ? json['animais']['brinco'] : null,
      grupoNome: json['grupos'] != null ? json['grupos']['nome'] : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      if (id != null) 'id': id,
      if (categoriaId != null) 'categoria_id': categoriaId,
      'descricao': descricao,
      'valor': valor,
      'data_despesa': DateFormat('yyyy-MM-dd').format(dataDespesa),
      if (animalId != null) 'animal_id': animalId,
      if (grupoId != null) 'grupo_id': grupoId,
      if (quantidade != null) 'quantidade': quantidade,
      if (unidade != null) 'unidade': unidade,
      if (fornecedor != null) 'fornecedor': fornecedor,
      if (notaFiscal != null) 'nota_fiscal': notaFiscal,
    };
  }

  // Helpers de formatação
  String get valorFormatado {
    return 'R\$ ${valor.toStringAsFixed(2).replaceAll('.', ',')}';
  }

  String get dataFormatada {
    return DateFormat('dd/MM/yyyy').format(dataDespesa);
  }

  String? get quantidadeFormatada {
    if (quantidade == null) return null;
    return '${quantidade!.toStringAsFixed(2)} ${unidade ?? ''}';
  }

  // Helper: Vinculação (animal ou grupo)
  String? get vinculacao {
    if (animalBrinco != null) return '🐄 $animalBrinco';
    if (grupoNome != null) return '📁 $grupoNome';
    return null;
  }

  // Helper: Descrição completa
  String get descricaoCompleta {
    String desc = descricao;
    if (vinculacao != null) {
      desc += ' • $vinculacao';
    }
    return desc;
  }
}
