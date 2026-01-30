import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../core/auth/user_role.dart';
import '../../core/providers/grade_provider.dart';
import '../../core/localization/app_localizations.dart';
import 'grades_management_sheet.dart'; // New file for the modal sheet

class GradesListScreen extends ConsumerStatefulWidget {
  final UserRole userRole;
  const GradesListScreen({super.key, required this.userRole});

  @override
  ConsumerState<GradesListScreen> createState() => _GradesListScreenState();
}

class _GradesListScreenState extends ConsumerState<GradesListScreen> {
  @override
  void initState() {
    super.initState();
    _fetchGrades();
  }

  Future<void> _fetchGrades() async {
    final supabase = Supabase.instance.client;
    final user = supabase.auth.currentUser;
    if (user == null) return;

    String? studentId;
    String? groupId;

    if (widget.userRole == UserRole.student) {
      // For students, fetch their group ID
      final memberData = await supabase
          .from('group_members')
          .select('group_id')
          .eq('student_id', user.id)
          .maybeSingle();
      groupId = memberData?['group_id'];
      studentId = user.id; // Also fetch grades assigned directly to the student
    } else {
      // For delegates/admins, fetch their group ID
      final groupData = await supabase
          .from('groups')
          .select('id')
          .eq('delegate_id', user.id)
          .maybeSingle();
      groupId = groupData?['id'];
    }

    // Fetch grades for this user/group
    ref.read(gradeProvider.notifier).fetchGrades(
      studentId: studentId,
      groupId: groupId,
    );
  }

  void _showGradesManagement() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (context) => const GradesManagementSheet(),
    );
  }

  @override
  Widget build(BuildContext context) {
    final grades = ref.watch(gradeProvider);
    final l10n = AppLocalizations.of(context);
    final isDelegate = widget.userRole == UserRole.delegate || widget.userRole == UserRole.admin;

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.grades, style: const TextStyle(color: Colors.black, fontWeight: FontWeight.bold)),
        backgroundColor: Colors.white,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.black),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _fetchGrades,
          )
        ],
      ),
      body: grades.isEmpty
          ? const Center(child: Text('No grades available yet.'))
          : ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: grades.length,
              itemBuilder: (context, index) {
                final grade = grades[index];
                return Card(
                  margin: const EdgeInsets.only(bottom: 16),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                  elevation: 2,
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Expanded(
                              child: Text(
                                grade.subject, 
                                style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                            if (grade.fileUrl != null && grade.fileUrl!.isNotEmpty)
                              IconButton(
                                icon: const Icon(Icons.open_in_new, color: Color(0xFF3F51B5)),
                                onPressed: () async {
                                  final url = Uri.parse(grade.fileUrl!);
                                  if (await canLaunchUrl(url)) {
                                    await launchUrl(url, mode: LaunchMode.externalApplication);
                                  }
                                },
                              ),
                          ],
                        ),
                        const SizedBox(height: 4),
                        if (grade.doctor != null && grade.doctor!.isNotEmpty)
                          Text('Doctor: ${grade.doctor}', style: TextStyle(color: Colors.grey.shade600, fontSize: 14)),
                        const Divider(height: 24),
                        if (grade.note != null && grade.note!.isNotEmpty)
                          Text(grade.note!, style: const TextStyle(fontSize: 14, height: 1.4)),
                        const SizedBox(height: 16),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              '${grade.createdAt.day}/${grade.createdAt.month}/${grade.createdAt.year}',
                              style: TextStyle(color: Colors.grey.shade500, fontSize: 12),
                            ),
                            if (grade.fileUrl != null && grade.fileUrl!.isNotEmpty)
                              const Icon(Icons.attach_file, size: 16, color: Colors.grey),
                          ],
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
      floatingActionButton: isDelegate
          ? FloatingActionButton(
              onPressed: _showGradesManagement,
              backgroundColor: const Color(0xFF3F51B5),
              child: const Icon(Icons.add, color: Colors.white),
            )
          : null,
    );
  }
}
