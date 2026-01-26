import 'package:flutter/material.dart';

import '../../../core/storage/secure_storage_service.dart';
import '../../../core/auth/user_role.dart';
import '../../daily_feed/daily_feed_screen.dart';

class StudentRegisterScreen extends StatefulWidget {
  const StudentRegisterScreen({super.key});

  @override
  State<StudentRegisterScreen> createState() => _StudentRegisterScreenState();
}

class _StudentRegisterScreenState extends State<StudentRegisterScreen> {
  final _nameController = TextEditingController();
  final _codeController = TextEditingController();

  Future<void> _joinClass() async {
    final name = _nameController.text.trim();
    final code = _codeController.text.trim();

    // تحقق من الإدخال
    if (name.isEmpty || code.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please fill all fields')),
      );
      return;
    }

    // حفظ المستخدم كطالب
    await SecureStorageService.saveUser(
      role: UserRole.student,
      name: name,
      classCode: code,
    );

    if (!mounted) return;

    // الانتقال إلى شاشة الطالب الرئيسية
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (_) => const DailyFeedScreen(),
      ),
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
    return Scaffold(
      backgroundColor: const Color(0xFFF6F7FB),
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.transparent,
        foregroundColor: Colors.black,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Join Your Class',
                style: TextStyle(fontSize: 26, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              const Text(
                'Enter your name and the class code provided by your delegate',
                style: TextStyle(color: Colors.black54, fontSize: 14),
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
                label: 'Class Code',
                icon: Icons.key_outlined,
              ),

              const SizedBox(height: 40),

              SizedBox(
                width: double.infinity,
                height: 56,
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
                  child: const Text(
                    'Join Class',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                ),
              ),
              // Keyboard padding
              SizedBox(height: MediaQuery.of(context).viewInsets.bottom > 0 ? 20 : 0),
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
        prefixIcon: Icon(icon, size: 22),
        labelText: label,
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
