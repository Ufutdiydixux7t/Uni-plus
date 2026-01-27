import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/providers/content_provider.dart';
import '../../core/storage/secure_storage_service.dart';
import '../../core/auth/user_role.dart';
import '../../core/localization/app_localizations.dart';

class LecturesScreen extends ConsumerWidget {
  const LecturesScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final lectures = ref.watch(contentProvider.notifier).getByCategory('lectures');
    
    return FutureBuilder<UserRole>(
      future: SecureStorageService.getUserRole(),
      builder: (context, snapshot) {
        final isDelegate = snapshot.data == UserRole.delegate || snapshot.data == UserRole.admin;
        
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
                      const Icon(Icons.menu_book, size: 64, color: Colors.grey),
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
                  itemCount: lectures.length,
                  itemBuilder: (context, index) {
                    final item = lectures[index];
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
                                const Icon(Icons.book, color: Color(0xFF3F51B5)),
                                if (isDelegate)
                                  IconButton(
                                    icon: const Icon(Icons.delete, color: Colors.red, size: 20),
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
                            Text(
                              item.description,
                              style: const TextStyle(fontSize: 12, color: Colors.grey),
                              maxLines: 3,
                              overflow: TextOverflow.ellipsis,
                            ),
                            const Spacer(),
                            Row(
                              children: [
                                const Icon(Icons.person, size: 14, color: Colors.grey),
                                const SizedBox(width: 4),
                                Expanded(
                                  child: Text(
                                    item.uploaderName,
                                    style: const TextStyle(fontSize: 11, color: Colors.grey),
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
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
          floatingActionButton: isDelegate
              ? FloatingActionButton(
                  onPressed: () => _showAddLectureDialog(context, ref),
                  backgroundColor: const Color(0xFF3F51B5),
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

  void _showAddLectureDialog(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final subjectController = TextEditingController();
    final timeController = TextEditingController();
    final doctorController = TextEditingController();
    final placeController = TextEditingController();
    final descriptionController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Text(l10n.addLecture, style: const TextStyle(color: Color(0xFF3F51B5), fontWeight: FontWeight.bold)),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              _dialogField(subjectController, l10n.subject, Icons.book_outlined),
              const SizedBox(height: 12),
              _dialogField(timeController, l10n.time, Icons.access_time, hint: '00:00 AM/PM'),
              const SizedBox(height: 12),
              _dialogField(doctorController, l10n.doctor, Icons.person_outline),
              const SizedBox(height: 12),
              _dialogField(placeController, l10n.place, Icons.place_outlined),
              const SizedBox(height: 12),
              _dialogField(descriptionController, l10n.description, Icons.notes, maxLines: 2),
            ],
          ),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: Text(l10n.cancel, style: const TextStyle(color: Colors.grey))),
          ElevatedButton(
            onPressed: () async {
              if (subjectController.text.isEmpty) return;
              final uploader = await SecureStorageService.getName() ?? 'Delegate';
              final desc = '${l10n.doctor}: ${doctorController.text}\n${l10n.time}: ${timeController.text}\n${l10n.place}: ${placeController.text}\n${descriptionController.text}';
              
              await ref.read(contentProvider.notifier).addContent(
                title: subjectController.text.trim(),
                description: desc.trim(),
                category: 'lectures',
                uploaderName: uploader,
              );
              if (context.mounted) Navigator.pop(context);
            },
            style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF3F51B5), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10))),
            child: Text(l10n.save, style: const TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  Widget _dialogField(TextEditingController controller, String label, IconData icon, {int maxLines = 1, String? hint}) {
    return TextField(
      controller: controller,
      maxLines: maxLines,
      decoration: InputDecoration(
        labelText: label,
        hintText: hint,
        prefixIcon: Icon(icon, color: const Color(0xFF3F51B5)),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      ),
    );
  }
}
