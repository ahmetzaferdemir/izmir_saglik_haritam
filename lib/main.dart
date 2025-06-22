import 'package:flutter/material.dart';
import 'pages/login_page.dart';
import 'pages/register.dart';
import 'pages/home_page.dart';

void main() {
  runApp(const SaglikHaritamApp());
}

class SaglikHaritamApp extends StatelessWidget {
  const SaglikHaritamApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Sağlık Haritam',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primarySwatch: Colors.green,
        scaffoldBackgroundColor: const Color(0xFFF5F5F5),
      ),
      initialRoute: '/login',
      routes: {
        '/login': (context) => const LoginPage(),
        '/register': (context) => const RegisterPage(),
        '/home': (context) => const HomePage(),
      },
    );
  }
}
