import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../theme/app_colors.dart';
import '../providers/api_provider.dart';
import '../utils/top_toast.dart';

class ForgotPasswordScreen extends ConsumerStatefulWidget {
  const ForgotPasswordScreen({super.key});

  @override
  ConsumerState<ForgotPasswordScreen> createState() => _ForgotPasswordScreenState();
}

class _ForgotPasswordScreenState extends ConsumerState<ForgotPasswordScreen> {
  final _emailCtrl = TextEditingController();
  final _newPasswordCtrl = TextEditingController();
  final _confirmPasswordCtrl = TextEditingController();

  final List<TextEditingController> _otpControllers = List.generate(6, (_) => TextEditingController());
  final List<FocusNode> _otpFocusNodes = List.generate(6, (_) => FocusNode());

  bool _isLoading = false;
  bool _isOtpSent = false;

  bool _hideNewPass = true;
  bool _hideConfirmPass = true;

  @override
  void dispose() {
    _emailCtrl.dispose();
    _newPasswordCtrl.dispose();
    _confirmPasswordCtrl.dispose();
    for (var c in _otpControllers) { c.dispose(); }
    for (var f in _otpFocusNodes) { f.dispose(); }
    super.dispose();
  }

  // ── 1. SEND OTP TO EMAIL ──
  Future<void> _sendResetLink() async {
    if (_emailCtrl.text.trim().isEmpty) {
      TopToast.show(context, 'Please enter your email', isError: true);
      return;
    }

    setState(() => _isLoading = true);

    try {
      await ref.read(apiProvider).sendOtp(_emailCtrl.text.trim(), purpose: 'RESET');

      if (!mounted) return;
      setState(() {
        _isLoading = false;
        _isOtpSent = true;
      });
      TopToast.show(context, 'OTP sent! Please check your email.');

    } catch (e) {
      setState(() => _isLoading = false);
      if (!mounted) return;
      TopToast.show(context, 'Failed to send OTP. Try again.', isError: true);
    }
  }

