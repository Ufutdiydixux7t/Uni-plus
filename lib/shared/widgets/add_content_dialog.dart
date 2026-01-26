import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:file_picker/file_picker.dart';
import '../../core/providers/content_provider.dart';
import '../../core/storage/secure_storage_service.dart';
import '../../core/localization/app_localizations.dart';

class AddContentDialog extends ConsumerStatefulWidget {
  final String title;
  final String category;

  const AddContentDialog({
    super.key,
    required this.title,
    required this.category,
  });

  @override
  ConsumerState<AddContentDialog> createState() => _AddContentDialogState();
}

class _AddContentDialogState extends ConsumerState<AddContentDialog> {
  final _subjectController = TextEditingController();
  final _descriptionController = TextEditingController();
  PlatformFile? _selectedFile;

  Future<void> _pickFile() async {
    final result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['pdf', 'jpg', 'jpeg', 'png', 'xlsx'],
    );

    if (result != null) {
      setState(() => _selectedFile = result.files.first);
    }
  }

  Future<void> _save() async {
    if (_subjectController.text.isEmpty) return;

    final uploaderName = await SecureStorageService.getName() ?? 'Delegate';

    await ref.read(contentProvider.notifier).addContent(
      title: _subjectController.text.trim(),
      description: _descriptionController.text.trim(),
      category: widget.category,
      fileName: _selectedFile?.name ?? 'No file',
      filePath: _selectedFile?.path,
      uploaderName: uploaderName,
    );

    if (mounted) {
      Navigator.of(context).pop({
        'subject': _subjectController.text.trim(),
        'description': _descriptionController.text.trim(),
        'file': _selectedFile,
      });
    }
  }

  @override
  void dispose() {
    _subjectController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);

    return AlertDialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      title: Text(
        '${l10n.addContent}: ${widget.title}',
        style: const TextStyle(color: Color(0xFF3F51B5), fontWeight: FontWeight.bold),
      ),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: _subjectController,
              decoration: InputDecoration(
                labelText: l10n.title,
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _descriptionController,
              maxLines: 3,
              decoration: InputDecoration(
                labelText: l10n.description,
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
              ),
            ),
            const SizedBox(height: 16),
            InkWell(
              onTap: _pickFile,
              child: Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.grey[300]!),
                  borderRadius: BorderRadius.circular(12),
                  color: Colors.grey[50],
                ),
                child: Row(
                  children: [
                    const Icon(Icons.attach_file, color: Color(0xFF3F51B5)),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        _selectedFile?.name ?? l10n.uploadFile,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(color: _selectedFile == null ? Colors.grey : Colors.black),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: Text(l10n.cancel, style: const TextStyle(color: Colors.grey)),
        ),
        ElevatedButton(
          onPressed: _save,
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xFF3F51B5),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
          ),
          child: Text(l10n.save, style: const TextStyle(color: Colors.white)),
        ),
      ],
    );
  }
}
