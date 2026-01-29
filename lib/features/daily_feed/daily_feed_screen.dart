import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/providers/content_provider.dart';
import '../../core/storage/secure_storage_service.dart';
import '../../core/localization/app_localizations.dart';
import '../../core/providers/announcement_provider.dart';
import '../../core/auth/user_role.dart';
import '../../shared/widgets/app_drawer.dart';
import '../shared/content_list_screen.dart';
import '../lectures/lectures_screen.dart';
import '../summaries/summaries_screen.dart';
import '../summaries/send_summary_screen.dart';
import './models/home_grid_item.dart';

class DailyFeedScreen extends ConsumerStatefulWidget {
  const DailyFeedScreen({super.key});

  @override
  ConsumerState<DailyFeedScreen> createState() => _DailyFeedScreenState();
}

class _DailyFeedScreenState extends ConsumerState<DailyFeedScreen> {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  String studentName = '';
  UserRole _userRole = UserRole.student;

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  Future<void> _loadUserData() async {
    final name = await SecureStorageService.getName();
    final role = await SecureStorageService.getUserRole();
    if (!mounted) return;
    setState(() {
      studentName = name ?? 'User';
      _userRole = role;
    });
  }

  List<HomeGridItem> _getGridItems(AppLocalizations l10n) {
    return [
      HomeGridItem(icon: Icons.menu_book, title: l10n.lectures, category: 'lectures'),
      HomeGridItem(icon: Icons.assessment_outlined, title: l10n.dailyReports, category: 'reports'),
      HomeGridItem(icon: Icons.description, title: l10n.summaries, category: 'summaries'),
      HomeGridItem(icon: Icons.task_alt, title: l10n.tasks, category: 'tasks'),
      HomeGridItem(icon: Icons.assignment, title: l10n.forms, category: 'forms'),
      HomeGridItem(icon: Icons.grade, title: l10n.grades, category: 'grades'),
    ];
  }

  void _handleItemTap(HomeGridItem item) {
    if (item.category == 'lectures') {
      Navigator.push(context, MaterialPageRoute(builder: (_) => const LecturesScreen()));
    } else if (item.category == 'summaries') {
      Navigator.push(context, MaterialPageRoute(builder: (_) => const SummariesScreen()));
    } else {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => ContentListScreen(
            category: item.category,
            title: item.title,
          ),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final announcements = ref.watch(announcementProvider);
    final isDelegate = _userRole == UserRole.delegate || _userRole == UserRole.admin;
    final gridItems = _getGridItems(l10n);

    return Scaffold(
      key: _scaffoldKey,
      backgroundColor: const Color(0xFFF6F7FB),
      drawer: const AppDrawer(),
      body: SafeArea(
        child: CustomScrollView(
          physics: const BouncingScrollPhysics(),
          slivers: [
            SliverToBoxAdapter(child: _header(l10n, isDelegate)),
            
            // Tomorrow Lectures Section - Student and Delegate (Read Only)
            SliverPadding(
              padding: const EdgeInsets.fromLTRB(20, 24, 20, 0),
              sliver: SliverToBoxAdapter(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          l10n.tomorrowLectures,
                          style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                          decoration: BoxDecoration(
                            color: Colors.blue.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Text(
                            l10n.readOnly,
                            style: const TextStyle(fontSize: 12, color: Colors.blue, fontWeight: FontWeight.w500),
                          ),
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
                          borderRadius: BorderRadius.circular(16),
                          boxShadow: [
                            BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10, offset: const Offset(0, 4)),
                          ],
                        ),
                        child: Center(
                          child: Text(
                            l10n.noContent,
                            style: const TextStyle(color: Colors.grey),
                          ),
                        ),
                      )
                    else
                      GridView.builder(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 2,
                          crossAxisSpacing: 12,
                          mainAxisSpacing: 12,
                          childAspectRatio: 1.2,
                        ),
                        itemCount: announcements.length,
                        itemBuilder: (context, index) => _announcementCard(announcements[index], l10n),
                      ),
                  ],
                ),
              ),
            ),

            SliverPadding(
              padding: const EdgeInsets.fromLTRB(20, 24, 20, 0),
              sliver: SliverGrid(
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  crossAxisSpacing: 16,
                  mainAxisSpacing: 16,
                  childAspectRatio: 1.1,
                ),
                delegate: SliverChildBuilderDelegate(
                  (context, index) {
                    final item = gridItems[index];
                    return _actionCard(item.icon, item.title, () => _handleItemTap(item));
                  },
                  childCount: gridItems.length,
                ),
              ),
            ),

