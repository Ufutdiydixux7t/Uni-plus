import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:file_picker/file_picker.dart';
import '../../core/providers/grade_provider.dart';

class GradesManagementSheet extends ConsumerStatefulWidget {
  const GradesManagementSheet({super.key});

  @override
  ConsumerState<GradesManagementSheet> createState() => _GradesManagementSheetState();
}

class _GradesManagementSheetState extends ConsumerState<GradesManagementSheet> {
  final _subjectController = TextEditingController();
  final _doctorController = TextEditingController();
  final _noteController = TextEditingController();
  File? _selectedFile;
  bool _isUploading = false;

  Future<void> _pickFile() async {
    final result = await FilePicker.platform.pickFiles();
    if (result != null) {
      setState(() => _selectedFile = File(result.files.single.path!));
    }
  }

  Future<void> _submit() async {
    if (_subjectController.text.isEmpty) return;
    setState(() => _isUploading = true);

    final user = Supabase.instance.client.auth.currentUser;
    
    // Get group_id for this delegate
    final groupData = await Supabase.instance.client
        .from('groups')
        .select('id')
        .eq('delegate_id', user?.id ?? '')
        .maybeSingle();
    
    final groupId = groupData?['id'];

    final success = await ref.read(gradeProvider.notifier).addGrade(
      subject: _subjectController.text,
      doctor: _doctorController.text,
      note: _noteController.text,
      groupId: groupId,
      file: _selectedFile,
    );

    if (mounted) {
      setState(() => _isUploading = false);
      if (success != null) {
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Grade added successfully!')));
      } else {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Failed to add grade. Check console for details.')));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom, left: 20, right: 20, top: 20),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Text('Add New Grade', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
          const SizedBox(height: 20),
          TextField(controller: _subjectController, decoration: const InputDecoration(labelText: 'Subject', border: OutlineInputBorder())),
          const SizedBox(height: 12),
          TextField(controller: _doctorController, decoration: const InputDecoration(labelText: 'Doctor', border: OutlineInputBorder())),
          const SizedBox(height: 12),
          TextField(controller: _noteController, decoration: const InputDecoration(labelText: 'Note', border: OutlineInputBorder())),
          const SizedBox(height: 20),
          ListTile(
            leading: const Icon(Icons.attach_file),
            title: Text(_selectedFile == null ? 'Attach File (Optional)' : _selectedFile!.path.split('/').last),
            onTap: _pickFile,
            tileColor: Colors.grey.shade100,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          ),
          const SizedBox(height: 24),
          SizedBox(
            width: double.infinity,
            height: 50,
            child: ElevatedButton(
              onPressed: _isUploading ? null : _submit,
              style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF3F51B5), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))),
              child: _isUploading ? const CircularProgressIndicator(color: Colors.white) : const Text('Submit Grade'),
            ),
          ),
          const SizedBox(height: 20),
        ],
      ),
    );
  }
}
