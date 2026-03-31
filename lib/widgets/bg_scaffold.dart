import 'package:flutter/material.dart';
import 'background_widget.dart';

// BgScaffold wraps every screen with the background.
// To change the background edit background_widget.dart only.
class BgScaffold extends StatelessWidget {
  final Widget child;
  const BgScaffold({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0D1B4B),
      body: Stack(
        fit: StackFit.expand,
        children: [
          const BackgroundWidget(),
          SafeArea(child: child),
        ],
      ),
    );
  }
}