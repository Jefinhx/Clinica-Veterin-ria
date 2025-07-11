import 'package:clinica_veterinaria/repositories/animals_repository.dart';
import 'package:clinica_veterinaria/repositories/auth_repository.dart';
import 'package:clinica_veterinaria/repositories/clients_repository.dart';
import 'package:clinica_veterinaria/repositories/prontuarios_repository.dart';
import 'package:clinica_veterinaria/repositories/users_repository.dart';
import 'package:clinica_veterinaria/screens/agendamentos_screen.dart';
import 'package:clinica_veterinaria/screens/cadastros_screen.dart';
import 'package:clinica_veterinaria/screens/estoque_farmacia_screen.dart';
import 'package:clinica_veterinaria/screens/home_screen.dart';
import 'package:clinica_veterinaria/screens/login_signup_screen.dart';
// 1. Import da nova tela da Loja
import 'package:clinica_veterinaria/screens/loja_screen.dart';
import 'package:clinica_veterinaria/screens/relatorios_screen.dart';
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
  static const Color borderColor = Color(0xFFDCDCDC);
  static const Color successColor = Color(0xFF28A745);
  static const Color errorColor = Color(0xFFDC3545);
  static const Color viewColor = Color(0xFF17A2B8);
  static const Color editColor = Color(0xFF007BFF);
  static const Color deleteColor = Color(0xFFDC3545);
}

class ProntuariosScreen extends StatefulWidget {
  const ProntuariosScreen({super.key});

  @override
  State<ProntuariosScreen> createState() => _ProntuariosScreenState();
}

class _ProntuariosScreenState extends State<ProntuariosScreen> {
  late final ProntuariosRepository _prontuariosRepo;
  late final ClientsRepository _clientsRepo;
  late final AnimalsRepository _animalsRepo;
  late final UsersRepository _usersRepo;
  late final AuthRepository _authRepo;

  String? _selectedClienteId;
  List<Map<String, dynamic>> _clientList = [];
  String? _selectedAnimalId;
  List<Map<String, dynamic>> _animalList = [];
  List<Map<String, dynamic>> _prontuariosList = [];
  String _animalNomeTitulo = '';
  bool _isLoadingReport = false;

  final _formKey = GlobalKey<FormState>();
  final _prontuarioIdController = TextEditingController();
  final _dataAtendimentoController = TextEditingController();
  String? _selectedVeterinarioId;
  List<Map<String, dynamic>> _veterinarioList = [];
  final _tipoAtendimentoController = TextEditingController();
  final _anamneseController = TextEditingController();
  final _diagnosticoController = TextEditingController();
  final _procedimentosController = TextEditingController();
  final _observacoesController = TextEditingController();

  @override
  void initState() {
    super.initState();
    final supabaseClient = Supabase.instance.client;
    _prontuariosRepo = ProntuariosRepository(supabaseClient);
    _clientsRepo = ClientsRepository(supabaseClient);
    _animalsRepo = AnimalsRepository(supabaseClient);
    _usersRepo = UsersRepository(supabaseClient);
    _authRepo = AuthRepository(supabaseClient);

    _fetchClientes();
    _fetchVeterinarios();
  }

  @override
  void dispose() {
    _prontuarioIdController.dispose();
    _dataAtendimentoController.dispose();
    _tipoAtendimentoController.dispose();
    _anamneseController.dispose();
    _diagnosticoController.dispose();
    _procedimentosController.dispose();
    _observacoesController.dispose();
    super.dispose();
  }

  Future<void> _fetchClientes() async {
    try {
      final data = await _clientsRepo.getClients();
      if (mounted) setState(() => _clientList = data);
    } catch (e) {
      _showSnackBar('Erro ao carregar clientes: ${e.toString()}', isError: true);
    }
  }

  Future<void> _fetchAnimais(String? clienteId) async {
    if (clienteId == null) return;
    try {
      final data = await _animalsRepo.getAnimalsByClientId(int.parse(clienteId));
      if (mounted) {
        setState(() {
          _animalList = data;
          _selectedAnimalId = null;
          _prontuariosList = [];
          _animalNomeTitulo = '';
        });
      }
    } catch (e) {
      _showSnackBar('Erro ao carregar animais: ${e.toString()}', isError: true);
    }
  }

