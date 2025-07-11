import 'package:clinica_veterinaria/models/cliente_model.dart';
import 'package:clinica_veterinaria/models/produto_model.dart';
import 'package:clinica_veterinaria/repositories/clients_repository.dart';
import 'package:clinica_veterinaria/repositories/produtos_repository.dart';
import 'package:clinica_veterinaria/repositories/vendas_repository.dart';
import 'package:clinica_veterinaria/screens/agendamentos_screen.dart';
import 'package:clinica_veterinaria/screens/cadastros_screen.dart';
import 'package:clinica_veterinaria/screens/estoque_farmacia_screen.dart';
import 'package:clinica_veterinaria/screens/home_screen.dart';
import 'package:clinica_veterinaria/screens/login_signup_screen.dart';
import 'package:clinica_veterinaria/screens/prontuarios_screen.dart';
import 'package:clinica_veterinaria/screens/relatorios_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class AppColors {
  static const Color bgBlack900 = Color(0xFFF2F2FC);
  static const Color bgBlack100 = Color(0xFFFDF9FF);
  static const Color bgBlack50 = Color(0xFFE8DFEC);
  static const Color textBlack900 = Color(0xFF009D66);
  static const Color skinColor = Color(0xFF000000);
  static const Color textGray = Color(0xFF555555);
  static const Color borderColor = Color(0xFFDCDCDC);
  static const Color successColor = Color(0xFF28A745);
  static const Color errorColor = Color(0xFFDC3545);
}

class LojaScreen extends StatefulWidget {
  const LojaScreen({super.key});
  @override
  State<LojaScreen> createState() => _LojaScreenState();
}
class _LojaScreenState extends State<LojaScreen> {
  late final ClientsRepository _clientsRepository;
  late final ProdutosRepository _produtosRepository;
  late final VendasRepository _vendasRepository;

  List<Cliente> _clientes = [];
  List<Produto> _produtos = [];

  Cliente? _selectedCliente;
  Produto? _selectedProduto;
  String? _formaPagamento;
  double _valorTotal = 0.0;
  bool _isLoading = true;
  bool _isFinalizandoCompra = false;
  final TextEditingController _quantidadeController = TextEditingController();

  @override
  void initState() {
    super.initState();
    final supabase = Supabase.instance.client;
    _clientsRepository = ClientsRepository(supabase);
    _produtosRepository = ProdutosRepository(supabase);
    _vendasRepository = VendasRepository(supabase);
    _quantidadeController.addListener(_updateTotal);
    _loadInitialData();
  }

  @override
  void dispose() {
    _quantidadeController.removeListener(_updateTotal);
    _quantidadeController.dispose();
    super.dispose();
  }

