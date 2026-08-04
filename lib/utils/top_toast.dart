import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../theme/app_colors.dart';

class TopToast {
  static OverlayEntry? _currentOverlay;

  static void show(BuildContext context, String message, {bool isError = false}) {
    if (_currentOverlay != null && _currentOverlay!.mounted) {
      _currentOverlay!.remove();
    }

    final overlay = Overlay.of(context);
    late OverlayEntry overlayEntry;

    overlayEntry = OverlayEntry(
      builder: (context) => Positioned(
        // Drop it safely below the device's top status bar (battery/wifi icons)
        top: MediaQuery.of(context).padding.top + 20,
        left: 0, right: 0,
        child: Material(
          color: Colors.transparent,
          child: Align(
            alignment: Alignment.topCenter, // Forces it to the absolute center
            child: TweenAnimationBuilder<double>(
              // 2. THE ANIMATION: Slide it down from -100 pixels above!
              tween: Tween(begin: -100.0, end: 0.0),
              duration: const Duration(milliseconds: 400),
              curve: Curves.easeOutBack, // Gives it a nice "bouncy" pop down
              builder: (context, value, child) {
                return Transform.translate(
                  offset: Offset(0, value),
                  child: ConstrainedBox(
                    // 3. RESPONSIVE: Half-size on large screens, slightly wider on mobile to fit text
                    constraints: BoxConstraints(
                      maxWidth: MediaQuery.of(context).size.width > 600
                          ? MediaQuery.of(context).size.width * 0.4
                          : MediaQuery.of(context).size.width * 0.8,
                    ),
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                      decoration: BoxDecoration(
                        // Red for errors, beautiful Neumorphic card for successes
                        color: isError ? AppColors.error : LoginColors.cardBase,
                        borderRadius: BorderRadius.circular(24),
                        // 4. Your signature Neumorphic shadows!
                        boxShadow: [
                          BoxShadow(
                            color: const Color(0xFFA3B1C6).withValues(alpha: 0.5),
                            offset: const Offset(6, 6), blurRadius: 12,
                          ),
                          const BoxShadow(
                            color: Colors.white,
                            offset: Offset(-6, -6), blurRadius: 12,
                          ),
                        ],
                      ),
                      child: Text(
                        message,
                        textAlign: TextAlign.center,
                        style: GoogleFonts.inter(
                          color: isError ? Colors.white : LoginColors.textDark,
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
        ),
      ),
    );

    // Save it to our tracker and inject it onto the screen
    _currentOverlay = overlayEntry;
    overlay.insert(overlayEntry);

    // 5. Wait exactly 3 seconds, then gracefully remove it
    Future.delayed(const Duration(seconds: 3), () {
      if (overlayEntry.mounted && _currentOverlay == overlayEntry) {
        overlayEntry.remove();
      }
    });
  }
}