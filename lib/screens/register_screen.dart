import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:dio/dio.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../services/api_service.dart';
import '../theme/app_colors.dart';
import '../utils/validators.dart';
import '../widgets/otp_input_widget.dart';
import 'login_screen.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _formKey     = GlobalKey<FormState>();
  final _userCtrl    = TextEditingController();
  final _emailCtrl   = TextEditingController();
  final _passCtrl    = TextEditingController();
  final _confirmCtrl = TextEditingController();
  final _mobileCtrl  = TextEditingController();
  final _api         = ApiService();

  bool   _otpSent     = false;
  bool   _otpVerified = false;
  bool   _sendingOtp  = false;
  int    _countdown   = 0;
  Timer? _timer;

  String _otpCode   = '';
  int    _strength  = 0;
  bool   _hidePass  = true;
  bool   _hideConf  = true;
  bool   _loading   = false;

  @override
  void initState() {
    super.initState();
    _passCtrl.addListener(() {
      final s = Validators.passwordStrength(_passCtrl.text);
      if (s != _strength) setState(() => _strength = s);
    });
  }

  @override
  void dispose() {
    _userCtrl.dispose();
    _emailCtrl.dispose();
    _passCtrl.dispose();
    _confirmCtrl.dispose();
    _mobileCtrl.dispose();
    _timer?.cancel();
    super.dispose();
  }

  // ── Countdown timer ──────────────────────────
  void _startTimer() {
    _timer?.cancel();
    _timer = Timer.periodic(const Duration(seconds: 1), (t) {
      if (_countdown == 0) {
        t.cancel();
      } else {
        setState(() => _countdown--);
      }
    });
  }

  // ── Send OTP ─────────────────────────────────
  Future<void> _sendOtp() async {
    final err = Validators.gmail(_emailCtrl.text);
    if (err != null) { _toast(err, error: true); return; }

    setState(() => _sendingOtp = true);
    try {
      await _api.sendOtp(_emailCtrl.text.trim());
      setState(() {
        _otpSent    = true;
        _otpCode    = '';
        _otpVerified = false;
        _countdown  = 60;
      });
      _startTimer();
      _toast('OTP sent to ${_emailCtrl.text.trim()}');
    } on DioException catch (e) {
      _toast(e.response?.data['error'] ?? 'Failed to send OTP.', error: true);
    } finally {
      setState(() => _sendingOtp = false);
    }
  }

  // ── OTP entered by user ───────────────────────
  void _onOtp(String otp) {
    setState(() => _otpCode = otp);
  }

  // ── Register + Verify ────────────────────────
  Future<void> _register() async {
    FocusScope.of(context).unfocus();
    if (!_formKey.currentState!.validate()) return;

    if (!_otpSent) {
      _toast('Please send OTP to your email first.', error: true);
      return;
    }
    if (_otpCode.length != 6) {
      _toast('Please enter the 6-digit OTP.', error: true);
      return;
    }

    setState(() => _loading = true);
    try {
      await _api.register(
        username: _userCtrl.text.trim(),
        email:    _emailCtrl.text.trim(),
        password: _passCtrl.text,
        mobile:   _mobileCtrl.text.trim(),
      );

      await _api.verifyOtp(
        email:   _emailCtrl.text.trim(),
        otpCode: _otpCode,
      );

      setState(() => _otpVerified = true);

      if (!mounted) return;
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (_) => const LoginScreen()),
      );
      _toast('Account created! Please sign in.');

    } on DioException catch (e) {
      final msg = e.response?.data['error'] ?? 'Something went wrong.';
      _toast(msg, error: true);

      if (msg.toLowerCase().contains('otp') ||
          msg.toLowerCase().contains('incorrect') ||
          msg.toLowerCase().contains('expired')) {
        try {
          await _api.deleteUnverifiedUser(_emailCtrl.text.trim());
          setState(() {
            _otpCode    = '';
            _otpVerified = false;
          });
        } catch (_) {}
      }
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  void _toast(String msg, {bool error = false}) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Text(msg, style: GoogleFonts.inter(fontSize: 13, color: Colors.white70)),
      backgroundColor: const Color(0xFF2D3142),
      behavior: SnackBarBehavior.floating,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
    ));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: LoginColors.screenBackground,
      body: Stack(
        children: [
          // ── ABSTRACT GEOMETRIC LANDSCAPE (Background) ──
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

          // ── THE UI LAYER ──
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

                          Text('Create Account',
                            style: GoogleFonts.dmSerifDisplay(
                              fontSize: 28, color: LoginColors.textDark, height: 1.1,
                            ),
                          ).animate().fadeIn(delay: 100.ms).slideY(begin: 0.1),
                          const SizedBox(height: 8),
                          Text(
                            'Join Book Lobby — it only takes a minute.',
                            style: GoogleFonts.inter(
                              fontSize: 14, color: LoginColors.textDark.withValues(alpha: 0.6), fontWeight: FontWeight.w500,
                            ),
                            textAlign: TextAlign.center,
                          ).animate().fadeIn(delay: 200.ms).slideY(begin: 0.1),
                          const SizedBox(height: 24),

                          // ── Username ──
                          _FieldLabel('Username').animate().fadeIn(delay: 350.ms),
                          const SizedBox(height: 6),
                          _buildTextField(
                            controller: _userCtrl,
                            hint: 'e.g. john_doe',
                            icon: Icons.person_outline_rounded,
                          ).animate().fadeIn(delay: 400.ms).slideY(begin: 0.05),
                          const SizedBox(height: 16),

                          // ── Email + Send OTP ──
                          _FieldLabel('Gmail Address').animate().fadeIn(delay: 450.ms),
                          const SizedBox(height: 6),
                          Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Expanded(
                                child: _buildTextField(
                                  controller: _emailCtrl,
                                  hint: 'you@gmail.com',
                                  icon: Icons.alternate_email_rounded,
                                  isEmail: true,
                                  enabled: !_otpSent,
                                ),
                              ),
                              const SizedBox(width: 10),
                              SizedBox(
                                height: 56, // Matches text field height perfectly
                                child: _NeumorphicSmallButton(
                                  onTap: (_sendingOtp || _countdown > 0) ? null : _sendOtp,
                                  loading: _sendingOtp,
                                  text: _otpSent ? (_countdown > 0 ? '${_countdown}s' : 'Resend') : 'Send OTP',
                                ),
                              ),
                            ],
                          ).animate().fadeIn(delay: 500.ms).slideY(begin: 0.05),

                          // ── OTP Input ──
                          if (_otpSent) ...[
                            const SizedBox(height: 16),
                            Align(
                              alignment: Alignment.centerLeft,
                              child: Text(
                                'Enter the 6-digit code sent to your email',
                                style: GoogleFonts.inter(
                                  fontSize: 12, fontWeight: FontWeight.w600, color: LoginColors.textDark.withValues(alpha: 0.65),
                                ),
                              ),
                            ),
                            const SizedBox(height: 10),
                            OtpInputWidget(onCompleted: _onOtp), // Needs updating in its own file later if needed
                            const SizedBox(height: 8),
                            if (_otpCode.length == 6)
                              Row(
                                children: [
                                  Icon(Icons.info_outline_rounded, color: LoginColors.textDark.withValues(alpha: 0.6), size: 14),
                                  const SizedBox(width: 5),
                                  Text(
                                    'Code entered — tap Create Account to verify',
                                    style: GoogleFonts.inter(
                                      fontSize: 11, fontWeight: FontWeight.w500, color: LoginColors.textDark.withValues(alpha: 0.6),
                                    ),
                                  ),
                                ],
                              ),
                          ],
                          const SizedBox(height: 16),

                          // ── Password ──
                          _FieldLabel('New Password').animate().fadeIn(delay: 550.ms),
                          const SizedBox(height: 6),
                          _buildTextField(
                            controller: _passCtrl,
                            hint: 'Min 8 characters',
                            icon: Icons.lock_outline_rounded,
                            isPassword: true,
                            hideFlag: _hidePass,
                            onToggleHide: () => setState(() => _hidePass = !_hidePass),
                          ).animate().fadeIn(delay: 600.ms).slideY(begin: 0.05),
                          if (_passCtrl.text.isNotEmpty) ...[
                            const SizedBox(height: 8),
                            _StrengthBar(strength: _strength),
                          ],
                          const SizedBox(height: 16),

                          // ── Confirm Password ──
                          _FieldLabel('Confirm Password').animate().fadeIn(delay: 650.ms),
                          const SizedBox(height: 6),
                          _buildTextField(
                            controller: _confirmCtrl,
                            hint: 'Re-enter your password',
                            icon: Icons.lock_reset_rounded,
                            isPassword: true,
                            hideFlag: _hideConf,
                            onToggleHide: () => setState(() => _hideConf = !_hideConf),
                            validatorOverride: (v) => Validators.confirmPassword(v, _passCtrl.text),
                          ).animate().fadeIn(delay: 700.ms).slideY(begin: 0.05),
                          const SizedBox(height: 16),

                          // ── Mobile ──
                          _FieldLabel('Mobile Number').animate().fadeIn(delay: 750.ms),
                          const SizedBox(height: 6),
                          _buildTextField(
                            controller: _mobileCtrl,
                            hint: '10-digit number',
                            icon: Icons.phone_android_rounded,
                            isPhone: true,
                          ).animate().fadeIn(delay: 800.ms).slideY(begin: 0.05),
                          const SizedBox(height: 32),

                          // ── Create Account Button ──
                          _NeumorphicButton(
                            text: 'Create Account',
                            loading: _loading,
                            onTap: _register,
                            color: LoginColors.accent,
                          ).animate().fadeIn(delay: 850.ms).slideY(begin: 0.05),
                          const SizedBox(height: 24),

                          // ── Sign in link ──
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text('Already have an account? ',
                                style: GoogleFonts.inter(
                                  fontSize: 14, fontWeight: FontWeight.w500, color: LoginColors.textDark.withValues(alpha: 0.6),
                                ),
                              ),
                              GestureDetector(
                                onTap: () => Navigator.of(context).pop(),
                                child: Text('Sign in',
                                  style: GoogleFonts.inter(
                                    fontSize: 14, fontWeight: FontWeight.bold, color: LoginColors.accent,
                                  ),
                                ),
                              ),
                            ],
                          ).animate().fadeIn(delay: 900.ms),

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
    bool isPhone = false,
    bool enabled = true,
    bool? hideFlag,
    VoidCallback? onToggleHide,
    String? Function(String?)? validatorOverride,
  }) {
    return TextFormField(
      controller: controller,
      obscureText: isPassword && (hideFlag ?? true),
      enabled: enabled,
      keyboardType: isPhone ? TextInputType.phone : (isEmail ? TextInputType.emailAddress : TextInputType.text),
      textInputAction: TextInputAction.next,
      inputFormatters: isPhone ? [FilteringTextInputFormatter.digitsOnly, LengthLimitingTextInputFormatter(10)] : null,
      validator: validatorOverride ?? (isEmail ? Validators.gmail : (isPhone ? Validators.mobile : (isPassword ? Validators.password : Validators.username))),
      style: GoogleFonts.inter(fontSize: 15, color: LoginColors.textDark, fontWeight: FontWeight.w600),
      decoration: InputDecoration(
        hintText: hint,
        hintStyle: GoogleFonts.inter(color: LoginColors.textDark.withValues(alpha: 0.4), fontWeight: FontWeight.w500),
        prefixIcon: isPhone
            ? Padding(
          padding: const EdgeInsets.only(left: 20, right: 10, top: 18, bottom: 18),
          child: Text('+91', style: GoogleFonts.inter(fontSize: 15, color: LoginColors.textDark, fontWeight: FontWeight.w700)),
        )
            : Icon(icon, color: LoginColors.textDark.withValues(alpha: 0.5), size: 20),
        suffixIcon: isPassword
            ? GestureDetector(
          onTap: onToggleHide,
          child: Icon(
            (hideFlag ?? true) ? Icons.visibility_off_rounded : Icons.visibility_rounded,
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

class _NeumorphicButton extends StatelessWidget {
  final String text;
  final bool loading;
  final VoidCallback? onTap;
  final Color color;

  const _NeumorphicButton({required this.text, required this.loading, required this.onTap, required this.color});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: loading ? null : onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        width: double.infinity, height: 56,
        decoration: BoxDecoration(
          color: onTap == null ? color.withValues(alpha: 0.5) : color,
          borderRadius: BorderRadius.circular(20),
          boxShadow: onTap == null ? [] : [
            BoxShadow(color: color.withValues(alpha: 0.50), offset: const Offset(6, 6), blurRadius: 12),
            const BoxShadow(color: Colors.white, offset: Offset(-4, -4), blurRadius: 10),
          ],
        ),
        child: Center(
          child: loading
              ? const SizedBox(width: 24, height: 24, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 3))
              : Text(text, style: GoogleFonts.inter(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white, letterSpacing: 0.5)),
        ),
      ),
    );
  }
}

// A smaller variant of the Neumorphic button for the "Send OTP" action next to the email field
class _NeumorphicSmallButton extends StatelessWidget {
  final String text;
  final bool loading;
  final VoidCallback? onTap;

  const _NeumorphicSmallButton({required this.text, required this.loading, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: loading ? null : onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        padding: const EdgeInsets.symmetric(horizontal: 16),
        decoration: BoxDecoration(
          color: onTap == null ? LoginColors.cardBase : LoginColors.cardBase,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(color: const Color(0xFFA3B1C6).withValues(alpha: onTap == null ? 0.2 : 0.6), offset: const Offset(4, 4), blurRadius: 8),
            BoxShadow(color: Colors.white.withValues(alpha: onTap == null ? 0.4 : 1.0), offset: const Offset(-4, -4), blurRadius: 8),
          ],
        ),
        child: Center(
          child: loading
              ? const SizedBox(width: 16, height: 16, child: CircularProgressIndicator(color: LoginColors.accent, strokeWidth: 2))
              : Text(text, style: GoogleFonts.inter(fontSize: 13, fontWeight: FontWeight.bold, color: onTap == null ? LoginColors.textDark.withValues(alpha: 0.4) : LoginColors.accent)),
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
          BoxShadow(color: Color(0xFFA3B1C6), offset: Offset(6, 6), blurRadius: 12),
          BoxShadow(color: Colors.white, offset: Offset(-6, -6), blurRadius: 12),
        ],
      ),
      child: const Center(child: Text('📚', style: TextStyle(fontSize: 32))),
    );
  }
}

