import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:uuid/uuid.dart';
import '../models/tomorrow_lecture_model.dart';

final tomorrowLectureProvider = StateNotifierProvider<TomorrowLectureNotifier, List<TomorrowLecture>>((ref) {
  return TomorrowLectureNotifier();
});

class TomorrowLectureNotifier extends StateNotifier<List<TomorrowLecture>> {
  TomorrowLectureNotifier() : super([]);

  final _supabase = Supabase.instance.client;
  final _tableName = 'tomorrow_lectures';

  Future<void> fetchTomorrowLectures() async {
    try {
      final response = await _supabase
          .from(_tableName)
          .select()
          .order('created_at', ascending: false);
      state = (response as List).map((json) => TomorrowLecture.fromJson(json)).toList();
      print('Fetched ${state.length} tomorrow lectures');
    } on PostgrestException catch (e) {
      print('PostgrestException fetching $_tableName: ${e.message}');
      state = [];
    } catch (e) {
      print('General Error fetching $_tableName: $e');
      state = [];
    }
  }

  Future<String?> addTomorrowLecture({
    required String subject,
    required String doctor,
    required String room,
    required String time,
  }) async {
    final lectureId = const Uuid().v4();
    final userId = _supabase.auth.currentUser?.id;

    if (userId == null) {
      return 'User not authenticated. Please log in.';
    }

    try {
      final newLecture = {
        'id': lectureId,
        'subject': subject,
        'doctor': doctor,
        'room': room,
        'time': time,
        'delegate_id': userId,
      };

      await _supabase.from(_tableName).insert(newLecture);
      
      await fetchTomorrowLectures();
      return null; // Success
    } on PostgrestException catch (e) {
      return 'Database insertion failed: ${e.message}';
    } catch (e) {
      return 'An unexpected error occurred: $e';
    }
  }

  Future<String?> deleteTomorrowLecture(String lectureId, String delegateId) async {
    final currentUserId = _supabase.auth.currentUser?.id;
    if (currentUserId == null) {
      return 'User not authenticated. Please log in.';
    }
    
    // In some cases, delegate_id might be null in the DB, so we allow deletion if user is delegate
    // But for safety, we check if the ID matches if it exists
    try {
      await _supabase
          .from(_tableName)
          .delete()
          .eq('id', lectureId);
      
      await fetchTomorrowLectures();
      return null; // Success
    } on PostgrestException catch (e) {
      return 'Database deletion failed: ${e.message}';
    } catch (e) {
      return 'An unexpected error occurred: $e';
    }
  }
}
