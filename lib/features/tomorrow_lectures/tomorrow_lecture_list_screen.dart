import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../core/auth/user_role.dart';
import '../../core/localization/app_localizations.dart';
import '../../core/providers/tomorrow_lecture_provider.dart'; // New TomorrowLecture Provider
import '../../core/models/tomorrow_lecture_model.dart'; // New TomorrowLecture Model
import 'add_tomorrow_lecture_dialog.dart'; // New TomorrowLecture Dialog

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
          : GridView.builder(
              padding: const EdgeInsets.all(16),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                crossAxisSpacing: 12,
                mainAxisSpacing: 12,
                childAspectRatio: 0.8,
              ),
              itemCount: lectures.length,
              itemBuilder: (context, index) {
                final lecture = lectures[index];
                // Delegate can delete only what they created
                final canDelete = isDelegate && lecture.delegateId == currentUserId;

                return Card(
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                  elevation: 2,
                  child: Padding(
                    padding: const EdgeInsets.all(12),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const Icon(Icons.schedule, color: Color(0xFF3F51B5), size: 20),
                            if (canDelete)
                              IconButton(
                                icon: const Icon(Icons.delete_outline, color: Colors.red, size: 20),
                                onPressed: () => _confirmDelete(context, lecture.id, lecture.delegateId!),
                                constraints: const BoxConstraints(),
                                padding: EdgeInsets.zero,
                              ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        Text(
                          lecture.subject,
                          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 4),
                        if (lecture.doctor != null && lecture.doctor!.isNotEmpty)
                          Text('${l10n.doctor}: ${lecture.doctor}', style: TextStyle(color: Colors.grey.shade600, fontSize: 12)),
                        const SizedBox(height: 4),
                        if (lecture.time != null && lecture.time!.isNotEmpty)
                          Text('${l10n.time}: ${lecture.time}', style: TextStyle(color: Colors.grey.shade600, fontSize: 12)),
                        const SizedBox(height: 4),
                        if (lecture.room != null && lecture.room!.isNotEmpty)
                          Text('${l10n.room}: ${lecture.room}', style: TextStyle(color: Colors.grey.shade600, fontSize: 12)),
                        const SizedBox(height: 8),
                        Text(
                          '${lecture.createdAt.day}/${lecture.createdAt.month}/${lecture.createdAt.year}',
                          style: TextStyle(color: Colors.grey.shade500, fontSize: 10),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
      floatingActionButton: isDelegate
          ? FloatingActionButton.extended(
              onPressed: _showAddTomorrowLectureDialog,
              backgroundColor: const Color(0xFF3F51B5),
              icon: const Icon(Icons.add, color: Colors.white),
              label: Text(l10n.addAnnouncement, style: const TextStyle(color: Colors.white)), // Changed to addAnnouncement
            )
          : null,
    );
  }
}
