import 'package:flutter/material.dart';
import '../../core/auth/user_role.dart';
import 'student_register/student_register_screen.dart';
import 'delegate_setup/delegate_setup_screen.dart';

// This is a temporary routing screen. 
// The actual login logic will be implemented based on the final UI design.
class LoginScreen extends StatelessWidget {
  final UserRole role;
  const LoginScreen({super.key, required this.role});

  @override
  Widget build(BuildContext context) {
    if (role == UserRole.student) {
      return const StudentRegisterScreen();
    } else {
      return const DelegateSetupScreen();
    }
  }
}
