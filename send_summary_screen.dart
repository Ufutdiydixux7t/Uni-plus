import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:file_picker/file_picker.dart';
import '../../core/storage/secure_storage_service.dart';
import '../../core/localization/app_localizations.dart';
import '../../core/providers/content_provider.dart';

class SendSummaryScreen extends ConsumerStatefulWidget {
  const SendSummaryScreen({super.key});

  @override
  ConsumerState<SendSummaryScreen> createState() => _SendSummaryScreenState();
}

class _SendSummaryScreenState extends ConsumerState<SendSummaryScreen> {
  final _subjectController = TextEditingController();
  final _doctorController = TextEditingController();
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

  Future<void> _submit() async {
    final l10n = AppLocalizations.of(context);
    if (_subjectController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(l10n.locale.languageCode == 'ar' ? 'يرجى إدخال المادة' : 'Please enter subject')),
      );
      return;
    }

    final uploader = await SecureStorageService.getName() ?? 'Student';
    final desc = '${l10n.doctor}: ${_doctorController.text}\n${_descriptionController.text}';
    
    await ref.read(contentProvider.notifier).addContent(
      title: _subjectController.text.trim(),
      description: desc.trim(),
      category: 'summaries',
      uploaderName: uploader,
      fileName: _selectedFile?.name ?? '',
      filePath: _selectedFile?.path,
    );

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(l10n.success), backgroundColor: Colors.green),
      );
      Navigator.pop(context);
    }
  }

  @override
  void dispose() {
    _subjectController.dispose();
    _doctorController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.sendSummary),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _field(_subjectController, l10n.subject, Icons.book_outlined),
            const SizedBox(height: 16),
            _field(_doctorController, l10n.doctor, Icons.person_outline),
            const SizedBox(height: 16),
            _field(_descriptionController, l10n.description, Icons.notes, maxLines: 3),
            const SizedBox(height: 24),
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
            const SizedBox(height: 40),
            SizedBox(
              width: double.infinity,
              height: 55,
              child: ElevatedButton(
                onPressed: _submit,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF3F51B5),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
                child: Text(
                  l10n.submit,
                  style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _field(TextEditingController controller, String label, IconData icon, {int maxLines = 1}) {
    return TextField(
      controller: controller,
      maxLines: maxLines,
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: Icon(icon, color: const Color(0xFF3F51B5)),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
      ),
    );
  }
}
