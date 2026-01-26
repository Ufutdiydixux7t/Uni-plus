import 'dart:math';
import 'package:flutter/material.dart';

import '../../../core/storage/secure_storage_service.dart';
import '../../../core/auth/user_role.dart';
import '../../admin_dashboard/admin_dashboard_screen.dart';

class DelegateSetupScreen extends StatefulWidget {
  const DelegateSetupScreen({super.key});

  @override
  State<DelegateSetupScreen> createState() => _DelegateSetupScreenState();
}

class _DelegateSetupScreenState extends State<DelegateSetupScreen> {
  final _nameController = TextEditingController();
  final _universityController = TextEditingController();
  final _facultyController = TextEditingController();
  final _levelController = TextEditingController();

  // توليد كود فصل عشوائي (بدون حروف مربكة)
  String _generateClassCode() {
    const chars = 'ABCDEFGHJKLMNPQRSTUVWXYZ23456789';
    final rand = Random();
    return List.generate(6, (_) => chars[rand.nextInt(chars.length)]).join();
  }

  @override
  void dispose() {
    _nameController.dispose();
    _universityController.dispose();
    _facultyController.dispose();
    _levelController.dispose();
    super.dispose();
  }

  Future<void> _createClass() async {
    // تحقق من تعبئة الحقول
    if (_nameController.text.isEmpty ||
        _universityController.text.isEmpty ||
        _facultyController.text.isEmpty ||
        _levelController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('يرجى تعبئة جميع الحقول')),
      );
      return;
    }

    final classCode = _generateClassCode();

    // حفظ المستخدم كـ Delegate (مندوب)
    await SecureStorageService.saveUser(
      role: UserRole.delegate,
      name: _nameController.text.trim(),
      classCode: classCode,
    );

    if (!mounted) return;

    // الانتقال مباشرة إلى لوحة تحكم المندوب
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (_) => const AdminDashboardScreen(),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF6F7FB),
      appBar: AppBar(
        title: const Text('إعداد المندوب'),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        elevation: 0,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'أنشئ فصلك الدراسي',
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              const Text(
                'أدخل بياناتك وبيانات الفصل للبدء في إدارته',
                style: TextStyle(color: Colors.grey, fontSize: 14),
              ),
              const SizedBox(height: 32),

              _field(_nameController, 'اسمك الكامل', Icons.person_outline),
              const SizedBox(height: 16),

              _field(_universityController, 'الجامعة', Icons.school_outlined),
              const SizedBox(height: 16),

              _field(_facultyController, 'الكلية / القسم', Icons.account_balance_outlined),
              const SizedBox(height: 16),

              _field(_levelController, 'المستوى / المرحلة', Icons.layers_outlined),
              const SizedBox(height: 40),

              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _createClass,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF3F51B5),
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                    elevation: 0,
                  ),
                  child: const Text(
                    'إنشاء الفصل',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                ),
              ),
              // Add padding for keyboard
              SizedBox(height: MediaQuery.of(context).viewInsets.bottom > 0 ? 20 : 0),
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
        prefixIcon: Icon(icon, size: 22),
        filled: true,
        fillColor: Colors.white,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide(color: Colors.grey[200]!),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide(color: Colors.grey[200]!),
        ),
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
      ),
    );
  }
}
