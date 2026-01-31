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
      final List<dynamic> response = await _supabase.from(_tableName).select().order('created_at', ascending: false);
      state = (response as List).map((json) => TomorrowLecture.fromJson(json)).toList();
    } on PostgrestException catch (e) {
      print('PostgrestException fetching $_tableName: ${e.message}');
      state = [];
    } catch (e) {
      print('General Error fetching $_tableName: $e');
      state = [];
    }
  }

  // Returns null on success, or an error message string on failure
  Future<String?> addTomorrowLecture({
    required String subject,
    String? doctor,
    String? room,
    String? time,
    String? groupId, // Added groupId
  }) async {
    final contentId = const Uuid().v4();
    final userId = _supabase.auth.currentUser?.id;

    if (userId == null) {
      return 'User not authenticated. Please log in.';
    }

    try {
      final newContent = {
        'id': contentId,
        'subject': subject,
        'doctor': doctor,
        'room': room,
        'time': time,
        'delegate_id': userId, // Added delegate_id
        'group_id': groupId, // Added group_id
        // No file_url for tasks
      };

      // 3. Insert into table
      await _supabase.from(_tableName).insert(newContent);
      
      // Refresh state
      await fetchTomorrowLectures();
      return null; // Success
    } on PostgrestException catch (e, stackTrace) {
      return 'Database insertion failed: ${e.message}';
    } catch (e, stackTrace) {
      return 'An unexpected error occurred: $e';
    }
  }

  // Returns null on success, or an error message string on failure
  Future<String?> deleteTomorrowLecture(String contentId, String delegateId) async {
    final currentUserId = _supabase.auth.currentUser?.id;
    if (currentUserId == null) {
      return 'User not authenticated. Please log in.';
    }
    
    // Check if the current user is the creator (delegate)
    if (currentUserId != delegateId) {
      return 'You are not authorized to delete this content.';
    }

    try {
      // 1. Delete from table
      await _supabase
          .from(_tableName)
          .delete()
          .eq('id', contentId)
          .eq('delegate_id', currentUserId);
      
      // Refresh state
      await fetchTomorrowLectures();
      return null; // Success
    } on PostgrestException catch (e, stackTrace) {
      return 'Database deletion failed: ${e.message}';
    } catch (e, stackTrace) {
      return 'An unexpected error occurred: $e';
    }
  }
}
