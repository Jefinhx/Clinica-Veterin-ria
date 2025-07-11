import 'package:supabase_flutter/supabase_flutter.dart';

class ProntuariosRepository {
  final SupabaseClient _client;

  ProntuariosRepository(this._client);

  Future<List<Map<String, dynamic>>> getProntuariosByAnimalId(int animalId) async {
    try {
      return await _client
          .from('prontuarios')
          .select('*, usuarios(nome)')
          .eq('id_animal', animalId)
          .order('data_atendimento', ascending: false);
    } catch (e) {
      rethrow;
    }
  }

  Future<Map<String, dynamic>?> getProntuarioById(int prontuarioId) async {
     try {
      return await _client
          .from('prontuarios')
          .select('*, usuarios(nome)')
          .eq('id_prontuario', prontuarioId)
          .maybeSingle();
    } catch (e) {
      rethrow;
    }
  }

  Future<void> createProntuario(Map<String, dynamic> data) async {
    try {
      await _client.from('prontuarios').insert(data);
    } catch (e) {
      rethrow;
    }
  }

  Future<void> updateProntuario(int prontuarioId, Map<String, dynamic> data) async {
    try {
      await _client.from('prontuarios').update(data).eq('id_prontuario', prontuarioId);
    } catch (e) {
      rethrow;
    }
  }

  Future<void> deleteProntuario(int prontuarioId) async {
    try {
      await _client.from('prontuarios').delete().eq('id_prontuario', prontuarioId);
    } catch (e) {
      rethrow;
    }
  }
}