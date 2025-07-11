import 'package:supabase_flutter/supabase_flutter.dart';

class ClientsRepository { 
  final SupabaseClient _client;

  ClientsRepository(this._client);

  Future<List<Map<String, dynamic>>> getClients() async {
    try {
      return await _client
          .from('clientes')
          .select('id_cliente, nome, cpf, telefone, email, endereco, ativo') // Seleciona todos os campos
          .eq('ativo', true) // Garante que só clientes ativos apareçam
          .order('nome', ascending: true);
    } catch (e) { 
      rethrow; 
    }
  }
}