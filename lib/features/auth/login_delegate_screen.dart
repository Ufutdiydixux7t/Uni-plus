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
          'name': user.email?.split('@').first ?? 'Delegate',
        });

        await _onAuthSuccess(user.id, 'delegate', user.email?.split('@').first ?? 'Delegate');

      } else {
        // --- SIGN IN LOGIC ---
        final AuthResponse response = await supabase.auth.signInWithPassword(
          email: _emailController.text.trim(),
          password: _passwordController.text.trim(),
        );

        final user = response.user;
        if (user == null) throw const AuthException('Sign in failed.');

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
    const accentColor = Color(0xFF5C6BC0); // Slightly lighter indigo for Sign Up mode

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.transparent,
        foregroundColor: _isSignUpMode ? accentColor : primaryColor,
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
                const SizedBox(height: 10),
                // Animated Switcher for the Icon/Header to make it feel different
                AnimatedSwitcher(
                  duration: const Duration(milliseconds: 500),
                  child: Column(
                    key: ValueKey<bool>(_isSignUpMode),
                    children: [
                      Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: (_isSignUpMode ? accentColor : primaryColor).withOpacity(0.1),
                          shape: BoxShape.circle,
                        ),
                        child: Icon(
                          _isSignUpMode ? Icons.person_add_outlined : Icons.login_outlined,
                          size: 60,
                          color: _isSignUpMode ? accentColor : primaryColor,
                        ),
                      ),
                      const SizedBox(height: 20),
                      Text(
                        _isSignUpMode ? l10n.createAccount : l10n.signIn,
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 26, 
                          fontWeight: FontWeight.bold, 
                          color: _isSignUpMode ? accentColor : primaryColor
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 40),
                _inputField(
                  controller: _emailController,
                  label: l10n.email,
                  icon: Icons.email_outlined,
                  activeColor: _isSignUpMode ? accentColor : primaryColor,
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
                  activeColor: _isSignUpMode ? accentColor : primaryColor,
                  validator: (value) {
                    if (value == null || value.isEmpty) return l10n.passwordRequired;
                    if (_isSignUpMode && value.length < 6) return 'Password must be at least 6 characters';
                    return null;
                  },
                ),
                const SizedBox(height: 40),
                // Main Action Button
                SizedBox(
                  width: double.infinity,
                  height: 55,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: _isSignUpMode ? accentColor : primaryColor,
                      foregroundColor: Colors.white,
                      elevation: 2,
                      shadowColor: (_isSignUpMode ? accentColor : primaryColor).withOpacity(0.5),
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
                const SizedBox(height: 24),
                // Toggle Button with different styling
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      _isSignUpMode ? 'Already have an account?' : "Don't have an account?",
                      style: TextStyle(color: Colors.grey[600]),
                    ),
                    TextButton(
                      onPressed: () {
                        setState(() {
                          _isSignUpMode = !_isSignUpMode;
                        });
                      },
                      child: Text(
                        _isSignUpMode ? l10n.signIn : l10n.createAccount,
                        style: TextStyle(
                          color: _isSignUpMode ? accentColor : primaryColor, 
                          fontWeight: FontWeight.bold,
                          fontSize: 16
                        ),
                      ),
                    ),
                  ],
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
    required Color activeColor,
    bool isPassword = false,
    String? Function(String?)? validator,
  }) {
    return TextFormField(
      controller: controller,
      obscureText: isPassword,
      validator: validator,
      cursorColor: activeColor,
      decoration: InputDecoration(
        prefixIcon: Icon(icon, size: 22, color: activeColor),
        labelText: label,
        labelStyle: TextStyle(color: Colors.grey[600]),
        floatingLabelStyle: TextStyle(color: activeColor),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide(color: Colors.grey[300]!),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide(color: activeColor, width: 2),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: const BorderSide(color: Colors.red, width: 1),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: const BorderSide(color: Colors.red, width: 2),
        ),
        filled: true,
        fillColor: Colors.grey[50],
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
      ),
    );
  }
}
