import 'package:supabase_flutter/supabase_flutter.dart';

class AuthRepository {
  final SupabaseClient _supabaseClient;

  AuthRepository(this._supabaseClient);

  Future<String> signInWithEmailAndPassword(String email, String password) async {
    try {
      final AuthResponse res = await _supabaseClient.auth.signInWithPassword(
        email: email.trim(),
        password: password,
      );
      if (res.session != null && res.user != null) {
        return res.user!.id;
      } else {
        throw AuthException('Credenciais inválidas ou e-mail não confirmado.');
      }
    } on AuthException {
      rethrow;
    } catch (e) {
      throw AuthException('Erro inesperado ao fazer login: ${e.toString()}');
    }
  }

  Future<String> signUpWithEmailAndPassword(String name, String role, String email, String password) async {
    try {
      final AuthResponse res = await _supabaseClient.auth.signUp(
        email: email.trim(),
        password: password,
        data: {
          'nome': name,
          'perfil': role,
        },
      );
      if (res.user != null) {
        await _supabaseClient.from('usuarios').insert({
          'id_usuario': res.user!.id,
          'nome': name,
          'email': email,
          'perfil': role,
          'senha_hash': 'managed_by_supabase_auth',
          'ativo': true,
          'data_cadastro': DateTime.now().toIso8601String(),
        });
        return res.user!.id;
      } else {
        throw AuthException('Cadastro efetuado! Verifique seu e-mail para confirmar a conta.');
      }
    } on AuthException {
      rethrow;
    } on PostgrestException catch (e) {
      throw AuthException('Erro ao salvar perfil em public.usuarios: ${e.message}');
    } catch (e) {
      throw AuthException('Erro inesperado ao cadastrar: ${e.toString()}');
    }
  }

  Future<void> signOut() async {
    try {
      await _supabaseClient.auth.signOut();
    } catch (e) {

      throw Exception('Erro ao fazer logout: ${e.toString()}');
    }
  }
}