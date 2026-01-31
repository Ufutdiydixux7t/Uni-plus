import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:uuid/uuid.dart';
import '../../core/localization/app_localizations.dart';
import '../../core/storage/secure_storage_service.dart';
import '../../core/providers/tomorrow_lecture_provider.dart';
import '../../core/providers/content_provider.dart';
import '../../core/providers/lecture_provider.dart';
import '../../core/providers/grade_provider.dart';
import '../../core/providers/task_provider.dart';
import '../../core/providers/summary_provider.dart';
import '../../core/providers/daily_report_provider.dart';
import '../../core/providers/form_provider.dart';
import '../../shared/widgets/app_drawer.dart';
import '../shared/content_list_screen.dart';
import '../lectures/lectures_screen.dart';
import '../summaries/summaries_screen.dart';
import '../forms/forms_screen.dart';
import '../daily_reports/daily_reports_screen.dart';
import '../tasks/tasks_screen.dart';
import '../../core/auth/user_role.dart';
import '../grades/grades_list_screen.dart';

class AdminDashboardScreen extends ConsumerStatefulWidget {
  const AdminDashboardScreen({super.key});

  @override
  ConsumerState<AdminDashboardScreen> createState() => _AdminDashboardScreenState();
}

class _AdminDashboardScreenState extends ConsumerState<AdminDashboardScreen> {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  String joinCode = '';
  bool _isCodeLoading = true;

  @override
  void initState() {
    super.initState();
    _loadJoinCode();
    _refreshData();
  }

  void _refreshData() {
    ref.read(tomorrowLectureProvider.notifier).fetchTomorrowLectures();
    ref.read(contentProvider.notifier).fetchContent();
    ref.read(lectureProvider.notifier).fetchLectures();
    ref.read(gradeProvider.notifier).fetchGrades();
    ref.read(taskProvider.notifier).fetchTasks();
    ref.read(summaryProvider.notifier).fetchSummaries();
    ref.read(dailyReportProvider.notifier).fetchDailyReports();
    ref.read(formProvider.notifier).fetchForms();
  }

  String _generateJoinCode() {
    const chars = 'ABCDEFGHJKLMNPQRSTUVWXYZ23456789';
    final rnd = Random();
    return String.fromCharCodes(Iterable.generate(
        8, (_) => chars.codeUnitAt(rnd.nextInt(chars.length))));
  }

  Future<void> _loadJoinCode() async {
    setState(() => _isCodeLoading = true);
    try {
      final supabase = Supabase.instance.client;
      final user = supabase.auth.currentUser;
      
      if (user == null) return;

      final profile = await supabase
          .from('profiles')
          .select('join_code, role')
          .eq('id', user.id)
          .maybeSingle();

      String? code = profile?['join_code'];

      if (code == null || code.isEmpty) {
        final group = await supabase
            .from('groups')
            .select('join_code')
            .eq('delegate_id', user.id)
            .maybeSingle();
        code = group?['join_code'];
      }

      if (code == null || code.isEmpty) {
        code = _generateJoinCode();
        final now = DateTime.now().toIso8601String();

        final existingGroup = await supabase
            .from('groups')
            .select()
            .eq('delegate_id', user.id)
            .maybeSingle();

        if (existingGroup == null) {
          await supabase.from('groups').insert({
            'id': const Uuid().v4(),
            'delegate_id': user.id,
            'join_code': code,
            'created_at': now,
          });
        } else {
          await supabase.from('groups').update({
            'join_code': code,
          }).eq('delegate_id', user.id);
        }

        await supabase.from('profiles').update({
          'join_code': code,
        }).eq('id', user.id);
      }

      await SecureStorageService.saveUser(
        role: (profile?['role'] == 'admin') ? UserRole.admin : UserRole.delegate,
        name: code,
      );

      if (mounted) {
        setState(() {
          joinCode = code!;
          _isCodeLoading = false;
        });
      }
    } catch (e) {
      debugPrint('Error loading join code: $e');
      if (mounted) setState(() => _isCodeLoading = false);
    }
  }

