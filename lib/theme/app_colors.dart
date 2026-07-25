import 'package:flutter/material.dart';

// 🟩🟩🟩 1. GLOBAL COLORS 🟩🟩🟩

class AppColors {
  AppColors._();

  static const Color error        = Color(0xFFFF3B30);
  static const Color errorSoft    = Color(0xFFFFCDD2); // error text on dark bg
  static const Color success      = Color(0xFF34C759);
  static const Color warning      = Color(0xFFFF9500);
  static const Color pureWhite    = Color(0xFFFFFFFF);
  static const Color pureBlack    = Color(0xFF000000);
}

// 🟨🟨🟨 2. ADMIN PALETTE 🟨🟨🟨
class AdminColors {
  AdminColors._();

  // ── Backgrounds ──────────────────────────────────────────
  static const Color bgDark       = Color(0xFF1C1C26); // Main background
  static const Color bgCard       = Color(0xFF1A1A2E); // Login / card surface
  static const Color dialogBg     = Color(0xFF1E1E2E); // Popup background

  // ── Accents ───────────────────────────────────────────────
  static const Color purple   = Color(0xFF6C63FF);
}

// 🟦🟦🟦 3. LIBRARIAN / STAFF PALETTE 🟦🟦🟦
class StaffColors {
  StaffColors._();

  static const Color bgLight      = Color(0xFFF5F6FA); // Light grey workspace
  static const Color primaryBlue  = Color(0xFF0984E3); // Professional blue
  static const Color textMain     = Color(0xFF2D3436); // Dark reading text
}

// 🟪🟪🟪 4. MEMBER / STUDENT PALETTE 🟪🟪🟪
class MemberColors {
  MemberColors._();

  static const Color bgWhite      = Color(0xFFBDB9B9); // Clean white
  static const Color primaryTheme = Color(0xFF6C5CE7); // Modern purple
  static const Color textSub      = Color(0xFF636E72); // Subtitle grey
}

// 🟦🟦🟦 NEUMORPHISM PALETTE 🟦🟦🟦
class LoginColors {
  LoginColors._();

  // The Golden Rule: Background and Card Base MUST match exactly
  static const Color screenBackground = Color(0xFFE0E7EA);
  static const Color cardBase         = Color(0xFFE0E5EC);
  static const Color textDark = Color(0xFF2D3142);
  static const Color accent   = Color(0xFF6C63FF);
}