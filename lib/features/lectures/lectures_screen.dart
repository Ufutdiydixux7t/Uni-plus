import 'package:flutter/material.dart';
import '../../core/auth/user_role.dart';
import '../../core/storage/secure_storage_service.dart';

class LecturesScreen extends StatefulWidget {
  const LecturesScreen({super.key});

  @override
  State<LecturesScreen> createState() => _LecturesScreenState();
}

class _LecturesScreenState extends State<LecturesScreen> {
  UserRole _role = UserRole.student;
  final List<Map<String, String>> _lectures = [
    {'subject': 'Mathematics', 'doctor': 'Dr. Ahmed', 'time': '08:00 AM', 'room': 'Hall 1'},
    {'subject': 'Computer Science', 'doctor': 'Dr. Sara', 'time': '10:00 AM', 'room': 'Lab 3'},
  ];

  @override
  void initState() {
    super.initState();
    _loadRole();
  }

  Future<void> _loadRole() async {
    final role = await SecureStorageService.getUserRole();
    setState(() => _role = role);
  }

  void _addLecture() {
    // Logic to add lecture (Delegate only)
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Add New Lecture'),
        content: const Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(decoration: InputDecoration(labelText: 'Subject')),
            TextField(decoration: InputDecoration(labelText: 'Doctor')),
            TextField(decoration: InputDecoration(labelText: 'Time')),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
          ElevatedButton(onPressed: () => Navigator.pop(context), child: const Text('Add')),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Lectures'),
        backgroundColor: const Color(0xFF3F51B5),
        foregroundColor: Colors.white,
      ),
      body: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: _lectures.length,
        itemBuilder: (context, index) {
          final lecture = _lectures[index];
          return Card(
            margin: const EdgeInsets.bottom(12),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            child: ListTile(
              leading: const CircleAvatar(
                backgroundColor: Color(0xFFEEF1FF),
                child: Icon(Icons.book, color: Color(0xFF3F51B5)),
              ),
              title: Text(lecture['subject']!, style: const TextStyle(fontWeight: FontWeight.bold)),
              subtitle: Text('${lecture['doctor']} • ${lecture['time']}'),
              trailing: _role == UserRole.delegate 
                ? IconButton(icon: const Icon(Icons.edit, color: Colors.grey), onPressed: () {})
                : Text(lecture['room']!, style: const TextStyle(color: Colors.blueGrey, fontWeight: FontWeight.w500)),
            ),
          );
        },
      ),
      floatingActionButton: _role == UserRole.delegate
          ? FloatingActionButton(
              onPressed: _addLecture,
              backgroundColor: const Color(0xFF3F51B5),
              child: const Icon(Icons.add, color: Colors.white),
            )
          : null,
    );
  }
}
