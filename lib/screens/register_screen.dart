import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import '../theme/app_theme.dart';
import '../utils/validators.dart';
import '../widgets/bg_scaffold.dart';
import '../widgets/glass_card.dart';
import '../widgets/otp_input_widget.dart';
import 'login_screen.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _formKey      = GlobalKey<FormState>();
  final _userCtrl     = TextEditingController();
  final _emailCtrl    = TextEditingController();
  final _passCtrl     = TextEditingController();
  final _confirmCtrl  = TextEditingController();
  final _mobileCtrl   = TextEditingController();

  bool   _otpSent      = false;
  bool   _otpVerified  = false;
  bool   _sendingOtp   = false;
  int    _countdown    = 0;
  Timer? _timer;

  int  _strength      = 0;
  bool _hidePass      = true;
  bool _hideConfirm   = true;
  bool _loading       = false;

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

  Future<void> _sendOtp() async {
    final err = Validators.email(_emailCtrl.text);
    if (err != null) { _toast(err, error: true); return; }
    setState(() => _sendingOtp = true);
    await Future.delayed(const Duration(milliseconds: 1200));
    if (!mounted) return;
    setState(() {
      _otpSent    = true;
      _sendingOtp = false;
      _countdown  = 60;
    });
    _timer?.cancel();
    _timer = Timer.periodic(const Duration(seconds: 1), (t) {
      if (_countdown <= 1) {
        t.cancel();
        if (mounted) setState(() => _countdown = 0);
      } else {
        if (mounted) setState(() => _countdown--);
      }
    });
    _toast('OTP sent to ${_emailCtrl.text}');
  }

  void _onOtp(String otp) {
    if (otp.length == 6) setState(() => _otpVerified = true);
  }

  Future<void> _register() async {
    FocusScope.of(context).unfocus();
    if (!_formKey.currentState!.validate()) return;
    if (!_otpVerified) {
      _toast('Please verify your email with OTP first.', error: true);
      return;
    }
    setState(() => _loading = true);
    await Future.delayed(const Duration(milliseconds: 1400));
    if (!mounted) return;
    setState(() => _loading = false);
    Navigator.of(context).pushReplacement(
      MaterialPageRoute(builder: (_) => const LoginScreen()),
    );
    _toast('Account created! Please sign in.');
  }

  void _toast(String msg, {bool error = false}) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Text(msg, style: GoogleFonts.inter(fontSize: 13)),
      backgroundColor: error ? AppColors.error : AppColors.btnDark,
      behavior: SnackBarBehavior.floating,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
    ));
  }

  // ── Input decoration ─────────────────────────
  InputDecoration _dec({required String hint, Widget? suffix, Widget? prefix}) {
    return InputDecoration(
      hintText: hint,
      hintStyle: GoogleFonts.inter(
        fontSize: 14, color: Colors.white.withValues(alpha: 0.40),
      ),
      suffixIcon: suffix,
      prefix: prefix,
      counterText: '',
      filled: true,
      fillColor: Colors.white.withValues(alpha: 0.14),
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10),
        borderSide: BorderSide(
          color: Colors.white.withValues(alpha: 0.32), width: 1,
        ),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10),
        borderSide: const BorderSide(color: Colors.white, width: 1.5),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10),
        borderSide: const BorderSide(color: Color(0xFFFF6B6B), width: 1),
      ),
      focusedErrorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10),
        borderSide: const BorderSide(color: Color(0xFFFF6B6B), width: 1.5),
      ),
      errorStyle: GoogleFonts.inter(
        fontSize: 11, color: const Color(0xFFFFCDD2),
      ),
    );
  }

  Widget _label(String t) => Align(
    alignment: Alignment.centerLeft,
    child: Text(t,
      style: GoogleFonts.inter(
        fontSize: 13, fontWeight: FontWeight.w600, color: Colors.white,
      ),
    ),
  );

  TextStyle get _ts => GoogleFonts.inter(fontSize: 14, color: Colors.white);

  @override
  Widget build(BuildContext context) {
    return BgScaffold(
      child: SingleChildScrollView(
        keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
        child: Padding(
          padding: EdgeInsets.only(
            left: 24, right: 24,
            top: MediaQuery.of(context).size.height * 0.06,
            bottom: 32,
          ),
          child: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 420),
              child: GlassCard(
                child: Form(
                  key: _formKey,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [

                      // ── Icon ──────────────────────────
                      Container(
                        width: 56, height: 56,
                        decoration: BoxDecoration(
                          color: Colors.white.withValues(alpha: 0.22),
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(
                            color: Colors.white.withValues(alpha: 0.48),
                          ),
                        ),
                        child: const Center(
                          child: Text('📚', style: TextStyle(fontSize: 28)),
                        ),
                      ),
                      const SizedBox(height: 14),

                      // ── Title ─────────────────────────
                      Text('Create Account',
                        style: GoogleFonts.dmSerifDisplay(
                          fontSize: 26, color: Colors.white,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Join Book Lobby — it only takes a minute.',
                        style: GoogleFonts.inter(
                          fontSize: 13,
                          color: Colors.white.withValues(alpha: 0.75),
                        ),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 20),

                      // ── Social ─────────────────────────
                      _SocialRow(),
                      const SizedBox(height: 14),
                      _OrDivider(),
                      const SizedBox(height: 16),

                      // ── 1. Username ────────────────────
                      _label('Username'),
                      const SizedBox(height: 6),
                      TextFormField(
                        controller: _userCtrl,
                        textInputAction: TextInputAction.next,
                        validator: Validators.username,
                        style: _ts,
                        decoration: _dec(hint: 'e.g. john_doe'),
                      ),
                      const SizedBox(height: 14),

                      // ── 2. Email + OTP ─────────────────
                      _label('Gmail / Email Address'),
                      const SizedBox(height: 6),
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Expanded(
                            child: TextFormField(
                              controller: _emailCtrl,
                              keyboardType: TextInputType.emailAddress,
                              textInputAction: TextInputAction.done,
                              autocorrect: false,
                              enabled: !_otpVerified,
                              validator: Validators.email,
                              style: _ts,
                              decoration: _dec(
                                hint: 'Enter your email...',
                                suffix: _otpVerified
                                    ? const Icon(Icons.verified_rounded,
                                    color: AppColors.success, size: 20)
                                    : null,
                              ),
                            ),
                          ),
                          const SizedBox(width: 10),
                          SizedBox(
                            height: 50,
                            child: ElevatedButton(
                              onPressed: (_sendingOtp ||
                                  _otpVerified ||
                                  _countdown > 0)
                                  ? null
                                  : _sendOtp,
                              style: ElevatedButton.styleFrom(
                                backgroundColor: _otpVerified
                                    ? AppColors.success
                                    : AppColors.btnDark,
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 12,
                                ),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(10),
                                ),
                              ),
                              child: _sendingOtp
                                  ? const SizedBox(
                                width: 16, height: 16,
                                child: CircularProgressIndicator(
                                  color: Colors.white, strokeWidth: 2,
                                ),
                              )
                                  : Text(
                                _otpVerified
                                    ? 'Verified'
                                    : _otpSent
                                    ? (_countdown > 0
                                    ? '${_countdown}s'
                                    : 'Resend')
                                    : 'Send OTP',
                                style: GoogleFonts.inter(
                                  fontSize: 13,
                                  fontWeight: FontWeight.w600,
                                  color: Colors.white,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),

                      // ── 3. OTP boxes ───────────────────
                      if (_otpSent && !_otpVerified) ...[
                        const SizedBox(height: 12),
                        Align(
                          alignment: Alignment.centerLeft,
                          child: Text(
                            'Enter the 6-digit code sent to your email',
                            style: GoogleFonts.inter(
                              fontSize: 11,
                              color: Colors.white.withValues(alpha: 0.65),
                            ),
                          ),
                        ),
                        const SizedBox(height: 10),
                        OtpInputWidget(onCompleted: _onOtp),
                      ],
                      if (_otpVerified) ...[
                        const SizedBox(height: 8),
                        Row(
                          children: [
                            const Icon(Icons.check_circle_rounded,
                                color: AppColors.success, size: 15),
                            const SizedBox(width: 5),
                            Text('Email verified',
                              style: GoogleFonts.inter(
                                fontSize: 12,
                                color: AppColors.success,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ),
                      ],
                      const SizedBox(height: 14),

                      // ── 4. New password ────────────────
                      _label('New Password'),
                      const SizedBox(height: 6),
                      TextFormField(
                        controller: _passCtrl,
                        obscureText: _hidePass,
                        textInputAction: TextInputAction.next,
                        validator: Validators.password,
                        style: _ts,
                        decoration: _dec(
                          hint: 'Min 8 characters',
                          suffix: IconButton(
                            icon: Icon(
                              _hidePass
                                  ? Icons.visibility_off_outlined
                                  : Icons.visibility_outlined,
                              color: Colors.white70, size: 20,
                            ),
                            onPressed: () =>
                                setState(() => _hidePass = !_hidePass),
                          ),
                        ),
                      ),
                      if (_passCtrl.text.isNotEmpty) ...[
                        const SizedBox(height: 8),
                        _StrengthBar(strength: _strength),
                      ],
                      const SizedBox(height: 14),

                      // ── 5. Confirm password ────────────
                      _label('Confirm Password'),
                      const SizedBox(height: 6),
                      TextFormField(
                        controller: _confirmCtrl,
                        obscureText: _hideConfirm,
                        textInputAction: TextInputAction.next,
                        validator: (v) =>
                            Validators.confirmPassword(v, _passCtrl.text),
                        style: _ts,
                        decoration: _dec(
                          hint: 'Re-enter your password',
                          suffix: IconButton(
                            icon: Icon(
                              _hideConfirm
                                  ? Icons.visibility_off_outlined
                                  : Icons.visibility_outlined,
                              color: Colors.white70, size: 20,
                            ),
                            onPressed: () =>
                                setState(() => _hideConfirm = !_hideConfirm),
                          ),
                        ),
                      ),
                      const SizedBox(height: 14),

                      // ── 6. Mobile ──────────────────────
                      _label('Mobile Number'),
                      const SizedBox(height: 6),
                      TextFormField(
                        controller: _mobileCtrl,
                        keyboardType: TextInputType.phone,
                        textInputAction: TextInputAction.done,
                        validator: Validators.mobile,
                        inputFormatters: [
                          FilteringTextInputFormatter.digitsOnly,
                          LengthLimitingTextInputFormatter(10),
                        ],
                        style: _ts,
                        decoration: _dec(
                          hint: '10-digit number',
                          prefix: Text('+91  ',
                            style: GoogleFonts.inter(
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                              color: Colors.white,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 24),

                      // ── Create account ─────────────────
                      SizedBox(
                        width: double.infinity, height: 50,
                        child: ElevatedButton(
                          onPressed: _loading ? null : _register,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.btnDark,
                            foregroundColor: Colors.white,
                            elevation: 0,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                          child: _loading
                              ? const SizedBox(
                            width: 20, height: 20,
                            child: CircularProgressIndicator(
                              color: Colors.white, strokeWidth: 2.5,
                            ),
                          )
                              : Text('Create Account',
                              style: GoogleFonts.inter(
                                fontSize: 15,
                                fontWeight: FontWeight.w600,
                              )),
                        ),
                      ),
                      const SizedBox(height: 16),

                      // ── Sign in link ───────────────────
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text('Already have an account? ',
                            style: GoogleFonts.inter(
                              fontSize: 13,
                              color: Colors.white.withValues(alpha: 0.75),
                            ),
                          ),
                          TextButton(
                            onPressed: () => Navigator.of(context).pop(),
                            style: TextButton.styleFrom(
                              padding: const EdgeInsets.only(left: 2),
                              minimumSize: const Size(10, 36),
                              tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                              foregroundColor: Colors.white,
                            ),
                            child: Text('Sign in',
                              style: GoogleFonts.inter(
                                fontSize: 13,
                                fontWeight: FontWeight.w700,
                                color: Colors.white,
                              ),
                            ),
                          ),
                        ],
                      ),

                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

// ── Local widgets ────────────────────────────
class _SocialRow extends StatelessWidget {
  @override
  Widget build(BuildContext context) => Row(
    children: [
      _SBtn(icon: Icons.apple_rounded),
      const SizedBox(width: 10),
      _SBtn(child: Text('G',
        style: GoogleFonts.inter(
          fontSize: 17, fontWeight: FontWeight.w700, color: Colors.white,
        ),
      )),
      const SizedBox(width: 10),
      _SBtn(icon: Icons.work_outline_rounded),
    ],
  );
}

class _SBtn extends StatelessWidget {
  final IconData? icon;
  final Widget? child;
  const _SBtn({this.icon, this.child});
  @override
  Widget build(BuildContext context) => Expanded(
    child: Container(
      height: 46,
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.16),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: Colors.white.withValues(alpha: 0.38)),
      ),
      child: Center(
        child: child ?? Icon(icon, size: 22, color: Colors.white),
      ),
    ),
  );
}

class _OrDivider extends StatelessWidget {
  @override
  Widget build(BuildContext context) => Row(
    children: [
      Expanded(child: Divider(
        color: Colors.white.withValues(alpha: 0.32), thickness: 1,
      )),
      Padding(
        padding: const EdgeInsets.symmetric(horizontal: 12),
        child: Text('OR',
          style: GoogleFonts.inter(
            fontSize: 12, fontWeight: FontWeight.w600,
            color: Colors.white.withValues(alpha: 0.55),
            letterSpacing: 0.8,
          ),
        ),
      ),
      Expanded(child: Divider(
        color: Colors.white.withValues(alpha: 0.32), thickness: 1,
      )),
    ],
  );
}

class _StrengthBar extends StatelessWidget {
  final int strength;
  const _StrengthBar({required this.strength});
  Color get _color {
    if (strength <= 1) return AppColors.error;
    if (strength == 2) return AppColors.warning;
    return AppColors.success;
  }
  @override
  Widget build(BuildContext context) => Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Row(
        children: List.generate(4, (i) => Expanded(
          child: Container(
            margin: EdgeInsets.only(right: i < 3 ? 4 : 0),
            height: 3,
            decoration: BoxDecoration(
              color: i < strength
                  ? _color
                  : Colors.white.withValues(alpha: 0.22),
              borderRadius: BorderRadius.circular(3),
            ),
          ),
        )),
      ),
      const SizedBox(height: 4),
      Text(Validators.passwordStrengthLabel(strength),
        style: GoogleFonts.inter(
          fontSize: 11, color: _color, fontWeight: FontWeight.w600,
        ),
      ),
    ],
  );
}