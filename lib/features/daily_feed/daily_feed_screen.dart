import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/storage/secure_storage_service.dart';
import '../../core/localization/app_localizations.dart';
import '../../core/providers/announcement_provider.dart';
import '../../shared/widgets/app_drawer.dart';
import '../shared/content_list_screen.dart';
import '../lectures/lectures_screen.dart';
import '../../core/auth/user_role.dart';
import '../../core/providers/content_provider.dart';
import '../summaries/summaries_screen.dart';

class DailyFeedScreen extends ConsumerStatefulWidget {
  const DailyFeedScreen({super.key});

  @override
  ConsumerState<DailyFeedScreen> createState() => _DailyFeedScreenState();
}

class _DailyFeedScreenState extends ConsumerState<DailyFeedScreen> {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  String studentName = '';

  @override
  void initState() {
    super.initState();
    _loadName();
  }

  Future<void> _loadName() async {
    final name = await SecureStorageService.getName();
    if (!mounted) return;
    setState(() => studentName = name ?? 'Student');
  }

  void _navigateToContent(String title, String category) {
    if (category == 'lectures') {
      Navigator.push(context, MaterialPageRoute(builder: (_) => const LecturesScreen()));
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
    final screenWidth = MediaQuery.of(context).size.width;
    final crossAxisCount = screenWidth > 600 ? 3 : 2;

    return Scaffold(
      key: _scaffoldKey,
      backgroundColor: const Color(0xFFF6F7FB),
      drawer: const AppDrawer(),
      body: SafeArea(
        child: CustomScrollView(
          physics: const BouncingScrollPhysics(),
          slivers: [
            SliverToBoxAdapter(child: _header(l10n)),
            if (announcements.isNotEmpty)
              SliverPadding(
                padding: const EdgeInsets.fromLTRB(20, 24, 20, 0),
                sliver: SliverToBoxAdapter(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        l10n.tomorrowLectures,
                        style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 16),
                      ...announcements.map((a) => _announcementCard(a, l10n)).toList(),
                    ],
                  ),
                ),
              ),
            SliverPadding(
              padding: const EdgeInsets.all(20),
              sliver: SliverGrid(
                gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: crossAxisCount,
                  crossAxisSpacing: 16,
                  mainAxisSpacing: 16,
                  childAspectRatio: 1.1,
                ),
                delegate: SliverChildListDelegate([
                  _actionCard(Icons.menu_book, l10n.lectures, () => _navigateToContent(l10n.lectures, 'lectures')),
                  _actionCard(Icons.assessment_outlined, l10n.dailyReports, () => _navigateToContent(l10n.dailyReports, 'dailyReports')),
                  _actionCard(Icons.description, l10n.summaries, () => _navigateToContent(l10n.summaries, 'summaries')),
                  _actionCard(Icons.task_alt, l10n.tasks, () => _navigateToContent(l10n.tasks, 'tasks')),
                  _actionCard(Icons.assignment, l10n.forms, () => _navigateToContent(l10n.forms, 'forms')),
                  _actionCard(Icons.grade, l10n.grades, () => _navigateToContent(l10n.grades, 'grades')),
                ]),
              ),
            ),
            SliverToBoxAdapter(
              child: FutureBuilder<UserRole>(
                future: SecureStorageService.getUserRole(),
                builder: (context, snapshot) {
                  final role = snapshot.data ?? UserRole.student;
                  final isDelegate = role == UserRole.delegate || role == UserRole.admin;
                  return Padding(
                    padding: const EdgeInsets.fromLTRB(20, 0, 20, 40),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          isDelegate ? "Student Submissions" : "Send Summary",
                          style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                        ),
                        const SizedBox(height: 12),
                        InkWell(
                          onTap: () {
                            if (isDelegate) {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (_) => ContentListScreen(
                                    category: 'summaries',
                                    title: l10n.receivedSummaries,
                                  ),
                                ),
                              );
                            } else {
                              _showSendSummaryDialog(context, ref);
                            }
                          },
                          child: Container(
                            padding: const EdgeInsets.all(16),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(20),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withOpacity(0.05),
                                  blurRadius: 10,
                                  offset: const Offset(0, 4),
                                ),
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
                                  child: Icon(
                                    isDelegate ? Icons.inbox : Icons.send,
                                    color: const Color(0xFF3F51B5),
                                  ),
                                ),
                                const SizedBox(width: 16),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        isDelegate ? l10n.receivedSummaries : l10n.sendSummary,
                                        style: const TextStyle(
                                          fontSize: 16,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                      Text(
                                        isDelegate 
                                          ? "View summaries sent by students" 
                                          : "Share your summaries with the class",
                                        style: const TextStyle(
                                          fontSize: 13,
                                          color: Colors.grey,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                const Icon(Icons.chevron_right, color: Colors.grey),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showSendSummaryDialog(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final subjectController = TextEditingController();
    final doctorController = TextEditingController();
    final descriptionController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Text(l10n.sendSummary, style: const TextStyle(color: Color(0xFF3F51B5), fontWeight: FontWeight.bold)),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              _dialogField(subjectController, l10n.subject, Icons.book_outlined),
              const SizedBox(height: 12),
              _dialogField(doctorController, l10n.doctor, Icons.person_outline),
              const SizedBox(height: 12),
              _dialogField(descriptionController, l10n.description, Icons.notes, maxLines: 2),
              const SizedBox(height: 12),
              OutlinedButton.icon(
                onPressed: () {
                  // File picker logic would go here
                },
                icon: const Icon(Icons.attach_file),
                label: Text(l10n.uploadFile),
                style: OutlinedButton.styleFrom(
                  minimumSize: const Size(double.infinity, 50),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: Text(l10n.cancel, style: const TextStyle(color: Colors.grey))),
          ElevatedButton(
            onPressed: () async {
              if (subjectController.text.isEmpty) return;
              final uploader = await SecureStorageService.getName() ?? 'Student';
              final desc = '${l10n.doctor}: ${doctorController.text}\n${descriptionController.text}';
              
              await ref.read(contentProvider.notifier).addContent(
                title: subjectController.text.trim(),
                description: desc.trim(),
                category: 'summaries',
                uploaderName: uploader, fileName: '',
              );
              if (context.mounted) {
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text(l10n.success), backgroundColor: Colors.green),
                );
              }
            },
            style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF3F51B5), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10))),
            child: Text(l10n.submit, style: const TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  Widget _dialogField(TextEditingController controller, String label, IconData icon, {int maxLines = 1}) {
    return TextField(
      controller: controller,
      maxLines: maxLines,
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: Icon(icon, color: const Color(0xFF3F51B5)),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      ),
    );
  }

  Widget _header(AppLocalizations l10n) {
    return Container(
      padding: const EdgeInsets.fromLTRB(16, 18, 20, 28),
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [Color(0xFF3F51B5), Color(0xFF6A5AE0)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.only(
          bottomLeft: Radius.circular(28),
          bottomRight: Radius.circular(28),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              _menuButton(),
              const Spacer(),
              const Icon(Icons.school_outlined, color: Colors.white70, size: 22),
            ],
          ),
          const SizedBox(height: 16),
          Text(
            '${l10n.welcome}, $studentName',
            style: const TextStyle(
              color: Colors.white,
              fontSize: 22,
              fontWeight: FontWeight.w600,
              height: 1.3,
            ),
          ),
          const SizedBox(height: 6),
          const Text(
            'Access your academic content easily',
            style: TextStyle(color: Colors.white70, fontSize: 13),
          ),
        ],
      ),
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
          Text(a.subject, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: Color(0xFF3F51B5))),
          const Divider(),
          _infoRow(Icons.person_outline, '${l10n.doctor}: ${a.doctor}'),
          const SizedBox(height: 8),
          _infoRow(Icons.access_time, '${l10n.time}: ${a.time}'),
          const SizedBox(height: 8),
          _infoRow(Icons.place_outlined, '${l10n.place}: ${a.place}'),
          if (a.note.isNotEmpty) ...[
            const SizedBox(height: 8),
            _infoRow(Icons.notes, '${l10n.note}: ${a.note}'),
          ],
        ],
      ),
    );
  }

  Widget _infoRow(IconData icon, String text) {
    return Row(
      children: [
        Icon(icon, size: 16, color: Colors.grey),
        const SizedBox(width: 8),
        Expanded(child: Text(text, style: const TextStyle(fontSize: 13, color: Colors.black87))),
      ],
    );
  }

  Widget _menuButton() {
    return InkWell(
      borderRadius: BorderRadius.circular(12),
      onTap: () => _scaffoldKey.currentState?.openDrawer(),
      child: Container(
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.15),
          borderRadius: BorderRadius.circular(12),
        ),
        child: const Icon(Icons.menu, color: Colors.white, size: 22),
      ),
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
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 32, color: const Color(0xFF3F51B5)),
            const SizedBox(height: 12),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8.0),
              child: Text(
                title,
                textAlign: TextAlign.center,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: Colors.black87,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
