import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/providers/locale_provider.dart';
import '../../core/storage/secure_storage_service.dart';
import '../../core/auth/user_role.dart';
import '../../core/localization/app_localizations.dart';
import '../../features/auth/role_selection/role_selection_screen.dart';
import '../../features/lectures/lectures_screen.dart';
import '../../features/summaries/summaries_screen.dart';
import '../../features/shared/content_list_screen.dart';

class AppDrawer extends ConsumerWidget {
  const AppDrawer({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final currentLocale = ref.watch(localeProvider);

    return Drawer(
      width: 290,
      backgroundColor: const Color(0xFFF6F7FB),
      child: Column(
        children: [
          const _UserHeader(),
          Expanded(
            child: SingleChildScrollView(
              physics: const BouncingScrollPhysics(),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 12),
                  _section(l10n.home.toUpperCase()),
                  _drawerItem(
                    icon: Icons.home_outlined,
                    title: l10n.home,
                    onTap: () => Navigator.pop(context),
                  ),
                  _drawerItem(
                    icon: Icons.analytics_outlined,
                    title: l10n.dailyReports,
                    onTap: () {
                      Navigator.pop(context);
                      Navigator.push(context, MaterialPageRoute(builder: (_) => ContentListScreen(category: 'reports', title: l10n.dailyReports)));
                    },
                  ),
                  _drawerItem(
                    icon: Icons.menu_book_outlined,
                    title: l10n.lectures,
                    onTap: () {
                      Navigator.pop(context);
                      Navigator.push(context, MaterialPageRoute(builder: (_) => const LecturesScreen()));
                    },
                  ),
                  FutureBuilder<UserRole>(
                    future: SecureStorageService.getUserRole(),
                    builder: (context, snapshot) {
                      final role = snapshot.data ?? UserRole.student;
                      final isDelegate = role == UserRole.delegate || role == UserRole.admin;
                      
                      return Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          _drawerItem(
                            icon: Icons.description_outlined,
                            title: l10n.summaries,
                            onTap: () {
                              Navigator.pop(context);
                              Navigator.push(context, MaterialPageRoute(builder: (_) => const SummariesScreen()));
                            },
                          ),
                          if (isDelegate)
                            _drawerItem(
                              icon: Icons.inbox_outlined,
                              title: l10n.receivedSummaries,
                              onTap: () {
                                Navigator.pop(context);
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (_) => ContentListScreen(
                                      category: 'summaries',
                                      title: l10n.receivedSummaries,
                                    ),
                                  ),
                                );
                              },
                            )
                          else
                            _drawerItem(
                              icon: Icons.send_outlined,
                              title: l10n.sendSummary,
                              onTap: () {
                                Navigator.pop(context);
                                Navigator.push(context, MaterialPageRoute(builder: (_) => const SummariesScreen()));
                              },
                            ),
                        ],
                      );
                    },
                  ),
                  _drawerItem(
                    icon: Icons.assignment_outlined,
                    title: l10n.tasks,
                    onTap: () {
                      Navigator.pop(context);
                      Navigator.push(context, MaterialPageRoute(builder: (_) => ContentListScreen(category: 'tasks', title: l10n.tasks)));
                    },
                  ),
                  _drawerItem(
                    icon: Icons.list_alt_outlined,
                    title: l10n.forms,
                    onTap: () {
                      Navigator.pop(context);
                      Navigator.push(context, MaterialPageRoute(builder: (_) => ContentListScreen(category: 'forms', title: l10n.forms)));
                    },
                  ),
                  _drawerItem(
                    icon: Icons.grade_outlined,
                    title: l10n.grades,
                    onTap: () {
                      Navigator.pop(context);
                      Navigator.push(context, MaterialPageRoute(builder: (_) => ContentListScreen(category: 'grades', title: l10n.grades)));
                    },
                  ),
                  
                  const Divider(height: 24),
                  _section(l10n.language.toUpperCase()),
                  ListTile(
                    dense: true,
                    leading: const Icon(Icons.language, color: Colors.indigo, size: 22),
                    title: Text(
                      currentLocale.languageCode == 'en' ? 'English' : 'العربية',
                      style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
                    ),
                    trailing: const Icon(Icons.swap_horiz, size: 18, color: Colors.grey),
                    onTap: () => ref.read(localeProvider.notifier).toggleLocale(),
                  ),
                  
                  _drawerItem(
                    icon: Icons.info_outline,
                    title: l10n.about,
                    onTap: () {
                      Navigator.pop(context);
                      _showAboutDialog(context, l10n);
                    },
                  ),
                ],
              ),
            ),
          ),
          const Divider(height: 1),
          ListTile(
            dense: true,
            leading: const Icon(Icons.logout, color: Colors.red, size: 22),
            title: Text(
              l10n.logout,
              style: const TextStyle(color: Colors.red, fontSize: 14, fontWeight: FontWeight.w500),
            ),
            onTap: () async {
              await SecureStorageService.clear();
              if (context.mounted) {
                Navigator.of(context).pushAndRemoveUntil(
                  MaterialPageRoute(builder: (_) => const RoleSelectionScreen()),
                  (route) => false,
                );
              }
            },
          ),
          SizedBox(height: MediaQuery.of(context).padding.bottom + 12),
        ],
      ),
    );
  }

  void _showAboutDialog(BuildContext context, AppLocalizations l10n) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(l10n.about),
        content: Text(l10n.aboutText),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

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

  Widget _drawerItem({
    required IconData icon,
    required String title,
    required VoidCallback onTap,
  }) {
    return ListTile(
      dense: true,
      leading: Icon(icon, color: Colors.indigo, size: 22),
      title: Text(
        title,
        style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
      ),
      onTap: onTap,
    );
  }
}

class _UserHeader extends StatelessWidget {
  const _UserHeader();

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return FutureBuilder<Map<String, dynamic>>(
      future: Future.wait([
        SecureStorageService.getName(),
        SecureStorageService.getUserRole(),
      ]).then((results) => {
        'name': results[0],
        'role': results[1],
      }),
      builder: (context, snapshot) {
        final name = snapshot.data?['name'] as String? ?? 'User';
        final role = snapshot.data?['role'] as UserRole? ?? UserRole.student;
        
        String roleText = l10n.student;
        if (role == UserRole.delegate) roleText = l10n.roleDelegate;
        if (role == UserRole.admin) roleText = l10n.admin;

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
                    Text(
                      roleText,
                      style: const TextStyle(
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
