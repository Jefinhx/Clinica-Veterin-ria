import 'package:clinica_veterinaria/screens/agendamentos_screen.dart';
import 'package:clinica_veterinaria/screens/estoque_farmacia_screen.dart';
import 'package:clinica_veterinaria/screens/prontuarios_screen.dart';
import 'package:clinica_veterinaria/screens/relatorios_screen.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:intl/intl.dart';


import 'package:clinica_veterinaria/screens/login_signup_screen.dart';
// 1. Import da tela da Loja que estava faltando
import 'package:clinica_veterinaria/screens/loja_screen.dart';


class AppColors {
  static const Color bgBlack900 = Color(0xFFF2F2FC);
  static const Color bgBlack100 = Color(0xFFFDF9FF);
  static const Color bgBlack50 = Color(0xFFE8DFEC);
  static const Color textBlack900 = Color(0xFF009D66);
  static const Color skinColor = Color(0xFF000000);
  static const Color editColor = Color(0xFF007BFF);
  static const Color deleteColor = Color(0xFFDC3545);
}

class CadastrosScreen extends StatefulWidget {
  const CadastrosScreen({super.key});

  @override
  State<CadastrosScreen> createState() => _CadastrosScreenState();
}

class _CadastrosScreenState extends State<CadastrosScreen> {
  final supabase = Supabase.instance.client;


  final TextEditingController _userNomeController = TextEditingController();
  final TextEditingController _userEmailController = TextEditingController();
  final TextEditingController _userSenhaController = TextEditingController();
  final TextEditingController _userEmailBuscaController = TextEditingController();

  String? _selectedUserPerfil;

  // Cliente
  final TextEditingController _clientNomeController = TextEditingController();
  final TextEditingController _clientCpfController = TextEditingController();
  final TextEditingController _clientTelefoneController = TextEditingController();
  final TextEditingController _clientEmailController = TextEditingController();
  final TextEditingController _clientEnderecoController = TextEditingController();
  final TextEditingController _clientCpfBuscaController = TextEditingController();

  // Animal
  final TextEditingController _animalNomeController = TextEditingController();
  final TextEditingController _animalEspecieController = TextEditingController();
  final TextEditingController _animalRacaController = TextEditingController();
  final TextEditingController _animalNascimentoController = TextEditingController();
  final TextEditingController _animalSexoController = TextEditingController();
  final TextEditingController _animalPesoController = TextEditingController();
  final TextEditingController _animalObservacoesController = TextEditingController();
  final TextEditingController _animalBuscaController = TextEditingController();

  // --- Gerenciamento de Estado para UI e Ações ---
  bool _isUserEmailBuscaDisabled = true;
  bool _isClientCpfBuscaDisabled = true;
  bool _isAnimalBuscaDisabled = true;
  bool _isClientCpfEditable = true;

  String? _selectedAnimalTutorId;
  List<Map<String, dynamic>> _clientRawList = [];

  String? _editingUserId;
  int? _editingClientId;
  int? _editingAnimalId;


  @override
  void initState() {
    super.initState();
    _carregarClientesNoSelect();
  }

  @override
  void dispose() {
    _userNomeController.dispose();
    _userEmailController.dispose();
    _userSenhaController.dispose();
    _userEmailBuscaController.dispose();
    _clientNomeController.dispose();
    _clientCpfController.dispose();
    _clientTelefoneController.dispose();
    _clientEmailController.dispose();
    _clientEnderecoController.dispose();
    _clientCpfBuscaController.dispose();
    _animalNomeController.dispose();
    _animalEspecieController.dispose();
    _animalRacaController.dispose();
    _animalNascimentoController.dispose();
    _animalSexoController.dispose();
    _animalPesoController.dispose();
    _animalObservacoesController.dispose();
    _animalBuscaController.dispose();
    super.dispose();
  }

  // --- Funções Auxiliares Comuns ---

