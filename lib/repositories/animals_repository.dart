import 'package:supabase_flutter/supabase_flutter.dart';

class AnimalsRepository {
  final SupabaseClient _client;

  AnimalsRepository(this._client);


  Future<List<Map<String, dynamic>>> getAnimalsByClientId(int clientId) async {
    try {
      return await _client
          .from('animais')
          .select('id_animal, nome')
          .eq('id_cliente', clientId)
          .order('nome', ascending: true);
    } catch (e) {
      rethrow;
    }
  }
}