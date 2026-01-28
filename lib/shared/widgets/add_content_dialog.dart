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
  final _doctorController = TextEditingController();
  final _hallController = TextEditingController();
  final _timeController = TextEditingController();
  final _notesController = TextEditingController();
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
    final l10n = AppLocalizations.of(context);
    if (_subjectController.text.isEmpty) return;

    final uploaderName = await SecureStorageService.getName() ?? 'Delegate';
    
    // Phase 4: Custom description for Daily Reports
    String fullDescription = '';
    if (widget.category == 'reports') {
      fullDescription = '${l10n.doctor}: ${_doctorController.text}\n${l10n.room}: ${_hallController.text}\n${l10n.time}: ${_timeController.text}\n${l10n.note}: ${_notesController.text}';
    } else {
      fullDescription = '${l10n.doctor}: ${_doctorController.text}\n${l10n.note}: ${_notesController.text}';
    }

    await ref.read(contentProvider.notifier).addContent(
      title: _subjectController.text.trim(),
      description: fullDescription.trim(),
      category: widget.category,
      fileName: _selectedFile?.name ?? '',
      filePath: _selectedFile?.path,
      uploaderName: uploaderName,
    );

    if (mounted) {
      Navigator.of(context).pop();
    }
  }

  @override
  void dispose() {
    _subjectController.dispose();
    _doctorController.dispose();
    _hallController.dispose();
    _timeController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final isReport = widget.category == 'reports';
    final isLecture = widget.category == 'lectures';

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
            _dialogField(_subjectController, l10n.subject, Icons.book_outlined),
            const SizedBox(height: 12),
            _dialogField(_doctorController, l10n.doctor, Icons.person_outline),
            const SizedBox(height: 12),
            if (isReport) ...[
              _dialogField(_hallController, l10n.room, Icons.room_outlined),
              const SizedBox(height: 12),
              _dialogField(_timeController, l10n.time, Icons.access_time),
              const SizedBox(height: 12),
            ],
            _dialogField(_notesController, l10n.note, Icons.notes_outlined, maxLines: 2),
            if (isLecture || widget.category == 'summaries') ...[
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
