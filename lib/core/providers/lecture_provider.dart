import 'dart:io';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:uuid/uuid.dart';
import '../models/lecture_model.dart';

final lectureProvider = StateNotifierProvider<LectureNotifier, List<Lecture>>((ref) {
  return LectureNotifier();
});

class LectureNotifier extends StateNotifier<List<Lecture>> {
  LectureNotifier() : super([]);

  final _supabase = Supabase.instance.client;
  final _tableName = 'lectures';
  final _bucketName = 'lectures';

  Future<void> fetchLectures() async {
    try {
      final response = await _supabase.from(_tableName).select().order('created_at', ascending: false);
      state = (response as List).map((json) => Lecture.fromJson(json)).toList();
      print('Fetched ${state.length} lectures');
    } on PostgrestException catch (e) {
      print('PostgrestException fetching $_tableName: ${e.message}');
      state = [];
    } catch (e) {
      print('General Error fetching $_tableName: $e');
      state = [];
    }
  }

  // Returns null on success, or an error message string on failure
  Future<String?> addLecture({
    required String subject,
    String? doctor,
    String? note,
    File? file,
    String? groupId,
  }) async {
    String? fileUrl;
    final lectureId = const Uuid().v4();
    final userId = _supabase.auth.currentUser?.id;

    if (userId == null) {
      return 'User not authenticated. Please log in.';
    }

    try {
      if (file != null) {
        // 1. Upload to Storage
        final originalFileName = file.path.split('/').last;
        final safeFileName = originalFileName.replaceAll(RegExp(r'[^\w\-. ]'), '_');
        final fileName = '$userId/$lectureId/$safeFileName';
        
        await _supabase.storage.from(_bucketName).upload(
          fileName, 
          file,
          fileOptions: const FileOptions(cacheControl: '3600', upsert: false),
        );
        
        // 2. Get public URL
        fileUrl = _supabase.storage.from(_bucketName).getPublicUrl(fileName);
      }

      final newLecture = {
        'id': lectureId,
        'subject': subject,
        'doctor': doctor,
        'note': note,
        'file_url': fileUrl,
        'delegate_id': userId,
        'group_id': groupId,
      };

      // 3. Insert into table
      await _supabase.from(_tableName).insert(newLecture);
      
      // Refresh state
      await fetchLectures();
      return null; // Success
    } on StorageException catch (e) {
      return 'File upload failed: ${e.message}';
    } on PostgrestException catch (e) {
      // Clean up file if DB insert fails
      if (fileUrl != null) {
        try {
          final originalFileName = file!.path.split('/').last;
          final safeFileName = originalFileName.replaceAll(RegExp(r'[^\w\-. ]'), '_');
          final pathToRemove = '$userId/$lectureId/$safeFileName';
          await _supabase.storage.from(_bucketName).remove([pathToRemove]);
        } catch (cleanupError) {
          print('Failed to clean up file: $cleanupError');
        }
      }
      return 'Database insertion failed: ${e.message}';
    } catch (e) {
      return 'An unexpected error occurred: $e';
    }
  }

  // Returns null on success, or an error message string on failure
  Future<String?> deleteLecture(String lectureId, String delegateId) async {
    final currentUserId = _supabase.auth.currentUser?.id;
    if (currentUserId == null) {
      return 'User not authenticated. Please log in.';
    }
    if (currentUserId != delegateId) {
      return 'You are not authorized to delete this lecture.';
    }

    try {
      // 1. Get lecture details to find file_url
      final lecture = await _supabase
          .from(_tableName)
          .select('file_url')
          .eq('id', lectureId)
          .maybeSingle();

      // 2. Delete from table
      await _supabase
          .from(_tableName)
          .delete()
          .eq('id', lectureId)
          .eq('delegate_id', currentUserId);
      
      // 3. Delete file from Storage if it exists
      final fileUrl = lecture?['file_url'];
      if (fileUrl != null && fileUrl.isNotEmpty) {
        try {
          final fileName = fileUrl.split('/').last;
          final pathToRemove = '$currentUserId/$lectureId/$fileName';
          await _supabase.storage.from(_bucketName).remove([pathToRemove]);
        } catch (e) {
          print('Failed to delete file from Storage: $e');
        }
      }

      // Refresh state
      await fetchLectures();
      return null; // Success
    } on PostgrestException catch (e) {
      return 'Database deletion failed: ${e.message}';
    } catch (e) {
      return 'An unexpected error occurred: $e';
    }
  }
}