class _FieldLabel extends StatelessWidget {
  final String text;
  const _FieldLabel(this.text);

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: Alignment.centerLeft,
      child: Text(
        text,
        style: GoogleFonts.inter(fontSize: 13, fontWeight: FontWeight.w700, color: LoginColors.textDark.withValues(alpha: 0.8), letterSpacing: 0.3),
      ),
    );
  }
}

class _StrengthBar extends StatelessWidget {
  final int strength;
  const _StrengthBar({required this.strength});
  Color get _color {
    if (strength <= 1) return const Color(0xFFFF6B6B);
    if (strength == 2) return const Color(0xFFFDCB6E);
    return const Color(0xFF00B894);
  }
  @override
  Widget build(BuildContext context) => Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Row(
        children: List.generate(4, (i) => Expanded(
          child: Container(
            margin: EdgeInsets.only(right: i < 3 ? 4 : 0),
            height: 4,
            decoration: BoxDecoration(
              color: i < strength ? _color : Colors.black.withValues(alpha: 0.06),
              borderRadius: BorderRadius.circular(3),
            ),
          ),
        )),
      ),
      const SizedBox(height: 6),
      Text(Validators.passwordStrengthLabel(strength), style: GoogleFonts.inter(fontSize: 11, color: _color, fontWeight: FontWeight.w700)),
    ],
  );
}