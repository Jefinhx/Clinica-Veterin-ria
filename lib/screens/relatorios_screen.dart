import 'package:clinica_veterinaria/repositories/auth_repository.dart';
import 'package:clinica_veterinaria/repositories/relatorios_repository.dart';
import 'package:clinica_veterinaria/screens/agendamentos_screen.dart';
import 'package:clinica_veterinaria/screens/cadastros_screen.dart';
import 'package:clinica_veterinaria/screens/estoque_farmacia_screen.dart';
import 'package:clinica_veterinaria/screens/home_screen.dart';
import 'package:clinica_veterinaria/screens/login_signup_screen.dart';
// 1. Import da nova tela da Loja
import 'package:clinica_veterinaria/screens/loja_screen.dart';
import 'package:clinica_veterinaria/screens/prontuarios_screen.dart';
import 'package:flutter/material.dart';
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
}

class RelatoriosScreen extends StatefulWidget {
  const RelatoriosScreen({super.key});

  @override
  State<RelatoriosScreen> createState() => _RelatoriosScreenState();
}

class _RelatoriosScreenState extends State<RelatoriosScreen> {
  late final RelatoriosRepository _relatoriosRepo;
  late final AuthRepository _authRepo;

  bool _isLoadingReport = false;
  String _reportTitle = 'Selecione um relatório para começar.';
  dynamic _reportData;
  List<DataColumn> _reportColumns = [];

  @override
  void initState() {
    super.initState();
    final supabaseClient = Supabase.instance.client;
    _relatoriosRepo = RelatoriosRepository(supabaseClient);
    _authRepo = AuthRepository(supabaseClient);
  }

