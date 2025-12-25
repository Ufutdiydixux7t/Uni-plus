import 'dart:math';
import 'package:flutter/material.dart';
import '../../../core/storage/secure_storage_service.dart';
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

    await SecureStorageService.saveUser(
      role: 'delegate',
      name: _nameController.text.trim(),
      classCode: classCode,
    );

    // ✅ لا نمرر أي بيانات
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
      body: SingleChildScrollView(
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
            const SizedBox(height: 24),

            _field(_nameController, 'اسمك'),
            const SizedBox(height: 16),

            _field(_universityController, 'الجامعة'),
            const SizedBox(height: 16),

            _field(_facultyController, 'الكلية / القسم'),
            const SizedBox(height: 16),

            _field(_levelController, 'المستوى / المرحلة'),
            const SizedBox(height: 32),

            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _createClass,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF3F51B5),
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                ),
                child: const Text(
                  'إنشاء الفصل',
                  style: TextStyle(fontSize: 16),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _field(TextEditingController controller, String label) {
    return TextField(
      controller: controller,
      decoration: InputDecoration(
        labelText: label,
        filled: true,
        fillColor: Colors.white,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
        ),
      ),
    );
  }
}