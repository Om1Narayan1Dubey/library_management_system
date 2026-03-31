import 'package:flutter/material.dart';

// ═══════════════════════════════════════════════════════
//  background_widget.dart
//
//  THIS IS THE ONLY FILE YOU NEED TO EDIT FOR THE BG.
//
//  HOW TO USE YOUR OWN IMAGE (background.png):
//  ─────────────────────────────────────────────
//  Step 1 → Create folder:  assets/images/
//            inside your project root (same level as lib/)
//
//  Step 2 → Copy your file there:
//            assets/images/background.png
//
//  Step 3 → Open pubspec.yaml, add under flutter:
//              assets:
//                - assets/images/background.png
//
//  Step 4 → Run:  flutter pub get
//
//  Step 5 → In THIS file, comment out _PaintedBackground()
//            and uncomment _ImageBackground()  (see below)
//
//  Step 6 → Hot restart the app
// ═══════════════════════════════════════════════════════

class BackgroundWidget extends StatelessWidget {
  const BackgroundWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return const _ImageBackground();   // ← default: painted sky
    // return const _ImageBackground();  // ← uncomment when image is ready
  }
}

// ───────────────────────────────────────────────────────
//  Option A — Painted sky (works with zero setup)
// ───────────────────────────────────────────────────────
class _PaintedBackground extends StatelessWidget {
  const _PaintedBackground();

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      painter: _SkyPainter(),
      child: const SizedBox.expand(),
    );
  }
}

class _SkyPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final w = size.width;
    final h = size.height;

    // Sky gradient — deep midnight blue → pale horizon
    canvas.drawRect(
      Rect.fromLTWH(0, 0, w, h),
      Paint()
        ..shader = const LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            Color(0xFF0D1B4B),
            Color(0xFF1A3A8C),
            Color(0xFF2979C8),
            Color(0xFF64A8E0),
            Color(0xFFB8D9F0),
          ],
          stops: [0.0, 0.25, 0.52, 0.78, 1.0],
        ).createShader(Rect.fromLTWH(0, 0, w, h)),
    );

    // Stars
    final starPaint = Paint()..color = const Color(0xCCFFFFFF);
    for (final p in [
      Offset(w * 0.07, h * 0.04), Offset(w * 0.22, h * 0.02),
      Offset(w * 0.45, h * 0.06), Offset(w * 0.63, h * 0.03),
      Offset(w * 0.80, h * 0.07), Offset(w * 0.92, h * 0.02),
      Offset(w * 0.15, h * 0.11), Offset(w * 0.37, h * 0.13),
      Offset(w * 0.71, h * 0.09), Offset(w * 0.55, h * 0.15),
    ]) {
      canvas.drawCircle(p, 1.4, starPaint);
    }

    // Cloud layers (bottom half of screen)
    _cloud(canvas, Offset(-w * 0.06, h * 0.63), w * 0.82, h * 0.17,
        const Color(0xEEFFFFFF));
    _cloud(canvas, Offset(w * 0.08, h * 0.55), w * 0.60, h * 0.14,
        const Color(0xDDFFFFFF));
    _cloud(canvas, Offset(w * 0.40, h * 0.48), w * 0.70, h * 0.12,
        const Color(0xCCFFFFFF));
    _cloud(canvas, Offset(w * 0.52, h * 0.38), w * 0.52, h * 0.10,
        const Color(0xAAFFFFFF));

    // Bottom white haze
    canvas.drawRect(
      Rect.fromLTWH(0, h * 0.75, w, h * 0.25),
      Paint()
        ..shader = LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            Colors.white.withValues(alpha: 0.0),
            Colors.white.withValues(alpha: 0.85),
          ],
        ).createShader(Rect.fromLTWH(0, h * 0.75, w, h * 0.25)),
    );
  }

  void _cloud(Canvas canvas, Offset o, double cw, double ch, Color color) {
    final p  = Paint()..color = color;
    final rw = cw / 2;
    final rh = ch / 2;
    for (final r in [
      Rect.fromCenter(center: o, width: cw, height: ch),
      Rect.fromCenter(
          center: Offset(o.dx - rw * 0.28, o.dy - rh * 0.42),
          width: cw * 0.50, height: ch * 1.12),
      Rect.fromCenter(
          center: Offset(o.dx + rw * 0.12, o.dy - rh * 0.56),
          width: cw * 0.56, height: ch * 1.22),
      Rect.fromCenter(
          center: Offset(o.dx + rw * 0.54, o.dy - rh * 0.28),
          width: cw * 0.44, height: ch * 1.02),
      Rect.fromCenter(
          center: Offset(o.dx - rw * 0.66, o.dy),
          width: cw * 0.36, height: ch * 0.88),
    ]) {
      canvas.drawOval(r, p);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter old) => false;
}

// ───────────────────────────────────────────────────────
//  Option B — Your own background.png
//  Uncomment BackgroundWidget.build() return above
// ───────────────────────────────────────────────────────
class _ImageBackground extends StatelessWidget {
  const _ImageBackground();

  @override
  Widget build(BuildContext context) {
    return Image.asset(
      'assets/images/background.png',
      fit: BoxFit.cover,
      width: double.infinity,
      height: double.infinity,
    );
  }
}