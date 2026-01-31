import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/auth/user_role.dart';
import '../../../core/storage/secure_storage_service.dart';
import '../../../core/providers/locale_provider.dart';
import '../../../core/localization/app_localizations.dart';
import '../../admin_dashboard/admin_dashboard_screen.dart';

class DelegateSetupScreen extends ConsumerStatefulWidget {
  const DelegateSetupScreen({super.key});

  @override
  ConsumerState<DelegateSetupScreen> createState() => _DelegateSetupScreenState();
}

class _DelegateSetupScreenState extends ConsumerState<DelegateSetupScreen> {
  final _nameController = TextEditingController();
  final _universityController = TextEditingController();
  final _facultyController = TextEditingController();
  final _levelController = TextEditingController();

  String _generateClassCode() {
    const chars = 'ABCDEFGHJKLMNPQRSTUVWXYZ23456789';
    final rand = Random();
    return List.generate(6, (_) => chars[rand.nextInt(chars.length)]).join();
  }

  Future<void> _createClass() async {
    if (_nameController.text.isEmpty ||
        _universityController.text.isEmpty ||
        _facultyController.text.isEmpty ||
        _levelController.text.isEmpty) {
      return;
    }

    final classCode = _generateClassCode();

    await SecureStorageService.saveUser(
      role: UserRole.delegate,
      name: _nameController.text.trim(),
      classCode: classCode,
    );

    if (!mounted) return;

    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(builder: (_) => const AdminDashboardScreen()),
      (route) => false,
    );
  }

  @override
  void dispose() {
    _nameController.dispose();
    _universityController.dispose();
    _facultyController.dispose();
    _levelController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
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
          padding: const EdgeInsets.symmetric(horizontal: 30),
          child: Column(
            children: [
              const SizedBox(height: 10),
              Image.asset('assets/icons/uniplus_icon1.png', height: 80),
              const SizedBox(height: 20),
              Text(
                l10n.roleDelegate,
                style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Color(0xFF3F51B5)),
              ),
              const SizedBox(height: 32),
              _field(_nameController, l10n.fullName, Icons.person_outline),
              const SizedBox(height: 16),
              _field(_universityController, l10n.university, Icons.school_outlined),
              const SizedBox(height: 16),
              _field(_facultyController, l10n.faculty, Icons.account_balance_outlined),
              const SizedBox(height: 16),
              _field(_levelController, l10n.level, Icons.layers_outlined),
              const SizedBox(height: 40),
              SizedBox(
                width: double.infinity,
                height: 55,
                child: ElevatedButton(
                  onPressed: _createClass,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF3F51B5),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                    elevation: 0,
                  ),
                  child: Text(l10n.submit, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white)),
                ),
              ),
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }

  Widget _field(TextEditingController controller, String label, IconData icon) {
    return TextField(
      controller: controller,
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: Icon(icon, color: const Color(0xFF3F51B5)),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(16)),
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
      ),
    );
  }
}