  // ── 2. VERIFY OTP & RESET PASSWORD ──
  Future<void> _resetPassword() async {
    String otp = _otpControllers.map((c) => c.text.trim()).join();

    if (otp.length < 6 || _newPasswordCtrl.text.isEmpty) {
      TopToast.show(context, 'Please enter the OTP and a new password', isError: true);
      return;
    }

    if (_newPasswordCtrl.text.isEmpty || _confirmPasswordCtrl.text.isEmpty) {
      TopToast.show(context, 'Please fill in both password fields', isError: true);
      return;
    }

    if (_newPasswordCtrl.text != _confirmPasswordCtrl.text) {
      TopToast.show(context, 'Passwords do not match!', isError: true);
      return;
    }

    setState(() => _isLoading = true);

    try {
      await ref.read(apiProvider).resetPassword(
         email: _emailCtrl.text.trim(),
         otpCode: otp,
         newPassword: _newPasswordCtrl.text,
       );

      if (!mounted) return;
      setState(() => _isLoading = false);
      TopToast.show(context, 'Password Reset Successfully!');

      Navigator.pop(context);

    } catch (e) {
      setState(() => _isLoading = false);
      if (!mounted) return;
      TopToast.show(context, 'Invalid OTP or failed to reset.', isError: true);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: LoginColors.screenBackground,
      body: Stack(
        children: [
          // Background Shapes
          Positioned(top: -120, right: -80, child: const _NeumorphicBackgroundShape(size: 380)),
          Positioned(bottom: -150, left: -100, child: const _NeumorphicBackgroundShape(size: 450)),

          // Main Content
          SafeArea(
            child: Center(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 420),
                  child: _NeumorphicCard(
                    child: AnimatedSwitcher(
                      duration: const Duration(milliseconds: 300),
                      child: !_isOtpSent ? _buildEmailStep() : _buildOtpStep(),
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

  // ── UI: STEP 1 (EMAIL ENTRY) ──
  Widget _buildEmailStep() {
    return Column(
      key: const ValueKey('email_step'),
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 80, height: 80,
          decoration: BoxDecoration(
            color: LoginColors.cardBase, shape: BoxShape.circle,
            boxShadow: const [
              BoxShadow(color: Color(0xFFA3B1C6), offset: Offset(6, 6), blurRadius: 12),
              BoxShadow(color: Colors.white, offset: Offset(-6, -6), blurRadius: 12),
            ],
          ),
          child: const Center(child: Icon(Icons.lock_reset_rounded, size: 36, color: LoginColors.accent)),
        ),
        const SizedBox(height: 24),
        Text('Reset Password', style: GoogleFonts.dmSerifDisplay(fontSize: 32, color: LoginColors.textDark)),
        const SizedBox(height: 8),
        Text(
          'Enter your email address and we will send you an OTP to reset your password.',
          style: GoogleFonts.inter(fontSize: 14, color: LoginColors.textDark.withValues(alpha: 0.6)),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 32),
        Align(
          alignment: Alignment.centerLeft,
          child: Text('Email address', style: GoogleFonts.inter(fontSize: 13, fontWeight: FontWeight.w700, color: LoginColors.textDark.withValues(alpha: 0.8))),
        ),
        const SizedBox(height: 8),
        TextFormField(
          controller: _emailCtrl,
          keyboardType: TextInputType.emailAddress,
          style: GoogleFonts.inter(color: LoginColors.textDark, fontWeight: FontWeight.w600),
          decoration: InputDecoration(
            hintText: 'you@gmail.com',
            hintStyle: GoogleFonts.inter(color: LoginColors.textDark.withValues(alpha: 0.4)),
            prefixIcon: Icon(Icons.alternate_email_rounded, color: LoginColors.textDark.withValues(alpha: 0.5)),
            filled: true, fillColor: Colors.black.withValues(alpha: 0.04),
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: BorderSide.none),
          ),
        ),
        const SizedBox(height: 32),
        _buildActionButton('Send OTP', _isLoading, _sendResetLink),
        const SizedBox(height: 24),
        GestureDetector(
          onTap: () => Navigator.pop(context),
          child: Text('Back to Login', style: GoogleFonts.inter(fontSize: 14, fontWeight: FontWeight.bold, color: LoginColors.textDark.withValues(alpha: 0.6))),
        ),
      ],
    );
  }

  // ── UI: STEP 2 (OTP & NEW PASSWORD) ──
  Widget _buildOtpStep() {
    return Column(
      key: const ValueKey('otp_step'),
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 80, height: 80,
          decoration: BoxDecoration(
            color: LoginColors.cardBase, shape: BoxShape.circle,
            boxShadow: const [
              BoxShadow(color: Color(0xFFA3B1C6), offset: Offset(6, 6), blurRadius: 12),
              BoxShadow(color: Colors.white, offset: Offset(-6, -6), blurRadius: 12),
            ],
          ),
          child: const Center(child: Icon(Icons.mark_email_read_rounded, size: 36, color: LoginColors.accent)),
        ),
        const SizedBox(height: 24),
        Text('Check Your Email', style: GoogleFonts.dmSerifDisplay(fontSize: 32, color: LoginColors.textDark)),
        const SizedBox(height: 8),
        Text(
          'We sent a 6-digit OTP to\n${_emailCtrl.text}',
          style: GoogleFonts.inter(fontSize: 14, color: LoginColors.textDark.withValues(alpha: 0.6)),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 32),

        // 6-Digit OTP Boxes
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: List.generate(6, (index) {
            return SizedBox(
              width: 45, height: 55,
              child: TextField(
                controller: _otpControllers[index],
                focusNode: _otpFocusNodes[index],
                textAlign: TextAlign.center,
                keyboardType: TextInputType.number,
                maxLength: 1,
                style: GoogleFonts.inter(color: LoginColors.textDark, fontSize: 16, fontWeight: FontWeight.bold),
                decoration: InputDecoration(
                  counterText: "", filled: true, fillColor: Colors.black.withValues(alpha: 0.02),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(color: Colors.black.withValues(alpha: 0.05), width: 1.5),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: const BorderSide(color: LoginColors.accent, width: 2),
                  ),
                ),
                onChanged: (value) {
                  if (value.isNotEmpty && index < 5) _otpFocusNodes[index + 1].requestFocus();
                  if (value.isEmpty && index > 0) _otpFocusNodes[index - 1].requestFocus();
                },
              ),
            );
          }),
        ),
        const SizedBox(height: 24),

        _buildPasswordField(
          label: 'New Password',
          controller: _newPasswordCtrl,
          isHidden: _hideNewPass,
          onToggle: () => setState(() => _hideNewPass = !_hideNewPass),
        ),
        const SizedBox(height: 16),
        _buildPasswordField(
          label: 'Confirm Password',
          controller: _confirmPasswordCtrl,
          isHidden: _hideConfirmPass,
          onToggle: () => setState(() => _hideConfirmPass = !_hideConfirmPass),
        ),
        const SizedBox(height: 32),

        _buildActionButton('Update Password', _isLoading, _resetPassword),
        const SizedBox(height: 24),
        GestureDetector(
          onTap: () => setState(() => _isOtpSent = false),
          child: Text('Wrong email? Go back', style: GoogleFonts.inter(fontSize: 14, fontWeight: FontWeight.bold, color: AppColors.error)),
        ),
      ],
    );
  }

