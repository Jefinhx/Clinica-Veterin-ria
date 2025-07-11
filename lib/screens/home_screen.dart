// lib/screens/home_screen.dart

import 'package:clinica_veterinaria/repositories/auth_repository.dart';
import 'package:clinica_veterinaria/screens/agendamentos_screen.dart';
import 'package:clinica_veterinaria/screens/cadastros_screen.dart';
import 'package:clinica_veterinaria/screens/estoque_farmacia_screen.dart';
import 'package:clinica_veterinaria/screens/login_signup_screen.dart';
import 'package:clinica_veterinaria/screens/loja_screen.dart'; // 1. Import da nova tela
import 'package:clinica_veterinaria/screens/prontuarios_screen.dart';
import 'package:clinica_veterinaria/screens/relatorios_screen.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:supabase_flutter/supabase_flutter.dart';


class AppColors {
  static const Color bgBlack900 = Color(0xFFF2F2FC);
  static const Color bgBlack100 = Color(0xFFFDF9FF);
  static const Color bgBlack50 = Color(0xFFE8DFEC);
  static const Color textBlack900 = Color(0xFF009D66);
  static const Color skinColor = Color(0xFF000000);
}

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {

  late final AuthRepository _authRepository;

  @override
  void initState() {
    super.initState();

    _authRepository = AuthRepository(Supabase.instance.client);
  }


  Future<void> _logout() async {
    try {
      await _authRepository.signOut();

      if (!mounted) return;

      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(builder: (context) => const LoginSignupScreen()),
        (Route<dynamic> route) => false,
      );

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Você foi deslogado com sucesso!')),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Erro ao deslogar: ${e.toString()}')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {

    return Scaffold(
      backgroundColor: AppColors.bgBlack900,
      body: Row(
        children: [
          Container(
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
                      _buildNavLink(FontAwesomeIcons.house, 'Página Inicial', isActive: true, onTap: () {}),
                      _buildNavLink(FontAwesomeIcons.calendarCheck, 'Agendamentos', onTap: () {
                        Navigator.push(context, MaterialPageRoute(builder: (context) => const AgendamentosScreen()));
                      }),
                      _buildNavLink(FontAwesomeIcons.user, 'Cadastros', onTap: () {
                        Navigator.push(context, MaterialPageRoute(builder: (context) => const CadastrosScreen()));
                      }),
                      _buildNavLink(FontAwesomeIcons.boxesStacked, 'Estoque', onTap: () {
                        Navigator.push(context, MaterialPageRoute(builder: (context) => const EstoqueFarmaciaScreen()));
                      }),
                      // 2. Link para a tela de Loja adicionado aqui
                      _buildNavLink(FontAwesomeIcons.store, 'Loja', onTap: () {
                        Navigator.push(context, MaterialPageRoute(builder: (context) => const LojaScreen()));
                      }),
                      _buildNavLink(FontAwesomeIcons.stethoscope, 'Prontuários', onTap: () {
                        Navigator.push(context, MaterialPageRoute(builder: (context) => const ProntuariosScreen()));
                      }),
                      _buildNavLink(FontAwesomeIcons.chartBar, 'Relatórios', onTap: () {
                        Navigator.push(context, MaterialPageRoute(builder: (context) => const RelatoriosScreen()));
                      }),
                      _buildNavLink(FontAwesomeIcons.rightFromBracket, 'Sair', onTap: _logout),
                    ],
                  ),
                ),
              ],
            ),
          ),

          Expanded(
            child: Container(
              color: AppColors.bgBlack900,
              padding: const EdgeInsets.all(30),
              child: SingleChildScrollView(
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      flex: 1,
                      child: Container(
                        constraints: const BoxConstraints(maxWidth: 500),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                const Icon(FontAwesomeIcons.paw, color: AppColors.skinColor, size: 24),
                                const SizedBox(width: 5),
                                Flexible(
                                  child: Text(
                                    'Bem-estar Animal - Veterinária',
                                    style: GoogleFonts.poppins(
                                      fontSize: 37,
                                      color: AppColors.textBlack900,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 5),
                                const Icon(FontAwesomeIcons.paw, color: AppColors.skinColor, size: 24),
                              ],
                            ),
                            const SizedBox(height: 20),
                            Text(
                              'Bem-vindo ao coração digital da Clínica Bem-estar Animal! Este sistema foi criado para que você, nosso colaborador, tenha total controle e agilidade no dia a dia.\n\nAqui, você pode gerenciar agendamentos para nossa vasta gama de serviços — de consultas de rotina e especializadas a cirurgias e vacinação. Acompanhe os prontuários de cada um dos nossos queridos pacientes, administre o cadastro de clientes e seus pets, e mantenha nosso estoque e farmácia sempre em dia. Nossa equipe de veterinários e especialistas dedicados trabalha com amor e excelência de segunda a sexta, das 8h às 19h, e aos sábados, das 8h às 14h.\n\nUse esta ferramenta para continuar nos ajudando a cuidar da saúde e da felicidade de cada animal que passa por nossa porta.',
                              style: GoogleFonts.poppins(
                                fontSize: 16,
                                color: AppColors.textBlack900.withOpacity(0.8),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),

                    const SizedBox(width: 40),
                    Expanded(
                      flex: 1,
                      child: Container(
                        alignment: Alignment.center,
                        child: Image.asset(
                          'assets/images/imagem_principal.jpg',
                          fit: BoxFit.contain,
                          height: 450,
                          width: double.infinity,
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
            Flexible(
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