import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/storage/secure_storage_service.dart';
import '../../core/auth/user_role.dart';
import 'tomorrow_lecture_list_screen.dart'; // Import the new list screen

class TomorrowLecturesScreen extends ConsumerWidget {
  const TomorrowLecturesScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return FutureBuilder<UserRole>(
      future: SecureStorageService.getUserRole(),
      builder: (context, snapshot) {
        final role = snapshot.data ?? UserRole.student;
        
        // Use the new TomorrowLectureListScreen which handles the UI logic
        return TomorrowLectureListScreen(userRole: role);
      },
    );
  }
}
