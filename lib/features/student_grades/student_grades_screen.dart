import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../core/providers/grade_provider.dart';
import '../../core/localization/app_localizations.dart';

class StudentGradesScreen extends ConsumerStatefulWidget {
  const StudentGradesScreen({super.key});

  @override
  ConsumerState<StudentGradesScreen> createState() => _StudentGradesScreenState();
}

class _StudentGradesScreenState extends ConsumerState<StudentGradesScreen> {
  @override
  void initState() {
    super.initState();
    Future.microtask(() {
      final user = Supabase.instance.client.auth.currentUser;
      if (user != null) {
        ref.read(gradeProvider.notifier).fetchGrades(studentId: user.id);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final grades = ref.watch(gradeProvider);
    final l10n = AppLocalizations.of(context);

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.grades, style: const TextStyle(color: Colors.black, fontWeight: FontWeight.bold)),
        backgroundColor: Colors.white,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.black),
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
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(grade.subject, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                            if (grade.fileUrl != null)
                              IconButton(
                                icon: const Icon(Icons.download, color: Color(0xFF3F51B5)),
                                onPressed: () async {
                                  final url = Uri.parse(grade.fileUrl!);
                                  if (await canLaunchUrl(url)) {
                                    await launchUrl(url);
                                  }
                                },
                              ),
                          ],
                        ),
                        if (grade.doctor != null)
                          Text('Doctor: ${grade.doctor}', style: TextStyle(color: Colors.grey.shade600)),
                        const SizedBox(height: 8),
                        if (grade.note != null)
                          Text(grade.note!, style: const TextStyle(fontSize: 14)),
                        const SizedBox(height: 12),
                        Text(
                          'Date: ${grade.createdAt.day}/${grade.createdAt.month}/${grade.createdAt.year}',
                          style: TextStyle(color: Colors.grey.shade500, fontSize: 12),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
    );
  }
}
