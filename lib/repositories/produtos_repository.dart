import 'package:supabase_flutter/supabase_flutter.dart';

class ProdutosRepository {
  final SupabaseClient _client;

  ProdutosRepository(this._client);


  Future<List<Map<String, dynamic>>> getProdutos() async {
    try {
      final data = await _client
          .from('produtos')
          .select()
          .order('nome', ascending: true);
      return data;
    } catch (e) {
      
      rethrow;
    }
  }

  // CREATE: vai criar um novo produto
  Future<void> createProduto(Map<String, dynamic> produtoData) async {
    try {
      await _client.from('produtos').insert(produtoData);
    } catch (e) {
      rethrow;
    }
  }

  // UPDATE: vai atualizar o produto
  Future<void> updateProduto(int produtoId, Map<String, dynamic> produtoData) async {
    try {
      await _client
          .from('produtos')
          .update(produtoData)
          .eq('id_produto', produtoId);
    } catch (e) {
      rethrow;
    }
  }

  // DELETE: Vai deletar o produto
  Future<void> deleteProduto(int produtoId) async {
    try {
      await _client
          .from('produtos')
          .delete()
          .eq('id_produto', produtoId);
    } catch (e) {
      rethrow;
    }
  }
}