  Future<void> _fetchVeterinarios() async {
    try {
      final data = await _usersRepo.getVeterinarios();
      if (mounted) setState(() => _veterinarioList = data);
    } catch (e) {
      _showSnackBar('Erro ao carregar veterinários: ${e.toString()}', isError: true);
    }
  }

  Future<void> _fetchProntuarios(String? animalId) async {
    if (animalId == null) {
      setState(() => _prontuariosList = []);
      return;
    }
    setState(() => _isLoadingReport = true);
    try {
      final data = await _prontuariosRepo.getProntuariosByAnimalId(int.parse(animalId));
      if (mounted) setState(() => _prontuariosList = data);
    } catch (e) {
      _showSnackBar('Erro ao carregar prontuários: ${e.toString()}', isError: true);
    } finally {
      if (mounted) setState(() => _isLoadingReport = false);
    }
  }

  Future<void> _handleFormSubmit() async {
    if (!_formKey.currentState!.validate()) return;

    DateTime? dataAtendimentoParsed;
    try {
      dataAtendimentoParsed = DateFormat('dd/MM/yyyy HH:mm').parseStrict(_dataAtendimentoController.text);
    } catch (e) {
      _showSnackBar('Formato de data inválido. Use DD/MM/AAAA HH:mm.', isError: true);
      return;
    }

    final record = {
      'id_animal': int.parse(_selectedAnimalId!),
      'id_veterinario': _selectedVeterinarioId,
      'data_atendimento': dataAtendimentoParsed.toIso8601String(),
      'tipo_atendimento': _tipoAtendimentoController.text.trim(),
      'anamnese': _anamneseController.text.trim(),
      'diagnostico': _diagnosticoController.text.trim(),
      'procedimentos_realizados': _procedimentosController.text.trim(),
      'observacoes': _observacoesController.text.trim(),
    };

    try {
      final idProntuario = int.tryParse(_prontuarioIdController.text);
      if (idProntuario != null) {
        await _prontuariosRepo.updateProntuario(idProntuario, record);
        _showSnackBar('Prontuário atualizado com sucesso!');
      } else {
        await _prontuariosRepo.createProntuario(record);
        _showSnackBar('Prontuário criado com sucesso!');
      }
      if (mounted) {
        Navigator.pop(context); // Fecha o modal
        _fetchProntuarios(_selectedAnimalId);
      }
    } catch (e) {
      _showSnackBar('Erro ao salvar prontuário: ${e.toString()}', isError: true);
    }
  }

