import 'package:flutter/material.dart';
import '../../core/auth/user_role.dart';
import '../../core/storage/secure_storage_service.dart';
import '../../shared/widgets/add_content_dialog.dart';

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
  final List<Map<String, dynamic>> _items = [];

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

  void _addItem() async {
    final result = await showDialog<Map<String, dynamic>>(
      context: context,
      builder: (context) => AddContentDialog(
        title: widget.title,
        category: widget.isGrades ? 'grades' : widget.title,
      ),
    );

    if (result != null) {
      setState(() {
        _items.add({
          'title': result['subject'],
          'description': result['description'],
          'file': result['file'],
          'date': DateTime.now().toString().substring(0, 10),
        });
      });
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('${widget.title} added successfully (locally)')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
        backgroundColor: const Color(0xFF3F51B5),
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      body: SafeArea(
        child: _items.isEmpty
            ? _buildEmptyState()
            : _buildListState(),
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

  Widget _buildEmptyState() {
    return Center(
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: Colors.grey[100],
                shape: BoxShape.circle,
              ),
              child: Icon(widget.icon, size: 64, color: Colors.grey[300]),
            ),
            const SizedBox(height: 24),
            Text(
              'No ${widget.title} available yet',
              style: TextStyle(
                color: Colors.grey[600],
                fontSize: 18,
                fontWeight: FontWeight.w500,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              _role == UserRole.delegate 
                ? 'Tap the button below to add your first ${widget.title.toLowerCase()}'
                : 'Check back later for updates from your delegate',
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.grey[400], fontSize: 14),
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
      itemCount: _items.length,
      itemBuilder: (context, index) {
        final item = _items[index];
        final file = item['file'];
        
        return Card(
          margin: const EdgeInsets.only(bottom: 16),
          elevation: 2,
          shadowColor: Colors.black12,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          child: ListTile(
            contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
            leading: Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: const Color(0xFFEEF1FF),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(
                widget.isGrades ? Icons.table_chart : _getFileIcon(file?.extension),
                color: const Color(0xFF3F51B5),
              ),
            ),
            title: Text(
              item['title'] ?? '',
              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
            ),
            subtitle: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 4),
                Text(item['description'] ?? '', maxLines: 2, overflow: TextOverflow.ellipsis),
                if (file != null) ...[
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      const Icon(Icons.attach_file, size: 14, color: Colors.grey),
                      const SizedBox(width: 4),
                      Expanded(
                        child: Text(
                          '${file.name} (${file.size})',
                          style: const TextStyle(fontSize: 12, color: Colors.blueGrey),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                ],
              ],
            ),
            trailing: _role == UserRole.delegate
                ? IconButton(
                    icon: const Icon(Icons.delete_outline, color: Colors.redAccent),
                    onPressed: () {
                      setState(() => _items.removeAt(index));
                    },
                  )
                : const Icon(Icons.download, color: Color(0xFF3F51B5), size: 20),
          ),
        );
      },
    );
  }

  IconData _getFileIcon(String? extension) {
    if (extension == null) return widget.icon;
    switch (extension.toLowerCase()) {
      case 'pdf': return Icons.picture_as_pdf;
      case 'jpg':
      case 'jpeg':
      case 'png': return Icons.image;
      case 'xlsx': return Icons.table_chart;
      default: return Icons.insert_drive_file;
    }
  }
}
