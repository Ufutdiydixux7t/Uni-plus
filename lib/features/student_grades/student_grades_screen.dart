import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/auth/user_role.dart';
import '../grades/grades_list_screen.dart'; // Import the new GradesListScreen

class StudentGradesScreen extends ConsumerWidget {
  const StudentGradesScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Simply redirect to the unified GradesListScreen for the student role
    return const GradesListScreen(userRole: UserRole.student);
  }
}
