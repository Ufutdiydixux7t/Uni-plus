import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/storage/secure_storage_service.dart';
import '../../core/localization/app_localizations.dart';
import '../../core/providers/content_provider.dart';
import '../../core/auth/user_role.dart';
import '../shared/content_list_screen.dart';

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
    final summaries = ref.watch(contentProvider).where((c) => c.category == 'summaries').toList();

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.summaries),
        actions: [
          if (isDelegate)
            IconButton(
              icon: const Icon(Icons.description),
              onPressed: () => Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => ContentListScreen(category: 'summaries', title: l10n.receivedSummaries),
                ),
              ),
            ),
        ],
      ),
      body: summaries.isEmpty
          ? _buildEmptyState(isDelegate)
          : ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: summaries.length,
              itemBuilder: (context, index) {
                final summary = summaries[index];
                return Card(
                  margin: const EdgeInsets.only(bottom: 12),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
                  child: ListTile(
                    leading: const CircleAvatar(
                      backgroundColor: Color(0xFFFFFFFF),
                      child: Icon(Icons.description, color: Colors.white),
                    ),
                    title: Text(summary.title, style: const TextStyle(fontWeight: FontWeight.bold)),
                    subtitle: Text(summary.uploaderName),
                    trailing: const Icon(Icons.chevron_right),
                    onTap: () {
                      // View summary logic
                    },
                  ),
                );
              },
            ),

    );
  }

  Widget _buildEmptyState(bool isDelegate) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.description_outlined, size: 80, color: Colors.grey[400]),
          const SizedBox(height: 16),
          Text(
            isDelegate ? "No summaries to manage yet" : "No summaries available",
            style: TextStyle(fontSize: 18, color: Colors.grey[600], fontWeight: FontWeight.w500),
          ),
        ],
      ),
    );
  }

  void _showSendSummaryDialog(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final subjectController = TextEditingController();
    final doctorController = TextEditingController();
    final descriptionController = TextEditingController();

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
              _dialogField(doctorController, l10n.doctor, Icons.person_outline),
              const SizedBox(height: 12),
              _dialogField(descriptionController, l10n.description, Icons.notes, maxLines: 2),
              const SizedBox(height: 12),
              OutlinedButton.icon(
                onPressed: () {},
                icon: const Icon(Icons.attach_file),
                label: Text(l10n.uploadFile),
                style: OutlinedButton.styleFrom(
                  minimumSize: const Size(double.infinity, 50),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: Text(l10n.cancel, style: const TextStyle(color: Colors.grey))),
          ElevatedButton(
            onPressed: () async {
              if (subjectController.text.isEmpty) return;
              final uploader = await SecureStorageService.getName() ?? 'Student';
              final desc = '${l10n.doctor}: ${doctorController.text}\n${descriptionController.text}';
              
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
