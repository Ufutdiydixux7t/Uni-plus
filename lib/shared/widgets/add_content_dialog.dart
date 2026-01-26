import 'package:flutter/material.dart';
import '../../core/services/file_picker_service.dart';

class AddContentDialog extends StatefulWidget {
  final String title;
  final String category;

  const AddContentDialog({
    super.key,
    required this.title,
    required this.category,
  });

  @override
  State<AddContentDialog> createState() => _AddContentDialogState();
}

class _AddContentDialogState extends State<AddContentDialog> {
  final _subjectController = TextEditingController();
  final _descriptionController = TextEditingController();
  PickedFileModel? _selectedFile;
  String? _errorMessage;

  Future<void> _pickFile() async {
    final extensions = FilePickerService.getExtensionsFor(widget.category);
    final result = await FilePickerService.pickFile(allowedExtensions: extensions);

    setState(() {
      if (result != null) {
        _selectedFile = result;
        _errorMessage = null;
      } else {
        // Only show error if they actually picked a wrong file, 
        // but file_picker handles extension filtering on most platforms.
        // If result is null, it usually means user cancelled.
      }
    });
  }

  @override
  void dispose() {
    _subjectController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      insetPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
      child: Container(
        constraints: BoxConstraints(
          maxHeight: MediaQuery.of(context).size.height * 0.8,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(24, 24, 24, 8),
              child: Text(
                'Add New ${widget.title}',
                style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
            ),
            Flexible(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildTextField(_subjectController, 'Subject', Icons.subject),
                    const SizedBox(height: 16),
                    _buildTextField(_descriptionController, 'Description', Icons.description, maxLines: 3),
                    const SizedBox(height: 20),
                    const Text('Attachment', style: TextStyle(fontWeight: FontWeight.w600)),
                    const SizedBox(height: 8),
                    _buildFilePickerSection(),
                    if (_errorMessage != null)
                      Padding(
                        padding: const EdgeInsets.only(top: 8.0),
                        child: Text(_errorMessage!, style: const TextStyle(color: Colors.red, fontSize: 12)),
                      ),
                  ],
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(24.0),
              child: _buildActionButtons(context),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTextField(TextEditingController controller, String label, IconData icon, {int maxLines = 1}) {
    return TextField(
      controller: controller,
      maxLines: maxLines,
      onChanged: (_) => setState(() {}), // Trigger rebuild to update submit button state
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: Icon(icon, size: 20),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      ),
    );
  }

  Widget _buildFilePickerSection() {
    final extensions = FilePickerService.getExtensionsFor(widget.category);
    
    return InkWell(
      onTap: _pickFile,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          border: Border.all(color: _selectedFile != null ? Colors.green : Colors.grey[300]!),
          borderRadius: BorderRadius.circular(12),
          color: _selectedFile != null ? Colors.green.withOpacity(0.05) : Colors.grey[50],
        ),
        child: _selectedFile == null
            ? Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.attach_file, size: 20, color: Color(0xFF3F51B5)),
                  const SizedBox(width: 8),
                  Text(
                    'Attach ${extensions.join("/")}',
                    style: const TextStyle(color: Color(0xFF3F51B5), fontWeight: FontWeight.w500),
                  ),
                ],
              )
            : Row(
                children: [
                  const Icon(Icons.insert_drive_file, color: Colors.green, size: 24),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(_selectedFile!.name, maxLines: 1, overflow: TextOverflow.ellipsis, style: const TextStyle(fontWeight: FontWeight.w500)),
                        Text(_selectedFile!.size, style: TextStyle(fontSize: 12, color: Colors.grey[600])),
                      ],
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.close, size: 20),
                    onPressed: () => setState(() => _selectedFile = null),
                  )
                ],
              ),
      ),
    );
  }

  Widget _buildActionButtons(BuildContext context) {
    final bool isReady = _subjectController.text.isNotEmpty && _selectedFile != null;

    return Row(
      children: [
        Expanded(
          child: TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: ElevatedButton(
            onPressed: isReady ? () {
              // Return the data to the caller
              Navigator.pop(context, {
                'subject': _subjectController.text,
                'description': _descriptionController.text,
                'file': _selectedFile,
              });
            } : null,
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF3F51B5),
              foregroundColor: Colors.white,
              disabledBackgroundColor: Colors.grey[300],
              disabledForegroundColor: Colors.grey[500],
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              padding: const EdgeInsets.symmetric(vertical: 12),
              elevation: 0,
            ),
            child: const Text('Submit'),
          ),
        ),
      ],
    );
  }
}
