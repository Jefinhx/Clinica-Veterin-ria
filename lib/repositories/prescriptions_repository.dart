class Prescricao {
  final int? idPrescricao;
  final int idProntuario; 
  final String medicamento;
  final String? dosagem;
  final String? frequencia;
  final String? duracao;
  final String? observacoes;
  final DateTime? dataPrescricao;

  Prescricao({
    this.idPrescricao,
    required this.idProntuario,
    required this.medicamento,
    this.dosagem,
    this.frequencia,
    this.duracao,
    this.observacoes,
    this.dataPrescricao,
  });

  /// [Map] [Prescricao].
  factory Prescricao.fromMap(Map<String, dynamic> map) {
    return Prescricao(
      idPrescricao: map['id_prescricao'] as int?,
      idProntuario: map['id_prontuario'] as int,
      medicamento: map['medicamento'] as String,
      dosagem: map['dosagem'] as String?,
      frequencia: map['frequencia'] as String?,
      duracao: map['duracao'] as String?,
      observacoes: map['observacoes'] as String?,
      dataPrescricao: map['data_prescricao'] != null
          ? DateTime.parse(map['data_prescricao'] as String)
          : null,
    );
  }

  /// [Prescricao] [Map]
  Map<String, dynamic> toMap() {
    return {
      'id_prescricao': idPrescricao,
      'id_prontuario': idProntuario,
      'medicamento': medicamento,
      'dosagem': dosagem,
      'frequencia': frequencia,
      'duracao': duracao,
      'observacoes': observacoes,
      'data_prescricao': dataPrescricao?.toIso8601String(),
    };
  }

  @override
  String toString() {
    return 'Prescricao(idPrescricao: $idPrescricao, idProntuario: $idProntuario, medicamento: $medicamento)';
  }
}