  Widget _buildPasswordField({
    required String label,
    required TextEditingController controller,
    required bool isHidden,
    required VoidCallback onToggle,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: GoogleFonts.inter(fontSize: 13, fontWeight: FontWeight.w700, color: LoginColors.textDark.withValues(alpha: 0.8)),
        ),
        const SizedBox(height: 8),
        TextFormField(
          controller: controller,
          obscureText: isHidden,
          style: GoogleFonts.inter(color: LoginColors.textDark, fontWeight: FontWeight.w600),
          decoration: InputDecoration(
            hintText: '••••••••',
            hintStyle: GoogleFonts.inter(color: LoginColors.textDark.withValues(alpha: 0.4)),
            prefixIcon: Icon(Icons.lock_outline_rounded, color: LoginColors.textDark.withValues(alpha: 0.5)),
            suffixIcon: GestureDetector(
              onTap: onToggle,
              child: Icon(
                isHidden ? Icons.visibility_off_rounded : Icons.visibility_rounded,
                color: LoginColors.textDark.withValues(alpha: 0.5),
                size: 20,
              ),
            ),
            filled: true, fillColor: Colors.black.withValues(alpha: 0.04),
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: BorderSide.none),
          ),
        ),
      ],
    );
  }

  // ── REUSABLE BUTTON ──
  Widget _buildActionButton(String text, bool loading, VoidCallback onTap) {
    return GestureDetector(
      onTap: loading ? null : onTap,
      child: Container(
        width: double.infinity, height: 56,
        decoration: BoxDecoration(
          color: LoginColors.accent, borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(color: LoginColors.accent.withValues(alpha: 0.50), offset: const Offset(6, 6), blurRadius: 12),
          ],
        ),
        child: Center(
          child: loading
              ? const SizedBox(width: 24, height: 24, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 3))
              : Text(text, style: GoogleFonts.inter(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white)),
        ),
      ),
    );
  }
}

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
          BoxShadow(color: const Color(0xFFA3B1C6).withValues(alpha: 0.5), offset: const Offset(18, 18), blurRadius: 40),
          BoxShadow(color: Colors.white.withValues(alpha: 0.7), offset: const Offset(-18, -18), blurRadius: 40),
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