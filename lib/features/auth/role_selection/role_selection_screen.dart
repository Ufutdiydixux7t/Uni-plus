import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/providers/locale_provider.dart';
import '../../../core/localization/app_localizations.dart';
import '../student_register/student_register_screen.dart';
import '../login_delegate_screen.dart';

class RoleSelectionScreen extends ConsumerWidget {
  const RoleSelectionScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.language, color: Color(0xFF3F51B5)),
            onPressed: () => ref.read(localeProvider.notifier).toggleLocale(),
          ),
        ],
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 30),
          child: Column(
            children: [
              const SizedBox(height: 40),
              Image.asset('assets/icons/uniplus_icon1.png', height: 100),
              const SizedBox(height: 24),
              Text(
                l10n.appTitle,
                style: const TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF3F51B5),
                ),
              ),
              const SizedBox(height: 12),
              Text(
                l10n.selectRole,
                style: const TextStyle(fontSize: 16, color: Colors.grey),
              ),
              const SizedBox(height: 60),
              _RoleButton(
                title: l10n.student,
                icon: Icons.school_outlined,
                onTap: () => Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const StudentRegisterScreen()),
                ),
              ),
              const SizedBox(height: 24),
              _RoleButton(
                title: l10n.roleDelegate,
                icon: Icons.person_outline,
                onTap: () => Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const LoginDelegateScreen()),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _RoleButton extends StatelessWidget {
  final String title;
  final IconData icon;
  final VoidCallback onTap;

  const _RoleButton({required this.title, required this.icon, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF3F51B5).withOpacity(0.05),
            blurRadius: 15,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Material(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(20),
          child: Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(vertical: 24, horizontal: 24),
            decoration: BoxDecoration(
              // Professional Border
              border: Border.all(
                color: const Color(0xFF3F51B5).withOpacity(0.2),
                width: 1.5,
              ),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: const Color(0xFF3F51B5).withOpacity(0.1),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(icon, color: const Color(0xFF3F51B5), size: 30),
                ),
                const SizedBox(width: 20),
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 19, 
                    fontWeight: FontWeight.w700,
                    color: Color(0xFF2D3142),
                  ),
                ),
                const Spacer(),
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Colors.grey[50],
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: const Icon(
                    Icons.arrow_forward_ios_rounded, 
                    size: 14, 
                    color: Color(0xFF3F51B5),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