  Future<void> _handleDelete(int idProntuario) async {
    final bool confirmar = await showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Confirmar Exclusão'),
        content: const Text('Deseja realmente excluir este registro?'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('Cancelar')),
          TextButton(onPressed: () => Navigator.pop(context, true), child: const Text('Excluir')),
        ],
      ),
    ) ?? false;

    if (!confirmar) return;

    try {
      await _prontuariosRepo.deleteProntuario(idProntuario);
      _showSnackBar('Prontuário excluído com sucesso!');
      _fetchProntuarios(_selectedAnimalId);
    } catch (e) {
      _showSnackBar('Erro ao excluir prontuário: ${e.toString()}', isError: true);
    }
  }

  void _resetFormProntuario() {
    _formKey.currentState?.reset();
    _prontuarioIdController.clear();
    _dataAtendimentoController.text = DateFormat('dd/MM/yyyy HH:mm').format(DateTime.now());
    _tipoAtendimentoController.clear();
    _anamneseController.clear();
    _diagnosticoController.clear();
    _procedimentosController.clear();
    _observacoesController.clear();
    setState(() {
      _selectedVeterinarioId = _veterinarioList.isNotEmpty ? _veterinarioList.first['id_usuario'] : null;
    });
  }

  Future<void> _openFormModal({int? idProntuario}) async {
    _resetFormProntuario();

    if (idProntuario != null) {
      final prontuarioData = await _prontuariosRepo.getProntuarioById(idProntuario);
      if (prontuarioData != null && mounted) {
        setState(() {
          _prontuarioIdController.text = prontuarioData['id_prontuario'].toString();
          _dataAtendimentoController.text = _formatDateTime(prontuarioData['data_atendimento']);
          _selectedVeterinarioId = prontuarioData['id_veterinario'];
          _tipoAtendimentoController.text = prontuarioData['tipo_atendimento'] ?? '';
          _anamneseController.text = prontuarioData['anamnese'] ?? '';
          _diagnosticoController.text = prontuarioData['diagnostico'] ?? '';
          _procedimentosController.text = prontuarioData['procedimentos_realizados'] ?? '';
          _observacoesController.text = prontuarioData['observacoes'] ?? '';
        });
      }
    }

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(idProntuario != null ? 'Editar Prontuário' : 'Adicionar Prontuário'),
        content: SizedBox(
          width: MediaQuery.of(context).size.width * 0.8,
          child: SingleChildScrollView(child: _buildProntuarioForm()),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancelar')),
          ElevatedButton(onPressed: _handleFormSubmit, child: const Text('Salvar')),
        ],
      ),
    );
  }

  Future<void> _openViewModal(int idProntuario) async {
    final prontuarioData = await _prontuariosRepo.getProntuarioById(idProntuario);
    if (prontuarioData != null && mounted) {
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text('Detalhes do Prontuário'),
          content: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildDetailRow('Data:', _formatDateTime(prontuarioData['data_atendimento'])),
                _buildDetailRow('Veterinário:', 'Dr(a). ${prontuarioData['usuarios']?['nome'] ?? 'N/A'}'),
                _buildDetailRow('Tipo de Atendimento:', prontuarioData['tipo_atendimento'] ?? 'Não informado'),
                const Divider(),
                _buildDetailRow('Anamnese:', prontuarioData['anamnese'] ?? 'Não informado'),
                _buildDetailRow('Diagnóstico:', prontuarioData['diagnostico'] ?? 'Não informado'),
                _buildDetailRow('Procedimentos:', prontuarioData['procedimentos_realizados'] ?? 'Não informado'),
                _buildDetailRow('Observações:', prontuarioData['observacoes'] ?? 'Não informado'),
              ],
            ),
          ),
          actions: [TextButton(onPressed: () => Navigator.pop(context), child: const Text('Fechar'))],
        ),
      );
    }
  }
  
  void _showSnackBar(String message, {bool isError = false}) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Text(message),
      backgroundColor: isError ? AppColors.errorColor : AppColors.successColor,
    ));
  }
  
  String _formatDateTime(String? dateTimeString) {
    if (dateTimeString == null) return 'N/A';
    return DateFormat('dd/MM/yyyy HH:mm').format(DateTime.parse(dateTimeString));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bgBlack900,
      body: Row(
        children: [
          _buildSidebar(context),
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(30),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Prontuários', style: GoogleFonts.poppins(fontSize: 37, fontWeight: FontWeight.bold, color: AppColors.textBlack900)),
                  const SizedBox(height: 40),
                  _buildFilterSection(),
                  const SizedBox(height: 30),
                  _buildReportSection(),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFilterSection() {
    return Container(
      padding: const EdgeInsets.all(25),
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(12)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Buscar Prontuário', style: GoogleFonts.poppins(fontSize: 22, fontWeight: FontWeight.bold, color: AppColors.textBlack900)),
          const Divider(height: 30),
          Wrap(
            spacing: 20,
            runSpacing: 20,
            children: [
              _buildFormGroup(
                label: 'Cliente',
                child: DropdownButtonFormField<String>(
                  value: _selectedClienteId,
                  items: _clientList.map((c) => DropdownMenuItem(value: c['id_cliente'].toString(), child: Text(c['nome']))).toList(),
                  onChanged: (value) {
                    setState(() => _selectedClienteId = value);
                    _fetchAnimais(value);
                  },
                  decoration: _inputDecoration(hintText: 'Selecione um cliente'),
                ),
              ),
              _buildFormGroup(
                label: 'Animal',
                child: DropdownButtonFormField<String>(
                  value: _selectedAnimalId,
                  items: _animalList.map((a) => DropdownMenuItem(value: a['id_animal'].toString(), child: Text(a['nome']))).toList(),
                  onChanged: (value) {
                    setState(() {
                      _selectedAnimalId = value;
                      _animalNomeTitulo = _animalList.firstWhere((a) => a['id_animal'].toString() == value)['nome'];
                    });
                    _fetchProntuarios(value);
                  },
                  decoration: _inputDecoration(hintText: 'Selecione um animal'),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildReportSection() {
    return Container(
      padding: const EdgeInsets.all(25),
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(12)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Flexible(child: Text('Registros de $_animalNomeTitulo', style: GoogleFonts.poppins(fontSize: 22, fontWeight: FontWeight.bold, color: AppColors.textBlack900))),
              ElevatedButton.icon(
                onPressed: _selectedAnimalId != null ? () => _openFormModal() : null,
                icon: const Icon(FontAwesomeIcons.plus, size: 16),
                label: const Text('Adicionar Registro'),
              ),
            ],
          ),
          const Divider(height: 30),
          _isLoadingReport
              ? const Center(child: CircularProgressIndicator())
              : _prontuariosList.isEmpty
                  ? Center(child: Padding(padding: const EdgeInsets.all(40), child: Text(_selectedAnimalId == null ? 'Selecione um animal.' : 'Nenhum prontuário encontrado.')))
                  : ListView.builder(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      itemCount: _prontuariosList.length,
                      itemBuilder: (context, index) {
                        final prontuario = _prontuariosList[index];
                        final vetNome = prontuario['usuarios']?['nome'] ?? 'N/A';
                        return Card(
                          margin: const EdgeInsets.only(bottom: 15),
                          child: ListTile(
                            title: Text(prontuario['tipo_atendimento'] ?? 'Atendimento', style: const TextStyle(fontWeight: FontWeight.bold)),
                            subtitle: Text('${_formatDateTime(prontuario['data_atendimento'])} - Dr(a). $vetNome'),
                            trailing: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                IconButton(icon: const Icon(FontAwesomeIcons.eye, size: 16, color: AppColors.viewColor), onPressed: () => _openViewModal(prontuario['id_prontuario'])),
                                IconButton(icon: const Icon(FontAwesomeIcons.pencil, size: 16, color: AppColors.editColor), onPressed: () => _openFormModal(idProntuario: prontuario['id_prontuario'])),
                                IconButton(icon: const Icon(FontAwesomeIcons.trash, size: 16, color: AppColors.deleteColor), onPressed: () => _handleDelete(prontuario['id_prontuario'])),
                              ],
                            ),
                          ),
                        );
                      },
                    ),
        ],
      ),
    );
  }

  Widget _buildProntuarioForm() {
    return Form(
      key: _formKey,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          _buildFormGroup(
            label: 'Data do Atendimento',
            child: TextFormField(
              controller: _dataAtendimentoController,
              readOnly: true,
              decoration: _inputDecoration(hintText: 'DD/MM/AAAA HH:mm'),
              onTap: () async {
                DateTime? pickedDate = await showDatePicker(context: context, initialDate: DateTime.now(), firstDate: DateTime(2000), lastDate: DateTime(2101));
                if (pickedDate != null && mounted) {
                  TimeOfDay? pickedTime = await showTimePicker(context: context, initialTime: TimeOfDay.now());
                  if (pickedTime != null) {
                    final dt = DateTime(pickedDate.year, pickedDate.month, pickedDate.day, pickedTime.hour, pickedTime.minute);
                    _dataAtendimentoController.text = DateFormat('dd/MM/yyyy HH:mm').format(dt);
                  }
                }
              },
              validator: (v) => v == null || v.isEmpty ? 'Campo obrigatório' : null,
            ),
          ),
          const SizedBox(height: 20),
          _buildFormGroup(
            label: 'Veterinário Responsável',
            child: DropdownButtonFormField<String>(
              value: _selectedVeterinarioId,
              items: _veterinarioList.map((v) {
                return DropdownMenuItem<String>(
                  value: v['id_usuario'].toString(),
                  child: Text(v['nome'] ?? 'Nome indisponível'),
                );
              }).toList(),
              onChanged: (value) => setState(() => _selectedVeterinarioId = value),
              decoration: _inputDecoration(hintText: 'Selecione um veterinário'),
              validator: (v) => v == null ? 'Campo obrigatório' : null,
            ),
          ),
          const SizedBox(height: 20),
          _buildFormGroup(label: 'Tipo de Atendimento', child: TextFormField(controller: _tipoAtendimentoController, decoration: _inputDecoration(hintText: 'Ex: Consulta de rotina'))),
          const SizedBox(height: 20),
          _buildFormGroup(label: 'Anamnese', child: TextFormField(controller: _anamneseController, maxLines: 4, decoration: _inputDecoration(hintText: 'Histórico e queixas...'))),
          const SizedBox(height: 20),
          _buildFormGroup(label: 'Diagnóstico', child: TextFormField(controller: _diagnosticoController, maxLines: 4, decoration: _inputDecoration(hintText: 'Diagnóstico clínico...'))),
          const SizedBox(height: 20),
          _buildFormGroup(label: 'Procedimentos Realizados', child: TextFormField(controller: _procedimentosController, maxLines: 4, decoration: _inputDecoration(hintText: 'Medicações, exames...'))),
          const SizedBox(height: 20),
          _buildFormGroup(label: 'Observações', child: TextFormField(controller: _observacoesController, maxLines: 3, decoration: _inputDecoration(hintText: 'Outras observações...'))),
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
          Padding(padding: const EdgeInsets.only(bottom: 30), child: Text('Bem-estar Animal', style: GoogleFonts.clickerScript(fontSize: 30, fontWeight: FontWeight.bold, color: AppColors.textBlack900))),
          Expanded(
            child: ListView(
              padding: EdgeInsets.zero,
              children: [
                _buildNavLink(FontAwesomeIcons.house, 'Página Inicial', onTap: () => Navigator.pushReplacement(context, MaterialPageRoute(builder: (c) => const HomeScreen()))),
                _buildNavLink(FontAwesomeIcons.calendarCheck, 'Agendamentos', onTap: () => Navigator.push(context, MaterialPageRoute(builder: (c) => const AgendamentosScreen()))),
                _buildNavLink(FontAwesomeIcons.user, 'Cadastros', onTap: () => Navigator.push(context, MaterialPageRoute(builder: (c) => const CadastrosScreen()))),
                _buildNavLink(FontAwesomeIcons.boxesStacked, 'Estoque', onTap: () => Navigator.push(context, MaterialPageRoute(builder: (c) => const EstoqueFarmaciaScreen()))),
                // 2. Link para a Loja adicionado aqui
                _buildNavLink(FontAwesomeIcons.store, 'Loja', onTap: () => Navigator.push(context, MaterialPageRoute(builder: (c) => const LojaScreen()))),
                _buildNavLink(FontAwesomeIcons.stethoscope, 'Prontuários', isActive: true),
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
      SizedBox(width: 250, child: child),
    ]);
  }

  InputDecoration _inputDecoration({required String hintText}) {
    return InputDecoration(
      hintText: hintText,
      fillColor: Colors.white,
      filled: true,
      border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
      contentPadding: const EdgeInsets.symmetric(vertical: 12, horizontal: 15),
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Text(label, style: GoogleFonts.poppins(fontWeight: FontWeight.bold, fontSize: 16)),
        Text(value, style: GoogleFonts.poppins(fontSize: 14)),
      ]),
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
          Text(text, style: GoogleFonts.poppins(fontWeight: FontWeight.w600, color: isActive ? AppColors.skinColor : AppColors.textBlack900)),
        ]),
      ),
    );
  }
}