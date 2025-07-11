class Cliente {
  final int? idCliente;
  final String nome;
  final String cpf;
  final String? telefone;
  final String? email;
  final String? endereco;
  final DateTime? dataCadastro;
  final DateTime? dataAtualizacao;
  final bool ativo;

  Cliente({
    this.idCliente,
    required this.nome,
    required this.cpf,
    this.telefone,
    this.email,
    this.endereco,
    this.dataCadastro,
    this.dataAtualizacao,
    this.ativo = true,
  });

  /// [Map]  [Cliente].
  factory Cliente.fromMap(Map<String, dynamic> map) {
    return Cliente(
      idCliente: map['id_cliente'] as int?,
      nome: map['nome'] as String,
      cpf: map['cpf'] as String,
      telefone: map['telefone'] as String?,
      email: map['email'] as String?,
      endereco: map['endereco'] as String?,
      ativo: map['ativo'] == 1, 
      dataCadastro: map['data_cadastro'] != null
          ? DateTime.parse(map['data_cadastro'] as String)
          : null,
      dataAtualizacao: map['data_atualizacao'] != null
          ? DateTime.parse(map['data_atualizacao'] as String)
          : null,
    );
  }

  /// [Cliente] em um [Map]
  Map<String, dynamic> toMap() {
    return {
      'id_cliente': idCliente,
      'nome': nome,
      'cpf': cpf,
      'telefone': telefone,
      'email': email,
      'endereco': endereco,
      'ativo': ativo ? 1 : 0,
      'data_cadastro': dataCadastro?.toIso8601String(),
      'data_atualizacao': dataAtualizacao?.toIso8601String(),
    };
  }

  @override
  String toString() {
    return 'Cliente(idCliente: $idCliente, nome: $nome, cpf: $cpf, email: $email, ativo: $ativo)';
  }
}