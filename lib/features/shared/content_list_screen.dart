import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/providers/content_provider.dart';
import '../../core/providers/student_summary_provider.dart';
import '../../core/storage/secure_storage_service.dart';
import '../../core/auth/user_role.dart';
import '../../core/localization/app_localizations.dart';
import '../../shared/widgets/add_content_dialog.dart';

class ContentListScreen extends ConsumerStatefulWidget {
  final String category;
  final String title;

  const ContentListScreen({
    super.key,
    required this.category,
    required this.title,
  });

  @override
  ConsumerState<ContentListScreen> createState() => _ContentListScreenState();
}

class _ContentListScreenState extends ConsumerState<ContentListScreen> {
  @override
  void initState() {
    super.initState();
    _fetchData();
  }

  void _fetchData() {
    if (widget.category == 'student_summaries') {
      ref.read(studentSummaryProvider.notifier).fetchStudentSummaries(isDelegate: true);
    } else {
      ref.read(contentProvider.notifier).fetchContent();
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    
    if (widget.category == 'student_summaries') {
      final studentSummaries = ref.watch(studentSummaryProvider);
      return Scaffold(
        backgroundColor: const Color(0xFFF6F7FB),
        appBar: AppBar(
          title: Text(widget.title, style: const TextStyle(color: Colors.black, fontWeight: FontWeight.bold)),
          backgroundColor: Colors.white,
          elevation: 0,
          iconTheme: const IconThemeData(color: Colors.black),
          actions: [
            IconButton(icon: const Icon(Icons.refresh), onPressed: _fetchData),
          ],
        ),
        body: studentSummaries.isEmpty
            ? Center(child: Text(l10n.noContent))
            : ListView.builder(
                padding: const EdgeInsets.all(16),
                itemCount: studentSummaries.length,
                itemBuilder: (context, index) {
                  final summary = studentSummaries[index];
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
                            children: [
                              Container(
                                padding: const EdgeInsets.all(8),
                                decoration: BoxDecoration(
                                  color: const Color(0xFF3F51B5).withOpacity(0.1),
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: const Icon(Icons.description, color: Color(0xFF3F51B5), size: 20),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      summary.subject,
                                      style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                    if (summary.doctor != null && summary.doctor!.isNotEmpty)
                                      Text(
                                        '${l10n.doctor}: ${summary.doctor}',
                                        style: TextStyle(color: Colors.grey.shade600, fontSize: 13),
                                      ),
                                  ],
                                ),
                              ),
                              Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  if (summary.fileUrl != null)
                                    IconButton(
                                      icon: const Icon(Icons.download, color: Color(0xFF3F51B5)),
                                      onPressed: () {
                                        // Download logic
                                      },
                                    ),
                                  IconButton(
                                    icon: const Icon(Icons.delete_outline, color: Colors.redAccent),
                                    onPressed: () => _confirmDelete(context, summary.id),
                                  ),
                                ],
                              ),
                            ],
                          ),
                          if (summary.note != null && summary.note!.isNotEmpty) ...[
                            const Divider(height: 24),
                            Text(
                              summary.note!,
                              style: const TextStyle(fontSize: 14, color: Colors.black87),
                            ),
                          ],
                          const SizedBox(height: 16),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                '${summary.createdAt.day}/${summary.createdAt.month}/${summary.createdAt.year}',
                                style: TextStyle(color: Colors.grey.shade500, fontSize: 12),
                              ),
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                decoration: BoxDecoration(
                                  color: Colors.blue.withOpacity(0.1),
                                  borderRadius: BorderRadius.circular(6),
                                ),
                                child: Text(
                                  l10n.locale.languageCode == 'ar' ? 'ملخص طالب' : 'Student Summary',
                                  style: const TextStyle(color: Colors.blue, fontSize: 10, fontWeight: FontWeight.bold),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
      );
    }

    // Default behavior for other categories
    final allContent = ref.watch(contentProvider);
    final contentItems = allContent.where((item) => item.category == widget.category).toList();
    
