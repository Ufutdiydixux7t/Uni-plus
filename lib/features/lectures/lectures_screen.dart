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
    if (mounted) {
      setState(() => _role = role);
    }
  }

  void _addLecture() {
    final subjectController = TextEditingController();
    final doctorController = TextEditingController();
    final timeController = TextEditingController();
    final roomController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) => Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        child: Container(
          constraints: BoxConstraints(
            maxHeight: MediaQuery.of(context).size.height * 0.8,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Padding(
                padding: EdgeInsets.fromLTRB(24, 24, 24, 8),
                child: Text(
                  'Add New Lecture',
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                ),
              ),
              Flexible(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
                  child: Column(
                    children: [
                      _buildDialogField(subjectController, 'Subject', Icons.book),
                      const SizedBox(height: 16),
                      _buildDialogField(doctorController, 'Doctor', Icons.person),
                      const SizedBox(height: 16),
                      _buildDialogField(timeController, 'Time', Icons.access_time),
                      const SizedBox(height: 16),
                      _buildDialogField(roomController, 'Room/Hall', Icons.location_on),
                    ],
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(24.0),
                child: Row(
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
                        onPressed: () {
                          if (subjectController.text.isNotEmpty) {
                            setState(() {
                              _lectures.add({
                                'subject': subjectController.text,
                                'doctor': doctorController.text,
                                'time': timeController.text,
                                'room': roomController.text,
                              });
                            });
                            Navigator.pop(context);
                          }
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF3F51B5),
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        ),
                        child: const Text('Add'),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDialogField(TextEditingController controller, String label, IconData icon) {
    return TextField(
      controller: controller,
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: Icon(icon, size: 20),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
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
        elevation: 0,
      ),
      body: SafeArea(
        child: _lectures.isEmpty
            ? _buildEmptyState()
            : _buildListState(),
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

  Widget _buildEmptyState() {
    return Center(
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.event_busy_outlined, size: 64, color: Colors.grey[300]),
            const SizedBox(height: 16),
            Text(
              'No lectures scheduled yet',
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
      itemCount: _lectures.length,
      itemBuilder: (context, index) {
        final lecture = _lectures[index];
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
                color: const Color(0xFFEEF1FF),
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Icon(Icons.book, color: Color(0xFF3F51B5), size: 28),
            ),
            title: Text(
              lecture['subject']!,
              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
            ),
            subtitle: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 4),
                Text('${lecture['doctor']} • ${lecture['time']}', style: TextStyle(color: Colors.grey[600])),
                const SizedBox(height: 2),
                Row(
                  children: [
                    const Icon(Icons.location_on_outlined, size: 14, color: Colors.grey),
                    const SizedBox(width: 4),
                    Text(lecture['room']!, style: const TextStyle(fontSize: 12, color: Colors.blueGrey)),
                  ],
                ),
              ],
            ),
            trailing: _role == UserRole.delegate 
              ? IconButton(
                  icon: const Icon(Icons.delete_outline, color: Colors.redAccent),
                  onPressed: () => setState(() => _lectures.removeAt(index)),
                )
              : null,
          ),
        );
      },
    );
  }
}
