import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:uuid/uuid.dart';

import '../../../core/navigation/app_routes.dart';
import '../../../core/providers/locale_provider.dart';
import '../../../core/storage/secure_storage_service.dart';
import '../../../core/auth/user_role.dart';
import '../../../core/localization/app_localizations.dart';

final supabase = Supabase.instance.client;

class LoginDelegateScreen extends ConsumerStatefulWidget {
  const LoginDelegateScreen({super.key});

  @override
  ConsumerState<LoginDelegateScreen> createState() =>
      _LoginDelegateScreenState();
}

class _LoginDelegateScreenState
    extends ConsumerState<LoginDelegateScreen> {
  final _formKey = GlobalKey<FormState>();
  final _email = TextEditingController();
  final _password = TextEditingController();

  bool _loading = false;
  bool _signUpMode = false;
  bool _obscure = true;

  @override
  void dispose() {
    _email.dispose();
    _password.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _loading = true);

    try {
      if (_signUpMode) {
        // =========================
        // SIGN UP (DELEGATE)
        // =========================
        final res = await supabase.auth.signUp(
          email: _email.text.trim(),
          password: _password.text.trim(),
        );

        final user = res.user;
        if (user == null) {
          throw const AuthException('Failed to create account');
        }

        // check profile
        final profile = await supabase
            .from('profiles')
            .select()
            .eq('id', user.id)
            .maybeSingle();

        if (profile == null) {
          final joinCode =
          const Uuid().v4().substring(0, 6).toUpperCase();

          // create profile
          await supabase.from('profiles').insert({
            'id': user.id,
            'email': user.email,
            'role': 'delegate',
            'join_code': joinCode,
            'created_at': DateTime.now().toIso8601String(),
          });

          // create group automatically
          await supabase.from('groups').insert({
            'id': const Uuid().v4(),
            'delegate_id': user.id,
            'join_code': joinCode,
            'created_at': DateTime.now().toIso8601String(),
          });
        }
      } else {
        // =========================
        // SIGN IN
        // =========================
        final res = await supabase.auth.signInWithPassword(
          email: _email.text.trim(),
          password: _password.text.trim(),
        );

        final user = res.user;
        if (user == null) {
          throw const AuthException('Invalid email or password');
        }

        final profile = await supabase
            .from('profiles')
            .select('role')
            .eq('id', user.id)
            .maybeSingle();

        if (profile == null) {
          throw const AuthException('Profile not found');
        }

        if (profile['role'] != 'delegate') {
          await supabase.auth.signOut();
          throw const AuthException('Access denied');
        }
      }

      // =========================
      // SUCCESS
      // =========================
      await SecureStorageService.saveUser(
        role: UserRole.delegate,
        name: _email.text.split('@').first,
      );

      if (!mounted) return;
      Navigator.pushNamedAndRemoveUntil(
        context,
        AppRoutes.homeDelegate,
            (_) => false,
      );
    } on AuthException catch (e) {
      _error(e.message);
    } catch (e) {
      _error(e.toString());
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  void _error(String msg) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(backgroundColor: Colors.red, content: Text(msg)),
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    const primary = Color(0xFF3F51B5);
    const accent = Color(0xFF5C6BC0);

    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Form(
            key: _formKey,
            child: Column(
              children: [
                const SizedBox(height: 60),
                Icon(
                  _signUpMode ? Icons.person_add : Icons.login,
                  size: 80,
                  color: _signUpMode ? accent : primary,
                ),
                const SizedBox(height: 24),
                Text(
                  _signUpMode ? l10n.createAccount : l10n.signIn,
                  style: TextStyle(
                    fontSize: 26,
                    fontWeight: FontWeight.bold,
                    color: _signUpMode ? accent : primary,
                  ),
                ),
                const SizedBox(height: 40),
                _field(
                  controller: _email,
                  label: l10n.email,
                  icon: Icons.email,
                ),
                const SizedBox(height: 20),
                _field(
                  controller: _password,
                  label: l10n.password,
                  icon: Icons.lock,
                  password: true,
                ),
                const SizedBox(height: 40),
                SizedBox(
                  width: double.infinity,
                  height: 50,
                  child: ElevatedButton(
                    onPressed: _loading ? null : _submit,
                    style: ElevatedButton.styleFrom(
                      backgroundColor:
                      _signUpMode ? accent : primary,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14),
                      ),
                    ),
                    child: _loading
                        ? const CircularProgressIndicator(
                      color: Colors.white,
                    )
                        : Text(
                      _signUpMode
                          ? l10n.createAccount
                          : l10n.signIn,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 20),
                TextButton(
                  onPressed: () =>
                      setState(() => _signUpMode = !_signUpMode),
                  child: Text(
                    _signUpMode
                        ? l10n.signIn
                        : l10n.createAccount,
                    style: TextStyle(
                      color: _signUpMode ? accent : primary,
                      fontWeight: FontWeight.bold,
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

  Widget _field({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    bool password = false,
  }) {
    return TextFormField(
      controller: controller,
      obscureText: password ? _obscure : false,
      validator: (v) =>
      v == null || v.isEmpty ? '$label required' : null,
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: Icon(icon),
        suffixIcon: password
            ? IconButton(
          icon: Icon(
              _obscure ? Icons.visibility_off : Icons.visibility),
          onPressed: () =>
              setState(() => _obscure = !_obscure),
        )
            : null,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
        ),
      ),
    );
  }
}