  void _showSnackBar(String message, {bool isError = false}) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: isError ? Colors.red : Colors.green,
        duration: const Duration(seconds: 2),
      ),
    );
  }

  // --- CRUD USUÁRIO ---

  void _prepararAcaoUsuario(String acao) {
    _limparCamposUsuario();
    setState(() {
      _isUserEmailBuscaDisabled = false;
    });
    if (_userEmailBuscaController.text.trim().isNotEmpty) {
      _buscarUsuarioPorEmail();
    } else {
      _showSnackBar('Informe o e-mail no campo de busca e pressione Enter ou clique em Editar/Excluir novamente.',);
    }
  }

  Future<void> _buscarUsuarioPorEmail() async {
    final emailBusca = _userEmailBuscaController.text.trim();
    if (emailBusca.isEmpty) {
      _showSnackBar('Informe o email para buscar.', isError: true);
      return;
    }

    try {
      final Map<String, dynamic>? usuarioData = await supabase
          .from('usuarios')
          .select()
          .eq('email', emailBusca)
          .maybeSingle();

      if (!mounted) return;

      if (usuarioData != null) {
        setState(() {
          _userNomeController.text = usuarioData['nome']?.toString() ?? '';
          _userEmailController.text = usuarioData['email']?.toString() ?? '';
          _userSenhaController.text = ''; 
          _selectedUserPerfil = usuarioData['perfil']?.toString();
          _editingUserId = usuarioData['id_usuario']?.toString();
        });
        _showSnackBar('Usuário carregado. Edite os dados e clique em "Salvar".');
      } else {
        _showSnackBar('Usuário não encontrado.', isError: true);
        _limparCamposUsuario();
      }
    } on PostgrestException catch (e) {
      if (!mounted) return;
      _showSnackBar('Erro Supabase ao buscar usuário: ${e.message}', isError: true);
      print('Erro Supabase ao buscar usuário: $e');
    } catch (e) {
      if (!mounted) return;
      _showSnackBar('Erro ao buscar usuário: ${e.toString()}', isError: true);
      print('Erro ao buscar usuário: $e');
    } finally {
      if (!mounted) return;
      setState(() {
        _isUserEmailBuscaDisabled = true;
      });
    }
  }

  Future<void> _excluirUsuario() async {
    final emailBusca = _userEmailBuscaController.text.trim();
    if (emailBusca.isEmpty) {
      _showSnackBar('Informe o email do usuário para excluir.', isError: true);
      return;
    }

    final bool confirmar = await showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Confirmar Exclusão'),
        content: Text('Deseja realmente excluir o usuário com e-mail "$emailBusca"?'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('Cancelar')),
          TextButton(onPressed: () => Navigator.pop(context, true), child: const Text('Excluir')),
        ],
      ),
    ) ?? false;

    if (!confirmar) {
      _limparCamposUsuario();
      return;
    }

    try {
      await supabase
          .from('usuarios')
          .delete()
          .eq('email', emailBusca);

      if (!mounted) return;
      _showSnackBar('Usuário excluído com sucesso!');
      _limparCamposUsuario();
    } on PostgrestException catch (e) {
      if (!mounted) return;
      _showSnackBar('Erro Supabase ao excluir usuário: ${e.message}', isError: true);
      print('Erro Supabase ao excluir usuário: $e');
    } catch (e) {
      if (!mounted) return;
      _showSnackBar('Erro ao excluir usuário: ${e.toString()}', isError: true);
      print('Erro ao excluir usuário: $e');
    } finally {
      if (!mounted) return;
      setState(() {
        _isUserEmailBuscaDisabled = true;
      });
    }
  }

  Future<void> _salvarUsuario() async {
    final nome = _userNomeController.text.trim();
    final email = _userEmailController.text.trim();
    final senha = _userSenhaController.text;
    final String? perfil = _selectedUserPerfil; 

    if (nome.isEmpty || email.isEmpty || (perfil == null || perfil.isEmpty)) {
      _showSnackBar('Nome, Email e Perfil são campos obrigatórios.', isError: true);
      return;
    }

    if (_editingUserId == null && senha.isEmpty) {
        _showSnackBar('A senha é obrigatória para um novo cadastro.', isError: true);
        return;
    }

    try {
      if (_editingUserId != null) {
        final Map<String, dynamic> updateData = {
          'nome': nome,
          'email': email,
          'perfil': perfil,
          'data_atualizacao': DateTime.now().toIso8601String(),
        };
        
        if (senha.isNotEmpty) {
          try {
             await supabase.auth.updateUser(UserAttributes(
               email: email,
               password: senha,
             ));
            _showSnackBar('Senha do usuário atualizada na autenticação!', isError: false);
          } on AuthException catch (e) {
            _showSnackBar('Erro ao atualizar senha no Auth: ${e.message}', isError: true);
            print('Erro ao atualizar senha no Auth: ${e.message}');
          }
        }

        await supabase
            .from('usuarios')
            .update(updateData)
            .eq('id_usuario', _editingUserId!);

        if (!mounted) return;
        _showSnackBar('Usuário atualizado com sucesso!');
      } else {
        final AuthResponse authRes = await supabase.auth.signUp(
          email: email,
          password: senha,
          data: {'nome': nome, 'perfil': perfil},
        );

        if (!mounted) return;

        if (authRes.user != null) {
          await supabase.from('usuarios').insert({
            'id_usuario': authRes.user!.id,
            'nome': nome,
            'email': email,
            'perfil': perfil,
            'senha_hash': 'managed_by_supabase_auth',
            'ativo': true,
            'data_cadastro': DateTime.now().toIso8601String(),
          });
          _showSnackBar('Usuário cadastrado com sucesso!');
        } else {
          if (!mounted) return;
          final String authErrorMsg = authRes.session?.user?.lastSignInAt != null
              ? 'Usuário criado, mas sessão não iniciada. Verifique seu e-mail para confirmar.'
              : authRes.session?.user?.email != null
                  ? 'Erro de autenticação para ${authRes.session?.user?.email}'
                  : 'Erro de autenticação desconhecido.';
          _showSnackBar('Erro no cadastro (Auth): $authErrorMsg', isError: true);
          return;
        }
      }
      _limparCamposUsuario();
    } on PostgrestException catch (e) {
      if (!mounted) return;
      _showSnackBar('Erro Supabase ao salvar usuário: ${e.message}', isError: true);
      print('Erro Supabase ao salvar usuário: $e');
    } on AuthException catch (e) {
      if (!mounted) return;
      _showSnackBar('Erro Supabase Auth ao salvar usuário: ${e.message}', isError: true);
      print('Erro Supabase Auth ao salvar usuário: $e');
    } catch (e) {
      if (!mounted) return;
      _showSnackBar('Erro ao salvar usuário: ${e.toString()}', isError: true);
      print('Erro ao salvar usuário: $e');
    }
  }

  void _limparCamposUsuario() {
    _userNomeController.clear();
    _userEmailController.clear();
    _userSenhaController.clear();
    _userEmailBuscaController.clear();
    setState(() {
      _selectedUserPerfil = null;
      _isUserEmailBuscaDisabled = true;
      _editingUserId = null;
    });
  }


  // --- CRUD CLIENTE ---

  void _prepararAcaoCliente(String acao) {
    _limparCamposCliente();
    setState(() {
      _isClientCpfBuscaDisabled = false;
      _isClientCpfEditable = true;
    });
    if (_clientCpfBuscaController.text.trim().isNotEmpty) {
      _buscarClientePorCPF();
    } else {
      _showSnackBar('Informe o CPF no campo de busca e pressione Enter ou clique em Editar/Excluir novamente.');
    }
  }

  Future<void> _buscarClientePorCPF() async {
    final cpfBusca = _clientCpfBuscaController.text.trim();
    if (cpfBusca.isEmpty) {
      _showSnackBar('Informe o CPF para buscar.', isError: true);
      return;
    }

    try {
      final Map<String, dynamic>? clienteData = await supabase
          .from('clientes')
          .select()
          .eq('cpf', cpfBusca)
          .maybeSingle();

      if (!mounted) return;

      if (clienteData != null) {
        setState(() {
          _clientNomeController.text = clienteData['nome']?.toString() ?? '';
          _clientCpfController.text = clienteData['cpf']?.toString() ?? '';
          _clientTelefoneController.text = clienteData['telefone']?.toString() ?? '';
          _clientEmailController.text = clienteData['email']?.toString() ?? '';
          _clientEnderecoController.text = clienteData['endereco']?.toString() ?? '';
          _isClientCpfEditable = false;
          _editingClientId = clienteData['id_cliente'] as int?;
        });
        _showSnackBar('Cliente carregado. Edite os dados e clique em "Salvar".');
      } else {
        _showSnackBar('Cliente não encontrado.', isError: true);
        _limparCamposCliente();
      }
    } on PostgrestException catch (e) {
      if (!mounted) return;
      _showSnackBar('Erro Supabase ao buscar cliente: ${e.message}', isError: true);
      print('Erro Supabase ao buscar cliente: $e');
    } catch (e) {
      if (!mounted) return;
      _showSnackBar('Erro ao buscar cliente: ${e.toString()}', isError: true);
      print('Erro ao buscar cliente: $e');
    } finally {
      if (!mounted) return;
      setState(() {
        _isClientCpfBuscaDisabled = true;
      });
    }
  }

  Future<void> _excluirCliente() async {
    final cpfBusca = _clientCpfBuscaController.text.trim();
    if (cpfBusca.isEmpty) {
      _showSnackBar('Informe o CPF do cliente para excluir.', isError: true);
      return;
    }

    final bool confirmar = await showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Confirmar Exclusão'),
        content: Text('Deseja realmente excluir o cliente com CPF "$cpfBusca"?'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('Cancelar')),
          TextButton(onPressed: () => Navigator.pop(context, true), child: const Text('Excluir')),
        ],
      ),
    ) ?? false;

    if (!confirmar) return;

    try {
      await supabase
          .from('clientes')
          .delete()
          .eq('cpf', cpfBusca);

      if (!mounted) return;
      _showSnackBar('Cliente excluído com sucesso!');
      _limparCamposCliente();
      _carregarClientesNoSelect();
    } on PostgrestException catch (e) {
      if (!mounted) return;
      _showSnackBar('Erro Supabase ao excluir cliente: ${e.message}', isError: true);
      print('Erro Supabase ao excluir cliente: $e');
    } catch (e) {
      if (!mounted) return;
      _showSnackBar('Erro ao excluir cliente: ${e.toString()}', isError: true);
      print('Erro ao excluir cliente: $e');
    } finally {
      if (!mounted) return;
      setState(() {
        _isClientCpfBuscaDisabled = true;
      });
    }
  }

  Future<void> _salvarCliente() async {
    final nome = _clientNomeController.text.trim();
    final cpf = _clientCpfController.text.trim();
    final telefone = _clientTelefoneController.text.trim();
    final email = _clientEmailController.text.trim();
    final endereco = _clientEnderecoController.text.trim();

    if (nome.isEmpty || cpf.isEmpty) {
      _showSnackBar('Nome e CPF são campos obrigatórios.', isError: true);
      return;
    }

    final isEdicao = _editingClientId != null;

    try {
      final Map<String, dynamic> dataToSave = {
        'nome': nome,
        'cpf': cpf,
        'telefone': telefone.isNotEmpty ? telefone : null,
        'email': email.isNotEmpty ? email : null,
        'endereco': endereco.isNotEmpty ? endereco : null,
        'ativo': true,
      };

      if (isEdicao) {
        await supabase
            .from('clientes')
            .update(dataToSave)
            .eq('id_cliente', _editingClientId!);

        _showSnackBar('Cliente atualizado com sucesso!');
      } else {
        final List<Map<String, dynamic>>? responseData = await supabase
            .from('clientes')
            .select('cpf')
            .eq('cpf', cpf)
            .limit(1);

        if (responseData != null && responseData.isNotEmpty) {
          if (!mounted) return;
          _showSnackBar('Erro: CPF já cadastrado.', isError: true);
          return;
        }

        await supabase
            .from('clientes')
            .insert(dataToSave);
        _showSnackBar('Cliente cadastrado com sucesso!');
      }
      if (!mounted) return;
      _limparCamposCliente();
      _carregarClientesNoSelect();
    } on PostgrestException catch (e) {
      if (!mounted) return;
      _showSnackBar('Erro Supabase ao salvar cliente: ${e.message}', isError: true);
      print('Erro Supabase ao salvar cliente: $e');
    } catch (e) {
      if (!mounted) return;
      _showSnackBar('Erro ao salvar cliente: ${e.toString()}', isError: true);
      print('Erro ao salvar cliente: $e');
    }
  }

  void _limparCamposCliente() {
    _clientNomeController.clear();
    _clientCpfController.clear();
    _clientTelefoneController.clear();
    _clientEmailController.clear();
    _clientEnderecoController.clear();
    _clientCpfBuscaController.clear();
    setState(() {
      _isClientCpfBuscaDisabled = true;
      _isClientCpfEditable = true;
      _editingClientId = null;
    });
  }


  // --- CRUD ANIMAL ---

  Future<void> _carregarClientesNoSelect() async {
    try {
      final List<Map<String, dynamic>>? responseData = await supabase
          .from('clientes')
          .select('id_cliente, nome')
          .eq('ativo', true)
          .order('nome', ascending: true);

      if (!mounted) return;

      if (responseData != null) {
        final List<Map<String, dynamic>> clientesRaw = responseData.cast<Map<String, dynamic>>();

        setState(() {
          _clientRawList = clientesRaw;
          _selectedAnimalTutorId = null;
        });
      } else {
        setState(() {
          _clientRawList = [];
          _selectedAnimalTutorId = null;
        });
      }
    } on PostgrestException catch (e) {
      if (!mounted) return;
      _showSnackBar('Erro Supabase ao carregar clientes: ${e.message}', isError: true);
    } catch (e) {
      if (!mounted) return;
      _showSnackBar('Erro ao carregar clientes: ${e.toString()}', isError: true);
    }
  }

  void _prepararAcaoAnimal(String acao) {
    _limparCamposAnimal();
    setState(() {
      _isAnimalBuscaDisabled = false;
    });
    if (_animalBuscaController.text.trim().isNotEmpty) {
      _buscarAnimal();
    } else {
      _showSnackBar('Informe o ID do Animal no campo de busca e pressione Enter ou clique em Editar/Excluir novamente.');
    }
  }

  Future<void> _buscarAnimal() async {
    final idAnimalBusca = int.tryParse(_animalBuscaController.text.trim());
    if (idAnimalBusca == null) {
      _showSnackBar('Informe um ID de Animal válido para buscar.', isError: true);
      return;
    }

    try {
      final Map<String, dynamic>? animalData = await supabase
          .from('animais')
          .select()
          .eq('id_animal', idAnimalBusca)
          .maybeSingle();

      if (!mounted) return;

      if (animalData != null) {
        setState(() {
          _selectedAnimalTutorId = animalData['id_cliente']?.toString();
          _animalNomeController.text = animalData['nome']?.toString() ?? '';
          _animalEspecieController.text = animalData['especie']?.toString() ?? '';
          _animalRacaController.text = animalData['raca']?.toString() ?? '';
          
          final String? dataNascimentoDb = animalData['data_nascimento']?.toString();
          if (dataNascimentoDb != null && dataNascimentoDb.isNotEmpty) {
            try {
              final DateTime date = DateTime.parse(dataNascimentoDb);
              _animalNascimentoController.text = DateFormat('dd/MM/yyyy').format(date);
            } catch (e) {
              _animalNascimentoController.text = dataNascimentoDb;
            }
          } else {
            _animalNascimentoController.text = '';
          }

          _animalSexoController.text = animalData['sexo']?.toString() ?? '';
          _animalPesoController.text = (animalData['peso'] ?? '').toString();
          _animalObservacoesController.text = animalData['observacoes']?.toString() ?? '';
          _editingAnimalId = animalData['id_animal'] as int?;
        });
        _showSnackBar('Animal carregado. Edite os dados e clique em "Salvar".');
      } else {
        _showSnackBar('Animal não encontrado.', isError: true);
        _limparCamposAnimal();
      }
    } on PostgrestException catch (e) {
      if (!mounted) return;
      _showSnackBar('Erro Supabase ao buscar animal: ${e.message}', isError: true);
    } catch (e) {
      if (!mounted) return;
      _showSnackBar('Erro ao buscar animal: ${e.toString()}', isError: true);
    } finally {
      if (!mounted) return;
      setState(() {
        _isAnimalBuscaDisabled = true;
      });
    }
  }

  Future<void> _excluirAnimal() async {
    final idAnimalBusca = int.tryParse(_animalBuscaController.text.trim());
    if (idAnimalBusca == null) {
      _showSnackBar('Informe um ID de Animal válido para excluir.', isError: true);
      return;
    }
    final Map<String, dynamic>? animalData = await supabase
        .from('animais')
        .select('id_animal')
        .eq('id_animal', idAnimalBusca)
        .maybeSingle();

    if (!mounted) return;
    if (animalData == null || animalData['id_animal'] == null) {
      _showSnackBar('Animal não encontrado para exclusão.', isError: true);
      return;
    }
    _editingAnimalId = animalData['id_animal'] as int?;

    final bool confirmar = await showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Confirmar Exclusão'),
        content: Text('Deseja realmente excluir o animal com ID "$idAnimalBusca"?'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('Cancelar')),
          TextButton(onPressed: () => Navigator.pop(context, true), child: const Text('Excluir')),
        ],
      ),
    ) ?? false;

    if (!confirmar) return;

    try {
      await supabase
          .from('animais')
          .delete()
          .eq('id_animal', _editingAnimalId!);

      if (!mounted) return;
      _showSnackBar('Animal excluído com sucesso!');
      _limparCamposAnimal();
      _carregarClientesNoSelect();
    } on PostgrestException catch (e) {
      if (!mounted) return;
      _showSnackBar('Erro Supabase ao excluir animal: ${e.message}', isError: true);
    } catch (e) {
      if (!mounted) return;
      _showSnackBar('Erro ao excluir animal: ${e.toString()}', isError: true);
    } finally {
      if (!mounted) return;
      setState(() {
        _isAnimalBuscaDisabled = true;
        _editingAnimalId = null;
      });
    }
  }

  Future<void> _salvarAnimal() async {
    final int? idCliente = int.tryParse(_selectedAnimalTutorId ?? '');
    final nome = _animalNomeController.text.trim();
    final especie = _animalEspecieController.text.trim();
    final raca = _animalRacaController.text.trim();
    final dataNascimentoStr = _animalNascimentoController.text.trim();
    final sexo = _animalSexoController.text.trim();
    final peso = double.tryParse(_animalPesoController.text.trim());
    final observacoes = _animalObservacoesController.text.trim();

    if (idCliente == null || nome.isEmpty || especie.isEmpty) {
      _showSnackBar('Tutor, Nome e Espécie são obrigatórios.', isError: true);
      return;
    }

    String? dataNascimentoFormattedForDb;
    if (dataNascimentoStr.isNotEmpty) {
      try {
        final DateFormat formatterBr = DateFormat('dd/MM/yyyy');
        final DateTime parsedDate = formatterBr.parseStrict(dataNascimentoStr);
        dataNascimentoFormattedForDb = DateFormat('yyyy-MM-dd').format(parsedDate);
      } catch (e) {
        _showSnackBar('Formato de Data de Nascimento inválido (esperado DD/MM/AAAA).', isError: true);
        return;
      }
    }

    try {
      final Map<String, dynamic> dataToSave = {
        'id_cliente': idCliente,
        'nome': nome,
        'especie': especie,
        'raca': raca.isNotEmpty ? raca : null,
        'data_nascimento': dataNascimentoFormattedForDb,
        'sexo': sexo.isNotEmpty ? sexo : null,
        'peso': peso,
        'observacoes': observacoes.isNotEmpty ? observacoes : null,
      };

      if (_editingAnimalId != null) {
        dataToSave['data_atualizacao'] = DateTime.now().toIso8601String();
        await supabase
            .from('animais')
            .update(dataToSave)
            .eq('id_animal', _editingAnimalId!);
        _showSnackBar('Animal atualizado com sucesso!');
      } else {
        await supabase
            .from('animais')
            .insert(dataToSave);
        _showSnackBar('Animal cadastrado com sucesso!');
      }
      if (!mounted) return;
      _limparCamposAnimal();
      _carregarClientesNoSelect();
    } on PostgrestException catch (e) {
      if (!mounted) return;
      _showSnackBar('Erro Supabase ao salvar animal: ${e.message}', isError: true);
    } catch (e) {
      if (!mounted) return;
      _showSnackBar('Erro ao salvar animal: ${e.toString()}', isError: true);
    }
  }

  void _limparCamposAnimal() {
    _animalNomeController.clear();
    _animalEspecieController.clear();
    _animalRacaController.clear();
    _animalNascimentoController.clear();
    _animalSexoController.clear();
    _animalPesoController.clear();
    _animalObservacoesController.clear();
    _animalBuscaController.clear();
    setState(() {
      _selectedAnimalTutorId = null;
      _isAnimalBuscaDisabled = true;
      _editingAnimalId = null;
    });
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
            child: Container(
              color: AppColors.bgBlack900,
              padding: const EdgeInsets.all(30),
              child: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Padding(
                      padding: const EdgeInsets.only(bottom: 20),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(FontAwesomeIcons.userPlus, color: AppColors.skinColor, size: 24),
                          const SizedBox(width: 10),
                          Flexible(
                            child: Text(
                              'Gerenciamento de Cadastros',
                              style: GoogleFonts.poppins(
                                fontSize: 37,
                                color: AppColors.textBlack900,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 20),
                    Text(
                      'Gerencie usuários, clientes e animais da clínica aqui. Use os formulários abaixo para buscar, editar, excluir e cadastrar novos.',
                      style: GoogleFonts.poppins(
                        fontSize: 16,
                        color: AppColors.textBlack900.withOpacity(0.8),
                      ),
                    ),
                    const SizedBox(height: 40),
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // --- Formulário de Usuário ---
                        Expanded(
                          child: _buildFormBloco(
                            title: 'Usuário',
                            children: [
                              _buildInputField(controller: _userNomeController, hintText: 'Nome', icon: FontAwesomeIcons.user),
                              _buildInputField(controller: _userEmailController, hintText: 'Email', icon: FontAwesomeIcons.envelope, keyboardType: TextInputType.emailAddress),
                              _buildInputField(controller: _userSenhaController, hintText: 'Senha', icon: FontAwesomeIcons.lock, obscureText: true),
                              _buildPerfilDropdownField(),
                              const SizedBox(height: 10),
                              _buildFormActions(
                                onEdit: () => _prepararAcaoUsuario('editar'),
                                onExclude: _excluirUsuario,
                                onSave: _salvarUsuario,
                              ),
                              const Divider(height: 30),
                              _buildInputField(
                                controller: _userEmailBuscaController,
                                hintText: 'Buscar por Email',
                                icon: FontAwesomeIcons.magnifyingGlass,
                                keyboardType: TextInputType.emailAddress,
                                isEnabled: !_isUserEmailBuscaDisabled,
                                onSubmitted: (value) => _buscarUsuarioPorEmail(),
                              ),
                            ],
                          ),
                        ),

                        const SizedBox(width: 30),

                        // --- Formulário de Cliente ---
                        Expanded(
                          child: _buildFormBloco(
                            title: 'Cliente',
                            children: [
                              _buildInputField(controller: _clientNomeController, hintText: 'Nome', icon: FontAwesomeIcons.user),
                              _buildInputField(
                                controller: _clientCpfController,
                                hintText: 'CPF',
                                icon: FontAwesomeIcons.idCard,
                                keyboardType: TextInputType.number,
                                isEnabled: _isClientCpfEditable,
                                onSubmitted: (value) => _buscarClientePorCPF(),
                              ),
                              _buildInputField(controller: _clientTelefoneController, hintText: 'Telefone', icon: FontAwesomeIcons.phone, keyboardType: TextInputType.phone),
                              _buildInputField(controller: _clientEmailController, hintText: 'Email', icon: FontAwesomeIcons.envelope, keyboardType: TextInputType.emailAddress),
                              _buildInputField(controller: _clientEnderecoController, hintText: 'Endereço', icon: FontAwesomeIcons.mapMarkerAlt),
                              const SizedBox(height: 10),
                              _buildFormActions(
                                onEdit: () => _prepararAcaoCliente('editar'),
                                onExclude: _excluirCliente,
                                onSave: _salvarCliente,
                              ),
                              const Divider(height: 30),
                              _buildInputField(
                                controller: _clientCpfBuscaController,
                                hintText: 'Buscar por CPF',
                                icon: FontAwesomeIcons.magnifyingGlass,
                                keyboardType: TextInputType.number,
                                isEnabled: !_isClientCpfBuscaDisabled,
                                onSubmitted: (value) => _buscarClientePorCPF(),
                              ),
                            ],
                          ),
                        ),

                        const SizedBox(width: 30),

                        // --- Formulário de Animal ---
                        Expanded(
                          child: _buildFormBloco(
                            title: 'Animal',
                            children: [
                              DropdownButtonFormField<String>(
                                value: _selectedAnimalTutorId,
                                decoration: _inputDecoration(hintText: 'Tutor (Cliente)', icon: FontAwesomeIcons.userShield),
                                items: _clientRawList.map<DropdownMenuItem<String>>((clienteData) {
                                  return DropdownMenuItem<String>(
                                    value: clienteData['id_cliente']?.toString(),
                                    child: Text(clienteData['nome']?.toString() ?? 'Cliente sem nome', overflow: TextOverflow.ellipsis),
                                  );
                                }).toList(),
                                onChanged: (value) {
                                  setState(() { _selectedAnimalTutorId = value; });
                                },
                                hint: _clientRawList.isEmpty ? const Text('Nenhum cliente') : const Text('Selecione...'),
                              ),
                              _buildInputField(controller: _animalNomeController, hintText: 'Nome', icon: FontAwesomeIcons.paw),
                              Row(
                                children: [
                                  Expanded(child: _buildInputField(controller: _animalEspecieController, hintText: 'Espécie', icon: FontAwesomeIcons.dna)),
                                  const SizedBox(width: 10),
                                  Expanded(child: _buildInputField(controller: _animalRacaController, hintText: 'Raça', icon: FontAwesomeIcons.dog)),
                                ],
                              ),
                              _buildInputField(
                                controller: _animalNascimentoController,
                                hintText: 'Nasc. (DD/MM/AAAA)',
                                icon: FontAwesomeIcons.calendar,
                                keyboardType: TextInputType.datetime,
                              ),
                              Row(
                                children: [
                                  Expanded(
                                    child: DropdownButtonFormField<String>(
                                      value: _animalSexoController.text.isEmpty ? null : _animalSexoController.text,
                                      decoration: _inputDecoration(hintText: 'Sexo', icon: FontAwesomeIcons.venusMars),
                                      items: const [
                                        DropdownMenuItem(value: 'Macho', child: Text('Macho')),
                                        DropdownMenuItem(value: 'Fêmea', child: Text('Fêmea')),
                                      ],
                                      onChanged: (value) { setState(() { _animalSexoController.text = value ?? ''; }); },
                                    ),
                                  ),
                                  const SizedBox(width: 10),
                                  Expanded(child: _buildInputField(controller: _animalPesoController, hintText: 'Peso (kg)', icon: FontAwesomeIcons.weightHanging, keyboardType: const TextInputType.numberWithOptions(decimal: true))),
                                ],
                              ),
                              _buildInputField(controller: _animalObservacoesController, hintText: 'Observações', icon: FontAwesomeIcons.infoCircle, maxLines: 3),
                              const SizedBox(height: 10),
                              _buildFormActions(
                                onEdit: () => _prepararAcaoAnimal('editar'),
                                onExclude: _excluirAnimal,
                                onSave: _salvarAnimal,
                              ),
                              const Divider(height: 30),
                              _buildInputField(
                                controller: _animalBuscaController,
                                hintText: 'Buscar por ID do Animal',
                                icon: FontAwesomeIcons.magnifyingGlass,
                                keyboardType: TextInputType.number,
                                isEnabled: !_isAnimalBuscaDisabled,
                                onSubmitted: (value) => _buscarAnimal(),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
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
        border: Border(
          right: BorderSide(color: AppColors.bgBlack50, width: 1),
        ),
      ),
      padding: const EdgeInsets.all(30),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Padding(
            padding: const EdgeInsets.only(bottom: 30),
            child: Column(
              children: [
                const SizedBox(height: 10),
                Text(
                  'Bem-estar Animal',
                  style: GoogleFonts.clickerScript(
                    fontSize: 30,
                    color: AppColors.textBlack900,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            child: ListView(
              padding: EdgeInsets.zero,
              children: [
                _buildNavLink(FontAwesomeIcons.house, 'Página Inicial', isActive: false, onTap: () {
                  // Usei pushReplacementNamed aqui porque o código original tinha, mantendo o padrão.
                  Navigator.pushReplacementNamed(context, '/home');
                }),
                _buildNavLink(FontAwesomeIcons.calendarCheck, 'Agendamentos', onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => const AgendamentosScreen()),
                  );
                }),
                _buildNavLink(FontAwesomeIcons.user, 'Cadastros', isActive: true, onTap: () { /* Já está nesta tela */ }),
                _buildNavLink(FontAwesomeIcons.boxesStacked, 'Estoque', isActive: false, onTap: () {
                  Navigator.push(context, MaterialPageRoute(builder: (context) => const EstoqueFarmaciaScreen()));
                }),
                // 2. Link da Loja adicionado aqui
                _buildNavLink(FontAwesomeIcons.store, 'Loja', onTap: () {
                  Navigator.push(context, MaterialPageRoute(builder: (context) => const LojaScreen()));
                }),
                _buildNavLink(FontAwesomeIcons.stethoscope, 'Prontuários', onTap: () {
                  Navigator.push(context, MaterialPageRoute(builder: (context) => const ProntuariosScreen()));
                }),
                _buildNavLink(FontAwesomeIcons.chartBar, 'Relatórios', isActive: false, onTap: () {
                  Navigator.push(context, MaterialPageRoute(builder: (context) => const RelatoriosScreen()));
                }),
                _buildNavLink(FontAwesomeIcons.rightFromBracket, 'Sair', onTap: () async {
                  await supabase.auth.signOut();
                  if (!mounted) return;
                  Navigator.pushAndRemoveUntil(
                    context,
                    MaterialPageRoute(builder: (context) => const LoginSignupScreen()),
                    (Route<dynamic> route) => false,
                  );
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Você foi deslogado com sucesso!')),
                  );
                }),
              ],
            ),
          ),
        ],
      ),
    );
  }

  InputDecoration _inputDecoration({required String hintText, IconData? icon}) {
    return InputDecoration(
      hintText: hintText,
      fillColor: const Color(0xFFFFFFFF),
      filled: true,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: const BorderSide(color: Color(0xFFDCDCDC)),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: const BorderSide(color: Color(0xFFDCDCDC)),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: const BorderSide(color: AppColors.textBlack900, width: 2),
      ),
      contentPadding: const EdgeInsets.symmetric(vertical: 13, horizontal: 20),
      prefixIcon: icon != null ? Padding(
        padding: const EdgeInsets.only(left: 15.0, right: 12.0),
        child: Icon(icon, size: 18, color: Colors.black54),
      ) : null,
    );
  }

  Widget _buildPerfilDropdownField() {
    final List<String> cargos = ['Administrador', 'Balconista', 'Veterinário'];
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 8),
      child: DropdownButtonFormField<String>(
        value: _selectedUserPerfil,
        decoration: _inputDecoration(hintText: 'Perfil', icon: FontAwesomeIcons.briefcase),
        items: cargos.map((cargo) => DropdownMenuItem<String>(value: cargo, child: Text(cargo))).toList(),
        onChanged: (value) {
          setState(() { _selectedUserPerfil = value; });
        },
      ),
    );
  }

  Widget _buildInputField({
    required TextEditingController controller,
    required String hintText,
    required IconData icon,
    bool obscureText = false,
    TextInputType keyboardType = TextInputType.text,
    bool isEnabled = true,
    ValueChanged<String>? onSubmitted,
    int? maxLines = 1,
  }) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 8),
      child: TextFormField(
        controller: controller,
        obscureText: obscureText,
        keyboardType: keyboardType,
        decoration: _inputDecoration(hintText: hintText, icon: icon),
        enabled: isEnabled,
        onFieldSubmitted: onSubmitted,
        maxLines: maxLines,
      ),
    );
  }

  Widget _buildFormBloco({required String title, required List<Widget> children}) {
    return Container(
      padding: const EdgeInsets.all(25),
      decoration: BoxDecoration(
        color: AppColors.bgBlack100,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.bgBlack50.withOpacity(0.5)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          )
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: GoogleFonts.poppins(fontSize: 22, fontWeight: FontWeight.bold, color: AppColors.textBlack900),
          ),
          const Divider(height: 25),
          ...children,
        ],
      ),
    );
  }

  Widget _buildFormActions({
    required VoidCallback onEdit,
    required VoidCallback onExclude,
    required VoidCallback onSave,
  }) {
    return Row(
      children: [
        Expanded(
          child: ElevatedButton.icon(
            icon: const Icon(FontAwesomeIcons.pencil, size: 14),
            label: const Text('Editar'),
            onPressed: onEdit,
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.editColor,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(vertical: 15),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
              textStyle: GoogleFonts.poppins(fontWeight: FontWeight.bold),
            ),
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: ElevatedButton.icon(
            icon: const Icon(FontAwesomeIcons.trash, size: 14),
            label: const Text('Excluir'),
            onPressed: onExclude,
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.deleteColor,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(vertical: 15),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
              textStyle: GoogleFonts.poppins(fontWeight: FontWeight.bold),
            ),
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          flex: 2,
          child: ElevatedButton.icon(
            icon: const Icon(FontAwesomeIcons.solidFloppyDisk, size: 14),
            label: const Text('Salvar'),
            onPressed: onSave,
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.textBlack900,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(vertical: 15),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
              textStyle: GoogleFonts.poppins(fontWeight: FontWeight.bold),
            ),
          ),
        ),
      ],
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
        child: Row(
          children: [
            Icon(
              icon,
              color: isActive ? AppColors.skinColor : AppColors.textBlack900,
              size: 20,
            ),
            const SizedBox(width: 15),
            Flexible( // Correção do Overflow
              child: Text(
                text,
                style: GoogleFonts.poppins(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: isActive ? AppColors.skinColor : AppColors.textBlack900,
                ),
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
      ),
    );
  }
}