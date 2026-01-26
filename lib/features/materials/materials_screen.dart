import 'package:flutter/material.dart';
import '../../core/auth/user_role.dart';
import '../../core/storage/secure_storage_service.dart';
import '../../shared/widgets/add_content_dialog.dart';

class MaterialsScreen extends StatefulWidget {
  const MaterialsScreen({super.key});

  @override
  State<MaterialsScreen> createState() => _MaterialsScreenState();
}

class _MaterialsScreenState extends State<MaterialsScreen> {
  UserRole _role = UserRole.student;
  final List<Map<String, dynamic>> _materials = [
    {'title': 'Introduction to AI', 'type': 'PDF', 'size': '2.4 MB', 'date': '2024-01-20'},
    {'title': 'Database Systems - Chapter 1', 'type': 'PDF', 'size': '1.8 MB', 'date': '2024-01-22'},
  ];

  @override
  void initState() {
    super.initState();
    _loadRole();
  }

  Future<void> _loadRole() async {
    final role = await SecureStorageService.getUserRole();
    if (mounted) {
      setState(() => _role = role);
    }
  }

  void _uploadMaterial() async {
    final result = await showDialog<Map<String, dynamic>>(
      context: context,
      builder: (context) => const AddContentDialog(
        title: 'Material',
        category: 'materials',
      ),
    );

    if (result != null) {
      setState(() {
        _materials.add({
          'title': result['subject'],
          'type': result['file'].extension.toUpperCase(),
          'size': result['file'].size,
          'date': DateTime.now().toString().substring(0, 10),
          'file': result['file'],
        });
      });
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Material uploaded successfully (locally)')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Academic Materials'),
        backgroundColor: const Color(0xFF3F51B5),
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      body: SafeArea(
        child: _materials.isEmpty
            ? _buildEmptyState()
            : _buildListState(),
      ),
      floatingActionButton: _role == UserRole.delegate
          ? FloatingActionButton(
              onPressed: _uploadMaterial,
              backgroundColor: const Color(0xFF3F51B5),
              child: const Icon(Icons.upload_file, color: Colors.white),
            )
          : null,
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.picture_as_pdf_outlined, size: 64, color: Colors.grey[300]),
            const SizedBox(height: 16),
            Text(
              'No materials available yet',
              style: TextStyle(color: Colors.grey[500], fontSize: 16),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildListState() {
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      physics: const BouncingScrollPhysics(),
      itemCount: _materials.length,
      itemBuilder: (context, index) {
        final item = _materials[index];
        return Card(
          margin: const EdgeInsets.bottom(16),
          elevation: 2,
          shadowColor: Colors.black12,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          child: ListTile(
            contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
            leading: Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: const Color(0xFFFFEBEE),
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Icon(Icons.picture_as_pdf, color: Colors.redAccent, size: 28),
            ),
            title: Text(
              item['title']!,
              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
            ),
            subtitle: Text(
              '${item['type']} • ${item['size']} • ${item['date']}',
              style: TextStyle(color: Colors.grey[600], fontSize: 13),
            ),
            trailing: _role == UserRole.delegate
                ? IconButton(
                    icon: const Icon(Icons.delete_outline, color: Colors.redAccent),
                    onPressed: () {
                      setState(() => _materials.removeAt(index));
                    },
                  )
                : const Icon(Icons.download, color: Color(0xFF3F51B5), size: 20),
            onTap: () {
              // Open PDF logic
            },
          ),
        );
      },
    );
  }
}
