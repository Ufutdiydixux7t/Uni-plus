import 'package:flutter/material.dart';

import '../../core/storage/secure_storage_service.dart';
import '../../core/auth/user_role.dart';
import '../../features/auth/role_selection/role_selection_screen.dart';

class AppDrawer extends StatelessWidget {
  const AppDrawer({super.key});

  @override
  Widget build(BuildContext context) {
    return Drawer(
      width: 290,
      backgroundColor: const Color(0xFFF6F7FB),
      child: FutureBuilder<UserRole>(
        future: SecureStorageService.getUserRole(),
        builder: (context, snapshot) {
          final role = snapshot.data ?? UserRole.student;

          return Column(
            children: [
              const _UserHeader(),
              Expanded(
                child: SingleChildScrollView(
                  physics: const BouncingScrollPhysics(),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const SizedBox(height: 12),
                      _section('GENERAL'),
                      _item(context,
                        icon: Icons.home_outlined,
                        title: 'Home',
                      ),

                      if (role == UserRole.student) ...[
                        _section('STUDENT'),
                        _item(context,
                          icon: Icons.school_outlined,
                          title: 'My Courses',
                        ),
                      ],

                      if (role == UserRole.delegate) ...[
                        _section('DELEGATE'),
                        _item(context,
                          icon: Icons.menu_book_outlined,
                          title: 'Add Lecture',
                        ),
                        _item(context,
                          icon: Icons.assignment_outlined,
                          title: 'Add Assignment',
                        ),
                      ],

                      if (role == UserRole.admin) ...[
                        _section('ADMIN'),
                        _item(context,
                          icon: Icons.supervisor_account_outlined,
                          title: 'Manage Users',
                        ),
                        _item(context,
                          icon: Icons.settings_outlined,
                          title: 'System Settings',
                        ),
                      ],
                      const SizedBox(height: 20),
                    ],
                  ),
                ),
              ),
              const Divider(height: 1),
              _item(
                context,
                icon: Icons.logout,
                title: 'Logout',
                color: Colors.red,
                onTap: () async {
                  await SecureStorageService.clearUser();
                  if (!context.mounted) return;

                  Navigator.of(context).pushAndRemoveUntil(
                    MaterialPageRoute(
                      builder: (_) => const RoleSelectionScreen(),
                    ),
                        (_) => false,
                  );
                },
              ),
              SizedBox(height: MediaQuery.of(context).padding.bottom + 12),
            ],
          );
        },
      ),
    );
  }

  // ================= SECTIONS =================

  Widget _section(String title) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 18, 20, 6),
      child: Text(
        title,
        style: const TextStyle(
          fontSize: 11,
          letterSpacing: 1.2,
          fontWeight: FontWeight.w600,
          color: Colors.black54,
        ),
      ),
    );
  }

  Widget _item(
      BuildContext context, {
        required IconData icon,
        required String title,
        Color color = Colors.black,
        VoidCallback? onTap,
      }) {
    return ListTile(
      dense: true,
      leading: Icon(icon, color: color, size: 22),
      title: Text(
        title,
        style: TextStyle(
          color: color,
          fontSize: 14,
          fontWeight: FontWeight.w500,
        ),
      ),
      horizontalTitleGap: 10,
      onTap: () {
        if (onTap != null) {
          onTap();
        } else {
          Navigator.pop(context);
        }
      },
    );
  }
}

class _UserHeader extends StatelessWidget {
  const _UserHeader();

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<String?>(
      future: SecureStorageService.getName(),
      builder: (context, snapshot) {
        final name = snapshot.data ?? 'User';

        return Container(
          padding: EdgeInsets.fromLTRB(20, MediaQuery.of(context).padding.top + 24, 20, 28),
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              colors: [Color(0xFF3F51B5), Color(0xFF6A5AE0)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.only(
              bottomLeft: Radius.circular(26),
              bottomRight: Radius.circular(26),
            ),
          ),
          child: Row(
            children: [
              const CircleAvatar(
                radius: 26,
                backgroundColor: Colors.white24,
                child: Icon(Icons.person, color: Colors.white, size: 28),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Welcome',
                      style: TextStyle(
                        color: Colors.white70,
                        fontSize: 12,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      name,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 17,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
