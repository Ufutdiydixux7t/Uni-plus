import 'package:flutter_riverpod/flutter_riverpod.dart';

class Announcement {
  final String id;
  final String subject;
  final String doctor;
  final String time;
  final String place;
  final String note;

  Announcement({
    required this.id,
    required this.subject,
    required this.doctor,
    required this.time,
    required this.place,
    this.note = '',
  });
}

class AnnouncementNotifier extends StateNotifier<List<Announcement>> {
  AnnouncementNotifier() : super([]);

  void addAnnouncement({
    required String subject,
    required String doctor,
    required String time,
    required String place,
    String note = '',
  }) {
    final newAnnouncement = Announcement(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      subject: subject,
      doctor: doctor,
      time: time,
      place: place,
      note: note,
    );
    state = [...state, newAnnouncement];
  }

  void deleteAnnouncement(String id) {
    state = state.where((a) => a.id != id).toList();
  }
}

final announcementProvider = StateNotifierProvider<AnnouncementNotifier, List<Announcement>>((ref) {
  return AnnouncementNotifier();
});
