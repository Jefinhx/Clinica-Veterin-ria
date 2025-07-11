class Prontuario {
  final int? id;
  final int idAnimal;
  final String idVeterinario;
  final DateTime dataAtendimento;
  final String? tipoAtendimento;
  final String? anamnese;
  final String? diagnostico;
  final String? procedimentosRealizados;
  final String? observacoes;

  Prontuario({
    this.id,
    required this.idAnimal,
    required this.idVeterinario,
    required this.dataAtendimento,
    this.tipoAtendimento,
    this.anamnese,
    this.diagnostico,
    this.procedimentosRealizados,
    this.observacoes,
  });
}