import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import '../../../core/auth/user_role.dart';
import '../../../core/storage/secure_storage_service.dart';
import '../../../core/providers/locale_provider.dart';
import '../../daily_feed/daily_feed_screen.dart';

class StudentRegisterScreen extends ConsumerStatefulWidget {
  const StudentRegisterScreen({super.key});

  @override
  ConsumerState<StudentRegisterScreen> createState() => _StudentRegisterScreenState();
}

class _StudentRegisterScreenState extends ConsumerState<StudentRegisterScreen> {
  final _nameController = TextEditingController();
  final _codeController = TextEditingController();

  Future<void> _joinClass() async {
    final name = _nameController.text.trim();
    final code = _codeController.text.trim();

    if (name.isEmpty || code.isEmpty) {
      return;
    }

    await SecureStorageService.saveUser(
      role: UserRole.student,
      name: name,
      classCode: code,
    );

    if (!mounted) return;

    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(builder: (_) => const DailyFeedScreen()),
      (route) => false,
    );
  }

  @override
  void dispose() {
    _nameController.dispose();
    _codeController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.transparent,
        foregroundColor: const Color(0xFF3F51B5),
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
          child: Column(
            children: [
              const SizedBox(height: 20),
              Image.asset('assets/icons/uniplus_icon1.png', height: 100),
              const SizedBox(height: 24),
              Text(
                l10n.student,
                style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Color(0xFF3F51B5)),
              ),
              const SizedBox(height: 40),
              _inputField(
                controller: _nameController,
                label: 'Your Full Name',
                icon: Icons.person_outline,
              ),
              const SizedBox(height: 20),
              _inputField(
                controller: _codeController,
                label: l10n.classCode,
                icon: Icons.key_outlined,
              ),
              const SizedBox(height: 40),
              SizedBox(
                width: double.infinity,
                height: 55,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF3F51B5),
                    foregroundColor: Colors.white,
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                  ),
                  onPressed: _joinClass,
                  child: Text(
                    l10n.submit,
                    style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _inputField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
  }) {
    return TextField(
      controller: controller,
      decoration: InputDecoration(
        prefixIcon: Icon(icon, size: 22, color: const Color(0xFF3F51B5)),
        labelText: label,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
      ),
    );
  }
}
