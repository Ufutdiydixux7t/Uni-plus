import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/localization/app_localizations.dart';
import '../../core/storage/secure_storage_service.dart';
import '../../core/providers/announcement_provider.dart';
import '../../shared/widgets/app_drawer.dart';
import '../shared/content_list_screen.dart';
import '../lectures/lectures_screen.dart';
import '../summaries/summaries_screen.dart';

class AdminDashboardScreen extends ConsumerStatefulWidget {
  const AdminDashboardScreen({super.key});

  @override
  ConsumerState<AdminDashboardScreen> createState() => _AdminDashboardScreenState();
}

class _AdminDashboardScreenState extends ConsumerState<AdminDashboardScreen> {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  String delegateName = '';
  String classCode = '';

  @override
  void initState() {
    super.initState();
    _loadUser();
  }

  Future<void> _loadUser() async {
    final name = await SecureStorageService.getName();
    final code = await SecureStorageService.getClassCode();
    if (!mounted) return;
    setState(() {
      delegateName = name ?? 'Delegate';
      classCode = code ?? '';
    });
  }

  void _navigateToContent(String title, String category) {
    if (category == 'lectures') {
      Navigator.push(context, MaterialPageRoute(builder: (_) => const LecturesScreen()));
    } else if (category == 'summaries') {
      Navigator.push(context, MaterialPageRoute(builder: (_) => const SummariesScreen()));
    } else {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => ContentListScreen(
            category: category,
            title: title,
          ),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final announcements = ref.watch(announcementProvider);

    return Scaffold(
      key: _scaffoldKey,
      drawer: const AppDrawer(),
      backgroundColor: const Color(0xFFF6F7FB),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        title: Text(
          l10n.roleDelegate,
          style: const TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
        ),
        leading: IconButton(
          icon: const Icon(Icons.menu, color: Colors.black),
          onPressed: () => _scaffoldKey.currentState?.openDrawer(),
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _header(l10n),
              const SizedBox(height: 32),
              _announcementSection(l10n, announcements),
              const SizedBox(height: 32),
              Text(
                l10n.addContent,
                style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 16),
              _dashboardGrid(l10n),
              const SizedBox(height: 32),
              
              // Phase 3: Rectangular GridView Section at the bottom for Delegate
              Text(
                l10n.receivedSummaries,
                style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 16),
              _horizontalActionCard(
                icon: Icons.inbox_rounded,
                title: l10n.receivedSummaries,
                subtitle: l10n.locale.languageCode == 'ar' ? "عرض الملخصات المرسلة من الطلاب" : "View summaries sent by students",
                onTap: () {
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
              ),
              const SizedBox(height: 40),
            ],
          ),
        ),
      ),
    );
  }

  Widget _dashboardGrid(AppLocalizations l10n) {
    return GridView.count(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      crossAxisCount: 2,
      crossAxisSpacing: 16,
      mainAxisSpacing: 16,
      childAspectRatio: 1.1,
      children: [
        _actionCard(Icons.menu_book, l10n.lectures, () => _navigateToContent(l10n.lectures, 'lectures')),
        _actionCard(Icons.assessment_outlined, l10n.dailyReports, () => _navigateToContent(l10n.dailyReports, 'reports')),
        _actionCard(Icons.description, l10n.summaries, () => _navigateToContent(l10n.summaries, 'summaries')),
        _actionCard(Icons.task_alt, l10n.tasks, () => _navigateToContent(l10n.tasks, 'tasks')),
        _actionCard(Icons.assignment, l10n.forms, () => _navigateToContent(l10n.forms, 'forms')),
        _actionCard(Icons.grade, l10n.grades, () => _navigateToContent(l10n.grades, 'grades')),
      ],
    );
  }

  Widget _actionCard(IconData icon, String title, VoidCallback onTap) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(20),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10, offset: const Offset(0, 4)),
          ],
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 32, color: const Color(0xFF3F51B5)),
            const SizedBox(height: 12),
            Text(
              title,
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
            ),
          ],
        ),
      ),
    );
  }

  Widget _horizontalActionCard({
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(20),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10, offset: const Offset(0, 4)),
          ],
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: const Color(0xFF3F51B5).withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(icon, color: const Color(0xFF3F51B5)),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                  Text(subtitle, style: const TextStyle(fontSize: 13, color: Colors.grey)),
                ],
              ),
            ),
            const Icon(Icons.chevron_right, color: Colors.grey),
          ],
        ),
      ),
    );
  }

  Widget _header(AppLocalizations l10n) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF3F51B5), Color(0xFF6A5AE0)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(24),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '${l10n.welcome}, $delegateName',
            style: const TextStyle(color: Colors.white, fontSize: 22, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          Text(
            l10n.locale.languageCode == 'ar' ? 'شارك الرمز أدناه مع طلابك للانضمام إلى هذا الفصل.' : 'Share the code below with your students to join this class.',
            style: const TextStyle(color: Colors.white70, fontSize: 13),
          ),
          const SizedBox(height: 20),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.15),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              children: [
                const Icon(Icons.key, color: Colors.white70, size: 18),
                const SizedBox(width: 12),
                Text(
                  classCode,
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 18,
                    letterSpacing: 2,
                  ),
                ),
                const Spacer(),
                IconButton(
                  icon: const Icon(Icons.copy, color: Colors.white),
                  onPressed: () {
                    Clipboard.setData(ClipboardData(text: classCode));
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text(l10n.locale.languageCode == 'ar' ? 'تم نسخ الرمز!' : 'Code Copied!')),
                    );
                  },
                )
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _announcementSection(AppLocalizations l10n, List<Announcement> announcements) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              l10n.tomorrowLectures,
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            TextButton.icon(
              onPressed: () => _showAddAnnouncementDialog(context, ref),
              icon: const Icon(Icons.add, size: 18),
              label: Text(l10n.addAnnouncement),
            ),
          ],
        ),
        const SizedBox(height: 16),
        if (announcements.isEmpty)
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(20),
            ),
            child: Center(child: Text(l10n.noContent, style: const TextStyle(color: Colors.grey))),
          )
        else
          ...announcements.map((a) => _announcementCard(a, l10n)).toList(),
      ],
    );
  }

  Widget _announcementCard(Announcement a, AppLocalizations l10n) {
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10, offset: const Offset(0, 4)),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(a.subject, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: Color(0xFF3F51B5))),
              IconButton(
                icon: const Icon(Icons.delete, color: Colors.red, size: 20),
                onPressed: () => ref.read(announcementProvider.notifier).deleteAnnouncement(a.id),
                constraints: const BoxConstraints(),
                padding: EdgeInsets.zero,
              ),
            ],
          ),
          const Divider(),
          _infoRow(Icons.person_outline, '${l10n.doctor}: ${a.doctor}'),
          const SizedBox(height: 8),
          _infoRow(Icons.access_time, '${l10n.time}: ${a.time}'),
        ],
      ),
    );
  }

  Widget _infoRow(IconData icon, String text) {
    return Row(
      children: [
        Icon(icon, size: 16, color: Colors.grey),
        const SizedBox(width: 8),
        Text(text, style: const TextStyle(fontSize: 14, color: Colors.black87)),
      ],
    );
  }

  void _showAddAnnouncementDialog(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final subjectController = TextEditingController();
    final doctorController = TextEditingController();
    final timeController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Text(l10n.addAnnouncement, style: const TextStyle(color: Color(0xFF3F51B5), fontWeight: FontWeight.bold)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            _dialogField(subjectController, l10n.subject, Icons.book_outlined),
            const SizedBox(height: 12),
            _dialogField(doctorController, l10n.doctor, Icons.person_outline),
            const SizedBox(height: 12),
            _dialogField(timeController, l10n.time, Icons.access_time),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: Text(l10n.cancel, style: const TextStyle(color: Colors.grey))),
          ElevatedButton(
            onPressed: () {
              if (subjectController.text.isEmpty) return;
              ref.read(announcementProvider.notifier).addAnnouncement(
                subject: subjectController.text.trim(),
                doctor: doctorController.text.trim(),
                time: timeController.text.trim(), place: '',
              );
              Navigator.pop(context);
            },
            style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF3F51B5), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10))),
            child: Text(l10n.save, style: const TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  Widget _dialogField(TextEditingController controller, String label, IconData icon) {
    return TextField(
      controller: controller,
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: Icon(icon, color: const Color(0xFF3F51B5)),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      ),
    );
  }
}