  void _navigateToContent(String title, String category) {
    if (category == 'grades') {
      Navigator.push(context, MaterialPageRoute(builder: (_) => const GradesListScreen(userRole: UserRole.delegate)));
    } else if (category == 'lectures') {
      Navigator.push(context, MaterialPageRoute(builder: (_) => const LecturesScreen()));
    } else if (category == 'summaries') {
      Navigator.push(context, MaterialPageRoute(builder: (_) => const SummariesScreen()));
    } else if (category == 'forms') {
      Navigator.push(context, MaterialPageRoute(builder: (_) => const FormsScreen()));
    } else if (category == 'tasks') {
      Navigator.push(context, MaterialPageRoute(builder: (_) => const TasksScreen()));
    } else if (category == 'reports' || category == 'daily_reports') {
      Navigator.push(context, MaterialPageRoute(builder: (_) => const DailyReportsScreen()));
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

  void _showAddTomorrowLectureDialog() {
    final l10n = AppLocalizations.of(context);
    final subjectController = TextEditingController();
    final doctorController = TextEditingController();
    final roomController = TextEditingController();
    final timeController = TextEditingController();
    final formKey = GlobalKey<FormState>();
    bool isSubmitting = false;

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          title: Text(
            l10n.locale.languageCode == 'ar' ? 'إضافة محاضرة غداً' : 'Add Tomorrow Lecture',
            style: const TextStyle(color: Color(0xFF3F51B5), fontWeight: FontWeight.bold),
          ),
          content: Form(
            key: formKey,
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  _buildDialogField(subjectController, l10n.subject, Icons.book_outlined, l10n),
                  _buildDialogField(doctorController, l10n.doctor, Icons.person_outline, l10n),
                  _buildDialogField(roomController, l10n.locale.languageCode == 'ar' ? 'القاعة' : 'Room', Icons.room_outlined, l10n),
                  _buildDialogField(timeController, l10n.locale.languageCode == 'ar' ? 'الوقت' : 'Time', Icons.access_time_outlined, l10n),
                ],
              ),
            ),
          ),
          actions: [
            TextButton(
              onPressed: isSubmitting ? null : () => Navigator.pop(context),
              child: Text(l10n.cancel, style: TextStyle(color: Colors.grey.shade600)),
            ),
            ElevatedButton(
              onPressed: isSubmitting ? null : () async {
                if (formKey.currentState!.validate()) {
                  setDialogState(() => isSubmitting = true);
                  final error = await ref.read(tomorrowLectureProvider.notifier).addTomorrowLecture(
                    subject: subjectController.text,
                    doctor: doctorController.text,
                    room: roomController.text,
                    time: timeController.text,
                  );
                  if (mounted) {
                    if (error == null) {
                      Navigator.pop(context);
                      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(l10n.success)));
                    } else {
                      setDialogState(() => isSubmitting = false);
                      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(error), backgroundColor: Colors.red));
                    }
                  }
                }
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF3F51B5),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
              child: isSubmitting 
                ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                : Text(l10n.save, style: const TextStyle(color: Colors.white)),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDialogField(TextEditingController controller, String label, IconData icon, AppLocalizations l10n) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: TextFormField(
        controller: controller,
        decoration: InputDecoration(
          labelText: label,
          prefixIcon: Icon(icon, color: const Color(0xFF3F51B5)),
          filled: true,
          fillColor: Colors.grey.shade100,
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
        ),
        validator: (value) => value == null || value.isEmpty ? l10n.requiredField : null,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final tomorrowLectures = ref.watch(tomorrowLectureProvider);

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
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh, color: Colors.black),
            onPressed: () {
              _loadJoinCode();
              _refreshData();
            },
          )
        ],
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _joinCodeCard(l10n),
              const SizedBox(height: 32),
              _tomorrowLecturesSection(l10n, tomorrowLectures),
              const SizedBox(height: 32),
              Text(
                l10n.addContent,
                style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 16),
              _dashboardGrid(l10n),
              const SizedBox(height: 32),
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
                        category: 'student_summaries',
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

  Widget _joinCodeCard(AppLocalizations l10n) {
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
            l10n.locale.languageCode == 'ar' ? 'رمز الانضمام' : 'Join Code',
            style: const TextStyle(color: Colors.white, fontSize: 22, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          Text(
            l10n.locale.languageCode == 'ar' ? 'شارك هذا الرمز مع طلابك للانضمام إلى فصلك.' : 'Share this code with your students to join your class.',
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
                Expanded(
                  child: _isCodeLoading 
                    ? const SizedBox(height: 20, width: 20, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                    : Text(
                        joinCode,
                        style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 18,
                          letterSpacing: 2,
                        ),
                      ),
                ),
                IconButton(
                  icon: const Icon(Icons.copy, color: Colors.white),
                  onPressed: joinCode.isEmpty ? null : () {
                    Clipboard.setData(ClipboardData(text: joinCode));
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

  Widget _tomorrowLecturesSection(AppLocalizations l10n, List<dynamic> lectures) {
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
            IconButton(
              onPressed: _showAddTomorrowLectureDialog,
              icon: const Icon(Icons.add_circle, color: Color(0xFF3F51B5), size: 28),
              tooltip: l10n.addContent,
            ),
          ],
        ),
        const SizedBox(height: 16),
        if (lectures.isEmpty)
          _emptyState(l10n.noContent)
        else
          SizedBox(
            height: 160,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              physics: const BouncingScrollPhysics(),
              itemCount: lectures.length,
              itemBuilder: (context, index) => _tomorrowLectureCard(lectures[index], l10n),
            ),
          ),
      ],
    );
  }

  Widget _emptyState(String message) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Center(child: Text(message, style: const TextStyle(color: Colors.grey))),
    );
  }

  Widget _tomorrowLectureCard(dynamic lecture, AppLocalizations l10n) {
    return Container(
      width: 220,
      margin: const EdgeInsets.only(right: 16, bottom: 8),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10, offset: const Offset(0, 4)),
        ],
      ),
      child: Stack(
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  const Icon(Icons.school, size: 18, color: Color(0xFF3F51B5)),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      lecture.subject,
                      style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              _lectureInfoRow(Icons.person, lecture.doctor ?? ''),
              _lectureInfoRow(Icons.room, lecture.room ?? ''),
              const Spacer(),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                decoration: BoxDecoration(
                  color: const Color(0xFF3F51B5).withOpacity(0.1),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(Icons.access_time, size: 14, color: Color(0xFF3F51B5)),
                    const SizedBox(width: 6),
                    Text(
                      lecture.time ?? '',
                      style: const TextStyle(fontSize: 12, color: Color(0xFF3F51B5), fontWeight: FontWeight.bold),
                    ),
                  ],
                ),
              ),
            ],
          ),
          Positioned(
            top: -10,
            right: -10,
            child: IconButton(
              icon: const Icon(Icons.delete_outline, color: Colors.red, size: 18),
              onPressed: () => _confirmDeleteLecture(lecture.id, lecture.delegateId ?? ''),
            ),
          ),
        ],
      ),
    );
  }

  Widget _lectureInfoRow(IconData icon, String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 4),
      child: Row(
        children: [
          Icon(icon, size: 14, color: Colors.grey),
          const SizedBox(width: 6),
          Expanded(
            child: Text(
              text,
              style: TextStyle(color: Colors.grey.shade700, fontSize: 12),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }

  void _confirmDeleteLecture(String id, String delegateId) {
    final l10n = AppLocalizations.of(context);
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(l10n.delete),
        content: Text(l10n.confirmDelete),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: Text(l10n.cancel)),
          TextButton(
            onPressed: () async {
              Navigator.pop(context);
              await ref.read(tomorrowLectureProvider.notifier).deleteTomorrowLecture(id, delegateId);
            },
            child: Text(l10n.delete, style: const TextStyle(color: Colors.red)),
          ),
        ],
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
    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
        side: BorderSide(color: Colors.grey.shade200),
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(20),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 32, color: const Color(0xFF3F51B5)),
            const SizedBox(height: 12),
            Text(title, style: const TextStyle(fontWeight: FontWeight.bold)),
          ],
        ),
      ),
    );
  }

  Widget _horizontalActionCard({required IconData icon, required String title, required String subtitle, required VoidCallback onTap}) {
    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
        side: BorderSide(color: Colors.grey.shade200),
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(20),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(color: const Color(0xFF3F51B5).withOpacity(0.1), borderRadius: BorderRadius.circular(12)),
                child: Icon(icon, color: const Color(0xFF3F51B5)),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                    Text(subtitle, style: TextStyle(color: Colors.grey.shade600, fontSize: 12)),
                  ],
                ),
              ),
              const Icon(Icons.arrow_forward_ios, size: 16, color: Colors.grey),
            ],
          ),
        ),
      ),
    );
  }
}
