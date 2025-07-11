class Produto {
  final int? id;
  final String nome;
  final String? descricao;
  final double precoVenda;
  final String unidadeMedida;
  final int estoqueAtual;
  final int estoqueMinimo;
  final DateTime? dataCadastro;
  final DateTime? dataAtualizacao;

  Produto({
    this.id,
    required this.nome,
    this.descricao,
    required this.precoVenda,
    required this.unidadeMedida,
    required this.estoqueAtual,
    required this.estoqueMinimo,
    this.dataCadastro,
    this.dataAtualizacao,
  });

  // <<< GARANTA QUE ESTE MÉTODO EXISTA NO SEU ARQUIVO >>>
  factory Produto.fromMap(Map<String, dynamic> map) {
    return Produto(
      id: map['id_produto'] as int?,
      nome: map['nome'] as String? ?? 'Nome não informado',
      descricao: map['descricao'] as String?,
      precoVenda: (map['preco_venda'] as num? ?? 0).toDouble(),
      unidadeMedida: map['unidade_medida'] as String? ?? 'UN',
      estoqueAtual: map['estoque_atual'] as int? ?? 0,
      estoqueMinimo: map['estoque_minimo'] as int? ?? 0,
      dataCadastro: map['data_cadastro'] != null ? DateTime.parse(map['data_cadastro'] as String) : null,
      dataAtualizacao: map['data_atualizacao'] != null ? DateTime.parse(map['data_atualizacao'] as String) : null,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id_produto': id,
      'nome': nome,
      'descricao': descricao,
      'preco_venda': precoVenda,
      'unidade_medida': unidadeMedida,
      'estoque_atual': estoqueAtual,
      'estoque_minimo': estoqueMinimo,
    };
  }
}