import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/storage/secure_storage_service.dart';
import '../../core/localization/app_localizations.dart';
import '../../core/providers/content_provider.dart';
import '../../core/auth/user_role.dart';
import '../../shared/widgets/add_content_dialog.dart';
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
                      backgroundColor: Color(0xFF3F51B5),
                      child: Icon(Icons.description, color: Colors.white),
                    ),
                    title: Text(summary.title, style: const TextStyle(fontWeight: FontWeight.bold)),
                    subtitle: Text(summary.uploaderName),
                    trailing: const Icon(Icons.chevron_right),
                    onTap: () {
                      // View summary logic - Read Only
                    },
                  ),
                );
              },
            ),
      floatingActionButton: isDelegate
          ? FloatingActionButton(
              onPressed: () => Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => ContentListScreen(category: 'summaries', title: l10n.receivedSummaries),
                ),
              ),
              backgroundColor: const Color(0xFF3F51B5),
              child: const Icon(Icons.inbox_rounded, color: Colors.white),
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
}
