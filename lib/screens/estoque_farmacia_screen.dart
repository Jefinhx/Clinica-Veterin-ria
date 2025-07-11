import 'package:clinica_veterinaria/repositories/auth_repository.dart';
import 'package:clinica_veterinaria/repositories/produtos_repository.dart';
import 'package:clinica_veterinaria/screens/agendamentos_screen.dart';
import 'package:clinica_veterinaria/screens/cadastros_screen.dart';
import 'package:clinica_veterinaria/screens/home_screen.dart';
import 'package:clinica_veterinaria/screens/login_signup_screen.dart';
// 1. Import da nova tela da Loja
import 'package:clinica_veterinaria/screens/loja_screen.dart';
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
  static const Color editColor = Color(0xFF007BFF);
  static const Color deleteColor = Color(0xFFDC3545);
}

class EstoqueFarmaciaScreen extends StatefulWidget {
  const EstoqueFarmaciaScreen({super.key});

  @override
  State<EstoqueFarmaciaScreen> createState() => _EstoqueFarmaciaScreenState();
}

class _EstoqueFarmaciaScreenState extends State<EstoqueFarmaciaScreen> {
  late final ProdutosRepository _produtosRepo;
  late final AuthRepository _authRepo;

  final TextEditingController _produtoIdController = TextEditingController();
  final TextEditingController _nomeProdutoController = TextEditingController();
  final TextEditingController _precoProdutoController = TextEditingController();
  final TextEditingController _descricaoProdutoController = TextEditingController();
  final TextEditingController _unidadeMedidaController = TextEditingController();
  final TextEditingController _estoqueAtualController = TextEditingController();
  final TextEditingController _estoqueMinimoController = TextEditingController();
  final TextEditingController _searchController = TextEditingController();
  String _sortValue = 'nome-asc';
  List<Map<String, dynamic>> _allProdutos = [];
  List<Map<String, dynamic>> _filteredProdutos = [];
  bool _isLoading = true;
  bool _isEditing = false;

  @override
  void initState() {
    super.initState();
    final supabaseClient = Supabase.instance.client;
    _produtosRepo = ProdutosRepository(supabaseClient);
    _authRepo = AuthRepository(supabaseClient);

    _fetchProdutos();
    _searchController.addListener(_filterAndSortProdutos);
  }

