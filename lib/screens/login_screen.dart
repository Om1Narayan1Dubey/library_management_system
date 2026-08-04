import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:dio/dio.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../services/api_service.dart';
import '../theme/app_colors.dart';
import '../utils/validators.dart';
import 'register_screen.dart';
import 'home_screen.dart';
import '../utils/top_toast.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey      = GlobalKey<FormState>();
  final _emailCtrl    = TextEditingController();
  final _passwordCtrl = TextEditingController();

  bool _hidePass  = true;
  bool _remember  = false;
  bool _loading   = false;
  final _api      = ApiService();

  @override
  void dispose() {
    _emailCtrl.dispose();
    _passwordCtrl.dispose();
    super.dispose();
  }

  Future<void> _login() async {
    FocusScope.of(context).unfocus();
    if (!_formKey.currentState!.validate()) return;

    setState(() => _loading = true);
    try {
      final response = await _api.login(
        email:    _emailCtrl.text.trim(),
        password: _passwordCtrl.text,
      );
      if (!mounted) return;
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(
          builder: (_) => HomeScreen(
            username: response['username'] ?? '',
            role:     response['role'] ?? 'MEMBER',
            email:    response['email'] ?? '',
          ),
        ),
      );
    } on DioException catch (e) {
      final msg = e.response?.data['error'] ?? 'Login failed. Please try again.';

      TopToast.show(context, msg, isError: true);

    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  void _goRegister() {
    Navigator.of(context).push(
      MaterialPageRoute(builder: (_) => const RegisterScreen()),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: LoginColors.screenBackground,
      body: Stack(
        children: [
          // ── 1. ABSTRACT GEOMETRIC LANDSCAPE (Background) ──
          // Giant Top-Right Accent
          Positioned(
            top: -120,
            right: -80,
            child: const _NeumorphicBackgroundShape(size: 380)
                .animate().fadeIn(duration: 800.ms).scale(begin: const Offset(0.9, 0.9)),
          ),

          // Giant Bottom-Left Accent
          Positioned(
            bottom: -150,
            left: -100,
            child: const _NeumorphicBackgroundShape(size: 450)
                .animate().fadeIn(duration: 1000.ms).scale(begin: const Offset(0.9, 0.9)),
          ),

          // Small Middle-Left Accent for balance
          Positioned(
            top: MediaQuery.of(context).size.height * 0.35,
            left: -60,
            child: const _NeumorphicBackgroundShape(size: 160)
                .animate().fadeIn(duration: 1200.ms).scale(begin: const Offset(0.9, 0.9)),
          ),

          Positioned(
            top: MediaQuery.of(context).size.height * 0.35,
            left: -60,
            child: const _NeumorphicBackgroundShape(size: 160)
                .animate().fadeIn(duration: 1200.ms).scale(begin: const Offset(0.9, 0.9)),
          ),

          // ── 2. THE UI LAYER ──
          SafeArea(
            child: Center(
              child: SingleChildScrollView(
                keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 420),
                  child: _NeumorphicCard(
                    child: Form(
                      key: _formKey,
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const _NeumorphicEmblem().animate().fadeIn(duration: 400.ms).scale(begin: const Offset(0.8, 0.8)),
                          const SizedBox(height: 24),

                          Text(
                            'Welcome back',
                            style: GoogleFonts.dmSerifDisplay(
                              fontSize: 32,
                              color: LoginColors.textDark,
                              height: 1.1,
                            ),
                          ).animate().fadeIn(delay: 100.ms).slideY(begin: 0.1),
                          const SizedBox(height: 8),
                          Text(
                            'Sign in to your Book Lobby account',
                            style: GoogleFonts.inter(
                              fontSize: 14,
                              color: LoginColors.textDark.withValues(alpha: 0.6),
                              fontWeight: FontWeight.w500,
                            ),
                            textAlign: TextAlign.center,
                          ).animate().fadeIn(delay: 200.ms).slideY(begin: 0.1),
                          const SizedBox(height: 32),

                          _FieldLabel('Email address', LoginColors.textDark).animate().fadeIn(delay: 300.ms),
                          const SizedBox(height: 8),
                          _buildTextField(
                            controller: _emailCtrl,
                            hint: 'you@gmail.com',
                            icon: Icons.alternate_email_rounded,
                            isEmail: true,
                          ).animate().fadeIn(delay: 350.ms).slideY(begin: 0.05),
                          const SizedBox(height: 20),

                          _FieldLabel('Password', LoginColors.textDark).animate().fadeIn(delay: 400.ms),
                          const SizedBox(height: 8),
                          _buildTextField(
                            controller: _passwordCtrl,
                            hint: '••••••••',
                            icon: Icons.lock_outline_rounded,
                            isPassword: true,
                          ).animate().fadeIn(delay: 450.ms).slideY(begin: 0.05),
                          const SizedBox(height: 16),

                          Row(
                            children: [
                              _NeumorphicCheckbox(
                                value: _remember,
                                onChanged: (v) => setState(() => _remember = v ?? false),
                                accentColor: LoginColors.accent,
                              ),
                              const SizedBox(width: 12),
                              Text(
                                'Remember me',
                                style: GoogleFonts.inter(
                                  fontSize: 13,
                                  fontWeight: FontWeight.w600,
                                  color: LoginColors.textDark.withValues(alpha: 0.7),
                                ),
                              ),
                              const Spacer(),
                              GestureDetector(
                                onTap: () {},
                                child: Text(
                                  'Forgot password?',
                                  style: GoogleFonts.inter(
                                    fontSize: 13,
                                    color: LoginColors.accent,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                            ],
                          ).animate().fadeIn(delay: 500.ms),
                          const SizedBox(height: 32),

                          _NeumorphicButton(
                            text: 'Sign In',
                            loading: _loading,
                            onTap: _login,
                            color: LoginColors.accent,
                          ).animate().fadeIn(delay: 550.ms).slideY(begin: 0.05),
                          const SizedBox(height: 32),

                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(
                                "New to Book Lobby? ",
                                style: GoogleFonts.inter(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w500,
                                  color: LoginColors.textDark.withValues(alpha: 0.6),
                                ),
                              ),
                              GestureDetector(
                                onTap: _goRegister,
                                child: Text(
                                  'Create an account',
                                  style: GoogleFonts.inter(
                                    fontSize: 14,
                                    fontWeight: FontWeight.bold,
                                    color: LoginColors.accent,
                                  ),
                                ),
                              ),
                            ],
                          ).animate().fadeIn(delay: 600.ms),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ── PURE MATTE TEXT FIELD (NO SHADOWS) ──
  Widget _buildTextField({
    required TextEditingController controller,
    required String hint,
    required IconData icon,
    bool isEmail = false,
    bool isPassword = false,
  }) {
    return TextFormField(
      controller: controller,
      obscureText: isPassword && _hidePass,
      keyboardType: isEmail ? TextInputType.emailAddress : TextInputType.text,
      textInputAction: isPassword ? TextInputAction.done : TextInputAction.next,
      onFieldSubmitted: isPassword ? (_) => _login() : null,
      validator: isEmail ? Validators.gmail : Validators.password,
      style: GoogleFonts.inter(fontSize: 15, color: LoginColors.textDark, fontWeight: FontWeight.w600),
      decoration: InputDecoration(
        hintText: hint,
        hintStyle: GoogleFonts.inter(color: LoginColors.textDark.withValues(alpha: 0.4), fontWeight: FontWeight.w500),
        prefixIcon: Icon(icon, color: LoginColors.textDark.withValues(alpha: 0.5), size: 20),
        suffixIcon: isPassword
            ? GestureDetector(
          onTap: () => setState(() => _hidePass = !_hidePass),
          child: Icon(
            _hidePass ? Icons.visibility_off_rounded : Icons.visibility_rounded,
            color: LoginColors.textDark.withValues(alpha: 0.5),
            size: 20,
          ),
        )
            : null,
        filled: true,
        fillColor: Colors.black.withValues(alpha: 0.04),
        contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: BorderSide.none),
        errorStyle: GoogleFonts.inter(fontSize: 12, color: const Color(0xFFFF6B6B), fontWeight: FontWeight.w600),
      ),
    );
  }
}

// ════════════════════════════════════════════════════════════
//  NEUMORPHISM CORE COMPONENTS
// ════════════════════════════════════════════════════════════

// ── NEW: SCULPTED BACKGROUND SHAPE ──
class _NeumorphicBackgroundShape extends StatelessWidget {
  final double size;
  const _NeumorphicBackgroundShape({required this.size});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: LoginColors.cardBase, // Must match the background perfectly
        shape: BoxShape.circle,
        boxShadow: [
          // Extra large, highly blurred shadows to create sweeping curves
          BoxShadow(
            color: const Color(0xFFA3B1C6).withValues(alpha: 0.5),
            offset: const Offset(18, 18),
            blurRadius: 40,
            spreadRadius: 4,
          ),
          BoxShadow(
            color: Colors.white.withValues(alpha: 0.7),
            offset: const Offset(-18, -18),
            blurRadius: 40,
            spreadRadius: 4,
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
          BoxShadow(
            color: Color(0xFFA3B1C6),
            offset: Offset(9, 9),
            blurRadius: 18,
          ),
          BoxShadow(
            color: Colors.white,
            offset: Offset(-9, -9),
            blurRadius: 18,
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: child,
      ),
    );
  }
}

class _NeumorphicButton extends StatelessWidget {
  final String text;
  final bool loading;
  final VoidCallback onTap;
  final Color color;

  const _NeumorphicButton({
    required this.text,
    required this.loading,
    required this.onTap,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: loading ? null : onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        width: double.infinity,
        height: 56,
        decoration: BoxDecoration(
          color: color,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: color.withValues(alpha: 0.50),
              offset: const Offset(6, 6),
              blurRadius: 12,
            ),
            const BoxShadow(
              color: Colors.white,
              offset: Offset(-4, -4),
              blurRadius: 10,
            ),
          ],
        ),
        child: Center(
          child: loading
              ? const SizedBox(
            width: 24, height: 24,
            child: CircularProgressIndicator(color: Colors.white, strokeWidth: 3),
          )
              : Text(
            text,
            style: GoogleFonts.inter(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: Colors.white,
              letterSpacing: 0.5,
            ),
          ),
        ),
      ),
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
          BoxShadow(
            color: Color(0xFFA3B1C6),
            offset: Offset(6, 6),
            blurRadius: 12,
          ),
          BoxShadow(
            color: Colors.white,
            offset: Offset(-6, -6),
            blurRadius: 12,
          ),
        ],
      ),
      child: const Center(
        child: Text('📚', style: TextStyle(fontSize: 32)),
      ),
    );
  }
}

class _NeumorphicCheckbox extends StatelessWidget {
  final bool value;
  final ValueChanged<bool?> onChanged;
  final Color accentColor;

  const _NeumorphicCheckbox({required this.value, required this.onChanged, required this.accentColor});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => onChanged(!value),
      child: Container(
        width: 24, height: 24,
        decoration: BoxDecoration(
          color: value ? accentColor : Colors.black.withValues(alpha: 0.04),
          borderRadius: BorderRadius.circular(6),
          boxShadow: value
              ? [
            BoxShadow(
              color: accentColor.withValues(alpha: 0.45),
              offset: const Offset(3, 3),
              blurRadius: 6.0,
            ),
          ]
              : null,
        ),
        child: value
            ? const Icon(Icons.check_rounded, size: 16, color: Colors.white)
            : null,
      ),
    );
  }
}

class _FieldLabel extends StatelessWidget {
  final String text;
  final Color color;
  const _FieldLabel(this.text, this.color);

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: Alignment.centerLeft,
      child: Text(
        text,
        style: GoogleFonts.inter(
          fontSize: 13,
          fontWeight: FontWeight.w700,
          color: color.withValues(alpha: 0.8),
          letterSpacing: 0.3,
        ),
      ),
    );
  }
}