import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/providers/content_provider.dart';
import '../../core/storage/secure_storage_service.dart';
import '../../core/auth/user_role.dart';
import '../../core/localization/app_localizations.dart';
import '../../shared/widgets/add_content_dialog.dart';

class LecturesScreen extends ConsumerWidget {
  const LecturesScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final lectures = ref.watch(contentProvider.notifier).getByCategory('lectures');
    
    return FutureBuilder<UserRole>(
      future: SecureStorageService.getUserRole(),
      builder: (context, snapshot) {
        final role = snapshot.data ?? UserRole.student;
        final isDelegate = role == UserRole.delegate || role == UserRole.admin;
        
        return Scaffold(
          appBar: AppBar(
            title: Text(l10n.lectures),
            backgroundColor: Colors.white,
            foregroundColor: Colors.black,
            elevation: 0,
          ),
          body: lectures.isEmpty
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(Icons.school_outlined, size: 64, color: Colors.grey),
                      const SizedBox(height: 16),
                      Text(l10n.noContent, style: const TextStyle(color: Colors.grey)),
                    ],
                  ),
                )
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
                    final item = lectures[index];
                    return _buildLectureCard(context, ref, item, isDelegate);
                  },
                ),
          floatingActionButton: isDelegate
              ? FloatingActionButton.extended(
                  onPressed: () => showDialog(
                    context: context,
                    builder: (context) => AddContentDialog(
                      title: l10n.lectures,
                      category: 'lectures',
                    ),
                  ),
                  backgroundColor: const Color(0xFF3F51B5),
                  icon: const Icon(Icons.add, color: Colors.white),
                  label: Text(l10n.addLecture, style: const TextStyle(color: Colors.white)),
                )
              : null,
        );
      },
    );
  }

  Widget _buildLectureCard(BuildContext context, WidgetRef ref, dynamic item, bool isDelegate) {
    final l10n = AppLocalizations.of(context);

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
                const Icon(Icons.book, color: Color(0xFF3F51B5), size: 20),
                if (isDelegate)
                  IconButton(
                    icon: const Icon(Icons.delete_outline, color: Colors.red, size: 18),
                    onPressed: () => _confirmDelete(context, ref, item.id),
                    constraints: const BoxConstraints(),
                    padding: EdgeInsets.zero,
                  ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              item.title,
              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
            const SizedBox(height: 4),
            Expanded(
              child: SingleChildScrollView(
                child: Text(
                  item.description,
                  style: const TextStyle(fontSize: 11, color: Colors.black87),
                ),
              ),
            ),
            if (item.fileName.isNotEmpty) ...[
              const SizedBox(height: 8),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: Colors.indigo.withOpacity(0.05),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.attach_file, size: 12, color: Colors.indigo),
                    const SizedBox(width: 4),
                    Expanded(
                      child: Text(
                        item.fileName,
                        style: const TextStyle(fontSize: 10, color: Colors.indigo),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  void _confirmDelete(BuildContext context, WidgetRef ref, String id) {
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