            // Received Summaries (Delegate) / Send Summary (Student)
            SliverPadding(
              padding: const EdgeInsets.fromLTRB(20, 24, 20, 40),
              sliver: SliverToBoxAdapter(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      isDelegate ? l10n.receivedSummaries : l10n.sendSummary,
                      style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 16),
                    _horizontalActionCard(
                      icon: isDelegate ? Icons.inbox_rounded : Icons.send_rounded,
                      title: isDelegate ? l10n.receivedSummaries : l10n.sendSummary,
                      subtitle: l10n.locale.languageCode == 'ar' 
                          ? (isDelegate ? "عرض الملخصات المرسلة من الطلاب" : "شارك ملخصاتك مع زملائك")
                          : (isDelegate ? "View summaries sent by students" : "Share your summaries with the class"),
                      onTap: () {
                        if (isDelegate) {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => ContentListScreen(
                                category: 'student_summaries',
                                title: l10n.receivedSummaries,
                              ),
                            ),
                          );
                        } else {
                          _showSendSummaryDialog(context, l10n);
                        }
                      },
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _header(AppLocalizations l10n, bool isDelegate) {
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
              IconButton(
                icon: const Icon(Icons.menu, color: Colors.white),
                onPressed: () => _scaffoldKey.currentState?.openDrawer(),
              ),
              const Spacer(),
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
          Text(
            l10n.locale.languageCode == 'ar' ? 'الوصول إلى المحتوى الأكاديمي بسهولة' : 'Access your academic content easily',
            style: const TextStyle(color: Colors.white70, fontSize: 13),
          ),
        ],
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
            BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10, offset: const Offset(0, 4)),
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
                style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 14),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _announcementCard(Announcement announcement, AppLocalizations l10n) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(color: Colors.black.withOpacity(0.03), blurRadius: 8, offset: const Offset(0, 2)),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            announcement.subject,
            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: Color(0xFF3F51B5)),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
          const SizedBox(height: 6),
          _infoRow(Icons.person_outline, announcement.doctor),
          _infoRow(Icons.room_outlined, announcement.place),
          _infoRow(Icons.access_time, announcement.time),
        ],
      ),
    );
  }

  Widget _infoRow(IconData icon, String text) {
    return Padding(
      padding: const EdgeInsets.only(top: 4.0),
      child: Row(
        children: [
          Icon(icon, size: 12, color: Colors.grey),
          const SizedBox(width: 4),
          Expanded(
            child: Text(
              text,
              style: const TextStyle(fontSize: 11, color: Colors.black87),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }

  Widget _horizontalActionCard({required IconData icon, required String title, required String subtitle, required VoidCallback onTap}) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10, offset: const Offset(0, 4)),
          ],
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(12),
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
                  Text(title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                  const SizedBox(height: 4),
                  Text(subtitle, style: const TextStyle(color: Colors.grey, fontSize: 12)),
                ],
              ),
            ),
            const Icon(Icons.chevron_right, color: Colors.grey),
          ],
        ),
      ),
    );
  }

  void _showSendSummaryDialog(BuildContext context, AppLocalizations l10n) {
    showDialog(
      context: context,
      builder: (context) => const SendSummaryDialog(),
    );
  }
}

class SendSummaryDialog extends ConsumerStatefulWidget {
  const SendSummaryDialog({super.key});

  @override
  ConsumerState<SendSummaryDialog> createState() => _SendSummaryDialogState();
}

class _SendSummaryDialogState extends ConsumerState<SendSummaryDialog> {
  final _subjectController = TextEditingController();
  final _doctorController = TextEditingController();
  final _noteController = TextEditingController();
  String _fileName = '';
  String? _filePath;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return AlertDialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      title: Text(l10n.sendSummary, style: const TextStyle(color: Color(0xFF3F51B5), fontWeight: FontWeight.bold)),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            _field(_subjectController, l10n.subject, Icons.book_outlined),
            const SizedBox(height: 12),
            _field(_doctorController, l10n.doctor, Icons.person_outline),
            const SizedBox(height: 12),
            _field(_noteController, l10n.optionalNote, Icons.notes, maxLines: 2),
            const SizedBox(height: 16),
            InkWell(
              onTap: () async {
                // In a real app, use FilePicker. Here we simulate.
                setState(() {
                  _fileName = "summary_file.pdf";
                  _filePath = "/dummy/path/summary_file.pdf";
                });
              },
              child: Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.grey[300]!),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.attach_file, size: 20, color: Color(0xFF3F51B5)),
                    const SizedBox(width: 8),
                    Expanded(child: Text(_fileName.isEmpty ? l10n.attachFile : _fileName, style: TextStyle(color: _fileName.isEmpty ? Colors.grey : Colors.black))),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
      actions: [
        TextButton(onPressed: () => Navigator.pop(context), child: Text(l10n.cancel)),
        ElevatedButton(
          onPressed: () async {
            if (_subjectController.text.isEmpty) return;
            final uploader = await SecureStorageService.getName() ?? 'Student';
            final desc = '${l10n.doctor}: ${_doctorController.text}\n${l10n.note}: ${_noteController.text}';
            await ref.read(contentProvider.notifier).addContent(
              title: _subjectController.text.trim(),
              description: desc.trim(),
              category: 'student_summaries',
              uploaderName: uploader,
              fileName: _fileName,
              filePath: _filePath,
            );
            if (context.mounted) Navigator.pop(context);
          },
          style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF3F51B5)),
          child: Text(l10n.submit, style: const TextStyle(color: Colors.white)),
        ),
      ],
    );
  }

  Widget _field(TextEditingController controller, String label, IconData icon, {int maxLines = 1}) {
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
}
