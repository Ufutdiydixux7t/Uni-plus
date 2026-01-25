import 'package:flutter/material.dart';
import '../../core/auth/user_role.dart';
import '../../core/storage/secure_storage_service.dart';

class GenericFeatureScreen extends StatefulWidget {
  final String title;
  final IconData icon;
  final bool isGrades;

  const GenericFeatureScreen({
    super.key,
    required this.title,
    required this.icon,
    this.isGrades = false,
  });

  @override
  State<GenericFeatureScreen> createState() => _GenericFeatureScreenState();
}

class _GenericFeatureScreenState extends State<GenericFeatureScreen> {
  UserRole _role = UserRole.student;
  final List<Map<String, String>> _items = [];

  @override
  void initState() {
    super.initState();
    _loadRole();
  }

  Future<void> _loadRole() async {
    final role = await SecureStorageService.getUserRole();
    setState(() => _role = role);
  }

  void _addItem() {
    if (widget.isGrades) {
      // Excel upload logic for Delegate
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Excel upload functionality for Grades')),
      );
    } else {
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: Text('Add New ${widget.title}'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(decoration: InputDecoration(labelText: 'Title')),
              TextField(decoration: InputDecoration(labelText: 'Description')),
            ],
          ),
          actions: [
            TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
            ElevatedButton(onPressed: () => Navigator.pop(context), child: const Text('Add')),
          ],
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
        backgroundColor: const Color(0xFF3F51B5),
        foregroundColor: Colors.white,
      ),
      body: _items.isEmpty
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(widget.icon, size: 64, color: Colors.grey[300]),
                  const SizedBox(height: 16),
                  Text(
                    'No ${widget.title} available yet',
                    style: TextStyle(color: Colors.grey[500], fontSize: 16),
                  ),
                ],
              ),
            )
          : ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: _items.length,
              itemBuilder: (context, index) {
                final item = _items[index];
                return Card(
                  margin: const EdgeInsets.bottom(12),
                  child: ListTile(
                    leading: Icon(widget.icon, color: const Color(0xFF3F51B5)),
                    title: Text(item['title'] ?? ''),
                    subtitle: Text(item['description'] ?? ''),
                    trailing: _role == UserRole.delegate
                        ? IconButton(icon: const Icon(Icons.delete, color: Colors.red), onPressed: () {})
                        : null,
                  ),
                );
              },
            ),
      floatingActionButton: _role == UserRole.delegate
          ? FloatingActionButton(
              onPressed: _addItem,
              backgroundColor: const Color(0xFF3F51B5),
              child: Icon(widget.isGrades ? Icons.upload_file : Icons.add, color: Colors.white),
            )
          : null,
    );
  }
}
