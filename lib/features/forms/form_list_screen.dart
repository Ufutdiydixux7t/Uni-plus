import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../core/auth/user_role.dart';
import '../../core/localization/app_localizations.dart';
import '../../core/providers/form_provider.dart'; // New Form Provider
import '../../core/models/form_model.dart'; // New Form Model
import 'add_form_dialog.dart'; // New Form Dialog

class FormListScreen extends ConsumerStatefulWidget {
  final UserRole userRole;
  const FormListScreen({super.key, required this.userRole});

  @override
  ConsumerState<FormListScreen> createState() => _FormListScreenState();
}

class _FormListScreenState extends ConsumerState<FormListScreen> {
  @override
  void initState() {
    super.initState();
    _fetchForms();
  }

  Future<void> _fetchForms() async {
    ref.read(formProvider.notifier).fetchForms();
  }

  void _showAddFormDialog() {
    showDialog(
      context: context,
      builder: (_) => const AddFormDialog(),
    );
  }

  void _confirmDelete(BuildContext context, String contentId, String delegateId) {
    final l10n = AppLocalizations.of(context);
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(l10n.delete),
        content: Text(l10n.confirmDelete),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: Text(l10n.cancel)),
          TextButton(
            onPressed: () async {
              Navigator.pop(context);
              final errorMessage = await ref.read(formProvider.notifier).deleteForm(contentId, delegateId);
              if (mounted) {
                if (errorMessage == null) {
                  ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(l10n.success)));
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('${l10n.error}: $errorMessage'),
                      backgroundColor: Colors.red,
                    ),
                  );
                }
              }
            },
            child: Text(l10n.delete, style: const TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final forms = ref.watch(formProvider);
    final l10n = AppLocalizations.of(context);
    final isDelegate = widget.userRole == UserRole.delegate || widget.userRole == UserRole.admin;

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.forms, style: const TextStyle(color: Colors.black, fontWeight: FontWeight.bold)),
        backgroundColor: Colors.white,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.black),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _fetchForms,
          )
        ],
      ),
      body: forms.isEmpty
          ? Center(child: Text(l10n.noContent))
          : GridView.builder(
              padding: const EdgeInsets.all(16),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                crossAxisSpacing: 12,
                mainAxisSpacing: 12,
                childAspectRatio: 0.8,
              ),
              itemCount: forms.length,
              itemBuilder: (context, index) {
                final form = forms[index];
                // Check if the current user is the creator (delegate)
                final currentUserId = Supabase.instance.client.auth.currentUser?.id;
                final canDelete = isDelegate && form.delegateId == currentUserId;

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
                            Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                if (canDelete)
                                  IconButton(
                                    icon: const Icon(Icons.delete_outline, color: Colors.red, size: 20),
                                    onPressed: () => _confirmDelete(context, form.id, form.delegateId!),
                                    constraints: const BoxConstraints(),
                                    padding: EdgeInsets.zero,
                                  ),
                                if (form.fileUrl != null && form.fileUrl!.isNotEmpty)
                                  IconButton(
                                    icon: const Icon(Icons.open_in_new, color: Color(0xFF3F51B5), size: 20),
                                    onPressed: () async {
                                      final url = Uri.parse(form.fileUrl!);
                                      if (await canLaunchUrl(url)) {
                                        await launchUrl(url, mode: LaunchMode.externalApplication);
                                      }
                                    },
                                    constraints: const BoxConstraints(),
                                    padding: EdgeInsets.zero,
                                  ),
                              ],
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        Text(
                          form.subject,
                          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 4),
                        if (form.doctor != null && form.doctor!.isNotEmpty)
                          Text('${l10n.doctor}: ${form.doctor}', style: TextStyle(color: Colors.grey.shade600, fontSize: 12)),
                        const SizedBox(height: 4),
                        Expanded(
                          child: SingleChildScrollView(
                            child: Text(
                              form.note ?? '',
                              style: const TextStyle(fontSize: 11, color: Colors.black87),
                            ),
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          '${form.createdAt.day}/${form.createdAt.month}/${form.createdAt.year}',
                          style: TextStyle(color: Colors.grey.shade500, fontSize: 10),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
      floatingActionButton: isDelegate
          ? FloatingActionButton.extended(
              onPressed: _showAddFormDialog,
              backgroundColor: const Color(0xFF3F51B5),
              icon: const Icon(Icons.add, color: Colors.white),
              label: Text(l10n.addContent, style: const TextStyle(color: Colors.white)),
            )
          : null,
    );
  }
}
