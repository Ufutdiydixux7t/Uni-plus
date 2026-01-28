import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/providers/content_provider.dart';
import '../../core/storage/secure_storage_service.dart';
import '../../core/auth/user_role.dart';
import '../../core/localization/app_localizations.dart';

class SummariesScreen extends ConsumerWidget {
  const SummariesScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final summaries = ref.watch(contentProvider.notifier).getByCategory('summaries');
    final receivedSummaries = ref.watch(contentProvider.notifier).getByCategory('received_summaries');
    
    return FutureBuilder<UserRole>(
      future: SecureStorageService.getUserRole(),
      builder: (context, snapshot) {
        final role = snapshot.data ?? UserRole.student;
        final isDelegate = role == UserRole.delegate || role == UserRole.admin;
        
        return Scaffold(
          appBar: AppBar(
            title: Text(l10n.summaries),
            backgroundColor: Colors.white,
            foregroundColor: Colors.black,
            elevation: 0,
            actions: [
              if (isDelegate)
                TextButton.icon(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => ContentListScreen(
                          category: 'summaries',
                          title: l10n.receivedSummaries,
                        ),
                      ),
                    );
                  },
                  icon: const Icon(Icons.inbox, color: Color(0xFF3F51B5)),
                  label: Text(l10n.receivedSummaries, style: const TextStyle(color: Color(0xFF3F51B5))),
                ),
            ],
          ),
          body: summaries.isEmpty
              ? const SizedBox.shrink()
              : GridView.builder(
                  padding: const EdgeInsets.all(16),
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    crossAxisSpacing: 16,
                    mainAxisSpacing: 16,
                    childAspectRatio: 0.9,
                  ),
                  itemCount: summaries.length,
                  itemBuilder: (context, index) {
                    final item = summaries[index];
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
                                const Icon(Icons.description, color: Color(0xFF3F51B5)),
                                if (isDelegate)
                                  IconButton(
                                    icon: const Icon(Icons.delete_outline, color: Colors.red, size: 20),
                                    onPressed: () => _confirmDelete(context, ref, item.id),
                                    constraints: const BoxConstraints(),
                                    padding: EdgeInsets.zero,
                                  ),
                              ],
                            ),
                            const SizedBox(height: 8),
                            Text(
                              item.title,
                              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                            const SizedBox(height: 4),
                            Expanded(
                              child: Text(
                                item.description,
                                style: const TextStyle(fontSize: 12, color: Colors.grey),
                                maxLines: 4,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                            const Divider(height: 16),
                            Text(
                              item.uploaderName,
                              style: const TextStyle(fontSize: 11, color: Colors.indigo, fontWeight: FontWeight.bold),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
          floatingActionButton: !isDelegate
              ? FloatingActionButton.extended(
                  onPressed: () => _showSendSummaryDialog(context, ref),
                  backgroundColor: const Color(0xFF3F51B5),
                  icon: const Icon(Icons.send),
                  label: Text(l10n.sendSummary),
                )
              : null,
        );
      },
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

  void _showSendSummaryDialog(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final subjectController = TextEditingController();
    final descriptionController = TextEditingController();
    final noteController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Text(l10n.sendSummary, style: const TextStyle(color: Color(0xFF3F51B5), fontWeight: FontWeight.bold)),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              _dialogField(subjectController, l10n.subject, Icons.book_outlined),
              const SizedBox(height: 12),
              _dialogField(descriptionController, l10n.description, Icons.notes, maxLines: 2),
              const SizedBox(height: 12),
              _dialogField(noteController, l10n.note, Icons.comment_outlined),
            ],
          ),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: Text(l10n.cancel, style: const TextStyle(color: Colors.grey))),
          ElevatedButton(
            onPressed: () async {
              if (subjectController.text.isEmpty) return;
              final uploader = await SecureStorageService.getName() ?? 'Student';
              final desc = '${descriptionController.text}\n${l10n.note}: ${noteController.text}';
              
              await ref.read(contentProvider.notifier).addContent(
                title: subjectController.text.trim(),
                description: desc.trim(),
                category: 'summaries',
                uploaderName: uploader, fileName: '',
              );
              if (context.mounted) {
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text(l10n.success), backgroundColor: Colors.green),
                );
              }
            },
            style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF3F51B5), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10))),
            child: Text(l10n.submit, style: const TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  Widget _dialogField(TextEditingController controller, String label, IconData icon, {int maxLines = 1}) {
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
