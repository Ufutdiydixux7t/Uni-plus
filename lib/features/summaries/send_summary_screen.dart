import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
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
  final _noteController = TextEditingController();
  String _fileName = '';
  String? _filePath;

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
            _field(_noteController, l10n.optionalNote, Icons.notes, maxLines: 3),
            const SizedBox(height: 24),
            InkWell(
              onTap: () {
                // Simulated file picker
                setState(() {
                  _fileName = "summary_${DateTime.now().millisecondsSinceEpoch}.pdf";
                  _filePath = "/simulated/path/$_fileName";
                });
              },
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
                        _fileName.isEmpty ? l10n.attachFile : _fileName,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(color: _fileName.isEmpty ? Colors.grey : Colors.black),
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
                onPressed: () async {
                  if (_subjectController.text.isEmpty) return;
                  final uploader = await SecureStorageService.getName() ?? 'Student';
                  final desc = '${l10n.doctor}: ${_doctorController.text}\n${l10n.note}: ${_noteController.text}';
                  await ref.read(contentProvider.notifier).addContent(
                    title: _subjectController.text.trim(),
                    description: desc.trim(),
                    category: 'student_summaries',
                    uploaderName: uploader,
                    fileName: _fileName,
                    filePath: _filePath,
                  );
                  if (mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text(l10n.success), backgroundColor: Colors.green),
                    );
                    Navigator.pop(context);
                  }
                },
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
