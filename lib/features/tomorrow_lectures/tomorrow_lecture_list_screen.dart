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
      backgroundColor: const Color(0xFFF8F9FA),
      appBar: AppBar(
        title: Text(l10n.tomorrowLectures, style: const TextStyle(color: Colors.black, fontWeight: FontWeight.bold, fontSize: 22)),
        backgroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
        iconTheme: const IconThemeData(color: Colors.black),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh_rounded, size: 28),
            onPressed: _fetchTomorrowLectures,
          )
        ],
      ),
      body: lectures.isEmpty
          ? Center(child: Text(l10n.noContent, style: const TextStyle(fontSize: 18, color: Colors.grey)))
          : ListView.builder(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              itemCount: lectures.length,
              itemBuilder: (context, index) {
                final lecture = lectures[index];
                final canDelete = isDelegate && lecture.delegateId == currentUserId;

                return Container(
                  margin: const EdgeInsets.only(bottom: 16),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.05),
                        blurRadius: 10,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(16),
                    child: IntrinsicHeight(
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          // Side accent bar
                          Container(
                            width: 6,
                            color: const Color(0xFF3F51B5),
                          ),
                          Expanded(
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
                                          lecture.subject,
                                          style: const TextStyle(
                                            fontWeight: FontWeight.w900,
                                            fontSize: 18,
                                            color: Color(0xFF1A237E),
                                          ),
                                          maxLines: 1,
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                      ),
                                      if (canDelete)
                                        IconButton(
                                          icon: const Icon(Icons.delete_sweep_outlined, color: Colors.redAccent, size: 24),
                                          onPressed: () => _confirmDelete(context, lecture.id, lecture.delegateId!),
                                          constraints: const BoxConstraints(),
                                          padding: EdgeInsets.zero,
                                        ),
                                    ],
                                  ),
                                  const Divider(height: 20, thickness: 0.5),
                                  if (lecture.doctor != null && lecture.doctor!.isNotEmpty)
                                    Padding(
                                      padding: const EdgeInsets.only(bottom: 8),
                                      child: Row(
                                        children: [
                                          const Icon(Icons.person_pin_rounded, size: 20, color: Color(0xFF3F51B5)),
                                          const SizedBox(width: 8),
                                          Text(
                                            '${l10n.doctor}: ',
                                            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: Colors.black87),
                                          ),
                                          Expanded(
                                            child: Text(
                                              lecture.doctor!,
                                              style: const TextStyle(fontSize: 14, color: Colors.black54, fontWeight: FontWeight.w500),
                                              maxLines: 1,
                                              overflow: TextOverflow.ellipsis,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  Row(
                                    children: [
                                      if (lecture.time != null && lecture.time!.isNotEmpty)
                                        Expanded(
                                          child: Row(
                                            children: [
                                              const Icon(Icons.alarm_on_rounded, size: 20, color: Color(0xFF3F51B5)),
                                              const SizedBox(width: 8),
                                              Text(
                                                lecture.time!,
                                                style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: Colors.black87),
                                              ),
                                            ],
                                          ),
                                        ),
                                      if (lecture.room != null && lecture.room!.isNotEmpty)
                                        Expanded(
                                          child: Row(
                                            children: [
                                              const Icon(Icons.meeting_room_outlined, size: 20, color: Color(0xFF3F51B5)),
                                              const SizedBox(width: 8),
                                              Text(
                                                lecture.room!,
                                                style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: Colors.black87),
                                              ),
                                            ],
                                          ),
                                        ),
                                    ],
                                  ),
                                  const SizedBox(height: 12),
                                  Align(
                                    alignment: Alignment.bottomRight,
                                    child: Text(
                                      '${lecture.createdAt.day}/${lecture.createdAt.month}/${lecture.createdAt.year}',
                                      style: TextStyle(color: Colors.grey.shade500, fontSize: 12, fontWeight: FontWeight.w500),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              },
            ),
      floatingActionButton: isDelegate
          ? FloatingActionButton.extended(
              onPressed: _showAddTomorrowLectureDialog,
              backgroundColor: const Color(0xFF3F51B5),
              elevation: 4,
              icon: const Icon(Icons.add_task_rounded, color: Colors.white),
              label: Text(l10n.addAnnouncement, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16)),
            )
          : null,
    );
  }
}