  Future<void> _loadInitialData() async {
    if (!mounted) return;
    setState(() => _isLoading = true);
    try {
      final clientesDataFuture = _clientsRepository.getClients(); 
      final produtosDataFuture = _produtosRepository.getProdutos();

      final results = await Future.wait([clientesDataFuture, produtosDataFuture]);

      final clientesRaw = results[0] as List<dynamic>;
      final produtosRaw = results[1] as List<dynamic>;

      if (mounted) {
        setState(() {
          _clientes = clientesRaw
              .map((data) => Cliente.fromMap(data as Map<String, dynamic>))
              .toList();
          _produtos = produtosRaw
              .map((data) => Produto.fromMap(data as Map<String, dynamic>))
              .toList();
        });
      }
    } catch (e) {
      if (mounted) {
        _showSnackBar('Erro ao carregar dados: ${e.toString()}', isError: true);
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  void _updateTotal() {
    if (_selectedProduto != null) {
      final quantidade = int.tryParse(_quantidadeController.text) ?? 0;
      final preco = _selectedProduto!.precoVenda;
      setState(() => _valorTotal = preco * quantidade);
    } else {
      setState(() => _valorTotal = 0.0);
    }
  }

  void _resetForm() {
    setState(() {
      _selectedCliente = null;
      _selectedProduto = null;
      _formaPagamento = null;
      _valorTotal = 0.0;
      _quantidadeController.clear();
    });
  }

  String _formatCurrency(double? value) {
    return NumberFormat.currency(locale: 'pt_BR', symbol: 'R\$').format(value ?? 0);
  }

  Future<void> _handleFinalizarCompra() async {
    final quantidade = int.tryParse(_quantidadeController.text) ?? 0;

    if (_selectedCliente == null || _selectedProduto == null || quantidade <= 0 || _formaPagamento == null) {
      _showSnackBar('Preencha todos os campos corretamente.', isError: true);
      return;
    }
    if (quantidade > _selectedProduto!.estoqueAtual) {
      _showSnackBar('Estoque insuficiente. Disponível: ${_selectedProduto!.estoqueAtual}', isError: true);
      return;
    }

    setState(() => _isFinalizandoCompra = true);
    try {
      await _vendasRepository.registrarVenda(
        idCliente: _selectedCliente!.idCliente!,
        idProduto: _selectedProduto!.id!,
        quantidade: quantidade,
        valorTotal: _valorTotal,
        formaPagamento: _formaPagamento!,
        nomeProduto: _selectedProduto!.nome,
      );
      _showSnackBar('Venda finalizada com sucesso!');
      _resetForm();
      await _loadInitialData();
    } catch (e) {
      _showSnackBar('Erro ao finalizar a venda: ${e.toString()}', isError: true);
    } finally {
      if (mounted) {
        setState(() => _isFinalizandoCompra = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bgBlack900,
      body: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildSidebar(context),
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(30),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Padding(
                    padding: const EdgeInsets.only(bottom: 20),
                    child: Row(children: [
                      const Icon(FontAwesomeIcons.store, size: 24, color: AppColors.textBlack900),
                      const SizedBox(width: 10),
                      Text('Loja', style: GoogleFonts.poppins(fontSize: 37, fontWeight: FontWeight.bold, color: AppColors.textBlack900)),
                    ]),
                  ),
                  const SizedBox(height: 20),
                  Text('Realize a venda de produtos para os seus clientes de forma rápida.', style: GoogleFonts.poppins(fontSize: 16, color: AppColors.textBlack900.withOpacity(0.8))),
                  const SizedBox(height: 40),
                  _isLoading
                  ? const Center(child: CircularProgressIndicator(color: AppColors.textBlack900,))
                  : _buildVendaForm(),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildVendaForm() {
    return Container(
      padding: const EdgeInsets.all(30),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 15, offset: const Offset(0, 5))]
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Registrar Nova Venda', style: GoogleFonts.poppins(fontSize: 22, fontWeight: FontWeight.bold, color: AppColors.textBlack900)),
          const Divider(height: 30),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: _buildFormGroup(
                  label: 'Cliente',
                  child: DropdownButtonFormField<Cliente>(
                    value: _selectedCliente,
                    decoration: _inputDecoration(hintText: 'Selecione o cliente', icon: FontAwesomeIcons.userTag),
                    items: _clientes.map((cliente) => DropdownMenuItem<Cliente>(value: cliente, child: Text(cliente.nome))).toList(),
                    onChanged: (value) => setState(() => _selectedCliente = value),
                  ),
                ),
              ),
              const SizedBox(width: 20),
              Expanded(
                flex: 2,
                child: _buildFormGroup(
                  label: 'Produto',
                  child: DropdownButtonFormField<Produto>(
                    value: _selectedProduto,
                    decoration: _inputDecoration(hintText: 'Selecione o produto', icon: FontAwesomeIcons.boxOpen),
                    items: _produtos.map((produto) => DropdownMenuItem<Produto>(value: produto, child: Text(produto.nome))).toList(),
                    onChanged: (value) {
                      setState(() {
                        _selectedProduto = value;
                        _quantidadeController.text = "1";
                      });
                      _updateTotal();
                    },
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          if (_selectedProduto != null) ...[
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  flex: 1,
                  child: _buildFormGroup(
                    label: 'Quantidade',
                    child: TextFormField(
                      controller: _quantidadeController,
                      keyboardType: TextInputType.number,
                      inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                      decoration: _inputDecoration(hintText: 'Ex: 1'),
                      textAlign: TextAlign.center,
                      style: GoogleFonts.poppins(fontWeight: FontWeight.bold, fontSize: 18),
                    ),
                  ),
                ),
                const SizedBox(width: 20),
                Expanded(
                  flex: 1,
                  child: _buildInfoBox(
                    label: 'Preço Unitário',
                    value: _formatCurrency(_selectedProduto?.precoVenda),
                  ),
                ),
                Expanded(
                  flex: 1,
                  child: _buildInfoBox(
                    label: 'Estoque Atual',
                    value: _selectedProduto?.estoqueAtual.toString() ?? '0',
                  ),
                ),
              ],
            ),
          ],
          const Divider(height: 40, thickness: 1),
          Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Expanded(
                flex: 2,
                child: _buildFormGroup(
                  label: 'Forma de Pagamento',
                  child: DropdownButtonFormField<String>(
                    value: _formaPagamento,
                    decoration: _inputDecoration(hintText: 'Selecione a forma', icon: FontAwesomeIcons.creditCard),
                    items: const [
                      DropdownMenuItem(value: 'Pix', child: Text('Pix')),
                      DropdownMenuItem(value: 'Dinheiro', child: Text('Dinheiro')),
                      DropdownMenuItem(value: 'Débito', child: Text('Débito')),
                    ],
                    onChanged: (value) => setState(() => _formaPagamento = value),
                  ),
                ),
              ),
              const SizedBox(width: 20),
              Expanded(
                flex: 2,
                child: Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: AppColors.textBlack900.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('VALOR TOTAL', style: GoogleFonts.poppins(color: AppColors.textBlack900, fontSize: 12, fontWeight: FontWeight.bold)),
                      const SizedBox(height: 5),
                      Text(_formatCurrency(_valorTotal), style: GoogleFonts.poppins(color: AppColors.textBlack900, fontSize: 28, fontWeight: FontWeight.bold)),
                    ],
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 40),
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              _isFinalizandoCompra
              ? const CircularProgressIndicator(color: AppColors.successColor)
              : ElevatedButton.icon(
                  onPressed: _handleFinalizarCompra,
                  icon: const Icon(FontAwesomeIcons.check, size: 16),
                  label: const Text('Finalizar Compra'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.successColor,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 20),
                    textStyle: GoogleFonts.poppins(fontSize: 16, fontWeight: FontWeight.bold)
                  ),
                ),
            ],
          )
        ],
      ),
    );
  }

  Widget _buildInfoBox({required String label, required String value}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: GoogleFonts.poppins(fontWeight: FontWeight.w600, color: AppColors.textGray, fontSize: 14)),
        const SizedBox(height: 8),
        Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 15),
          decoration: BoxDecoration(
            color: AppColors.bgBlack900,
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: AppColors.borderColor),
          ),
          child: Text(value, style: GoogleFonts.poppins(fontSize: 16, fontWeight: FontWeight.w500)),
        )
      ],
    );
  }

  Widget _buildFormGroup({required String label, required Widget child}) {
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Text(label, style: GoogleFonts.poppins(fontWeight: FontWeight.w600, color: AppColors.textGray, fontSize: 14)),
      const SizedBox(height: 8),
      child,
    ]);
  }

  InputDecoration _inputDecoration({required String hintText, IconData? icon}) {
    return InputDecoration(
      hintText: hintText,
      fillColor: Colors.white,
      filled: true,
      border: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: const BorderSide(color: AppColors.borderColor)),
      focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: const BorderSide(color: AppColors.textBlack900, width: 2)),
      contentPadding: const EdgeInsets.symmetric(vertical: 16, horizontal: 15),
      prefixIcon: icon != null ? Padding(
        padding: const EdgeInsets.symmetric(horizontal: 12.0),
        child: Icon(icon, size: 18, color: AppColors.textGray),
      ) : null,
      prefixIconConstraints: icon != null ? const BoxConstraints(minWidth: 40) : null,
    );
  }

  void _showSnackBar(String message, {bool isError = false}) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Text(message, style: GoogleFonts.poppins()),
      backgroundColor: isError ? AppColors.errorColor : AppColors.successColor,
      behavior: SnackBarBehavior.floating,
      margin: const EdgeInsets.all(20),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
    ));
  }
  
  Widget _buildSidebar(BuildContext context) {
    return Container(
      width: 270,
      decoration: const BoxDecoration(color: AppColors.bgBlack100, border: Border(right: BorderSide(color: AppColors.bgBlack50))),
      padding: const EdgeInsets.all(30),
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.only(bottom: 30),
            child: Text('Bem-estar Animal', style: GoogleFonts.clickerScript(fontSize: 30, color: AppColors.textBlack900, fontWeight: FontWeight.bold)),
          ),
          Expanded(
            child: ListView(
              padding: EdgeInsets.zero,
              children: [
                _buildNavLink('Página Inicial', FontAwesomeIcons.house, false, () => Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => const HomeScreen()))),
                _buildNavLink('Agendamentos', FontAwesomeIcons.calendarCheck, false, () => Navigator.push(context, MaterialPageRoute(builder: (_) => const AgendamentosScreen()))),
                _buildNavLink('Cadastros', FontAwesomeIcons.user, false, () => Navigator.push(context, MaterialPageRoute(builder: (_) => const CadastrosScreen()))),
                _buildNavLink('Estoque', FontAwesomeIcons.boxesStacked, false, () => Navigator.push(context, MaterialPageRoute(builder: (_) => const EstoqueFarmaciaScreen()))),
                _buildNavLink('Loja', FontAwesomeIcons.store, true),
                _buildNavLink('Prontuários', FontAwesomeIcons.stethoscope, false, () => Navigator.push(context, MaterialPageRoute(builder: (_) => const ProntuariosScreen()))),
                _buildNavLink('Relatórios', FontAwesomeIcons.chartBar, false, () => Navigator.push(context, MaterialPageRoute(builder: (_) => const RelatoriosScreen()))),
                _buildNavLink('Sair', FontAwesomeIcons.rightFromBracket, false, () {
                  Navigator.pushAndRemoveUntil(context, MaterialPageRoute(builder: (_) => const LoginSignupScreen()), (route) => false);
                }),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildNavLink(String text, IconData icon, bool isActive, [VoidCallback? onTap]) {
    return InkWell(
      onTap: isActive ? null : onTap,
      hoverColor: isActive ? Colors.transparent : AppColors.bgBlack50.withOpacity(0.5),
      borderRadius: BorderRadius.circular(8),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 15),
        margin: const EdgeInsets.only(bottom: 20),
        decoration: BoxDecoration(
          color: isActive ? AppColors.bgBlack50 : Colors.transparent,
          borderRadius: BorderRadius.circular(8)
        ),
        child: Row(children: [
          Icon(icon, size: 20, color: isActive ? AppColors.skinColor : AppColors.textBlack900),
          const SizedBox(width: 15),
          Text(
            text,
            style: GoogleFonts.poppins(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: isActive ? AppColors.skinColor : AppColors.textBlack900
            ),
          ),
        ]),
      ),
    );
  }
}