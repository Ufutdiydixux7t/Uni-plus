/*
import 'package:flutter/material.dart';

import '../../shared/widgets/typewriter_text.dart';

enum UserRole { student, delegate }

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  UserRole _role = UserRole.student;

  final _nameController = TextEditingController();
  final _passwordController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF6F7FB),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              const Spacer(),

              // LOGO
              Container(
                height: 80,
                width: 80,
                decoration: BoxDecoration(
                  color: const Color(0xFF3F51B5),
                  borderRadius: BorderRadius.circular(24),
                ),
                child: const Icon(
                  Icons.school,
                  color: Colors.white,
                  size: 40,
                ),
              ),

              const SizedBox(height: 16),

              // APP NAME (Typewriter)
              const TypewriterText(
                text: 'Uni Plus',
                speed: Duration(milliseconds: 120),
                style: TextStyle(
                  fontSize: 26,
                  fontWeight: FontWeight.bold,
                ),
              ),

              const SizedBox(height: 32),

              // ROLE SWITCH
              _roleSwitcher(),

              const SizedBox(height: 24),

              // NAME
              _inputField(
                controller: _nameController,
                hint: _role == UserRole.student
                    ? 'Student Name'
                    : 'Delegate Name',
                icon: Icons.person_outline,
              ),

              const SizedBox(height: 16),

              // PASSWORD / CODE
              _inputField(
                controller: _passwordController,
                hint: _role == UserRole.student
                    ? 'Student ID'
                    : 'Delegate Code',
                icon: Icons.lock_outline,
              ),

              const SizedBox(height: 32),

              // LOGIN BUTTON
              SizedBox(
                width: double.infinity,
                height: 52,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF3F51B5),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                  ),
                  onPressed: _login,
                  child: const Text(
                    'Login',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),

              const Spacer(),
            ],
          ),
        ),
      ),
    );
  }

  // ================== WIDGETS ==================

  Widget _roleSwitcher() {
    return Container(
      height: 48,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        children: [
          _roleItem(UserRole.student, 'Student'),
          _roleItem(UserRole.delegate, 'Delegate'),
        ],
      ),
    );
  }

  Widget _roleItem(UserRole role, String title) {
    final isSelected = _role == role;

    return Expanded(
      child: GestureDetector(
        onTap: () {
          setState(() {
            _role = role;
          });
        },
        child: Container(
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: isSelected
                ? const Color(0xFF3F51B5)
                : Colors.transparent,
            borderRadius: BorderRadius.circular(16),
          ),
          child: Text(
            title,
            style: TextStyle(
              color: isSelected ? Colors.white : Colors.black54,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ),
    );
  }

  Widget _inputField({
    required TextEditingController controller,
    required String hint,
    required IconData icon,
  }) {
    return TextField(
      controller: controller,
      decoration: InputDecoration(
        hintText: hint,
        prefixIcon: Icon(icon),
        filled: true,
        fillColor: Colors.white,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide.none,
        ),
      ),
    );
  }

  // ================== LOGIC ==================

  void _login() {
    // هنا لاحقًا:
    // - حفظ الاسم
    // - حفظ الدور
    // - التنقل حسب role
  }
}

 */