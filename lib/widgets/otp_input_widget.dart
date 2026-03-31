import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class OtpInputWidget extends StatefulWidget {
  final void Function(String otp) onCompleted;
  final void Function(String)? onChanged;

  const OtpInputWidget({
    super.key,
    required this.onCompleted,
    this.onChanged,
  });

  @override
  State<OtpInputWidget> createState() => _OtpInputWidgetState();
}

class _OtpInputWidgetState extends State<OtpInputWidget> {
  static const int _len = 6;
  late final List<TextEditingController> _ctrl;
  late final List<FocusNode> _focus;

  @override
  void initState() {
    super.initState();
    _ctrl  = List.generate(_len, (_) => TextEditingController());
    _focus = List.generate(_len, (_) => FocusNode());
  }

  @override
  void dispose() {
    for (final c in _ctrl)  c.dispose();
    for (final f in _focus) f.dispose();
    super.dispose();
  }

  String get _otp => _ctrl.map((c) => c.text).join();

  void _onType(String value, int i) {
    if (value.length == 1) {
      if (i < _len - 1) {
        _focus[i + 1].requestFocus();
      } else {
        _focus[i].unfocus();
        widget.onCompleted(_otp);
      }
    }
    widget.onChanged?.call(_otp);
  }

  void _onKey(KeyEvent e, int i) {
    if (e is KeyDownEvent &&
        e.logicalKey == LogicalKeyboardKey.backspace &&
        _ctrl[i].text.isEmpty &&
        i > 0) {
      _focus[i - 1].requestFocus();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: List.generate(_len, (i) {
        return SizedBox(
          width: 44, height: 52,
          child: KeyboardListener(
            focusNode: FocusNode(),
            onKeyEvent: (e) => _onKey(e, i),
            child: TextField(
              controller: _ctrl[i],
              focusNode: _focus[i],
              textAlign: TextAlign.center,
              keyboardType: TextInputType.number,
              maxLength: 1,
              style: const TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w700,
                color: Colors.white,
              ),
              decoration: InputDecoration(
                counterText: '',
                filled: true,
                fillColor: Colors.white.withValues(alpha: 0.18),
                contentPadding: EdgeInsets.zero,
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                  borderSide: BorderSide(
                    color: Colors.white.withValues(alpha: 0.40),
                    width: 1.2,
                  ),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                  borderSide: const BorderSide(
                    color: Colors.white, width: 2,
                  ),
                ),
              ),
              inputFormatters: [FilteringTextInputFormatter.digitsOnly],
              onChanged: (v) => _onType(v, i),
            ),
          ),
        );
      }),
    );
  }
}