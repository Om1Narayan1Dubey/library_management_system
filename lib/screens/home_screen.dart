// lib/screens/home_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/auth_provider.dart';

import 'admin/staff_home_screen.dart';
import 'student/student_home_screen.dart';


class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {

    final user = ref.watch(currentUserProvider);


    if (user == null) return const Scaffold(body: Center(child: CircularProgressIndicator()));

    final role = user['role'] ?? 'MEMBER';


    switch (role) {
      case 'ADMIN':
        return const StaffHomeScreen();
      case 'LIBRARIAN':
        return const StaffHomeScreen();
      default:
        return const StudentHomeScreen();
    }
  }
}