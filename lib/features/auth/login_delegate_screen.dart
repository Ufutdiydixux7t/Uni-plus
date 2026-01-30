import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../../core/localization/app_localizations.dart';
import '../../../core/navigation/app_routes.dart';
import '../../../core/providers/locale_provider.dart';
import '../../../core/storage/secure_storage_service.dart';
import '../../../core/auth/user_role.dart';

// Helper to access Supabase client
final supabase = Supabase.instance.client;

class LoginDelegateScreen extends ConsumerStatefulWidget {
  const LoginDelegateScreen({super.key});

  @override
  ConsumerState<LoginDelegateScreen> createState() => _LoginDelegateScreenState();
}

class _LoginDelegateScreenState extends ConsumerState<LoginDelegateScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _isLoading = false;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _signIn() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      // 1. Supabase Auth Sign In
      final AuthResponse response = await supabase.auth.signInWithPassword(
        email: _emailController.text.trim(),
        password: _passwordController.text.trim(),
      );

      final user = response.user;

      if (user == null) {
        throw const AuthException('User is null after sign in.');
      }

      // 2. Fetch user profile from 'profiles' table
      final List<Map<String, dynamic>> profiles = await supabase
          .from('profiles')
          .select('role, name')
          .eq('id', user.id)
          .limit(1);

      if (profiles.isEmpty) {
        throw const AuthException('Profile not found.');
      }

      final String role = profiles.first['role'] as String;
      final String name = profiles.first['name'] as String;

      // 3. Role Check
      if (role != 'delegate' && role != 'admin') {
        // If not a delegate or admin, sign out and show error
        await supabase.auth.signOut();
        throw const AuthException('Access denied: You are not a delegate or admin.');
      }

      // 4. Successful Login: Save user data and navigate
      final userRole = role == 'admin' ? UserRole.admin : UserRole.delegate;
      
      await SecureStorageService.saveUser(
        role: userRole,
        name: name,
      );

      if (!mounted) return;

      // Navigate to Delegate/Admin Home Screen
      Navigator.pushNamedAndRemoveUntil(
        context,
        AppRoutes.homeDelegate,
        (route) => false,
      );

    } on AuthException catch (error) {
      _showErrorDialog(error.message);
    } catch (error) {
      _showErrorDialog('An unexpected error occurred: ${error.toString()}');
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  void _showErrorDialog(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.red,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    // Primary color from main.dart: Colors.indigo (0xFF3F51B5)
    const primaryColor = Color(0xFF3F51B5);

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.transparent,
        foregroundColor: primaryColor,
        actions: [
          IconButton(
            icon: const Icon(Icons.language),
            onPressed: () => ref.read(localeProvider.notifier).toggleLocale(),
          ),
        ],
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          padding: const EdgeInsets.symmetric(horizontal: 30),
          child: Form(
            key: _formKey,
            child: Column(
              children: [
                const SizedBox(height: 20),
                Image.asset('assets/icons/uniplus_icon1.png', height: 100),
                const SizedBox(height: 24),
                Text(
                  l10n.delegateLogin,
                  style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: primaryColor),
                ),
                const SizedBox(height: 40),
                // Email Field
                _inputField(
                  controller: _emailController,
                  label: l10n.email,
                  icon: Icons.email_outlined,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return l10n.emailRequired;
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 20),
                // Password Field
                _inputField(
                  controller: _passwordController,
                  label: l10n.password,
                  icon: Icons.lock_outline,
                  isPassword: true,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return l10n.passwordRequired;
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 40),
                // Login Button
                SizedBox(
                  width: double.infinity,
                  height: 55,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: primaryColor,
                      foregroundColor: Colors.white,
                      elevation: 0,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                    ),
                    onPressed: _isLoading ? null : _signIn,
                    child: _isLoading
                        ? const CircularProgressIndicator(color: Colors.white)
                        : Text(
                            l10n.signIn,
                            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                          ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _inputField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    bool isPassword = false,
    String? Function(String?)? validator,
  }) {
    const primaryColor = Color(0xFF3F51B5);
    return TextFormField(
      controller: controller,
      obscureText: isPassword,
      validator: validator,
      decoration: InputDecoration(
        prefixIcon: Icon(icon, size: 22, color: primaryColor),
        labelText: label,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
      ),
    );
  }
}
