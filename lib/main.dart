import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'core/auth/user_role.dart';
import 'core/storage/secure_storage_service.dart';
import 'features/auth/role_selection/role_selection_screen.dart';
import 'features/daily_feed/daily_feed_screen.dart';
import 'features/admin_dashboard/admin_dashboard_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  runApp(
    const ProviderScope(
      child: UniPlusApp(),
    ),
  );
}

class UniPlusApp extends StatelessWidget {
  const UniPlusApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Uni Plus',
      theme: ThemeData(
        useMaterial3: false,
        scaffoldBackgroundColor: const Color(0xFFF6F7FB),
        fontFamily: 'Roboto',
      ),
      home: const _Bootstrap(),
    );
  }
}

///
/// يقرر أول شاشة حسب حالة المستخدم
///
class _Bootstrap extends StatelessWidget {
  const _Bootstrap();

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<UserRole>(
      future: SecureStorageService.getUserRole(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }

        final role = snapshot.data;

        switch (role) {
          case UserRole.student:
            return const DailyFeedScreen();

          case UserRole.delegate:
          case UserRole.admin:
            return const AdminDashboardScreen();

          default:
            return const RoleSelectionScreen();
        }
      },
    );
  }
}