class Animal {
  final int? idAnimal;
  final int idCliente;
  final String nome;
  final String especie;
  final String? raca;
  final DateTime? dataNascimento;
  final String? sexo;
  final double? peso;
  final String? observacoes;
  final DateTime? dataCadastro;
  final DateTime? dataAtualizacao;

  Animal({
    this.idAnimal,
    required this.idCliente,
    required this.nome,
    required this.especie,
    this.raca,
    this.dataNascimento,
    this.sexo,
    this.peso,
    this.observacoes,
    this.dataCadastro,
    this.dataAtualizacao,
  });

  factory Animal.fromMap(Map<String, dynamic> map) {
    return Animal(
      idAnimal: map['id_animal'] as int?,
      idCliente: map['id_cliente'] as int,
      nome: map['nome'] as String,
      especie: map['especie'] as String,
      raca: map['raca'] as String?,
      dataNascimento: map['data_nascimento'] != null
          ? DateTime.parse(map['data_nascimento'] as String)
          : null,
      sexo: map['sexo'] as String?,
      peso: map['peso'] as double?,
      observacoes: map['observacoes'] as String?,
      dataCadastro: map['data_cadastro'] != null
          ? DateTime.parse(map['data_cadastro'] as String)
          : null,
      dataAtualizacao: map['data_atualizacao'] != null
          ? DateTime.parse(map['data_atualizacao'] as String)
          : null,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id_animal': idAnimal,
      'id_cliente': idCliente,
      'nome': nome,
      'especie': especie,
      'raca': raca,
      'data_nascimento': dataNascimento?.toIso8601String().split('T').first,
      'sexo': sexo,
      'peso': peso,
      'observacoes': observacoes,
      'data_cadastro': dataCadastro?.toIso8601String(),
      'data_atualizacao': dataAtualizacao?.toIso8601String(),
    };
  }

  @override
  String toString() {
    return 'Animal(idAnimal: $idAnimal, idCliente: $idCliente, nome: $nome, especie: $especie)';
  }
}