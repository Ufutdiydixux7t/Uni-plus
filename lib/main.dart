import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:supabase_flutter/supabase_flutter.dart'; // Added for Supabase initialization

import 'core/auth/user_role.dart';
import 'core/storage/secure_storage_service.dart';
import 'core/providers/locale_provider.dart';
import 'core/navigation/app_routes.dart';
import 'core/localization/app_localizations.dart';
import 'features/auth/role_selection/role_selection_screen.dart';
import 'features/daily_feed/daily_feed_screen.dart';
import 'features/admin_dashboard/admin_dashboard_screen.dart';
import 'features/auth/splash/splash_screen.dart';
import 'features/auth/login_delegate_screen.dart'; // New: Delegate Login Screen

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Supabase Initialization (Phase 1)
  // Reverting to the public Anon Key as requested by the user.
  // NOTE: Row Level Security (RLS) must be configured on the 'grades' table and 'grades' storage bucket
  // to allow authenticated users (delegates) to perform INSERT and UPLOAD operations.
  await Supabase.initialize(
    url: 'https://gvazzaxlekapzwztfowg.supabase.co',
    anonKey: 'sb_publishable_VSYDHkYftsuw_9SkAz2V8Q_sWncNSQU', // Reverted to Anon Key
  );

  runApp(
    const ProviderScope(
      child: UniPlusApp(),
    ),
  );
}

class UniPlusApp extends ConsumerWidget {
  const UniPlusApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final locale = ref.watch(localeProvider);

    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Uni Plus',
      theme: ThemeData(
        useMaterial3: false,
        primarySwatch: Colors.indigo,
        scaffoldBackgroundColor: const Color(0xFFF6F7FB),
        fontFamily: 'Roboto',
        // Correctly using cardTheme with CardTheme (which is the data class in Flutter)
        cardTheme: const CardThemeData(
          elevation: 2,
          margin: EdgeInsets.zero,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.all(Radius.circular(12)),
          ),
        ),
      ),
      locale: locale,
      localizationsDelegates: const [
        AppLocalizations.delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      supportedLocales: const [
        Locale('en'),
        Locale('ar'),
      ],
      routes: {
        AppRoutes.roleSelection: (context) => const RoleSelectionScreen(),
        AppRoutes.homeStudent: (context) => const DailyFeedScreen(),
        AppRoutes.homeDelegate: (context) => const AdminDashboardScreen(),
        AppRoutes.loginDelegate: (context) => const LoginDelegateScreen(), // New route
      },
      home: const SplashScreen(),
    );
  }
}

class Bootstrap extends StatelessWidget {
  const Bootstrap({super.key});

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
