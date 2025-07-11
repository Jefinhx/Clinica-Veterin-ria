// O repositório de usuários, responsável por buscar os dados no Supabase.
import 'package:supabase_flutter/supabase_flutter.dart';

class UsersRepository {
  final SupabaseClient _client;

  UsersRepository(this._client);


  Future<List<Map<String, dynamic>>> getVeterinarios() async {
    try {
      return await _client
          .from('usuarios')
          .select('id_usuario, nome')
          .eq('perfil', 'Veterinário')
          .order('nome', ascending: true);
    } catch (e) {
      rethrow;
    }
  }
}