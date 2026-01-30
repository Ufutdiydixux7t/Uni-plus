import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../core/auth/user_role.dart';
import '../../core/providers/grade_provider.dart';
import '../../core/localization/app_localizations.dart';
import 'add_grade_dialog.dart'; // Import the new AddGradeDialog

class GradesListScreen extends ConsumerStatefulWidget {
  final UserRole userRole;
  const GradesListScreen({super.key, required this.userRole});

  @override
  ConsumerState<GradesListScreen> createState() => _GradesListScreenState();
}

class _GradesListScreenState extends ConsumerState<GradesListScreen> {
  final currentUserId = Supabase.instance.client.auth.currentUser?.id;

  @override
  void initState() {
    super.initState();
    _fetchGrades();
  }

  Future<void> _fetchGrades() async {
    // Fetch all grades globally as there is no group_id filter
    ref.read(gradeProvider.notifier).fetchGrades();
  }

  void _showAddGradeDialog() {
    showDialog(
      context: context,
      builder: (_) => const AddGradeDialog(),
    );
  }

  void _confirmDelete(BuildContext context, String gradeId, String createdBy) {
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
              final success = await ref.read(gradeProvider.notifier).deleteGrade(gradeId, createdBy);
              if (mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text(success ? l10n.success : l10n.error)),
                );
              }
            },
            child: Text(l10n.delete, style: const TextStyle(color: Colors.red)),
          ),
        ],
      ),
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
          ? Center(child: Text(l10n.noContent))
          : ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: grades.length,
              itemBuilder: (context, index) {
                final grade = grades[index];
                final canDelete = isDelegate && grade.createdBy == currentUserId;

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
                            Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                if (canDelete)
                                  IconButton(
                                    icon: const Icon(Icons.delete_outline, color: Colors.red, size: 20),
                                    onPressed: () => _confirmDelete(context, grade.id, grade.createdBy!),
                                  ),
                                if (grade.fileUrl != null && grade.fileUrl!.isNotEmpty)
                                  IconButton(
                                    icon: const Icon(Icons.open_in_new, color: Color(0xFF3F51B5), size: 20),
                                    onPressed: () async {
                                      final url = Uri.parse(grade.fileUrl!);
                                      if (await canLaunchUrl(url)) {
                                        await launchUrl(url, mode: LaunchMode.externalApplication);
                                      }
                                    },
                                  ),
                              ],
                            ),
                          ],
                        ),
                        const SizedBox(height: 4),
                        if (grade.doctor != null && grade.doctor!.isNotEmpty)
                          Text('${l10n.doctor}: ${grade.doctor}', style: TextStyle(color: Colors.grey.shade600, fontSize: 14)),
                        const Divider(height: 24),
                        if (grade.note != null && grade.note!.isNotEmpty)
                          Text('${l10n.note}: ${grade.note!}', style: const TextStyle(fontSize: 14, height: 1.4)),
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
          ? FloatingActionButton.extended(
              onPressed: _showAddGradeDialog,
              backgroundColor: const Color(0xFF3F51B5),
              icon: const Icon(Icons.add, color: Colors.white),
              label: Text(l10n.addContent, style: const TextStyle(color: Colors.white)),
            )
          : null,
    );
  }
}
