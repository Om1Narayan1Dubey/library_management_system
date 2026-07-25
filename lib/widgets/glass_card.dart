import 'package:flutter/material.dart';

// Frosted-glass card. No BackdropFilter (causes Windows crashes).
// Glass effect via layered gradient + border + shadow.
class GlassCard extends StatelessWidget {
  final Widget child;
  const GlassCard({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 28),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(24),
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Colors.black.withValues(alpha: 0.62),
            Colors.grey.withValues(alpha: 0.42),
          ],
        ),
        border: Border.all(
          color: Colors.white.withValues(alpha: 0.70),
          width: 1.2,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.35),
            blurRadius: 70,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: child,
    );
  }
}