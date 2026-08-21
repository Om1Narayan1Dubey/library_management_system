import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../theme/app_colors.dart';

class BgScaffold extends StatelessWidget {
  final Widget child;

  const BgScaffold({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: LoginColors.screenBackground, // Pure grey background
      body: Stack(
        children: [
          // ── THE MASTER BACKGROUND SHAPES ──
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

          // ── THE "PAINTING" GOES HERE ──
          // This slots whatever screen you are building right on top of the background!
          SafeArea(
            child: child,
          ),
        ],
      ),
    );
  }
}

// ── THE REUSABLE SHAPE BUILDER ──
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