import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../services/api_service.dart';
import '../theme/app_colors.dart'; // Make sure this is imported for LoginColors!


class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {

  @override
  void initState() {
    super.initState();
    _checkSession();
  }

  Future<void> _checkSession() async {
    // We wait 2.0 seconds so the user can see the beautiful splash screen animations!
    await Future.delayed(const Duration(milliseconds: 2000));
    if (!mounted) return;

    final api = ApiService();
    final loggedIn = await api.isLoggedIn();

    if (!mounted) return;

    if (loggedIn) {
      try {
        // Fetch saved profile to get username and role
        final profile = await api.getProfile();
        if (!mounted) return;

        // PushReplacement means we destroy the splash screen.
        Navigator.of(context).pushReplacementNamed('/home-admin'); // Using our new routing!

      } catch (_) {
        if (!mounted) return;
        Navigator.of(context).pushReplacementNamed('/login'); // Using our new routing!
      }
    } else {
      Navigator.of(context).pushReplacementNamed('/login'); // Using our new routing!
    }
  }



  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: LoginColors.screenBackground, // 1. Solid Grey Background
      body: Stack(
        children: [
          // ── 2. ABSTRACT GEOMETRIC LANDSCAPE (Matches Login exactly) ──
          Positioned(
            top: -120, right: -80,
            child: const _NeumorphicBackgroundShape(size: 380)
                .animate().fadeIn(duration: 800.ms).scale(begin: const Offset(0.9, 0.9)),
          ),
          Positioned(
            bottom: -150, left: -100,
            child: const _NeumorphicBackgroundShape(size: 450)
                .animate().fadeIn(duration: 1000.ms).scale(begin: const Offset(0.9, 0.9)),
          ),
          Positioned(
            top: MediaQuery.of(context).size.height * 0.35, left: -60,
            child: const _NeumorphicBackgroundShape(size: 160)
                .animate().fadeIn(duration: 1200.ms).scale(begin: const Offset(0.9, 0.9)),
          ),

          // ── 3. THE UI LAYER ──
          Center(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 100),
              child: _NeumorphicCard( // 4. Swapped GlassCard for NeumorphicCard
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // The floating book emblem
                    const _NeumorphicEmblem()
                        .animate()
                        .fadeIn(duration: 400.ms)
                        .scale(begin: const Offset(0.8, 0.8)),
                    const SizedBox(height: 24),

                    Text(
                      'Book Lobby',
                      style: GoogleFonts.dmSerifDisplay(
                        fontSize: 32,
                        color: LoginColors.textDark, // 5. Changed to Dark Text
                        letterSpacing: 0.5,
                      ),
                    ).animate().fadeIn(delay: 200.ms).slideY(begin: 0.1),
                    const SizedBox(height: 6),

                    Text(
                      'Library Management System',
                      style: GoogleFonts.inter(
                        fontSize: 13,
                        color: LoginColors.textDark.withValues(alpha: 0.60), // Faded Dark Text
                      ),
                      textAlign: TextAlign.center,
                    ).animate().fadeIn(delay: 300.ms).slideY(begin: 0.1),
                    const SizedBox(height: 32),

                    SizedBox(
                      width: 24, height: 24,
                      child: CircularProgressIndicator(
                        color: LoginColors.accent, // 6. Changed spinner to Accent Color
                        strokeWidth: 3,
                      ),
                    ).animate().fadeIn(delay: 500.ms),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ════════════════════════════════════════════════════════════
//  NEUMORPHISM CORE COMPONENTS
// ════════════════════════════════════════════════════════════

class _NeumorphicBackgroundShape extends StatelessWidget {
  final double size;
  const _NeumorphicBackgroundShape({required this.size});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size, height: size,
      decoration: BoxDecoration(
        color: LoginColors.cardBase,
        shape: BoxShape.circle,
        boxShadow: [
          BoxShadow(
            color: const Color(0xFFA3B1C6).withValues(alpha: 0.5),
            offset: const Offset(18, 18), blurRadius: 40, spreadRadius: 4,
          ),
          BoxShadow(
            color: Colors.white.withValues(alpha: 0.7),
            offset: const Offset(-18, -18), blurRadius: 40, spreadRadius: 4,
          ),
        ],
      ),
    );
  }
}

class _NeumorphicCard extends StatelessWidget {
  final Widget child;
  const _NeumorphicCard({required this.child});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: LoginColors.cardBase,
        borderRadius: BorderRadius.circular(40),
        boxShadow: const [
          BoxShadow(color: Color(0xFFA3B1C6), offset: Offset(9, 9), blurRadius: 18),
          BoxShadow(color: Colors.white, offset: Offset(-9, -9), blurRadius: 18),
        ],
      ),
      child: Padding(padding: const EdgeInsets.all(32), child: child),
    );
  }
}

class _NeumorphicEmblem extends StatelessWidget {
  const _NeumorphicEmblem();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 80, height: 80,
      decoration: BoxDecoration(
        color: LoginColors.cardBase,
        shape: BoxShape.circle,
        boxShadow: const [
          BoxShadow(color: Color(0xFFA3B1C6), offset: Offset(6, 6), blurRadius: 12),
          BoxShadow(color: Colors.white, offset: Offset(-6, -6), blurRadius: 12),
        ],
      ),
      child: const Center(child: Text('📚', style: TextStyle(fontSize: 32))),
    );
  }
}