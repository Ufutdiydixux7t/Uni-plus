import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import '../../core/providers/content_provider.dart';
import '../../core/storage/secure_storage_service.dart';
import '../../core/auth/user_role.dart';
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
    final l10n = AppLocalizations.of(context)!;
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
                      Text(l10n.noFiles, style: const TextStyle(color: Colors.grey)),
                    ],
                  ),
                )
              : ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: contentItems.length,
                  itemBuilder: (context, index) {
                    final item = contentItems[index];
                    return Card(
                      margin: const EdgeInsets.bottom(12),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      child: ListTile(
                        leading: CircleAvatar(
                          backgroundColor: Colors.indigo.withOpacity(0.1),
                          child: Icon(
                            item.fileName.toLowerCase().endsWith('.pdf') 
                                ? Icons.picture_as_pdf 
                                : Icons.image,
                            color: Colors.indigo,
                          ),
                        ),
                        title: Text(item.title, style: const TextStyle(fontWeight: FontWeight.bold)),
                        subtitle: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(item.description),
                            const SizedBox(height: 4),
                            Text(
                              '${item.uploaderName} • ${DateFormat('yyyy-MM-dd').format(item.date)}',
                              style: const TextStyle(fontSize: 11, color: Colors.grey),
                            ),
                          ],
                        ),
                        trailing: isDelegate 
                            ? IconButton(
                                icon: const Icon(Icons.delete_outline, color: Colors.redAccent),
                                onPressed: () => ref.read(contentProvider.notifier).deleteContent(item.id),
                              )
                            : const Icon(Icons.download, color: Colors.indigo),
                        onTap: () {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text('Download feature coming soon (Local Mock)')),
                          );
                        },
                      ),
                    );
                  },
                ),
          floatingActionButton: isDelegate
              ? FloatingActionButton(
                  onPressed: () => showDialog(
                    context: context,
                    builder: (context) => AddContentDialog(title: title, category: category),
                  ),
                  backgroundColor: Colors.indigo,
                  child: const Icon(Icons.add),
                )
              : null,
        );
      },
    );
  }
}
