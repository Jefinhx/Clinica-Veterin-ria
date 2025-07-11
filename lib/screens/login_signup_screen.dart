import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'package:clinica_veterinaria/main.dart';

import 'package:clinica_veterinaria/screens/home_screen.dart';


class LoginSignupScreen extends StatefulWidget {
  const LoginSignupScreen({super.key});

  @override
  State<LoginSignupScreen> createState() => _LoginSignupScreenState();
}

class _LoginSignupScreenState extends State<LoginSignupScreen> {
  final TextEditingController _loginEmailController = TextEditingController();
  final TextEditingController _loginPasswordController = TextEditingController();
  final TextEditingController _registerNameController = TextEditingController();
  final TextEditingController _registerEmailController = TextEditingController();
  final TextEditingController _registerPasswordController = TextEditingController();

  String? _selectedRegisterRole;

  final GlobalKey<FormState> _loginFormKey = GlobalKey<FormState>();
  final GlobalKey<FormState> _registerFormKey = GlobalKey<FormState>();

  bool _isLoginPanel = true;

  Future<void> _login() async {
    if (_loginFormKey.currentState!.validate()) {
      try {
        final String userId = await authRepository.signInWithEmailAndPassword(
          _loginEmailController.text,
          _loginPasswordController.text,
        );

        if (!mounted) return;

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Login efetuado com sucesso! Redirecionando...')),
        );
        Navigator.pushReplacementNamed(context, '/home');
      } on AuthException catch (e) {
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Erro no login: ${e.message}')),
        );
        print('Erro de autenticação no login: ${e.message}');
      } catch (e) {
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Erro inesperado no login: ${e.toString()}')),
        );
        print('Erro inesperado no login: $e');
      }
    }
  }

  Future<void> _register() async {
    if (_registerFormKey.currentState!.validate()) {
      final String name = _registerNameController.text.trim();
      final String? role = _selectedRegisterRole;
      final String email = _registerEmailController.text.trim();
      final String password = _registerPasswordController.text;

      if (role == null || role.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Por favor, selecione um Cargo.')),
        );
        return;
      }

      try {
        final String userId = await authRepository.signUpWithEmailAndPassword(
          name,
          role,
          email,
          password,
        );

        if (!mounted) return;

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Usuário cadastrado com sucesso!')),
        );
        _registerFormKey.currentState!.reset();
        setState(() {
          _isLoginPanel = true;
          _selectedRegisterRole = null;
        });
      } on AuthException catch (e) {
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Erro no cadastro: ${e.message}')),
        );
        print('Erro de autenticação no cadastro: ${e.message}');
      } catch (e) {
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Erro inesperado ao cadastrar: ${e.toString()}')),
        );
        print('Erro inesperado no cadastro: $e');
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final containerWidth = screenWidth > 850 ? 850.0 : screenWidth * 0.95;
    final containerHeight = 550.0;

    return Scaffold(
      backgroundColor: Colors.transparent,
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [Color(0xFFE2E2E2), Color(0xFFC9D6FF)],
          ),
        ),
        child: Center(
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 1800),
            curve: Curves.easeInOutCubic,
            width: containerWidth,
            height: containerHeight,
            margin: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(30),
              boxShadow: const [
                BoxShadow(
                  color: Colors.black26,
                  blurRadius: 30,
                  offset: Offset(0, 0),
                ),
              ],
            ),
            child: Stack(
              children: [
                // Painel de Login
                AnimatedPositioned(
                  duration: const Duration(milliseconds: 600),
                  curve: Curves.easeInOut,
                  right: _isLoginPanel ? 0 : -containerWidth / 2,
                  width: containerWidth / 2,
                  height: containerHeight,
                  child: Container(
                    padding: const EdgeInsets.all(40),
                    alignment: Alignment.center,
                    child: Form(
                      key: _loginFormKey,
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            'Entrar',
                            style: GoogleFonts.poppins(fontSize: 36, fontWeight: FontWeight.bold),
                          ),
                          const SizedBox(height: 30),
                          _buildInputField(
                            controller: _loginEmailController,
                            hintText: 'E-mail',
                            icon: FontAwesomeIcons.user,
                            keyboardType: TextInputType.emailAddress,
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return 'Por favor, insira seu e-mail';
                              }
                              if (!RegExp(r'^[^@]+@[^@]+\.[^@]+').hasMatch(value)) {
                                return 'Por favor, insira um e-mail válido';
                              }
                              return null;
                            },
                          ),
                          _buildInputField(
                            controller: _loginPasswordController,
                            hintText: 'Senha',
                            icon: FontAwesomeIcons.lock,
                            obscureText: true,
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return 'Por favor, insira sua senha';
                              }
                              return null;
                            },
                          ),
                          
                          // BOTÃO "ESQUECEU SUA SENHA" REMOVIDO DESTA ÁREA

                          const SizedBox(height: 30), // Aumentei o espaçamento para compensar o botão removido
                          _buildButton(
                            text: 'Entrar',
                            onPressed: _login,
                            backgroundColor: const Color(0xFF009D66),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),

                // Painel de Cadastro
                AnimatedPositioned(
                  duration: const Duration(milliseconds: 600),
                  curve: Curves.easeInOut,
                  left: _isLoginPanel ? -containerWidth / 2 : 0,
                  width: containerWidth / 2,
                  height: containerHeight,
                  child: Container(
                    padding: const EdgeInsets.all(40),
                    alignment: Alignment.center,
                    child: Form(
                      key: _registerFormKey,
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            'Cadastrar',
                            style: GoogleFonts.poppins(fontSize: 36, fontWeight: FontWeight.bold),
                          ),
                          const SizedBox(height: 30),
                          _buildInputField(
                            controller: _registerNameController,
                            hintText: 'Nome',
                            icon: FontAwesomeIcons.user,
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return 'Por favor, insira seu nome';
                              }
                              return null;
                            },
                          ),
                          _buildRoleDropdownField(),
                          _buildInputField(
                            controller: _registerEmailController,
                            hintText: 'E-mail',
                            icon: FontAwesomeIcons.envelope,
                            keyboardType: TextInputType.emailAddress,
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return 'Por favor, insira seu e-mail';
                              }
                              if (!RegExp(r'^[^@]+@[^@]+\.[^@]+').hasMatch(value)) {
                                return 'Por favor, insira um e-mail válido';
                              }
                              return null;
                            },
                          ),
                          _buildInputField(
                            controller: _registerPasswordController,
                            hintText: 'Senha',
                            icon: FontAwesomeIcons.lock,
                            obscureText: true,
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return 'Por favor, insira sua senha';
                              }
                              if (value.length < 6) {
                                return 'A senha deve ter pelo menos 6 caracteres';
                              }
                              return null;
                            },
                          ),
                          const SizedBox(height: 15),
                          _buildButton(
                            text: 'Cadastrar',
                            onPressed: _register,
                            backgroundColor: const Color(0xFF009D66),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),

                AnimatedPositioned(
                  duration: const Duration(milliseconds: 1800),
                  curve: Curves.easeInOutCubic,
                  left: _isLoginPanel ? 0 : containerWidth / 2,
                  width: containerWidth / 2,
                  height: containerHeight,
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(30),
                    child: Container(
                      color: const Color(0xFF009D66),
                      child: Row(
                        children: [
                          Expanded(
                            child: AnimatedOpacity(
                              opacity: _isLoginPanel ? 1.0 : 0.0,
                              duration: const Duration(milliseconds: 600),
                              child: _buildTogglePanel(
                                title: 'Olá, Seja bem vindo!',
                                subtitle: 'Ainda não tem uma conta?',
                                buttonText: 'Cadastre-se',
                                onPressed: () {
                                  setState(() {
                                    _isLoginPanel = false;
                                  });
                                },
                              ),
                            ),
                          ),
                          Expanded(
                            child: AnimatedOpacity(
                              opacity: _isLoginPanel ? 0.0 : 1.0,
                              duration: const Duration(milliseconds: 600),
                              child: _buildTogglePanel(
                                title: 'Bem vindo!',
                                subtitle: 'Já tem uma conta?',
                                buttonText: 'Entrar',
                                onPressed: () {
                                  setState(() {
                                    _isLoginPanel = true;
                                  });
                                },
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildRoleDropdownField() {
    final List<String> cargos = ['Administrador', 'Balconista', 'Veterinário'];

    return Container(
      margin: const EdgeInsets.symmetric(vertical: 15),
      child: DropdownButtonFormField<String>(
        value: _selectedRegisterRole,
        decoration: InputDecoration(
          hintText: 'Cargo',
          fillColor: const Color(0xFFEEEEEE),
          filled: true,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8),
            borderSide: BorderSide.none,
          ),
          contentPadding: const EdgeInsets.symmetric(vertical: 13, horizontal: 20),
          prefixIcon: Padding(
            padding: const EdgeInsets.only(left: 20.0, right: 10.0),
            child: Icon(FontAwesomeIcons.briefcase, size: 20, color: Colors.black54),
          ),
          prefixIconConstraints: BoxConstraints.tight(const Size(50, 20)),
        ),
        items: cargos.map((cargo) {
          return DropdownMenuItem<String>(
            value: cargo,
            child: Text(cargo),
          );
        }).toList(),
        onChanged: (value) {
          setState(() {
            _selectedRegisterRole = value;
          });
        },
        validator: (value) {
          if (value == null || value.isEmpty) {
            return 'Por favor, selecione um cargo';
          }
          return null;
        },
        style: GoogleFonts.poppins(fontSize: 16, color: Colors.black87, fontWeight: FontWeight.w500),
      ),
    );
  }

  Widget _buildInputField({
    required TextEditingController controller,
    required String hintText,
    required IconData icon,
    bool obscureText = false,
    TextInputType keyboardType = TextInputType.text,
    String? Function(String?)? validator,
  }) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 15),
      child: TextFormField(
        controller: controller,
        obscureText: obscureText,
        keyboardType: keyboardType,
        decoration: InputDecoration(
          hintText: hintText,
          fillColor: const Color(0xFFEEEEEE),
          filled: true,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8),
            borderSide: BorderSide.none,
          ),
          contentPadding: const EdgeInsets.symmetric(vertical: 13, horizontal: 20),
          prefixIcon: Padding(
            padding: const EdgeInsets.only(left: 20.0, right: 10.0),
            child: Icon(icon, size: 20, color: Colors.black54),
          ),
          prefixIconConstraints: BoxConstraints.tight(const Size(50, 20)),
        ),
        style: GoogleFonts.poppins(fontSize: 16, color: Colors.black87, fontWeight: FontWeight.w500),
        validator: validator,
      ),
    );
  }

  Widget _buildButton({
    required String text,
    required VoidCallback onPressed,
    required Color backgroundColor,
    Color textColor = Colors.white,
    double width = double.infinity,
  }) {
    return SizedBox(
      width: width,
      height: 48,
      child: ElevatedButton(
        onPressed: onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: backgroundColor,
          foregroundColor: textColor,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
          ),
          shadowColor: Colors.black12,
          elevation: 10,
        ),
        child: Text(
          text,
          style: GoogleFonts.poppins(fontSize: 16, fontWeight: FontWeight.w600),
        ),
      ),
    );
  }

  Widget _buildTogglePanel({
    required String title,
    required String subtitle,
    required String buttonText,
    required VoidCallback onPressed,
  }) {
    return Center(
      child: Container(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Text(
              title,
              textAlign: TextAlign.center,
              style: GoogleFonts.poppins(
                fontSize: 36,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
            const SizedBox(height: 15),
            Text(
              subtitle,
              textAlign: TextAlign.center,
              style: GoogleFonts.poppins(
                fontSize: 14.5,
                color: Colors.white,
              ),
            ),
            const SizedBox(height: 20),
            _buildButton(
              text: buttonText,
              onPressed: onPressed,
              backgroundColor: Colors.transparent,
              textColor: Colors.white,
              width: 160,
            ),
          ],
        ),
      ),
    );
  }
}