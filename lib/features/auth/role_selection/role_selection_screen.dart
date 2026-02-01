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
    final size = MediaQuery.of(context).size;

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
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 40),
            child: Stack(
              clipBehavior: Clip.none,
              children: [
                // The Main Border Container
                Container(
                  width: double.infinity,
                  margin: const EdgeInsets.only(top: 50), // Space for the logo at the top
                  padding: const EdgeInsets.fromLTRB(20, 70, 20, 40),
                  decoration: BoxDecoration(
                    border: Border.all(
                      color: const Color(0xFF3F51B5).withOpacity(0.5),
                      width: 2,
                    ),
                    borderRadius: BorderRadius.circular(30),
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        l10n.appTitle,
                        style: const TextStyle(
                          fontSize: 26,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF3F51B5),
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        l10n.selectRole,
                        style: const TextStyle(fontSize: 15, color: Colors.grey),
                      ),
                      const SizedBox(height: 40),
                      _RoleButton(
                        title: l10n.student,
                        icon: Icons.school_outlined,
                        onTap: () => Navigator.push(
                          context,
                          MaterialPageRoute(builder: (_) => const StudentRegisterScreen()),
                        ),
                      ),
                      const SizedBox(height: 20),
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
                // The Logo placed on top of the border
                Positioned(
                  top: 0,
                  left: 0,
                  right: 0,
                  child: Center(
                    child: Container(
                      padding: const EdgeInsets.all(10),
                      decoration: const BoxDecoration(
                        color: Colors.white,
                        shape: BoxShape.circle,
                      ),
                      child: Container(
                        padding: const EdgeInsets.all(15),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          shape: BoxShape.circle,
                          border: Border.all(
                            color: const Color(0xFF3F51B5).withOpacity(0.5),
                            width: 2,
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: const Color(0xFF3F51B5).withOpacity(0.1),
                              blurRadius: 10,
                              spreadRadius: 2,
                            )
                          ],
                        ),
                        child: Image.asset(
                          'assets/icons/uniplus_icon1.png',
                          height: 60,
                          width: 60,
                        ),
                      ),
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
}

class _RoleButton extends StatelessWidget {
  final String title;
  final IconData icon;
  final VoidCallback onTap;

  const _RoleButton({required this.title, required this.icon, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        splashColor: const Color(0xFF3F51B5).withOpacity(0.1),
        highlightColor: const Color(0xFF3F51B5).withOpacity(0.05),
        borderRadius: BorderRadius.circular(20),
        child: Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 20),
          decoration: BoxDecoration(
            border: Border.all(
              color: const Color(0xFF3F51B5).withOpacity(0.15),
              width: 1.2,
            ),
            borderRadius: BorderRadius.circular(20),
          ),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: const Color(0xFF3F51B5).withOpacity(0.08),
                  shape: BoxShape.circle,
                ),
                child: Icon(icon, color: const Color(0xFF3F51B5), size: 26),
              ),
              const SizedBox(width: 16),
              Text(
                title,
                style: const TextStyle(
                  fontSize: 17, 
                  fontWeight: FontWeight.w600,
                  color: Color(0xFF2D3142),
                ),
              ),
              const Spacer(),
              const Icon(
                Icons.arrow_forward_ios_rounded, 
                size: 14, 
                color: Colors.grey,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