  @override
  void dispose() {
    _produtoIdController.dispose();
    _nomeProdutoController.dispose();
    _precoProdutoController.dispose();
    _descricaoProdutoController.dispose();
    _unidadeMedidaController.dispose();
    _estoqueAtualController.dispose();
    _estoqueMinimoController.dispose();
    _searchController.removeListener(_filterAndSortProdutos);
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _fetchProdutos() async {
    setState(() => _isLoading = true);
    try {
      final data = await _produtosRepo.getProdutos();
      if (!mounted) return;
      setState(() {
        _allProdutos = data;
      });
      _filterAndSortProdutos();
    } catch (e) {
      if (!mounted) return;
      _showSnackBar('Erro ao carregar produtos: ${e.toString()}', isError: true);
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _handleFormSubmit() async {
    final nome = _nomeProdutoController.text.trim();
    final precoVenda = double.tryParse(_precoProdutoController.text.replaceAll(',', '.').trim());
    final unidadeMedida = _unidadeMedidaController.text.trim();
    final estoqueAtual = int.tryParse(_estoqueAtualController.text.trim());
    final estoqueMinimo = int.tryParse(_estoqueMinimoController.text.trim());

    if (nome.isEmpty || precoVenda == null || unidadeMedida.isEmpty || estoqueAtual == null || estoqueMinimo == null) {
      _showSnackBar('Todos os campos, exceto Descrição, são obrigatórios.', isError: true);
      return;
    }

    final record = {
      'nome': nome,
      'descricao': _descricaoProdutoController.text.trim(),
      'preco_venda': precoVenda,
      'unidade_medida': unidadeMedida,
      'estoque_atual': estoqueAtual,
      'estoque_minimo': estoqueMinimo,
    };

    try {
      if (_isEditing) {
        final idProduto = int.parse(_produtoIdController.text);
        record['data_atualizacao'] = DateTime.now().toIso8601String();
        await _produtosRepo.updateProduto(idProduto, record);
        _showSnackBar('Produto atualizado com sucesso!');
      } else {
        await _produtosRepo.createProduto(record);
        _showSnackBar('Produto criado com sucesso!');
      }
      if (!mounted) return;
      _resetForm();
      await _fetchProdutos();
    } catch (e) {
      _showSnackBar('Erro ao salvar produto: ${e.toString()}', isError: true);
    }
  }

  Future<void> _handleDelete(int idProduto) async {
    final bool confirmar = await showDialog(
          context: context,
          builder: (context) => AlertDialog(
            title: const Text('Confirmar Exclusão'),
            content: const Text('Deseja realmente excluir este produto?'),
            actions: [
              TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('Cancelar')),
              TextButton(onPressed: () => Navigator.pop(context, true), child: const Text('Excluir')),
            ],
          ),
        ) ?? false;

    if (!confirmar) return;

    try {
      await _produtosRepo.deleteProduto(idProduto);
      _showSnackBar('Produto excluído com sucesso!');
      await _fetchProdutos();
    } catch (e) {
      _showSnackBar('Erro ao excluir produto: ${e.toString()}', isError: true);
    }
  }

  void _filterAndSortProdutos() {
    List<Map<String, dynamic>> tempProdutos = List.from(_allProdutos);
    final searchTerm = _searchController.text.toLowerCase();

    if (searchTerm.isNotEmpty) {
      tempProdutos = tempProdutos.where((p) => (p['nome'] ?? '').toLowerCase().contains(searchTerm)).toList();
    }

    tempProdutos.sort((a, b) {
      switch (_sortValue) {
        case 'nome-desc': return (b['nome'] ?? '').compareTo(a['nome'] ?? '');
        case 'preco-asc': return (a['preco_venda'] ?? 0.0).compareTo(b['preco_venda'] ?? 0.0);
        case 'preco-desc': return (b['preco_venda'] ?? 0.0).compareTo(a['preco_venda'] ?? 0.0);
        default: return (a['nome'] ?? '').compareTo(b['nome'] ?? '');
      }
    });

    setState(() => _filteredProdutos = tempProdutos);
  }

  void _resetForm() {
    _produtoIdController.clear();
    _nomeProdutoController.clear();
    _precoProdutoController.clear();
    _descricaoProdutoController.clear();
    _unidadeMedidaController.clear();
    _estoqueAtualController.clear();
    _estoqueMinimoController.clear();
    setState(() => _isEditing = false);
  }

  void _setupEditForm(int idProduto) {
    final produto = _allProdutos.firstWhere((p) => p['id_produto'] == idProduto, orElse: () => {});
    if (produto.isEmpty) {
      _showSnackBar('Produto não encontrado para edição.', isError: true);
      return;
    }
    setState(() {
      _isEditing = true;
      _produtoIdController.text = produto['id_produto'].toString();
      _nomeProdutoController.text = produto['nome'] ?? '';
      _precoProdutoController.text = (produto['preco_venda']?.toString() ?? '').replaceAll('.', ',');
      _descricaoProdutoController.text = produto['descricao'] ?? '';
      _unidadeMedidaController.text = produto['unidade_medida'] ?? '';
      _estoqueAtualController.text = produto['estoque_atual']?.toString() ?? '';
      _estoqueMinimoController.text = produto['estoque_minimo']?.toString() ?? '';
    });
  }

  void _showSnackBar(String message, {bool isError = false}) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Text(message),
      backgroundColor: isError ? AppColors.errorColor : AppColors.successColor,
    ));
  }
  
  String _formatCurrency(double? value) {
    return NumberFormat.currency(locale: 'pt_BR', symbol: 'R\$').format(value ?? 0);
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
                      const Icon(FontAwesomeIcons.boxesStacked, size: 24),
                      const SizedBox(width: 10),
                      Text('Estoque', style: GoogleFonts.poppins(fontSize: 37, fontWeight: FontWeight.bold, color: AppColors.textBlack900)),
                    ]),
                  ),
                  const SizedBox(height: 20),
                  Text('Gerencie seus produtos e medicamentos aqui. Cadastre novos, edite existentes e controle seu estoque.', style: GoogleFonts.poppins(fontSize: 16, color: AppColors.textBlack900.withOpacity(0.8))),
                  const SizedBox(height: 40),
                  Container(
                    padding: const EdgeInsets.all(25),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: _isEditing ? AppColors.editColor : Colors.transparent, width: 2),
                    ),
                    margin: const EdgeInsets.only(bottom: 30),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(_isEditing ? 'Editando Produto: ${_nomeProdutoController.text}' : 'Cadastrar Novo Produto', style: GoogleFonts.poppins(fontSize: 22, fontWeight: FontWeight.bold, color: AppColors.textBlack900)),
                        const Divider(height: 30),
                        _buildFormGroup(
                          label: 'Nome do Produto',
                          child: TextFormField(controller: _nomeProdutoController, decoration: _inputDecoration(hintText: 'Ex: Ração Super Premium')),
                        ),
                        const SizedBox(height: 20),
                        _buildFormGroup(
                          label: 'Preço de Venda (R\$)',
                          child: TextFormField(controller: _precoProdutoController, keyboardType: const TextInputType.numberWithOptions(decimal: true), inputFormatters: [FilteringTextInputFormatter.allow(RegExp(r'^\d*\,?\d{0,2}'))], decoration: _inputDecoration(hintText: 'Ex: 150,90')),
                        ),
                        const SizedBox(height: 20),
                        _buildFormGroup(
                          label: 'Unidade de Medida',
                          child: TextFormField(controller: _unidadeMedidaController, decoration: _inputDecoration(hintText: 'Ex: Kg, Litro, Unidade')),
                        ),
                        const SizedBox(height: 20),
                        Row(
                          children: [
                            Expanded(child: _buildFormGroup(label: 'Estoque Atual', child: TextFormField(controller: _estoqueAtualController, keyboardType: TextInputType.number, inputFormatters: [FilteringTextInputFormatter.digitsOnly], decoration: _inputDecoration(hintText: 'Ex: 100')))),
                            const SizedBox(width: 20),
                            Expanded(child: _buildFormGroup(label: 'Estoque Mínimo', child: TextFormField(controller: _estoqueMinimoController, keyboardType: TextInputType.number, inputFormatters: [FilteringTextInputFormatter.digitsOnly], decoration: _inputDecoration(hintText: 'Ex: 10')))),
                          ],
                        ),
                        const SizedBox(height: 20),
                        _buildFormGroup(
                          label: 'Descrição',
                          child: TextFormField(controller: _descricaoProdutoController, maxLines: 3, decoration: _inputDecoration(hintText: 'Detalhes do produto...')),
                        ),
                        const SizedBox(height: 20),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.end,
                          children: [
                            if (_isEditing)
                              ElevatedButton.icon(onPressed: _resetForm, icon: const Icon(FontAwesomeIcons.xmark, size: 16), label: const Text('Cancelar Edição'), style: ElevatedButton.styleFrom(backgroundColor: AppColors.textGray, foregroundColor: Colors.white)),
                            const SizedBox(width: 10),
                            ElevatedButton.icon(onPressed: _handleFormSubmit, icon: const Icon(FontAwesomeIcons.save, size: 16), label: Text(_isEditing ? 'Salvar Alterações' : 'Salvar Produto'), style: ElevatedButton.styleFrom(backgroundColor: AppColors.textBlack900, foregroundColor: Colors.white)),
                          ],
                        ),
                      ],
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.all(25),
                    decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(12)),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Controle de Estoque', style: GoogleFonts.poppins(fontSize: 22, fontWeight: FontWeight.bold, color: AppColors.textBlack900)),
                        const Divider(height: 30),
                        _buildFiltersSection(),
                        const SizedBox(height: 20),
                        _isLoading
                            ? const Center(child: CircularProgressIndicator())
                            : _filteredProdutos.isEmpty
                                ? const Center(child: Padding(padding: EdgeInsets.all(40.0), child: Text('Nenhum produto encontrado.')))
                                : SingleChildScrollView(
                                    scrollDirection: Axis.horizontal,
                                    child: DataTable(
                                      columns: const [
                                        DataColumn(label: Text('Nome')),
                                        DataColumn(label: Text('Preço')),
                                        DataColumn(label: Text('Unid.')),
                                        DataColumn(label: Text('Est. Atual')),
                                        DataColumn(label: Text('Est. Mín.')),
                                        DataColumn(label: Text('Ações')),
                                      ],
                                      rows: _filteredProdutos.map((produto) => DataRow(cells: [
                                        DataCell(Text(produto['nome'] ?? '')),
                                        DataCell(Text(_formatCurrency(produto['preco_venda']))),
                                        DataCell(Text(produto['unidade_medida'] ?? '')),
                                        DataCell(Text(produto['estoque_atual']?.toString() ?? '')),
                                        DataCell(Text(produto['estoque_minimo']?.toString() ?? '')),
                                        DataCell(Row(
                                          children: [
                                            IconButton(icon: const Icon(FontAwesomeIcons.pencil, size: 16, color: AppColors.editColor), onPressed: () => _setupEditForm(produto['id_produto'])),
                                            IconButton(icon: const Icon(FontAwesomeIcons.trash, size: 16, color: AppColors.deleteColor), onPressed: () => _handleDelete(produto['id_produto'])),
                                          ],
                                        )),
                                      ])).toList(),
                                    ),
                                  ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
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
                _buildNavLink(FontAwesomeIcons.house, 'Página Inicial', onTap: () => Navigator.pushReplacement(context, MaterialPageRoute(builder: (c) => const HomeScreen()))),
                _buildNavLink(FontAwesomeIcons.calendarCheck, 'Agendamentos', onTap: () => Navigator.push(context, MaterialPageRoute(builder: (c) => const AgendamentosScreen()))),
                _buildNavLink(FontAwesomeIcons.user, 'Cadastros', onTap: () => Navigator.push(context, MaterialPageRoute(builder: (c) => const CadastrosScreen()))),
                _buildNavLink(FontAwesomeIcons.boxesStacked, 'Estoque', isActive: true),
                // 2. Link para a Loja adicionado aqui
                _buildNavLink(FontAwesomeIcons.store, 'Loja', onTap: () => Navigator.push(context, MaterialPageRoute(builder: (c) => const LojaScreen()))),
                _buildNavLink(FontAwesomeIcons.stethoscope, 'Prontuários', onTap: () => Navigator.push(context, MaterialPageRoute(builder: (c) => const ProntuariosScreen()))),
                _buildNavLink(FontAwesomeIcons.chartBar, 'Relatórios', onTap: () => Navigator.push(context, MaterialPageRoute(builder: (c) => const RelatoriosScreen()))),
                _buildNavLink(FontAwesomeIcons.rightFromBracket, 'Sair', onTap: () async {
                  try {
                    await _authRepo.signOut();
                    if (mounted) Navigator.pushAndRemoveUntil(context, MaterialPageRoute(builder: (c) => const LoginSignupScreen()), (r) => false);
                  } catch (e) {
                    if (mounted) _showSnackBar('Erro ao sair: ${e.toString()}', isError: true);
                  }
                }),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFormGroup({required String label, required Widget child}) {
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Text(label, style: GoogleFonts.poppins(fontWeight: FontWeight.w600, color: AppColors.textGray)),
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
      contentPadding: const EdgeInsets.symmetric(vertical: 12, horizontal: 15),
      prefixIcon: icon != null ? Icon(icon, size: 20, color: AppColors.textGray) : null,
      prefixIconConstraints: icon != null ? const BoxConstraints(minWidth: 40) : null,
    );
  }

  Widget _buildFiltersSection() {
    return Padding(
      padding: const EdgeInsets.only(bottom: 20.0),
      child: Wrap(
        spacing: 20,
        runSpacing: 20,
        crossAxisAlignment: WrapCrossAlignment.end,
        children: [
          SizedBox(width: 250, child: _buildFormGroup(label: 'Buscar por nome', child: TextFormField(controller: _searchController, decoration: _inputDecoration(hintText: 'Digite para buscar...', icon: FontAwesomeIcons.magnifyingGlass)))),
          SizedBox(
            width: 200,
            child: _buildFormGroup(
              label: 'Ordenar por',
              child: DropdownButtonFormField<String>(
                value: _sortValue,
                decoration: _inputDecoration(hintText: 'Selecione', icon: FontAwesomeIcons.sort),
                items: const [
                  DropdownMenuItem(value: 'nome-asc', child: Text('Nome (A-Z)')),
                  DropdownMenuItem(value: 'nome-desc', child: Text('Nome (Z-A)')),
                  DropdownMenuItem(value: 'preco-asc', child: Text('Menor Preço')),
                  DropdownMenuItem(value: 'preco-desc', child: Text('Maior Preço')),
                ],
                onChanged: (value) {
                  setState(() {
                    _sortValue = value ?? 'nome-asc';
                    _filterAndSortProdutos();
                  });
                },
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildNavLink(IconData icon, String text, {bool isActive = false, VoidCallback? onTap}) {
    return InkWell(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 15),
        margin: const EdgeInsets.only(bottom: 20),
        decoration: BoxDecoration(color: isActive ? AppColors.bgBlack50 : Colors.transparent, borderRadius: BorderRadius.circular(8)),
        child: Row(children: [
          Icon(icon, color: isActive ? AppColors.skinColor : AppColors.textBlack900, size: 20),
          const SizedBox(width: 15),
          Text(text, style: GoogleFonts.poppins(fontSize: 16, fontWeight: FontWeight.w600, color: isActive ? AppColors.skinColor : AppColors.textBlack900)),
        ]),
      ),
    );
  }
}