import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

// repositórios necessários
import 'package:clinica_veterinaria/repositories/agendamentos_repository.dart';
import 'package:clinica_veterinaria/repositories/clients_repository.dart';
import 'package:clinica_veterinaria/repositories/animals_repository.dart';
import 'package:clinica_veterinaria/repositories/users_repository.dart';
import 'package:clinica_veterinaria/repositories/auth_repository.dart';

// telas para navegação
import 'package:clinica_veterinaria/screens/login_signup_screen.dart';
import 'package:clinica_veterinaria/screens/home_screen.dart';
import 'package:clinica_veterinaria/screens/cadastros_screen.dart';
import 'package:clinica_veterinaria/screens/estoque_farmacia_screen.dart';
import 'package:clinica_veterinaria/screens/loja_screen.dart';
import 'package:clinica_veterinaria/screens/relatorios_screen.dart';
import 'package:clinica_veterinaria/screens/prontuarios_screen.dart';

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

class AgendamentosScreen extends StatefulWidget {
  const AgendamentosScreen({super.key});

  @override
  State<AgendamentosScreen> createState() => _AgendamentosScreenState();
}

class _AgendamentosScreenState extends State<AgendamentosScreen> {
  late final AgendamentosRepository _agendamentosRepo;
  late final ClientsRepository _clientsRepo;
  late final AnimalsRepository _animalsRepo;
  late final UsersRepository _usersRepo;
  late final AuthRepository _authRepo;


  String? _selectedClienteId;
  List<Map<String, dynamic>> _clientList = [];
  String? _selectedAnimalId;
  List<Map<String, dynamic>> _animalList = [];
  final TextEditingController _agendamentoIdController = TextEditingController();
  final TextEditingController _dataHoraInicioController = TextEditingController();
  final TextEditingController _dataHoraFimController = TextEditingController();
  String? _selectedVeterinarioId;
  List<Map<String, dynamic>> _veterinarioList = [];
  String? _selectedTipoAgendamento = 'Consulta';
  String? _selectedStatusAgendamento = 'Agendado';
  final TextEditingController _observacoesController = TextEditingController();
  List<Map<String, dynamic>> _agendamentosList = [];
  bool _isLoadingAgendamentos = false;
  final _formKey = GlobalKey<FormState>();

  @override
  void initState() {
    super.initState();
    final supabaseClient = Supabase.instance.client;
      // Inicia os repositórios
    _agendamentosRepo = AgendamentosRepository(supabaseClient);
    _clientsRepo = ClientsRepository(supabaseClient);
    _animalsRepo = AnimalsRepository(supabaseClient);
    _usersRepo = UsersRepository(supabaseClient);
    _authRepo = AuthRepository(supabaseClient);

    _fetchClientes();
    _fetchVeterinarios();
  }

  @override
  void dispose() {
    _agendamentoIdController.dispose();
    _dataHoraInicioController.dispose();
    _dataHoraFimController.dispose();
    _observacoesController.dispose();
    super.dispose();
  }

