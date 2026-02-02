//tommowerow lectures
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../core/auth/user_role.dart';
import '../../core/localization/app_localizations.dart';
import '../../core/providers/tomorrow_lecture_provider.dart';
import '../../core/models/tomorrow_lecture_model.dart';
import 'add_tomorrow_lecture_dialog.dart';

class TomorrowLectureListScreen extends ConsumerStatefulWidget {
  final UserRole userRole;
  const TomorrowLectureListScreen({super.key, required this.userRole});

  @override
  ConsumerState<TomorrowLectureListScreen> createState() => _TomorrowLectureListScreenState();
}

class _TomorrowLectureListScreenState extends ConsumerState<TomorrowLectureListScreen> {
  final currentUserId = Supabase.instance.client.auth.currentUser?.id;

  @override
  void initState() {
    super.initState();
    _fetchTomorrowLectures();
  }

  Future<void> _fetchTomorrowLectures() async {
    ref.read(tomorrowLectureProvider.notifier).fetchTomorrowLectures();
  }

  void _showAddTomorrowLectureDialog() {
    showDialog(
      context: context,
      builder: (_) => const AddTomorrowLectureDialog(),
    );
  }

  void _confirmDelete(BuildContext context, String contentId, String delegateId) {
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
              final errorMessage = await ref.read(tomorrowLectureProvider.notifier).deleteTomorrowLecture(contentId, delegateId);
              if (mounted) {
                if (errorMessage == null) {
                  ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(l10n.success)));
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('${l10n.error}: $errorMessage'),
                      backgroundColor: Colors.red,
                    ),
                  );
                }
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
    final lectures = ref.watch(tomorrowLectureProvider);
    final l10n = AppLocalizations.of(context);
    final isDelegate = widget.userRole == UserRole.delegate || widget.userRole == UserRole.admin;

    return Scaffold(
      backgroundColor: const Color(0xFFF6F7FB),
      appBar: AppBar(
        title: Text(l10n.tomorrowLectures, style: const TextStyle(color: Colors.black, fontWeight: FontWeight.bold)),
        backgroundColor: Colors.white,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.black),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _fetchTomorrowLectures,
          )
        ],
      ),
      body: lectures.isEmpty
          ? Center(child: Text(l10n.noContent))
          : ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: lectures.length,
              itemBuilder: (context, index) {
                final lecture = lectures[index];
                final canDelete = isDelegate && lecture.delegateId == currentUserId;

                return Container(
                  width: double.infinity,
                  margin: const EdgeInsets.only(bottom: 16),
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
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          const Icon(Icons.school, size: 18, color: Color(0xFF3F51B5)),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              lecture.subject,
                              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          if (canDelete)
                            IconButton(
                              icon: const Icon(Icons.delete_outline, color: Colors.red, size: 20),
                              onPressed: () => _confirmDelete(context, lecture.id, lecture.delegateId!),
                              constraints: const BoxConstraints(),
                              padding: EdgeInsets.zero,
                            ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      Row(
                        children: [
                          Expanded(flex: 2, child: _lectureInfoRow(Icons.person, lecture.doctor ?? '-')),
                          const SizedBox(width: 4),
                          Expanded(flex: 1, child: _lectureInfoRow(Icons.room, lecture.room ?? '-')),
                          const SizedBox(width: 4),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                            decoration: BoxDecoration(
                              color: const Color(0xFF3F51B5).withOpacity(0.1),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                const Icon(Icons.access_time, size: 12, color: Color(0xFF3F51B5)),
                                const SizedBox(width: 4),
                                Text(
                                  lecture.time ?? '-',
                                  style: const TextStyle(fontSize: 11, color: Color(0xFF3F51B5), fontWeight: FontWeight.bold),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                );
              },
            ),
      floatingActionButton: isDelegate
          ? FloatingActionButton.extended(
              onPressed: _showAddTomorrowLectureDialog,
              backgroundColor: const Color(0xFF3F51B5),
              icon: const Icon(Icons.add, color: Colors.white),
              label: Text(l10n.addAnnouncement, style: const TextStyle(color: Colors.white)),
            )
          : null,
    );
  }

  Widget _lectureInfoRow(IconData icon, String text) {
    return Row(
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
    );
  }
}
