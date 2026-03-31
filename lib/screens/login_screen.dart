import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../theme/app_theme.dart';
import '../utils/validators.dart';
import '../widgets/bg_scaffold.dart';
import '../widgets/glass_card.dart';
import 'register_screen.dart';
import 'home_screen.dart';

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
    await Future.delayed(const Duration(milliseconds: 1400));
    if (!mounted) return;
    setState(() => _loading = false);
    Navigator.of(context).pushReplacement(
      MaterialPageRoute(builder: (_) => const HomeScreen()),
    );
  }

  void _goRegister() {
    Navigator.of(context).push(
      MaterialPageRoute(builder: (_) => const RegisterScreen()),
    );
  }

  @override
  Widget build(BuildContext context) {
    return BgScaffold(
      child: SingleChildScrollView(
        keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
        child: Padding(
          padding: EdgeInsets.only(
            left: 24, right: 24,
            top: MediaQuery.of(context).size.height * 0.10,
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

                      // ── App icon ───────────────────
                      _Icon(),
                      const SizedBox(height: 16),

                      // ── Title ──────────────────────
                      Text('Welcome back',
                        style: GoogleFonts.dmSerifDisplay(
                          fontSize: 26, color: Colors.white,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Please enter your detail to sign in.',
                        style: GoogleFonts.inter(
                          fontSize: 13,
                          color: Colors.white.withValues(alpha: 0.75),
                        ),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 22),

                      // ── Social row ─────────────────
                      _SocialRow(),
                      const SizedBox(height: 16),
                      _OrDivider(),
                      const SizedBox(height: 16),

                      // ── Email ──────────────────────
                      _FieldLabel('E-Mail Address'),
                      const SizedBox(height: 6),
                      TextFormField(
                        controller: _emailCtrl,
                        keyboardType: TextInputType.emailAddress,
                        textInputAction: TextInputAction.next,
                        autocorrect: false,
                        validator: Validators.email,
                        style: _inputTextStyle,
                        decoration: _dec(hint: 'Enter your email...'),
                      ),
                      const SizedBox(height: 14),

                      // ── Password ───────────────────
                      _FieldLabel('Password'),
                      const SizedBox(height: 6),
                      TextFormField(
                        controller: _passwordCtrl,
                        obscureText: _hidePass,
                        textInputAction: TextInputAction.done,
                        onFieldSubmitted: (_) => _login(),
                        validator: Validators.password,
                        style: _inputTextStyle,
                        decoration: _dec(
                          hint: 'Password@123',
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
                      const SizedBox(height: 12),

                      // ── Remember + Forgot ──────────
                      Row(
                        children: [
                          SizedBox(
                            width: 20, height: 20,
                            child: Checkbox(
                              value: _remember,
                              onChanged: (v) =>
                                  setState(() => _remember = v ?? false),
                              activeColor: Colors.white,
                              checkColor: AppColors.btnDark,
                              side: BorderSide(
                                color: Colors.white.withValues(alpha: 0.55),
                                width: 1.5,
                              ),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(4),
                              ),
                            ),
                          ),
                          const SizedBox(width: 8),
                          Text('Remember me',
                            style: GoogleFonts.inter(
                              fontSize: 13,
                              color: Colors.white.withValues(alpha: 0.80),
                            ),
                          ),
                          const Spacer(),
                          TextButton(
                            onPressed: () {},
                            style: TextButton.styleFrom(
                              padding: EdgeInsets.zero,
                              minimumSize: const Size(10, 36),
                              tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                              foregroundColor: Colors.white70,
                            ),
                            child: Text('Forgot password?',
                              style: GoogleFonts.inter(
                                fontSize: 13,
                                color: Colors.white.withValues(alpha: 0.80),
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 20),

                      // ── Sign in button ─────────────
                      SizedBox(
                        width: double.infinity, height: 50,
                        child: ElevatedButton(
                          onPressed: _loading ? null : _login,
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
                              : Text('Sign in',
                              style: GoogleFonts.inter(
                                fontSize: 15,
                                fontWeight: FontWeight.w600,
                              )),
                        ),
                      ),
                      const SizedBox(height: 16),

                      // ── Register link ──────────────
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text("Don't have an account yet? ",
                            style: GoogleFonts.inter(
                              fontSize: 13,
                              color: Colors.white.withValues(alpha: 0.75),
                            ),
                          ),
                          TextButton(
                            onPressed: _goRegister,
                            style: TextButton.styleFrom(
                              padding: const EdgeInsets.only(left: 2),
                              minimumSize: const Size(10, 36),
                              tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                              foregroundColor: Colors.white,
                            ),
                            child: Text('Sign up',
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

// ── Shared input style ───────────────────────
TextStyle get _inputTextStyle => GoogleFonts.inter(
  fontSize: 14, color: Colors.white,
);

InputDecoration _dec({required String hint, Widget? suffix}) {
  return InputDecoration(
    hintText: hint,
    hintStyle: GoogleFonts.inter(
      fontSize: 14, color: Colors.white.withValues(alpha: 0.40),
    ),
    suffixIcon: suffix,
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

// ── Small shared widgets ─────────────────────
class _Icon extends StatelessWidget {
  @override
  Widget build(BuildContext context) => Container(
    width: 56, height: 56,
    decoration: BoxDecoration(
      color: Colors.white.withValues(alpha: 0.22),
      borderRadius: BorderRadius.circular(16),
      border: Border.all(color: Colors.white.withValues(alpha: 0.48)),
    ),
    child: const Center(child: Text('📚', style: TextStyle(fontSize: 28))),
  );
}

class _FieldLabel extends StatelessWidget {
  final String text;
  const _FieldLabel(this.text);
  @override
  Widget build(BuildContext context) => Align(
    alignment: Alignment.centerLeft,
    child: Text(text,
      style: GoogleFonts.inter(
        fontSize: 13, fontWeight: FontWeight.w600, color: Colors.white,
      ),
    ),
  );
}

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