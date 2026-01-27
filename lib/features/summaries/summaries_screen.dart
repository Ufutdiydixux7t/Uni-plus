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
    
    return FutureBuilder<UserRole>(
      future: SecureStorageService.getUserRole(),
      builder: (context, snapshot) {
        final isDelegate = snapshot.data == UserRole.delegate || snapshot.data == UserRole.admin;
        
        return Scaffold(
          appBar: AppBar(
            title: Text(isDelegate ? l10n.receivedSummaries : l10n.summaries),
            backgroundColor: Colors.white,
            foregroundColor: Colors.black,
            elevation: 0,
          ),
          body: summaries.isEmpty
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(Icons.description_outlined, size: 64, color: Colors.grey),
                      const SizedBox(height: 16),
                      Text(l10n.noContent, style: const TextStyle(color: Colors.grey)),
                    ],
                  ),
                )
              : ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: summaries.length,
                  itemBuilder: (context, index) {
                    final item = summaries[index];
                    return Card(
                      margin: const EdgeInsets.only(bottom: 12),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      child: ListTile(
                        leading: CircleAvatar(
                          backgroundColor: const Color(0xFF3F51B5).withOpacity(0.1),
                          child: const Icon(Icons.description, color: Color(0xFF3F51B5)),
                        ),
                        title: Text(item.title, style: const TextStyle(fontWeight: FontWeight.bold)),
                        subtitle: Text('${item.uploaderName} • ${item.description}'),
                        trailing: isDelegate
                            ? IconButton(
                                icon: const Icon(Icons.delete_outline, color: Colors.red),
                                onPressed: () => ref.read(contentProvider.notifier).deleteContent(item.id),
                              )
                            : null,
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
          TextButton(onPressed: () => Navigator.pop(context), child: Text(l10n.cancel)),
          ElevatedButton(
            onPressed: () async {
              if (subjectController.text.isEmpty) return;
              final uploader = await SecureStorageService.getName() ?? 'Student';
              final desc = '${descriptionController.text}\n${l10n.note}: ${noteController.text}';
              
              await ref.read(contentProvider.notifier).addContent(
                title: subjectController.text.trim(),
                description: desc.trim(),
                category: 'summaries',
                uploaderName: uploader,
              );
              if (context.mounted) Navigator.pop(context);
            },
            style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF3F51B5)),
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
