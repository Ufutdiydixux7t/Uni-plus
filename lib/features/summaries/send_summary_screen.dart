import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:file_picker/file_picker.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../core/localization/app_localizations.dart';
import '../../core/providers/student_summary_provider.dart';
import '../../core/models/student_summary_model.dart';

class SendSummaryScreen extends ConsumerStatefulWidget {
  const SendSummaryScreen({super.key});

  @override
  ConsumerState<SendSummaryScreen> createState() => _SendSummaryScreenState();
}

class _SendSummaryScreenState extends ConsumerState<SendSummaryScreen> {
  @override
  void initState() {
    super.initState();
    _fetchMySummaries();
  }

  void _fetchMySummaries() {
    ref.read(studentSummaryProvider.notifier).fetchStudentSummaries(isDelegate: false);
  }

  void _showAddSummaryDialog() {
    showDialog(
      context: context,
      builder: (context) => const AddStudentSummaryDialog(),
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final summaries = ref.watch(studentSummaryProvider);

    return Scaffold(
      backgroundColor: const Color(0xFFF6F7FB),
      appBar: AppBar(
        title: Text(l10n.sendSummary, style: const TextStyle(color: Colors.black, fontWeight: FontWeight.bold)),
        backgroundColor: Colors.white,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.black),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _fetchMySummaries,
          )
        ],
      ),
      body: summaries.isEmpty
          ? Center(child: Text(l10n.noContent))
          : ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: summaries.length,
              itemBuilder: (context, index) {
                final summary = summaries[index];
                return Card(
                  margin: const EdgeInsets.only(bottom: 16),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                  elevation: 2,
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.all(8),
                              decoration: BoxDecoration(
                                color: const Color(0xFF3F51B5).withOpacity(0.1),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: const Icon(Icons.description, color: Color(0xFF3F51B5), size: 20),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    summary.subject,
                                    style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                  if (summary.doctor != null && summary.doctor!.isNotEmpty)
                                    Text(
                                      '${l10n.doctor}: ${summary.doctor}',
                                      style: TextStyle(color: Colors.grey.shade600, fontSize: 13),
                                    ),
                                ],
                              ),
                            ),
                            if (summary.fileUrl != null)
                              IconButton(
                                icon: const Icon(Icons.open_in_new, color: Color(0xFF3F51B5)),
                                onPressed: () {
                                  // Open file logic
                                },
                              ),
                          ],
                        ),
                        if (summary.note != null && summary.note!.isNotEmpty) ...[
                          const Divider(height: 24),
                          Text(
                            summary.note!,
                            style: const TextStyle(fontSize: 14, color: Colors.black87),
                          ),
                        ],
                        const SizedBox(height: 16),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              '${summary.createdAt.day}/${summary.createdAt.month}/${summary.createdAt.year}',
                              style: TextStyle(color: Colors.grey.shade500, fontSize: 12),
                            ),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                              decoration: BoxDecoration(
                                color: Colors.green.withOpacity(0.1),
                                borderRadius: BorderRadius.circular(6),
                              ),
                              child: Text(
                                l10n.locale.languageCode == 'ar' ? 'تم الإرسال' : 'Sent',
                                style: const TextStyle(color: Colors.green, fontSize: 10, fontWeight: FontWeight.bold),
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
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _showAddSummaryDialog,
        backgroundColor: const Color(0xFF3F51B5),
        icon: const Icon(Icons.add, color: Colors.white),
        label: Text(l10n.sendSummary, style: const TextStyle(color: Colors.white)),
      ),
    );
  }
}

class AddStudentSummaryDialog extends ConsumerStatefulWidget {
  const AddStudentSummaryDialog({super.key});

  @override
  ConsumerState<AddStudentSummaryDialog> createState() => _AddStudentSummaryDialogState();
}

class _AddStudentSummaryDialogState extends ConsumerState<AddStudentSummaryDialog> {
  final _formKey = GlobalKey<FormState>();
  final _subjectController = TextEditingController();
  final _doctorController = TextEditingController();
  final _noteController = TextEditingController();
  File? _selectedFile;
  String? _fileName;
  bool _isSubmitting = false;

  Future<void> _pickFile() async {
    final result = await FilePicker.platform.pickFiles();
    if (result != null && result.files.single.path != null) {
      setState(() {
        _selectedFile = File(result.files.single.path!);
        _fileName = result.files.single.name;
      });
    }
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _isSubmitting = true);

    final error = await ref.read(studentSummaryProvider.notifier).sendSummary(
      subject: _subjectController.text,
      doctor: _doctorController.text,
      note: _noteController.text,
      file: _selectedFile,
      fileName: _fileName,
    );

    if (mounted) {
      setState(() => _isSubmitting = false);
      final l10n = AppLocalizations.of(context);
      if (error == null) {
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(l10n.success)));
      } else {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(error), backgroundColor: Colors.red));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      child: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Form(
            key: _formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  l10n.sendSummary,
                  style: const TextStyle(color: Color(0xFF3F51B5), fontWeight: FontWeight.bold, fontSize: 20),
                ),
                const SizedBox(height: 24),
                _buildField(_subjectController, l10n.subject, Icons.book_outlined, l10n),
                _buildField(_doctorController, l10n.doctor, Icons.person_outline, l10n),
                _buildField(_noteController, l10n.note, Icons.notes, l10n, maxLines: 3),
                const SizedBox(height: 8),
                InkWell(
                  onTap: _pickFile,
                  child: Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.grey.shade100,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: Colors.grey.shade300),
                    ),
                    child: Row(
                      children: [
                        const Icon(Icons.attach_file, color: Color(0xFF3F51B5)),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Text(
                            _fileName ?? l10n.attachFile,
                            style: TextStyle(color: _fileName == null ? Colors.grey : Colors.black),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 24),
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    TextButton(
                      onPressed: _isSubmitting ? null : () => Navigator.pop(context),
                      child: Text(l10n.cancel, style: TextStyle(color: Colors.grey.shade600)),
                    ),
                    const SizedBox(width: 8),
                    ElevatedButton(
                      onPressed: _isSubmitting ? null : _submit,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF3F51B5),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                      ),
                      child: _isSubmitting
                          ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                          : Text(l10n.submit, style: const TextStyle(color: Colors.white)),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildField(TextEditingController controller, String label, IconData icon, AppLocalizations l10n, {int maxLines = 1}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: TextFormField(
        controller: controller,
        maxLines: maxLines,
        decoration: InputDecoration(
          labelText: label,
          prefixIcon: Icon(icon, color: const Color(0xFF3F51B5)),
          filled: true,
          fillColor: Colors.grey.shade100,
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
        ),
        validator: (value) => value == null || value.isEmpty ? l10n.requiredField : null,
      ),
    );
  }
}