    return FutureBuilder<UserRole>(
      future: SecureStorageService.getUserRole(),
      builder: (context, snapshot) {
        final role = snapshot.data ?? UserRole.student;
        final isDelegate = role == UserRole.delegate || role == UserRole.admin;
        bool canAdd = isDelegate && widget.category != 'student_summaries';

        return Scaffold(
          backgroundColor: const Color(0xFFF6F7FB),
          appBar: AppBar(
            title: Text(widget.title, style: const TextStyle(color: Colors.black, fontWeight: FontWeight.bold)),
            backgroundColor: Colors.white,
            elevation: 0,
            iconTheme: const IconThemeData(color: Colors.black),
            actions: [
              IconButton(icon: const Icon(Icons.refresh), onPressed: _fetchData),
            ],
          ),
          body: contentItems.isEmpty
              ? Center(child: Text(l10n.noContent))
              : ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: contentItems.length,
                  itemBuilder: (context, index) {
                    final item = contentItems[index];
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
                              children: [
                                Container(
                                  padding: const EdgeInsets.all(8),
                                  decoration: BoxDecoration(
                                    color: const Color(0xFF3F51B5).withOpacity(0.1),
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  child: const Icon(Icons.description, color: Color(0xFF3F51B5), size: 20),
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: Text(
                                    item.title,
                                    style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                                if (isDelegate)
                                  IconButton(
                                    icon: const Icon(Icons.delete_outline, color: Colors.redAccent),
                                    onPressed: () => _confirmDeleteOld(context, item.id),
                                  ),
                              ],
                            ),
                            const SizedBox(height: 12),
                            Text(
                              item.description,
                              style: const TextStyle(fontSize: 14, color: Colors.black87),
                            ),
                            if (item.fileName.isNotEmpty) ...[
                              const SizedBox(height: 16),
                              Container(
                                padding: const EdgeInsets.all(12),
                                decoration: BoxDecoration(
                                  color: Colors.grey.shade50,
                                  borderRadius: BorderRadius.circular(12),
                                  border: Border.all(color: Colors.grey.shade200),
                                ),
                                child: Row(
                                  children: [
                                    const Icon(Icons.attach_file, size: 18, color: Color(0xFF3F51B5)),
                                    const SizedBox(width: 12),
                                    Expanded(
                                      child: Text(
                                        item.fileName,
                                        style: const TextStyle(fontSize: 13, color: Colors.black54),
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                    ),
                                    const Icon(Icons.download, size: 18, color: Color(0xFF3F51B5)),
                                  ],
                                ),
                              ),
                            ],
                          ],
                        ),
                      ),
                    );
                  },
                ),
          floatingActionButton: canAdd
              ? FloatingActionButton.extended(
                  onPressed: () => showDialog(
                    context: context,
                    builder: (context) => AddContentDialog(
                      title: widget.title,
                      category: widget.category,
                    ),
                  ),
                  backgroundColor: const Color(0xFF3F51B5),
                  icon: const Icon(Icons.add, color: Colors.white),
                  label: Text(l10n.addContent, style: const TextStyle(color: Colors.white)),
                )
              : null,
        );
      },
    );
  }

  void _confirmDelete(BuildContext context, String id) {
    final l10n = AppLocalizations.of(context);
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(l10n.delete),
        content: Text(l10n.confirmDelete),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: Text(l10n.cancel)),
          TextButton(
            onPressed: () {
              ref.read(studentSummaryProvider.notifier).deleteSummary(id);
              Navigator.pop(context);
            },
            child: Text(l10n.delete, style: const TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }

  void _confirmDeleteOld(BuildContext context, String id) {
    final l10n = AppLocalizations.of(context);
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(l10n.delete),
        content: Text(l10n.confirmDelete),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: Text(l10n.cancel)),
          TextButton(
            onPressed: () {
              ref.read(contentProvider.notifier).deleteContent(id);
              Navigator.pop(context);
            },
            child: Text(l10n.delete, style: const TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }
}
