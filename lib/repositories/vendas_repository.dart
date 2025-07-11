import 'package:supabase_flutter/supabase_flutter.dart';

class VendasRepository {
  final SupabaseClient _supabaseClient;

  VendasRepository(this._supabaseClient);


  Future<void> registrarVenda({
    required int idCliente,
    required int idProduto,
    required int quantidade,
    required double valorTotal,
    required String formaPagamento,
    required String nomeProduto,
  }) async {
    try {
      await _supabaseClient.rpc('registrar_venda_produto', params: {
        'p_id_cliente': idCliente,
        'p_id_produto': idProduto,
        'p_quantidade': quantidade,
        'p_valor_total': valorTotal,
        'p_forma_pagamento': formaPagamento,
        'p_descricao_servico': 'Venda: $nomeProduto',
      });
    } catch (e) {
      // Relança o erro para ser tratado na UI
      print('Erro no repositório ao registrar venda: $e');
      rethrow;
    }
  }
}