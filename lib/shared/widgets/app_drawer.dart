import 'package:flutter/material.dart';
import '../../core/storage/secure_storage_service.dart';
import '../../features/auth/role_selection/role_selection_screen.dart';

class AppDrawer extends StatelessWidget {
  const AppDrawer({super.key});

  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: Column(
        children: [
          _header(),
          _item(
            icon: Icons.settings,
            title: 'Settings',
            onTap: () {},
          ),
          _item(
            icon: Icons.privacy_tip,
            title: 'Privacy',
            onTap: () {},
          ),
          _item(
            icon: Icons.language,
            title: 'Language',
            onTap: () {},
          ),
          const Spacer(),
          _item(
            icon: Icons.logout,
            title: 'Logout',
            color: Colors.red,
            onTap: () async {
              await SecureStorageService.clear();
              Navigator.pushAndRemoveUntil(
                context,
                MaterialPageRoute(
                  builder: (_) => const RoleSelectionScreen(),
                ),
                    (_) => false,
              );
            },
          ),
          const SizedBox(height: 20),
        ],
      ),
    );
  }

  Widget _header() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(20, 50, 20, 20),
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [Color(0xFF3F51B5), Color(0xFF6A5AE0)],
        ),
      ),
      child: const Text(
        'Uni Plus',
        style: TextStyle(
          color: Colors.white,
          fontSize: 22,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  Widget _item({
    required IconData icon,
    required String title,
    required VoidCallback onTap,
    Color color = Colors.black,
  }) {
    return ListTile(
      leading: Icon(icon, color: color),
      title: Text(
        title,
        style: TextStyle(
          color: color,
          fontWeight: FontWeight.w500,
        ),
      ),
      onTap: onTap,
    );
  }
}