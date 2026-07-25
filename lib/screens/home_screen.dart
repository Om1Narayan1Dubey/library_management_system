import 'package:flutter/material.dart';
import 'admin/admin_home_screen.dart';
import 'staff/staff_home_screen.dart';
import 'student/student_home_screen.dart';

class HomeScreen extends StatelessWidget {
  final String username;
  final String role;
  final String email;

  const HomeScreen({
    super.key,
    required this.username,
    required this.role,
    required this.email,
  });

  @override
  Widget build(BuildContext context) {
    switch (role) {
      case 'ADMIN':
        return AdminHomeScreen(
          username: username,
          email: email,
        );
      case 'LIBRARIAN':
        return StaffHomeScreen(
          username: username,
          email: email,
        );
      default:
        return StudentHomeScreen(
          username: username,
          email: email,
        );
    }
  }
}