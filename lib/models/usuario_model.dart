class Usuario {
  final int? idUsuario;
  final String nome;
  final String email;
  final String senhaHash;
  final String perfil;
  final bool ativo;
  final DateTime? dataCadastro;
  final DateTime? dataAtualizacao;

  Usuario({
    this.idUsuario,
    required this.nome,
    required this.email,
    required this.senhaHash,
    required this.perfil,
    this.ativo = true,
    this.dataCadastro,
    this.dataAtualizacao,
  });

  factory Usuario.fromMap(Map<String, dynamic> map) {
    return Usuario(
      idUsuario: map['id_usuario'] as int?,
      nome: map['nome'] as String,
      email: map['email'] as String,
      senhaHash: map['senha_hash'] as String,
      perfil: map['perfil'] as String,
      ativo: map['ativo'] == 1,
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
      'id_usuario': idUsuario,
      'nome': nome,
      'email': email,
      'senha_hash': senhaHash,
      'perfil': perfil,
      'ativo': ativo ? 1 : 0,
      'data_cadastro': dataCadastro?.toIso8601String(),
      'data_atualizacao': dataAtualizacao?.toIso8601String(),
    };
  }

  @override
  String toString() {
    return 'Usuario(idUsuario: $idUsuario, nome: $nome, email: $email, perfil: $perfil, ativo: $ativo)';
  }
}