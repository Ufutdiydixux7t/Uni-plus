import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/providers/content_provider.dart';
import '../../core/storage/secure_storage_service.dart';
import '../../core/auth/user_role.dart';
import '../../core/localization/app_localizations.dart';

class LecturesScreen extends ConsumerWidget {
  const LecturesScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final lectures = ref.watch(contentProvider.notifier).getByCategory('lectures');
    
    return FutureBuilder<UserRole>(
      future: SecureStorageService.getUserRole(),
      builder: (context, snapshot) {
        final role = snapshot.data ?? UserRole.student;
        final isDelegate = role == UserRole.delegate || role == UserRole.admin;
        
        return Scaffold(
          appBar: AppBar(
            title: Text(l10n.lectures),
            backgroundColor: Colors.white,
            foregroundColor: Colors.black,
            elevation: 0,
          ),
          body: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (role == UserRole.student) _buildTomorrowLectures(context, lectures),
                
                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Text(
                    l10n.lectures,
                    style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Color(0xFF3F51B5)),
                  ),
                ),
                
                lectures.isEmpty
                    ? Center(
                        child: Padding(
                          padding: const EdgeInsets.symmetric(vertical: 40),
                          child: Column(
                            children: [
                              const Icon(Icons.school_outlined, size: 64, color: Colors.grey),
                              const SizedBox(height: 16),
                              Text(l10n.noContent, style: const TextStyle(color: Colors.grey)),
                            ],
                          ),
                        ),
                      )
                    : GridView.builder(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 2,
                          crossAxisSpacing: 16,
                          mainAxisSpacing: 16,
                          childAspectRatio: 0.85,
                        ),
                        itemCount: lectures.length,
                        itemBuilder: (context, index) {
                          final item = lectures[index];
                          return _buildLectureCard(context, ref, item, isDelegate);
                        },
                      ),
                const SizedBox(height: 80),
              ],
            ),
          ),
          floatingActionButton: isDelegate
              ? FloatingActionButton.extended(
                  onPressed: () => _showAddLectureDialog(context, ref),
                  backgroundColor: const Color(0xFF3F51B5),
                  icon: const Icon(Icons.add),
                  label: Text(l10n.addLecture),
                )
              : null,
        );
      },
    );
  }

  Widget _buildTomorrowLectures(BuildContext context, List<dynamic> lectures) {
    final l10n = AppLocalizations.of(context);
    // Mock logic: assuming some lectures are for tomorrow
    final tomorrowLectures = lectures.take(2).toList(); 

    return Container(
      width: double.infinity,
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: const LinearGradient(colors: [Color(0xFF3F51B5), Color(0xFF6A5AE0)]),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [BoxShadow(color: Colors.indigo.withOpacity(0.3), blurRadius: 10, offset: const Offset(0, 4))],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.event_available, color: Colors.white, size: 20),
              const SizedBox(width: 8),
              Text(
                l10n.tomorrowLectures,
                style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16),
              ),
            ],
          ),
          const SizedBox(height: 12),
          if (tomorrowLectures.isEmpty)
            Text(l10n.noContent, style: const TextStyle(color: Colors.white70))
          else
            ...tomorrowLectures.map((l) => Padding(
              padding: const EdgeInsets.only(bottom: 8.0),
              child: Row(
                children: [
                  const Icon(Icons.arrow_right, color: Colors.white70),
                  Expanded(
                    child: Text(
                      '${l.title} - ${l.description.split('\n')[0]}',
                      style: const TextStyle(color: Colors.white, fontSize: 14),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
            )).toList(),
        ],
      ),
    );
  }

  Widget _buildLectureCard(BuildContext context, WidgetRef ref, dynamic item, bool isDelegate) {
    final l10n = AppLocalizations.of(context);
    final details = item.description.split('\n');
    final time = details.length > 0 ? details[0] : '';
    final doctor = details.length > 1 ? details[1] : '';
    final place = details.length > 2 ? details[2] : '';

    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Icon(Icons.book, color: Color(0xFF3F51B5), size: 20),
                if (isDelegate)
                  IconButton(
                    icon: const Icon(Icons.delete_outline, color: Colors.red, size: 20),
                    onPressed: () => _confirmDelete(context, ref, item.id),
                    constraints: const BoxConstraints(),
                    padding: EdgeInsets.zero,
                  ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              item.title,
              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
            const SizedBox(height: 4),
            _infoRow(Icons.access_time, time),
            _infoRow(Icons.person_outline, doctor),
            _infoRow(Icons.location_on_outlined, place),
          ],
        ),
      ),
    );
  }

  Widget _infoRow(IconData icon, String text) {
    return Padding(
      padding: const EdgeInsets.only(top: 2.0),
      child: Row(
        children: [
          Icon(icon, size: 12, color: Colors.grey),
          const SizedBox(width: 4),
          Expanded(
            child: Text(
              text,
              style: const TextStyle(fontSize: 11, color: Colors.black87),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }

  void _confirmDelete(BuildContext context, WidgetRef ref, String id) {
    final l10n = AppLocalizations.of(context);
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(l10n.delete),
        content: Text(l10n.confirmDelete),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: Text(l10n.cancel)),
          TextButton(
            onPressed: () {
              ref.read(contentProvider.notifier).deleteContent(id);
              Navigator.pop(context);
            },
            child: Text(l10n.delete, style: const TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }

  void _showAddLectureDialog(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final subjectController = TextEditingController();
    final timeController = TextEditingController();
    final doctorController = TextEditingController();
    final placeController = TextEditingController();
    final descController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Text(l10n.addLecture, style: const TextStyle(color: Color(0xFF3F51B5), fontWeight: FontWeight.bold)),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              _dialogField(subjectController, l10n.subject, Icons.book_outlined),
              const SizedBox(height: 12),
              _dialogField(timeController, l10n.time, Icons.access_time, hint: '00:00 AM/PM'),
              const SizedBox(height: 12),
              _dialogField(doctorController, l10n.doctor, Icons.person_outline),
              const SizedBox(height: 12),
              _dialogField(placeController, l10n.place, Icons.location_on_outlined),
              const SizedBox(height: 12),
              _dialogField(descController, l10n.description, Icons.notes, maxLines: 2),
            ],
          ),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: Text(l10n.cancel, style: const TextStyle(color: Colors.grey))),
          ElevatedButton(
            onPressed: () async {
              if (subjectController.text.isEmpty) return;
              final uploader = await SecureStorageService.getName() ?? 'Delegate';
              final desc = '${timeController.text}\n${doctorController.text}\n${placeController.text}\n${descController.text}';
              
              await ref.read(contentProvider.notifier).addContent(
                title: subjectController.text.trim(),
                description: desc.trim(),
                category: 'lectures',
                uploaderName: uploader, fileName: '',
              );
              if (context.mounted) {
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text(l10n.success), backgroundColor: Colors.green),
                );
              }
            },
            style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF3F51B5), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10))),
            child: Text(l10n.save, style: const TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  Widget _dialogField(TextEditingController controller, String label, IconData icon, {int maxLines = 1, String? hint}) {
    return TextField(
      controller: controller,
      maxLines: maxLines,
      decoration: InputDecoration(
        labelText: label,
        hintText: hint,
        prefixIcon: Icon(icon, color: const Color(0xFF3F51B5)),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      ),
    );
  }
}
