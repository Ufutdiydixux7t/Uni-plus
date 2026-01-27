import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/providers/content_provider.dart';
import '../../core/storage/secure_storage_service.dart';
import '../../core/auth/user_role.dart';
import '../../core/localization/app_localizations.dart';
import '../../shared/widgets/add_content_dialog.dart';
import 'package:intl/intl.dart';

class ContentListScreen extends ConsumerWidget {
  final String category;
  final String title;

  const ContentListScreen({
    super.key,
    required this.category,
    required this.title,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final contentItems = ref.watch(contentProvider.notifier).getByCategory(category);
    
    return FutureBuilder<UserRole>(
      future: SecureStorageService.getUserRole(),
      builder: (context, snapshot) {
        final isDelegate = snapshot.data == UserRole.delegate || snapshot.data == UserRole.admin;
        
        return Scaffold(
          appBar: AppBar(
            title: Text(title),
            backgroundColor: Colors.white,
            foregroundColor: Colors.black,
            elevation: 0,
          ),
          body: contentItems.isEmpty
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(Icons.folder_open, size: 64, color: Colors.grey),
                      const SizedBox(height: 16),
                      Text(l10n.noContent, style: const TextStyle(color: Colors.grey)),
                    ],
                  ),
                )
              : GridView.builder(
                  padding: const EdgeInsets.all(16),
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    crossAxisSpacing: 16,
                    mainAxisSpacing: 16,
                    childAspectRatio: 0.85,
                  ),
                  itemCount: contentItems.length,
                  itemBuilder: (context, index) {
                    final item = contentItems[index];
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
                                Icon(
                                  item.fileName.toLowerCase().endsWith('.pdf') 
                                      ? Icons.picture_as_pdf 
                                      : Icons.image,
                                  color: Colors.indigo,
                                ),
                                if (isDelegate)
                                  IconButton(
                                    icon: const Icon(Icons.delete_outline, color: Colors.redAccent, size: 20),
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
                                maxLines: 3,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                            const Divider(height: 16),
                            Text(
                              '${item.uploaderName} • ${DateFormat('MM/dd').format(item.date)}',
                              style: const TextStyle(fontSize: 10, color: Colors.grey),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
          floatingActionButton: isDelegate
              ? FloatingActionButton(
                  onPressed: () => showDialog(
                    context: context,
                    builder: (context) => AddContentDialog(
                      title: title,
                      category: category,
                    ),
                  ),
                  backgroundColor: Colors.indigo,
                  child: const Icon(Icons.add),
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
}
