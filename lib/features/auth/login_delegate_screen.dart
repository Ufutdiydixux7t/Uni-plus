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
  bool _isSignUpMode = false; // Toggle between Login and Sign Up

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _handleAuth() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      if (_isSignUpMode) {
        // --- SIGN UP LOGIC ---
        final AuthResponse response = await supabase.auth.signUp(
          email: _emailController.text.trim(),
          password: _passwordController.text.trim(),
        );

        final user = response.user;
        if (user == null) throw const AuthException('Sign up failed.');

        // Create profile row in 'profiles' table
        await supabase.from('profiles').insert({
          'id': user.id,
          'email': user.email,
          'role': 'delegate',
          'join_code': '',
          'created_at': DateTime.now().toIso8601String(),
          'name': user.email?.split('@').first ?? 'Delegate', // Default name from email
        });

        // After sign up, Supabase usually signs in automatically or requires confirmation.
        // We proceed to save local state and navigate.
        await _onAuthSuccess(user.id, 'delegate', user.email?.split('@').first ?? 'Delegate');

      } else {
        // --- SIGN IN LOGIC ---
        final AuthResponse response = await supabase.auth.signInWithPassword(
          email: _emailController.text.trim(),
          password: _passwordController.text.trim(),
        );

        final user = response.user;
        if (user == null) throw const AuthException('Sign in failed.');

        // Fetch profile to verify role
        final List<Map<String, dynamic>> profiles = await supabase
            .from('profiles')
            .select('role, name')
            .eq('id', user.id)
            .limit(1);

        if (profiles.isEmpty) throw const AuthException('Profile not found.');

        final String role = profiles.first['role'] as String;
        final String name = profiles.first['name'] as String;

        if (role != 'delegate' && role != 'admin') {
          await supabase.auth.signOut();
          throw const AuthException('Access denied: You are not a delegate.');
        }

        await _onAuthSuccess(user.id, role, name);
      }
    } on AuthException catch (error) {
      _showErrorDialog(error.message);
    } catch (error) {
      _showErrorDialog('An error occurred: ${error.toString()}');
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  Future<void> _onAuthSuccess(String userId, String role, String name) async {
    final userRole = role == 'admin' ? UserRole.admin : UserRole.delegate;
    
    await SecureStorageService.saveUser(
      role: userRole,
      name: name,
    );

    if (!mounted) return;

    Navigator.pushNamedAndRemoveUntil(
      context,
      AppRoutes.homeDelegate,
      (route) => false,
    );
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
                  textAlign: TextAlign.center,
                  style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: primaryColor),
                ),
                const SizedBox(height: 40),
                _inputField(
                  controller: _emailController,
                  label: l10n.email,
                  icon: Icons.email_outlined,
                  validator: (value) {
                    if (value == null || value.isEmpty) return l10n.emailRequired;
                    return null;
                  },
                ),
                const SizedBox(height: 20),
                _inputField(
                  controller: _passwordController,
                  label: l10n.password,
                  icon: Icons.lock_outline,
                  isPassword: true,
                  validator: (value) {
                    if (value == null || value.isEmpty) return l10n.passwordRequired;
                    return null;
                  },
                ),
                const SizedBox(height: 40),
                // Main Action Button (Sign In or Sign Up)
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
                    onPressed: _isLoading ? null : _handleAuth,
                    child: _isLoading
                        ? const CircularProgressIndicator(color: Colors.white)
                        : Text(
                            _isSignUpMode ? l10n.createAccount : l10n.signIn,
                            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                          ),
                  ),
                ),
                const SizedBox(height: 20),
                // Toggle Button
                TextButton(
                  onPressed: () {
                    setState(() {
                      _isSignUpMode = !_isSignUpMode;
                    });
                  },
                  child: Text(
                    _isSignUpMode ? l10n.haveAccount : l10n.createAccount,
                    style: const TextStyle(color: primaryColor, fontWeight: FontWeight.w600),
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