  void _showSnackBar(String message, {bool isError = false}) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: isError ? AppColors.errorColor : AppColors.successColor,
      ),
    );
  }

  String _formatDateTimeDisplay(String? isoString) {
    if (isoString == null || isoString.isEmpty) return 'N/A';
    try {
      return DateFormat('dd/MM/yyyy HH:mm').format(DateTime.parse(isoString));
    } catch (e) {
      return isoString;
    }
  }
  
  Future<void> _fetchClientes() async {
    try {
      final data = await _clientsRepo.getClients();
      if (!mounted) return;
      setState(() => _clientList = data);
    } catch (e) {
      _showSnackBar('Erro ao carregar clientes: ${e.toString()}', isError: true);
    }
  }

  Future<void> _fetchAnimais(String? clienteId) async {
    if (clienteId == null || clienteId.isEmpty) return;
    try {
      final data = await _animalsRepo.getAnimalsByClientId(int.parse(clienteId));
      if (!mounted) return;
      setState(() {
        _animalList = data;
        _selectedAnimalId = null;
        _agendamentosList = [];
      });
    } catch (e) {
      _showSnackBar('Erro ao carregar animais: ${e.toString()}', isError: true);
    }
  }

  Future<void> _fetchVeterinarios() async {
    try {
      final data = await _usersRepo.getVeterinarios();
      if (!mounted) return;
      setState(() => _veterinarioList = data);
    } catch (e) {
      _showSnackBar('Erro ao carregar veterinários: ${e.toString()}', isError: true);
    }
  }

  Future<void> _fetchAgendamentos(String? animalId) async {
    if (animalId == null || animalId.isEmpty) {
      setState(() => _agendamentosList = []);
      return;
    }
    setState(() => _isLoadingAgendamentos = true);
    try {
      final data = await _agendamentosRepo.getAgendamentosByAnimalId(int.parse(animalId));
      if (!mounted) return;
      setState(() => _agendamentosList = data);
    } catch (e) {
      _showSnackBar('Erro ao carregar agendamentos: ${e.toString()}', isError: true);
    } finally {
      if (mounted) setState(() => _isLoadingAgendamentos = false);
    }
  }


  void _resetAgendamentoForm() {
    _agendamentoIdController.clear();
    _dataHoraInicioController.text = DateFormat('dd/MM/yyyy HH:mm').format(DateTime.now());
    _dataHoraFimController.text = DateFormat('dd/MM/yyyy HH:mm').format(DateTime.now().add(const Duration(hours: 1)));
    _observacoesController.clear();
    setState(() {
      _selectedVeterinarioId = _veterinarioList.isNotEmpty ? _veterinarioList.first['id_usuario']?.toString() : null;
      _selectedTipoAgendamento = 'Consulta';
      _selectedStatusAgendamento = 'Agendado';
    });
  }

  Future<void> _openFormModal({int? idAgendamento}) async {
    _resetAgendamentoForm(); 
    
    if (idAgendamento != null) {
      _agendamentoIdController.text = idAgendamento.toString();
      try {
        final agendamentoData = await _agendamentosRepo.getAgendamentoById(idAgendamento);
        if (agendamentoData != null && mounted) {
          setState(() {
            _dataHoraInicioController.text = _formatDateTimeDisplay(agendamentoData['data_hora_inicio']);
            _dataHoraFimController.text = _formatDateTimeDisplay(agendamentoData['data_hora_fim']);
            _selectedVeterinarioId = agendamentoData['id_veterinario']?.toString();
            _selectedTipoAgendamento = agendamentoData['tipo_agendamento'];
            _selectedStatusAgendamento = agendamentoData['status_agendamento'];
            _observacoesController.text = agendamentoData['observacoes'] ?? '';
          });
        } else {
          _showSnackBar('Agendamento não encontrado.', isError: true);
          return;
        }
      } catch (e) {
        _showSnackBar('Erro ao carregar dados: ${e.toString()}', isError: true);
        return;
      }
    }

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(idAgendamento != null ? 'Editar Agendamento' : 'Adicionar Agendamento'),
        content: SizedBox(
          width: MediaQuery.of(context).size.width * 0.8,
          child: SingleChildScrollView(child: _buildAgendamentoForm()),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancelar')),
          ElevatedButton(
            onPressed: () => _handleFormSubmit(),
            child: const Text('Salvar'),
          ),
        ],
      ),
    );
  }

  Future<void> _handleFormSubmit() async {
    if (!_formKey.currentState!.validate()) return;
    
    final int? idCliente = int.tryParse(_selectedClienteId ?? '');
    final int? idAnimal = int.tryParse(_selectedAnimalId ?? '');
    if (idCliente == null || idAnimal == null) {
      _showSnackBar('Cliente e Animal são obrigatórios.', isError: true);
      return;
    }

    try {
      final dataHoraInicio = DateFormat('dd/MM/yyyy HH:mm').parseStrict(_dataHoraInicioController.text);
      final dataHoraFim = DateFormat('dd/MM/yyyy HH:mm').parseStrict(_dataHoraFimController.text);
      
      final record = {
        'id_cliente': idCliente,
        'id_animal': idAnimal,
        'id_veterinario': _selectedVeterinarioId,
        'tipo_agendamento': _selectedTipoAgendamento,
        'status_agendamento': _selectedStatusAgendamento,
        'data_hora_inicio': dataHoraInicio.toIso8601String(),
        'data_hora_fim': dataHoraFim.toIso8601String(),
        'observacoes': _observacoesController.text.trim(),
      };

      final idAgendamento = int.tryParse(_agendamentoIdController.text);

      if (idAgendamento != null) {
        await _agendamentosRepo.updateAgendamento(idAgendamento, record);
        _showSnackBar('Agendamento atualizado com sucesso!');
      } else {
        await _agendamentosRepo.createAgendamento(record);
        _showSnackBar('Agendamento criado com sucesso!');
      }

      if (!mounted) return;
      Navigator.pop(context);
      _fetchAgendamentos(_selectedAnimalId);
    } catch (e) {
      _showSnackBar('Erro ao salvar agendamento: ${e.toString()}', isError: true);
    }
  }

  Future<void> _handleDeleteAgendamento(int idAgendamento) async {
    final bool confirmar = await showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Confirmar Exclusão'),
        content: const Text('Deseja realmente excluir este agendamento?'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('Cancelar')),
          TextButton(onPressed: () => Navigator.pop(context, true), child: const Text('Excluir')),
        ],
      ),
    ) ?? false;

    if (!confirmar) return;

    try {
      await _agendamentosRepo.deleteAgendamento(idAgendamento);
      _showSnackBar('Agendamento excluído com sucesso!');
      _fetchAgendamentos(_selectedAnimalId);
    } catch (e) {
      _showSnackBar('Erro ao excluir: ${e.toString()}', isError: true);
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
                    child: Row(
                      children: [
                        const Icon(FontAwesomeIcons.calendarCheck, size: 24),
                        const SizedBox(width: 10),
                        Text('Agendamentos',
                            style: GoogleFonts.poppins(fontSize: 37, fontWeight: FontWeight.bold, color: AppColors.textBlack900)),
                      ],
                    ),
                  ),
                  const SizedBox(height: 40),
                  
                  Container(
                      padding: const EdgeInsets.all(25),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(12),
                        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 12, offset: const Offset(0, 4))],
                      ),
                      margin: const EdgeInsets.only(bottom: 30),
                      child: Form(
                        key: _formKey,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Filtrar e Adicionar Agendamentos',
                              style: GoogleFonts.poppins(fontSize: 22, fontWeight: FontWeight.bold, color: AppColors.textBlack900),
                            ),
                            const Divider(color: AppColors.bgBlack50, thickness: 2, height: 30),
                            _buildAgendamentoForm(),
                             const SizedBox(height: 20),
                             Align(
                               alignment: Alignment.bottomRight,
                               child: ElevatedButton.icon(
                                 onPressed: () => _openFormModal(),
                                 icon: const Icon(FontAwesomeIcons.plus, size: 16),
                                 label: const Text('Novo Agendamento'),
                                 style: ElevatedButton.styleFrom(
                                   backgroundColor: AppColors.textBlack900,
                                   foregroundColor: Colors.white,
                                   padding: const EdgeInsets.symmetric(horizontal: 25, vertical: 12),
                                 ),
                               ),
                             )
                          ],
                        )
                      )
                    ),

                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(25),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Agendamentos Encontrados',
                            style: GoogleFonts.poppins(fontSize: 22, fontWeight: FontWeight.bold, color: AppColors.textBlack900)),
                        const Divider(height: 30),
                        _isLoadingAgendamentos
                            ? const Center(child: CircularProgressIndicator())
                            : _agendamentosList.isEmpty
                                ? Center(
                                    child: Padding(
                                    padding: const EdgeInsets.all(40.0),
                                    child: Text(
                                      _selectedAnimalId == null ? 'Selecione um cliente e animal para ver os agendamentos.' : 'Nenhum agendamento encontrado.',
                                      style: const TextStyle(fontSize: 16)),
                                  ))
                                : SingleChildScrollView(
                                    scrollDirection: Axis.horizontal,
                                    child: DataTable(
                                      columns: const [
                                        DataColumn(label: Text('Data/Hora')),
                                        DataColumn(label: Text('Animal')),
                                        DataColumn(label: Text('Tipo')),
                                        DataColumn(label: Text('Veterinário')),
                                        DataColumn(label: Text('Status')),
                                        DataColumn(label: Text('Ações')),
                                      ],
                                      rows: _agendamentosList.map((agendamento) {
                                        return DataRow(cells: [
                                          DataCell(Text(_formatDateTimeDisplay(agendamento['data_hora_inicio']))),
                                          DataCell(Text(agendamento['animais']?['nome'] ?? 'N/A')),
                                          DataCell(Text(agendamento['tipo_agendamento'] ?? '')),
                                          DataCell(Text(agendamento['usuarios']?['nome'] ?? 'N/A')),
                                          DataCell(Text(agendamento['status_agendamento'] ?? '')),
                                          DataCell(Row(
                                            children: [
                                              IconButton(
                                                icon: const Icon(FontAwesomeIcons.pencil, size: 16, color: AppColors.editColor),
                                                onPressed: () => _openFormModal(idAgendamento: agendamento['id_agendamento']),
                                              ),
                                              IconButton(
                                                icon: const Icon(FontAwesomeIcons.trash, size: 16, color: AppColors.deleteColor),
                                                onPressed: () => _handleDeleteAgendamento(agendamento['id_agendamento']),
                                              ),
                                            ],
                                          )),
                                        ]);
                                      }).toList(),
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
      decoration: const BoxDecoration(
        color: AppColors.bgBlack100,
        border: Border(right: BorderSide(color: AppColors.bgBlack50, width: 1)),
      ),
      padding: const EdgeInsets.all(30),
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.only(bottom: 30),
            child: Text('Bem-estar Animal',
                style: GoogleFonts.clickerScript(fontSize: 30, color: AppColors.textBlack900, fontWeight: FontWeight.bold)),
          ),
          Expanded(
            child: ListView(
              padding: EdgeInsets.zero,
              children: [
                 _buildNavLink(FontAwesomeIcons.house, 'Página Inicial', onTap: () => Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => const HomeScreen()))),
                 _buildNavLink(FontAwesomeIcons.calendarCheck, 'Agendamentos', isActive: true),
                 _buildNavLink(FontAwesomeIcons.user, 'Cadastros', onTap: () => Navigator.push(context, MaterialPageRoute(builder: (context) => const CadastrosScreen()))),
                 _buildNavLink(FontAwesomeIcons.boxesStacked, 'Estoque', onTap: () => Navigator.push(context, MaterialPageRoute(builder: (context) => const EstoqueFarmaciaScreen()))),
                 // LINK ADICIONADO AQUI
                 _buildNavLink(FontAwesomeIcons.store, 'Loja', onTap: () => Navigator.push(context, MaterialPageRoute(builder: (context) => const LojaScreen()))),
                 _buildNavLink(FontAwesomeIcons.stethoscope, 'Prontuários', onTap: () => Navigator.push(context, MaterialPageRoute(builder: (context) => const ProntuariosScreen()))),
                 _buildNavLink(FontAwesomeIcons.chartBar, 'Relatórios', onTap: () => Navigator.push(context, MaterialPageRoute(builder: (context) => const RelatoriosScreen()))),
                 _buildNavLink(FontAwesomeIcons.rightFromBracket, 'Sair', onTap: () async {
                   try {
                     await _authRepo.signOut();
                     if (!mounted) return;
                     Navigator.pushAndRemoveUntil(
                         context,
                         MaterialPageRoute(builder: (context) => const LoginSignupScreen()),
                         (Route<dynamic> route) => false);
                   } catch (e) {
                     _showSnackBar('Erro ao sair: ${e.toString()}', isError: true);
                   }
                 }),
              ],
            ),
          ),
        ],
      ),
    );
  }
  
  Widget _buildAgendamentoForm() {
    return Wrap(
      spacing: 20,
      runSpacing: 20,
      children: [
        _buildFormGroup(
          label: 'Cliente',
          child: DropdownButtonFormField<String>(
            value: _selectedClienteId,
            items: _clientList.map((c) => DropdownMenuItem(value: c['id_cliente'].toString(), child: Text(c['nome']))).toList(),
            onChanged: (value) {
              setState(() {
                _selectedClienteId = value;
              });
              _fetchAnimais(value);
            },
            decoration: _inputDecoration(hintText: 'Selecione um cliente'),
            validator: (v) => v == null ? 'Campo obrigatório' : null,
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
              });
              _fetchAgendamentos(value);
            },
            decoration: _inputDecoration(hintText: 'Selecione um animal'),
            validator: (v) => v == null ? 'Campo obrigatório' : null,
          ),
        ),
        _buildFormGroup(
          label: 'Veterinário',
          child: DropdownButtonFormField<String>(
            value: _selectedVeterinarioId,
            items: _veterinarioList.map((v) => DropdownMenuItem(value: v['id_usuario'].toString(), child: Text(v['nome']))).toList(),
            onChanged: (value) => setState(() => _selectedVeterinarioId = value),
            decoration: _inputDecoration(hintText: 'Selecione um veterinário'),
            validator: (v) => v == null ? 'Campo obrigatório' : null,
          ),
        ),
        _buildFormGroup(
          label: 'Tipo de Agendamento',
          child: DropdownButtonFormField<String>(
            value: _selectedTipoAgendamento,
            items: ['Consulta', 'Vacinação', 'Banho e Tosa', 'Cirurgia', 'Retorno', 'Exame'].map((t) => DropdownMenuItem(value: t, child: Text(t))).toList(),
            onChanged: (value) => setState(() => _selectedTipoAgendamento = value),
            decoration: _inputDecoration(hintText: 'Tipo'),
            validator: (v) => v == null ? 'Campo obrigatório' : null,
          ),
        ),
        _buildFormGroup(
          label: 'Status',
          child: DropdownButtonFormField<String>(
            value: _selectedStatusAgendamento,
            items: ['Agendado', 'Confirmado', 'Cancelado', 'Realizado', 'Não Compareceu'].map((s) => DropdownMenuItem(value: s, child: Text(s))).toList(),
            onChanged: (value) => setState(() => _selectedStatusAgendamento = value),
            decoration: _inputDecoration(hintText: 'Status'),
            validator: (v) => v == null ? 'Campo obrigatório' : null,
          ),
        ),
         _buildFormGroup(
          label: 'Data e Hora de Início',
          child: TextFormField(
            controller: _dataHoraInicioController,
            readOnly: true,
            decoration: _inputDecoration(hintText: 'DD/MM/AAAA HH:mm'),
            onTap: () => _pickDateTime(_dataHoraInicioController),
            validator: (v) => v == null || v.isEmpty ? 'Campo obrigatório' : null,
          ),
        ),
         _buildFormGroup(
          label: 'Data e Hora de Fim',
          child: TextFormField(
            controller: _dataHoraFimController,
            readOnly: true,
            decoration: _inputDecoration(hintText: 'DD/MM/AAAA HH:mm'),
            onTap: () => _pickDateTime(_dataHoraFimController),
            validator: (v) => v == null || v.isEmpty ? 'Campo obrigatório' : null,
          ),
        ),
        _buildFormGroup(
          label: 'Observações',
          child: TextFormField(
            controller: _observacoesController,
            maxLines: 3,
            decoration: _inputDecoration(hintText: 'Observações...'),
          ),
        ),
      ].map((child) => SizedBox(width: 250, child: child)).toList(),
    );
  }

  Future<void> _pickDateTime(TextEditingController controller) async {
    DateTime? pickedDate = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime(2101),
    );
    if (pickedDate != null && mounted) {
      TimeOfDay? pickedTime = await showTimePicker(
        context: context,
        initialTime: TimeOfDay.fromDateTime(DateTime.now()),
      );
      if (pickedTime != null) {
        final DateTime finalDateTime = DateTime(pickedDate.year, pickedDate.month, pickedDate.day, pickedTime.hour, pickedTime.minute);
        setState(() {
          controller.text = DateFormat('dd/MM/yyyy HH:mm').format(finalDateTime);
        });
      }
    }
  }

  Widget _buildFormGroup({required String label, required Widget child}) {
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Text(label, style: GoogleFonts.poppins(fontWeight: FontWeight.w600, color: AppColors.textGray)),
      const SizedBox(height: 8),
      child,
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

  Widget _buildNavLink(IconData icon, String text, {bool isActive = false, VoidCallback? onTap}) {
    return InkWell(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 15),
        margin: const EdgeInsets.only(bottom: 20),
        decoration: BoxDecoration(
          color: isActive ? AppColors.bgBlack50 : Colors.transparent,
          borderRadius: BorderRadius.circular(8),
        ),
        child: Row(children: [
          Icon(icon, color: isActive ? AppColors.skinColor : AppColors.textBlack900, size: 20),
          const SizedBox(width: 15),
          Text(text, style: GoogleFonts.poppins(fontSize: 16, fontWeight: FontWeight.w600, color: isActive ? AppColors.skinColor : AppColors.textBlack900)),
        ]),
      ),
    );
  }
}