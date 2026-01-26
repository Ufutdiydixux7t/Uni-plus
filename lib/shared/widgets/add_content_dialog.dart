import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/providers/content_provider.dart';
import '../../core/storage/secure_storage_service.dart';
import '../../core/localization/app_localizations.dart';
import 'package:file_picker/file_picker.dart';

class AddContentDialog extends ConsumerStatefulWidget {
  final String category;

  const AddContentDialog({
    super.key,
    required this.category,
  });

  @override
  ConsumerState<AddContentDialog> createState() => _AddContentDialogState();
}

class _AddContentDialogState extends ConsumerState<AddContentDialog> {
  final _subjectController = TextEditingController();
  final _descriptionController = TextEditingController();
  String? _selectedFileName;

  Future<void> _pickFile() async {
    final result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['pdf', 'jpg', 'png', 'doc', 'docx'],
    );

    if (result != null) {
      setState(() {
        _selectedFileName = result.files.first.name;
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
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              '${l10n.addContent} - ${widget.category}',
              style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 24),
            _buildTextField(_subjectController, l10n.title, Icons.subject),
            const SizedBox(height: 16),
            _buildTextField(_descriptionController, l10n.description, Icons.description, maxLines: 3),
            const SizedBox(height: 20),
            _buildFilePickerSection(l10n),
            const SizedBox(height: 24),
            _buildActionButtons(context, l10n),
          ],
        ),
      ),
    );
  }

  Widget _buildTextField(TextEditingController controller, String label, IconData icon, {int maxLines = 1}) {
    return TextField(
      controller: controller,
      maxLines: maxLines,
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: Icon(icon, size: 20),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
      ),
    );
  }

  Widget _buildFilePickerSection(AppLocalizations l10n) {
    return InkWell(
      onTap: _pickFile,
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          border: Border.all(color: Colors.grey[300]!),
          borderRadius: BorderRadius.circular(12),
          color: Colors.grey[50],
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.attach_file, size: 20, color: Color(0xFF3F51B5)),
            const SizedBox(width: 8),
            Flexible(
              child: Text(
                _selectedFileName ?? l10n.uploadFile,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(color: Color(0xFF3F51B5), fontWeight: FontWeight.w500),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildActionButtons(BuildContext context, AppLocalizations l10n) {
    final bool isReady = _subjectController.text.isNotEmpty && _selectedFileName != null;

    return Row(
      children: [
        Expanded(
          child: TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(l10n.cancel),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: ElevatedButton(
            onPressed: isReady ? _save : null,
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF3F51B5),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            ),
            child: Text(l10n.save, style: const TextStyle(color: Colors.white)),
          ),
        ),
      ],
    );
  }

  Future<void> _save() async {
    final name = await SecureStorageService.getName();
    ref.read(contentProvider.notifier).addContent(
      title: _subjectController.text,
      description: _descriptionController.text,
      category: widget.category,
      fileName: _selectedFileName!,
      uploaderName: name ?? 'Delegate',
    );
    if (mounted) Navigator.pop(context);
  }
}
