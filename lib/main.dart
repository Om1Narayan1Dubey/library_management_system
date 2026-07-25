import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'screens/home_screen.dart';
import 'screens/splash_screen.dart';
import 'screens/login_screen.dart';
import 'screens/register_screen.dart';


void main() {
  runApp(const BookLobbyApp());
}

class BookLobbyApp extends StatelessWidget {
  const BookLobbyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Book Lobby',
      debugShowCheckedModeBanner: false,

      // ── THE ROUTING TABLE ──

      initialRoute: '/home-admin',

      routes: {
        '/splash': (context) => const SplashScreen(),
        '/login': (context) => const LoginScreen(),
        '/register': (context) => const RegisterScreen(),
        '/home-admin': (context) => const HomeScreen(
          username: 'om gom',
          role: 'ADMIN',
          email: 'tata111dubey@gmail.com',
        ),
      },
    );
  }
}