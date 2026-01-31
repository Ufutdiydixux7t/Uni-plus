import 'package:flutter/material.dart';
import '../auth/user_role.dart';
import '../storage/secure_storage_service.dart';
import 'app_routes.dart';

class NavigationService {
  static final navigatorKey = GlobalKey<NavigatorState>();

  static NavigatorState get _nav => navigatorKey.currentState!;

  // ================= ROLE BASED NAV =================

  static Future<void> goToHomeByRole() async {
    final role = await SecureStorageService.getUserRole();

    switch (role) {
      case UserRole.student:
        _nav.pushReplacementNamed(AppRoutes.homeStudent);
        break;
      case UserRole.delegate:
        _nav.pushReplacementNamed(AppRoutes.homeDelegate);
        break;
      case UserRole.admin:
      // لاحقًا
        break;
    }
  }

  // ================= GENERIC =================

  static void replace(String route) {
    _nav.pushReplacementNamed(route);
  }

  static void logout() async {
    await SecureStorageService.clearUser();
    _nav.pushNamedAndRemoveUntil(
      AppRoutes.roleSelection,
          (_) => false,
    );
  }
}