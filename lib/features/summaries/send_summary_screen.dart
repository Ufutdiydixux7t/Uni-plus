import 'package:flutter/material.dart';
import '../../core/services/file_picker_service.dart';

class SendSummaryScreen extends StatefulWidget {
  const SendSummaryScreen({super.key});

  @override
  State<SendSummaryScreen> createState() => _SendSummaryScreenState();
}

class _SendSummaryScreenState extends State<SendSummaryScreen> {
  final _textController = TextEditingController();
  PickedFileModel? _selectedFile;

  Future<void> _pickFile() async {
    final extensions = FilePickerService.getExtensionsFor('summaries');
    final result = await FilePickerService.pickFile(allowedExtensions: extensions);

    if (result != null) {
      setState(() {
        _selectedFile = result;
      });
    }
  }

  void _send() {
    if (_textController.text.isEmpty && _selectedFile == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter summary text or attach a file')),
      );
      return;
    }
    // Logic to send summary to delegate
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Summary sent to delegate successfully')),
    );
    Navigator.pop(context);
  }

  @override
  void dispose() {
    _textController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Send Summary'),
        backgroundColor: const Color(0xFF3F51B5),
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(24),
                physics: const BouncingScrollPhysics(),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Share your summary',
                      style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 8),
                    const Text(
                      'Your summary will be sent to the class delegate for review.',
                      style: TextStyle(color: Colors.grey, fontSize: 14),
                    ),
                    const SizedBox(height: 24),
                    TextField(
                      controller: _textController,
                      maxLines: 6,
                      decoration: InputDecoration(
                        hintText: 'Type your summary or notes here...',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(16),
                          borderSide: BorderSide(color: Colors.grey[300]!),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(16),
                          borderSide: BorderSide(color: Colors.grey[300]!),
                        ),
                        filled: true,
                        fillColor: Colors.white,
                      ),
                    ),
                    const SizedBox(height: 24),
                    const Text(
                      'Attachment',
                      style: TextStyle(fontWeight: FontWeight.w600, fontSize: 16),
                    ),
                    const SizedBox(height: 12),
                    _buildFilePickerSection(),
                  ],
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(24),
              child: SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: (_textController.text.isNotEmpty || _selectedFile != null) ? _send : null,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF3F51B5),
                    foregroundColor: Colors.white,
                    disabledBackgroundColor: Colors.grey[300],
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                    elevation: 0,
                  ),
                  child: const Text('Send to Delegate', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFilePickerSection() {
    return InkWell(
      onTap: _pickFile,
      borderRadius: BorderRadius.circular(16),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          border: Border.all(color: _selectedFile != null ? Colors.green : Colors.grey[300]!, width: 1.5),
          borderRadius: BorderRadius.circular(16),
          color: _selectedFile != null ? Colors.green.withOpacity(0.05) : Colors.grey[50],
        ),
        child: _selectedFile == null
            ? Column(
                children: [
                  Icon(Icons.cloud_upload_outlined, size: 40, color: Colors.grey[400]),
                  const SizedBox(height: 12),
                  const Text(
                    'Attach PDF or Image',
                    style: TextStyle(color: Color(0xFF3F51B5), fontWeight: FontWeight.w600),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Max size: 10MB',
                    style: TextStyle(color: Colors.grey[500], fontSize: 12),
                  ),
                ],
              )
            : Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: Colors.green.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Icon(Icons.insert_drive_file, color: Colors.green, size: 28),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          _selectedFile!.name,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(fontWeight: FontWeight.bold),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          _selectedFile!.size,
                          style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                        ),
                      ],
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.delete_outline, color: Colors.redAccent),
                    onPressed: () => setState(() => _selectedFile = null),
                  )
                ],
              ),
      ),
    );
  }
}
