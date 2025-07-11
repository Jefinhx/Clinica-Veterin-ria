// Em lib/main.dart

import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:clinica_veterinaria/screens/home_screen.dart';
import 'package:clinica_veterinaria/screens/login_signup_screen.dart';
import 'package:clinica_veterinaria/repositories/auth_repository.dart';

late final AuthRepository authRepository; // Declaração

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Supabase.initialize(
    url: 'https://aniypteieqbrkjbofppb.supabase.co',
    anonKey: 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6ImFuaXlwdGVpZXFicmtqYm9mcHBiIiwicm9sZSI6ImFub24iLCJpYXQiOjE3NTA4ODg2MTcsImV4cCI6MjA2NjQ2NDYxN30.-Yn82s-yeEKTSy-D-cfNYjaBQgJLTl84gM7gH8ltWBE',
  );

  authRepository = AuthRepository(Supabase.instance.client);


  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  MyApp({super.key});

  final Map<String, WidgetBuilder> routes = {
    '/': (context) => const LoginSignupScreen(),
    '/home': (context) => const HomeScreen(),
  };

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Bem-estar Animal',
      theme: ThemeData(
        primarySwatch: Colors.teal,
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      initialRoute: '/',
      routes: routes,
      debugShowCheckedModeBanner: false,
    );
  }
}