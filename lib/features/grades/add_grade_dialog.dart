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

    final errorMessage = await ref.read(gradeProvider.notifier).addGrade(
      subject: _subjectController.text,
      doctor: _doctorController.text,
      note: _noteController.text,
      file: _selectedFile,
    );

    if (mounted) {
      setState(() => _isSubmitting = false);
      final l10n = AppLocalizations.of(context);
      if (errorMessage == null) {
        Navigator.pop(context); // Close dialog on success
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(l10n.success)));
      } else {
        // Show detailed error message to the user
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('${l10n.error}: $errorMessage'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    int maxLines = 1,
    String? Function(String?)? validator,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16.0),
      child: TextFormField(
        controller: controller,
        maxLines: maxLines,
        validator: validator,
        decoration: InputDecoration(
          labelText: label,
          suffixIcon: Icon(icon, color: const Color(0xFF3F51B5)),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12.0),
            borderSide: BorderSide.none,
          ),
          filled: true,
          fillColor: Colors.grey.shade100,
          contentPadding: const EdgeInsets.symmetric(vertical: 16.0, horizontal: 16.0),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final theme = Theme.of(context);

    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20.0)),
      child: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Form(
            key: _formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Title
                Text(
                  '${l10n.addContent}: ${l10n.grades}',
                  style: theme.textTheme.headlineSmall?.copyWith(
                    color: const Color(0xFF3F51B5),
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 24),

                // Subject Field
                _buildTextField(
                  controller: _subjectController,
                  label: l10n.subject,
                  icon: Icons.book_outlined,
                  validator: (value) => value!.isEmpty ? l10n.requiredField : null,
                ),

                // Doctor Field
                _buildTextField(
                  controller: _doctorController,
                  label: l10n.doctor,
                  icon: Icons.person_outline,
                ),

                // Note Field
                _buildTextField(
                  controller: _noteController,
                  label: l10n.note,
                  icon: Icons.notes_outlined,
                  maxLines: 3,
                ),

                // File Picker Button (Designed as a field)
                GestureDetector(
                  onTap: _pickFile,
                  child: Container(
                    height: 56,
                    decoration: BoxDecoration(
                      color: Colors.grey.shade100,
                      borderRadius: BorderRadius.circular(12.0),
                    ),
                    padding: const EdgeInsets.symmetric(horizontal: 16.0),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Expanded(
                          child: Text(
                            _selectedFile == null
                                ? l10n.attachFile
                                : _selectedFile!.path.split('/').last,
                            style: TextStyle(
                              color: _selectedFile == null ? Colors.grey.shade600 : Colors.black,
                              fontSize: 16,
                            ),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        Icon(Icons.attachment, color: const Color(0xFF3F51B5)),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 24),

                // Action Buttons
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    // Cancel Button
                    TextButton(
                      onPressed: _isSubmitting ? null : () => Navigator.pop(context),
                      child: Text(
                        l10n.cancel,
                        style: TextStyle(color: Colors.grey.shade600, fontSize: 16),
                      ),
                    ),
                    const SizedBox(width: 8),

                    // Save Button
                    ElevatedButton(
                      onPressed: _isSubmitting ? null : _submit,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF3F51B5),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12.0),
                        ),
                        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                      ),
                      child: _isSubmitting
                          ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                          : Text(
                              l10n.save,
                              style: const TextStyle(color: Colors.white, fontSize: 16),
                            ),
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
}
