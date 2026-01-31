import 'dart:io';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:uuid/uuid.dart';
import '../models/grade_model.dart';

final gradeProvider = StateNotifierProvider<GradeNotifier, List<Grade>>((ref) {
  return GradeNotifier();
});

class GradeNotifier extends StateNotifier<List<Grade>> {
  GradeNotifier() : super([]);

  final _supabase = Supabase.instance.client;

  Future<void> fetchGrades() async {
    try {
      // Fetch all grades as there is no group_id to filter by and RLS is disabled
      final response = await _supabase.from('grades').select().order('created_at', ascending: false);
      state = (response as List).map((json) => Grade.fromJson(json)).toList();
    } on PostgrestException catch (e) {
      print('PostgrestException fetching grades: ${e.message}');
      state = [];
    } catch (e) {
      print('General Error fetching grades: $e');
      state = [];
    }
  }

  // Returns null on success, or an error message string on failure
  Future<String?> addGrade({
    required String subject,
    String? doctor,
    String? note,
    File? file, required groupId,
  }) async {
    String? fileUrl;
    final gradeId = const Uuid().v4();
    final userId = _supabase.auth.currentUser?.id;

    if (userId == null) {
      return 'User not authenticated. Please log in.';
    }

    try {
      if (file != null) {
        // 1. Upload to 'grades' bucket
        // Sanitize file name to handle non-ASCII, spaces, and symbols
        final originalFileName = file.path.split('/').last;
        final safeFileName = originalFileName.replaceAll(RegExp(r'[^\w\-. ]'), '_');
        final fileName = '$userId/$gradeId/$safeFileName';
        
        await _supabase.storage.from('grades').upload(
          fileName, 
          file,
          fileOptions: const FileOptions(cacheControl: '3600', upsert: false),
        );
        
        // 2. Get public URL
        fileUrl = _supabase.storage.from('grades').getPublicUrl(fileName);
        print('File uploaded successfully. Public URL: $fileUrl');
      }

      final newGrade = {
        'id': gradeId,
        'subject': subject,
        'doctor': doctor,
        'note': note,
        'file_url': fileUrl,
        'created_by': userId,
      };

      // 3. Insert into 'grades' table
      await _supabase.from('grades').insert(newGrade);
      
      print('Grade inserted successfully into database.');

      // Refresh state
      await fetchGrades();
      return null; // Success
    } on StorageException catch (e, stackTrace) {
      print('StorageException during file upload: ${e.message}');
      print('Stack Trace: $stackTrace');
      return 'File upload failed: ${e.message}';
    } on PostgrestException catch (e, stackTrace) {
      print('PostgrestException during database insert: ${e.message}');
      print('Stack Trace: $stackTrace');
      // Optional: Attempt to delete the file if the DB insert failed
      if (fileUrl != null) {
        try {
          // Re-sanitize the file name for cleanup
          final originalFileName = file!.path.split('/').last;
          final safeFileName = originalFileName.replaceAll(RegExp(r'[^\w\-. ]'), '_');
          final pathToRemove = '$userId/$gradeId/$safeFileName';
          await _supabase.storage.from('grades').remove([pathToRemove]);
          print('Cleaned up uploaded file due to DB insert failure.');
        } catch (e) {
          print('Failed to clean up file: $e');
        }
      }
      return 'Database insertion failed: ${e.message}';
    } catch (e, stackTrace) {
      print('General Error adding grade: $e');
      print('Stack Trace: $stackTrace');
      return 'An unexpected error occurred: $e';
    }
  }

  // Returns null on success, or an error message string on failure
  Future<String?> deleteGrade(String gradeId, String createdBy) async {
    final currentUserId = _supabase.auth.currentUser?.id;
    if (currentUserId == null) {
      return 'User not authenticated. Please log in.';
    }
    if (currentUserId != createdBy) {
      return 'You are not authorized to delete this grade.';
    }

    try {
      // 1. Get grade details to find file_url
      final grade = await _supabase
          .from('grades')
          .select('file_url')
          .eq('id', gradeId)
          .maybeSingle();

      // 2. Delete from 'grades' table (restricted by created_by)
      await _supabase
          .from('grades')
          .delete()
          .eq('id', gradeId)
          .eq('created_by', currentUserId);
      
      print('Grade deleted successfully from database.');

      // 3. Delete file from Storage if it exists
      final fileUrl = grade?['file_url'];
      if (fileUrl != null && fileUrl.isNotEmpty) {
        try {
          // Extract the path from the public URL
          final fileName = fileUrl.split('/').last;
          final pathToRemove = '$currentUserId/$gradeId/$fileName';
          
          await _supabase.storage.from('grades').remove([pathToRemove]);
          print('File deleted successfully from Storage.');
        } catch (e) {
          print('Failed to delete file from Storage: $e');
        }
      }

      // Refresh state
      await fetchGrades();
      return null; // Success
    } on PostgrestException catch (e, stackTrace) {
      print('PostgrestException during grade deletion: ${e.message}');
      print('Stack Trace: $stackTrace');
      return 'Database deletion failed: ${e.message}';
    } catch (e, stackTrace) {
      print('General Error deleting grade: $e');
      print('Stack Trace: $stackTrace');
      return 'An unexpected error occurred: $e';
    }
  }
}
