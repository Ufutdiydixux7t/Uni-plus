import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:file_picker/file_picker.dart';
import '../../core/localization/app_localizations.dart';
import '../../core/providers/grade_provider.dart';

class AddGradeDialog extends ConsumerStatefulWidget {
  const AddGradeDialog({super.key});

  @override
  ConsumerState<AddGradeDialog> createState() => _AddGradeDialogState();
}

class _AddGradeDialogState extends ConsumerState<AddGradeDialog> {
  final _formKey = GlobalKey<FormState>();
  final _subjectController = TextEditingController();
  final _doctorController = TextEditingController();
  final _noteController = TextEditingController();
  File? _selectedFile;
  bool _isSubmitting = false;

  @override
  void dispose() {
    _subjectController.dispose();
    _doctorController.dispose();
    _noteController.dispose();
    super.dispose();
  }

  Future<void> _pickFile() async {
    final result = await FilePicker.platform.pickFiles();
    if (result != null) {
      setState(() => _selectedFile = File(result.files.single.path!));
    }
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _isSubmitting = true);

    final success = await ref.read(gradeProvider.notifier).addGrade(
      subject: _subjectController.text,
      doctor: _doctorController.text,
      note: _noteController.text,
      file: _selectedFile,
    );

    if (mounted) {
      setState(() => _isSubmitting = false);
      final l10n = AppLocalizations.of(context);
      if (success) {
        Navigator.pop(context); // Close dialog on success
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(l10n.success)));
      } else {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(l10n.error)));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);

    return AlertDialog(
      title: Text(l10n.grades),
      content: SingleChildScrollView(
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextFormField(
                controller: _subjectController,
                decoration: InputDecoration(labelText: l10n.subject),
                validator: (value) => value!.isEmpty ? l10n.subject : null,
              ),
              TextFormField(
                controller: _doctorController,
                decoration: InputDecoration(labelText: l10n.doctor),
              ),
              TextFormField(
                controller: _noteController,
                decoration: InputDecoration(labelText: l10n.note),
                maxLines: 3,
              ),
              const SizedBox(height: 16),
              ListTile(
                leading: const Icon(Icons.attach_file),
                title: Text(_selectedFile == null ? l10n.attachFile : _selectedFile!.path.split('/').last),
                onTap: _pickFile,
                tileColor: Colors.grey.shade100,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
              ),
            ],
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: _isSubmitting ? null : () => Navigator.pop(context),
          child: Text(l10n.cancel),
        ),
        ElevatedButton(
          onPressed: _isSubmitting ? null : _submit,
          child: _isSubmitting
              ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2))
              : Text(l10n.save),
        ),
      ],
    );
  }
}
