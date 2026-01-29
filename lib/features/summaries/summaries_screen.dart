import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/storage/secure_storage_service.dart';
import '../../core/localization/app_localizations.dart';
import '../../core/providers/content_provider.dart';
import '../../core/auth/user_role.dart';
import '../../shared/widgets/add_content_dialog.dart';

class SummariesScreen extends ConsumerStatefulWidget {
  const SummariesScreen({super.key});

  @override
  ConsumerState<SummariesScreen> createState() => _SummariesScreenState();
}

class _SummariesScreenState extends ConsumerState<SummariesScreen> {
  UserRole _userRole = UserRole.student;

  @override
  void initState() {
    super.initState();
    _loadRole();
  }

  Future<void> _loadRole() async {
    final role = await SecureStorageService.getUserRole();
    if (!mounted) return;
    setState(() => _userRole = role);
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final isDelegate = _userRole == UserRole.delegate || _userRole == UserRole.admin;
    final summaries = ref.watch(contentProvider.notifier).getByCategory('summaries');

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.summaries),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        elevation: 0,
        actions: [
          Container(
            margin: const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: Colors.blue.withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Center(
              child: Text(
                l10n.readOnly,
                style: const TextStyle(fontSize: 12, color: Colors.blue, fontWeight: FontWeight.w500),
              ),
            ),
          ),
        ],
      ),
      body: summaries.isEmpty
          ? _buildEmptyState(l10n, isDelegate)
          : GridView.builder(
              padding: const EdgeInsets.all(16),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                crossAxisSpacing: 12,
                mainAxisSpacing: 12,
                childAspectRatio: 0.8,
              ),
              itemCount: summaries.length,
              itemBuilder: (context, index) {
                final summary = summaries[index];
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
                            const Icon(Icons.description, color: Color(0xFF3F51B5), size: 20),
                            if (isDelegate)
                              IconButton(
                                icon: const Icon(Icons.delete_outline, color: Colors.red, size: 18),
                                onPressed: () => _confirmDelete(context, ref, summary.id),
                                constraints: const BoxConstraints(),
                                padding: EdgeInsets.zero,
                              ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        Text(
                          summary.title,
                          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 4),
                        Expanded(
                          child: SingleChildScrollView(
                            child: Text(
                              summary.description,
                              style: const TextStyle(fontSize: 11, color: Colors.black87),
                            ),
                          ),
                        ),
                        if (summary.fileName.isNotEmpty) ...[
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
                                    summary.fileName,
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
              },
            ),
      floatingActionButton: isDelegate
          ? FloatingActionButton.extended(
              onPressed: () => showDialog(
                context: context,
                builder: (_) => AddContentDialog(
                  category: 'summaries',
                  title: l10n.summaries,
                ),
              ),
              backgroundColor: const Color(0xFF3F51B5),
              icon: const Icon(Icons.add, color: Colors.white),
              label: Text(l10n.addContent, style: const TextStyle(color: Colors.white)),
            )
          : null,
    );
  }

  Widget _buildEmptyState(AppLocalizations l10n, bool isDelegate) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.description_outlined, size: 80, color: Colors.grey[400]),
          const SizedBox(height: 16),
          Text(
            isDelegate ? l10n.noSummariesYet : l10n.noContent,
            style: TextStyle(fontSize: 18, color: Colors.grey[600], fontWeight: FontWeight.w500),
          ),
        ],
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