  void _showSnackBar(String message, {bool isError = false}) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), backgroundColor: isError ? Colors.red : Colors.green),
    );
  }

  String _formatCurrency(double? value) {
    if (value == null) return 'R\$ 0,00';
    return NumberFormat.currency(locale: 'pt_BR', symbol: 'R\$').format(value);
  }

  Future<void> _generateReport(String reportType) async {
    setState(() {
      _isLoadingReport = true;
      _reportTitle = 'Carregando relatório...';
      _reportData = null;
      _reportColumns = [];
    });

    try {
      List<Map<String, dynamic>> data;
      String title;
      List<DataColumn> columns;

      switch (reportType) {
        case 'lucros':
          title = 'Relatório de Lucros por Veterinário';
          columns = [
            const DataColumn(label: Text('Usuário')),
            const DataColumn(label: Text('Qtd. Pagamentos'), numeric: true),
            const DataColumn(label: Text('Valor Total'), numeric: true),
          ];
          data = await _relatoriosRepo.getRelatorioLucros();
          break;
        case 'atendimentos':
          title = 'Relatório de Atendimentos';
          columns = [
            const DataColumn(label: Text('Veterinário')),
            const DataColumn(label: Text('Qtd. Atendimentos'), numeric: true),
            const DataColumn(label: Text('Vacinas Aplicadas'), numeric: true),
          ];
          data = await _relatoriosRepo.getRelatorioAtendimentos();
          break;
        case 'clientes':
          title = 'Relatório de Gastos por Cliente';
          columns = [
            const DataColumn(label: Text('Cliente')),
            const DataColumn(label: Text('Qtd. Animais'), numeric: true),
            const DataColumn(label: Text('Total Gasto (R\$)'), numeric: true),
          ];
          data = await _relatoriosRepo.getRelatorioGastosCliente();
          break;
        default:
          throw Exception('Tipo de relatório não reconhecido.');
      }
      
      if (!mounted) return;
      setState(() {
        _reportTitle = title;
        _reportColumns = columns;
        if (data.isEmpty) {
          _reportData = 'Nenhum dado encontrado para este relatório.';
        } else {
          _reportData = data;
        }
      });

    } catch (e) {
      final errorMessage = 'Erro ao gerar relatório: ${e.toString()}';
      if (!mounted) return;
      _showSnackBar(errorMessage, isError: true);
      setState(() {
        _reportTitle = 'Ocorreu um Erro';
        _reportData = errorMessage;
      });
    } finally {
      if (!mounted) return;
      setState(() => _isLoadingReport = false);
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
                      const Icon(FontAwesomeIcons.chartBar, size: 24),
                      const SizedBox(width: 10),
                      Text('Relatórios', style: GoogleFonts.poppins(fontSize: 37, fontWeight: FontWeight.bold, color: AppColors.textBlack900)),
                    ]),
                  ),
                  const SizedBox(height: 20),
                  Text('Visualize dados e estatísticas da clínica através dos relatórios gerados abaixo.', style: GoogleFonts.poppins(fontSize: 16, color: AppColors.textBlack900.withOpacity(0.8))),
                  const SizedBox(height: 40),
                  Wrap(
                    spacing: 20,
                    runSpacing: 20,
                    children: [
                      _buildReportButton(context, 'Lucros por Veterinário', () => _generateReport('lucros')),
                      _buildReportButton(context, 'Atendimentos por Veterinário', () => _generateReport('atendimentos')),
                      _buildReportButton(context, 'Gastos por Cliente', () => _generateReport('clientes')),
                    ],
                  ),
                  const SizedBox(height: 40),
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(10)),
                    constraints: const BoxConstraints(minHeight: 300),
                    child: _buildReportContent(),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildReportContent() {
    if (_isLoadingReport) {
      return const Center(child: CircularProgressIndicator(color: AppColors.textBlack900));
    }
    if (_reportData is String) {
      return Center(child: Text(_reportData as String, style: GoogleFonts.poppins(fontSize: 16, color: AppColors.textGray)));
    }
    if (_reportData is List && (_reportData as List).isNotEmpty) {
      final dataList = _reportData as List<Map<String, dynamic>>;
      final keys = dataList.first.keys.toList();
      return SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.only(bottom: 16.0),
              child: Text(_reportTitle, style: GoogleFonts.poppins(fontSize: 18, fontWeight: FontWeight.bold, color: AppColors.textBlack900)),
            ),
            DataTable(
              columns: _reportColumns,
              rows: dataList.map((rowData) {
                return DataRow(
                  cells: keys.map((key) {
                    dynamic cellValue = rowData[key];
                    String cellText;
                    if (key.toLowerCase().contains('valor') || key.toLowerCase().contains('total')) {
                      cellText = _formatCurrency(double.tryParse(cellValue.toString()));
                    } else {
                      cellText = cellValue?.toString() ?? 'N/A';
                    }
                    return DataCell(Text(cellText));
                  }).toList(),
                );
              }).toList(),
            ),
          ],
        ),
      );
    }
    return Center(child: Text(_reportTitle, style: GoogleFonts.poppins(fontSize: 16, color: AppColors.textGray)));
  }

  Widget _buildReportButton(BuildContext context, String text, VoidCallback onPressed) {
    return ElevatedButton(
      onPressed: onPressed,
      style: ElevatedButton.styleFrom(
        backgroundColor: AppColors.textBlack900,
        foregroundColor: Colors.white,
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 15),
      ),
      child: Text(text, style: GoogleFonts.poppins(fontWeight: FontWeight.bold)),
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
                _buildNavLink('Página Inicial', FontAwesomeIcons.house, false, () => Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => const HomeScreen()))),
                _buildNavLink('Agendamentos', FontAwesomeIcons.calendarCheck, false, () => Navigator.push(context, MaterialPageRoute(builder: (_) => const AgendamentosScreen()))),
                _buildNavLink('Cadastros', FontAwesomeIcons.user, false, () => Navigator.push(context, MaterialPageRoute(builder: (_) => const CadastrosScreen()))),
                _buildNavLink('Estoque', FontAwesomeIcons.boxesStacked, false, () => Navigator.push(context, MaterialPageRoute(builder: (_) => const EstoqueFarmaciaScreen()))),
                // 2. Link para a Loja adicionado aqui
                _buildNavLink('Loja', FontAwesomeIcons.store, false, () => Navigator.push(context, MaterialPageRoute(builder: (_) => const LojaScreen()))),
                _buildNavLink('Prontuários', FontAwesomeIcons.stethoscope, false, () => Navigator.push(context, MaterialPageRoute(builder: (_) => const ProntuariosScreen()))),
                _buildNavLink('Relatórios', FontAwesomeIcons.chartBar, true),
                _buildNavLink('Sair', FontAwesomeIcons.rightFromBracket, false, () async {
                  try {
                    await _authRepo.signOut();
                    if (mounted) Navigator.pushAndRemoveUntil(context, MaterialPageRoute(builder: (_) => const LoginSignupScreen()), (route) => false);
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

  Widget _buildNavLink(String text, IconData icon, bool isActive, [VoidCallback? onTap]) {
    return InkWell(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 15),
        margin: const EdgeInsets.only(bottom: 20),
        decoration: BoxDecoration(color: isActive ? AppColors.bgBlack50 : Colors.transparent, borderRadius: BorderRadius.circular(8)),
        child: Row(children: [
          Icon(icon, size: 20, color: isActive ? AppColors.skinColor : AppColors.textBlack900),
          const SizedBox(width: 15),
          Text(text, style: GoogleFonts.poppins(fontSize: 16, fontWeight: FontWeight.w600, color: isActive ? AppColors.skinColor : AppColors.textBlack900)),
        ]),
      ),
    );
  }
}