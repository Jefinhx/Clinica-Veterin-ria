import 'package:supabase_flutter/supabase_flutter.dart';

class RelatoriosRepository {
  final SupabaseClient _client;

  RelatoriosRepository(this._client);

  Future<List<Map<String, dynamic>>> getRelatorioLucros() async {
    try {
      final response = await _client.rpc('relatorio_lucros');
    
      if (response is List) {
        return List<Map<String, dynamic>>.from(response);
      }
      return [];
    } catch (e) {
      
      rethrow;
    }
  }

  Future<List<Map<String, dynamic>>> getRelatorioAtendimentos() async {
    try {
      final response = await _client.rpc('relatorio_atendimentos');
      if (response is List) {
        return List<Map<String, dynamic>>.from(response);
      }
      return [];
    } catch (e) {
      rethrow;
    }
  }

  Future<List<Map<String, dynamic>>> getRelatorioGastosCliente() async {
    try {
      final response = await _client.rpc('relatorio_gastos');
      if (response is List) {
        return List<Map<String, dynamic>>.from(response);
      }
      return [];
    } catch (e) {
      rethrow;
    }
  }
}