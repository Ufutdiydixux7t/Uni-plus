import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:uuid/uuid.dart';

import '../../../core/localization/app_localizations.dart';
import '../../../core/navigation/app_routes.dart';
import '../../../core/providers/locale_provider.dart';
import '../../../core/storage/secure_storage_service.dart';
import '../../../core/auth/user_role.dart';

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
  bool _isSignUpMode = false;
  bool _obscurePassword = true;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  String _generateJoinCode() {
    const chars = 'ABCDEFGHJKLMNPQRSTUVWXYZ23456789';
    final rnd = Random();
    return String.fromCharCodes(Iterable.generate(
        8, (_) => chars.codeUnitAt(rnd.nextInt(chars.length))));
  }

  Future<void> _handleAuth() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    try {
      if (_isSignUpMode) {
        final AuthResponse response = await supabase.auth.signUp(
          email: _emailController.text.trim(),
          password: _passwordController.text.trim(),
        );

        final user = response.user;
        if (user == null) throw const AuthException('Sign up failed.');

        // 1. Check if profile exists
        final existingProfile = await supabase
            .from('profiles')
            .select()
            .eq('id', user.id)
            .maybeSingle();

        String joinCode = '';

        if (existingProfile == null) {
          // 2. Check if group exists for this delegate
          final existingGroup = await supabase
              .from('groups')
              .select()
              .eq('delegate_id', user.id)
              .maybeSingle();

          if (existingGroup == null) {
            joinCode = _generateJoinCode();
            final now = DateTime.now().toIso8601String();

            // Create Group
            await supabase.from('groups').insert({
              'id': const Uuid().v4(),
              'delegate_id': user.id,
              'join_code': joinCode,
              'created_at': now,
            });

            // Create Profile
            await supabase.from('profiles').insert({
              'id': user.id,
              'email': user.email,
              'role': 'delegate',
              'join_code': joinCode,
              'created_at': now,
            });
          } else {
            joinCode = existingGroup['join_code'] as String;
            // Create Profile with existing join_code
            await supabase.from('profiles').insert({
              'id': user.id,
              'email': user.email,
              'role': 'delegate',
              'join_code': joinCode,
              'created_at': DateTime.now().toIso8601String(),
            });
          }
        } else {
          joinCode = existingProfile['join_code'] as String;
        }

        await _onAuthSuccess(user.id, 'delegate', joinCode);
      } else {
        final AuthResponse response = await supabase.auth.signInWithPassword(
          email: _emailController.text.trim(),
          password: _passwordController.text.trim(),
        );

        final user = response.user;
        if (user == null) throw const AuthException('Sign in failed.');

        final profile = await supabase
            .from('profiles')
            .select('role, join_code')
            .eq('id', user.id)
            .maybeSingle();

        if (profile == null) throw const AuthException('Profile not found.');

        final String role = profile['role'] as String;
        final String joinCode = profile['join_code'] as String;

        if (role != 'delegate' && role != 'admin') {
          await supabase.auth.signOut();
          throw const AuthException('Access denied: You are not a delegate.');
        }

        await _onAuthSuccess(user.id, role, joinCode);
      }
    } on AuthException catch (error) {
      _showErrorDialog(error.message);
    } catch (error) {
      _showErrorDialog('An error occurred: ${error.toString()}');
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _onAuthSuccess(String userId, String role, String joinCode) async {
    final userRole = role == 'admin' ? UserRole.admin : UserRole.delegate;
    
    // Store join_code locally
    await SecureStorageService.saveUser(
      role: userRole,
      name: joinCode, // Using name field to store joinCode as per previous structure or just for local storage
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
      SnackBar(content: Text(message), backgroundColor: Colors.red),
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    const primaryColor = Color(0xFF3F51B5);
    const accentColor = Color(0xFF5C6BC0);

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
                  obscureText: _obscurePassword,
                  onToggleVisibility: () => setState(() => _obscurePassword = !_obscurePassword),
                  activeColor: _isSignUpMode ? accentColor : primaryColor,
                  validator: (value) {
                    if (value == null || value.isEmpty) return l10n.passwordRequired;
                    if (_isSignUpMode && value.length < 6) return 'Password must be at least 6 characters';
                    return null;
                  },
                ),
                const SizedBox(height: 40),
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
    bool obscureText = false,
    VoidCallback? onToggleVisibility,
    String? Function(String?)? validator,
  }) {
    return TextFormField(
      controller: controller,
      obscureText: isPassword ? obscureText : false,
      validator: validator,
      cursorColor: activeColor,
      decoration: InputDecoration(
        prefixIcon: Icon(icon, size: 22, color: activeColor),
        suffixIcon: isPassword 
          ? IconButton(
              icon: Icon(obscureText ? Icons.visibility_off : Icons.visibility, color: activeColor),
              onPressed: onToggleVisibility,
            )
          : null,
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
