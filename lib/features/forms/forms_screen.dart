import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/storage/secure_storage_service.dart';
import '../../core/auth/user_role.dart';
import 'form_list_screen.dart'; // Import the new list screen

class FormsScreen extends ConsumerWidget {
  const FormsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return FutureBuilder<UserRole>(
      future: SecureStorageService.getUserRole(),
      builder: (context, snapshot) {
        final role = snapshot.data ?? UserRole.student;
        
        // Use the new FormListScreen which handles the UI logic
        return FormListScreen(userRole: role);
      },
    );
  }
}
