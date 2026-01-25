import 'package:flutter/material.dart';
import '../../core/auth/user_role.dart';
import '../../core/storage/secure_storage_service.dart';

class MaterialsScreen extends StatefulWidget {
  const MaterialsScreen({super.key});

  @override
  State<MaterialsScreen> createState() => _MaterialsScreenState();
}

class _MaterialsScreenState extends State<MaterialsScreen> {
  UserRole _role = UserRole.student;
  final List<Map<String, String>> _materials = [
    {'title': 'Introduction to AI', 'type': 'PDF', 'size': '2.4 MB'},
    {'title': 'Database Systems - Chapter 1', 'type': 'PDF', 'size': '1.8 MB'},
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Academic Materials'),
        backgroundColor: const Color(0xFF3F51B5),
        foregroundColor: Colors.white,
      ),
      body: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: _materials.length,
        itemBuilder: (context, index) {
          final item = _materials[index];
          return Card(
            margin: const EdgeInsets.bottom(12),
            child: ListTile(
              leading: const Icon(Icons.picture_as_pdf, color: Colors.redAccent, size: 32),
              title: Text(item['title']!, style: const TextStyle(fontWeight: FontWeight.w600)),
              subtitle: Text(item['size']!),
              trailing: _role == UserRole.delegate
                ? IconButton(icon: const Icon(Icons.delete_outline, color: Colors.red), onPressed: () {})
                : const Icon(Icons.download, color: Color(0xFF3F51B5)),
              onTap: () {
                // Open PDF logic
              },
            ),
          );
        },
      ),
      floatingActionButton: _role == UserRole.delegate
          ? FloatingActionButton(
              onPressed: () {}, // Upload PDF logic
              backgroundColor: const Color(0xFF3F51B5),
              child: const Icon(Icons.upload_file, color: Colors.white),
            )
          : null,
    );
  }
}
