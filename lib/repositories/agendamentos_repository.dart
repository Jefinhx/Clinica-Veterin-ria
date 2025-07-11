import 'package:supabase_flutter/supabase_flutter.dart';

class AgendamentosRepository {
  final SupabaseClient _client;

  AgendamentosRepository(this._client);

  Future<List<Map<String, dynamic>>> getAgendamentosByAnimalId(int animalId) async {
    try {
      final response = await _client
          .from('agendamentos')
          .select('*, clientes(nome), animais(nome), usuarios(nome)')
          .eq('id_animal', animalId)
          .order('data_hora_inicio', ascending: true);
      return response;
    } on PostgrestException catch (e) {
      throw 'Erro ao buscar agendamentos: ${e.message}';
    } catch (e) {
      throw 'Erro inesperado: ${e.toString()}';
    }
  }

  Future<Map<String, dynamic>?> getAgendamentoById(int id) async {
    try {
      final response = await _client
          .from('agendamentos')
          .select('*')
          .eq('id_agendamento', id)
          .maybeSingle();
      return response;
    } on PostgrestException catch (e) {
      throw 'Erro ao buscar agendamento: ${e.message}';
    } catch (e) {
      throw 'Erro inesperado: ${e.toString()}';
    }
  }

  Future<void> createAgendamento(Map<String, dynamic> data) async {
    try {
      await _client.from('agendamentos').insert(data);
    } on PostgrestException catch (e) {
      throw 'Erro ao criar agendamento: ${e.message}';
    } catch (e) {
      throw 'Erro inesperado: ${e.toString()}';
    }
  }

  Future<void> updateAgendamento(int id, Map<String, dynamic> data) async {
    try {
      await _client
          .from('agendamentos')
          .update(data)
          .eq('id_agendamento', id);
    } on PostgrestException catch (e) {
      throw 'Erro ao atualizar agendamento: ${e.message}';
    } catch (e) {
      throw 'Erro inesperado: ${e.toString()}';
    }
  }

  Future<void> deleteAgendamento(int id) async {
    try {
      await _client
          .from('agendamentos')
          .delete()
          .eq('id_agendamento', id);
    } on PostgrestException catch (e) {
      throw 'Erro ao deletar agendamento: ${e.message}';
    } catch (e) {
      throw 'Erro inesperado: ${e.toString()}';
    }
  }
}