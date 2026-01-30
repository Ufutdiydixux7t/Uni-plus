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

  Future<void> fetchGrades({String? studentId, String? groupId}) async {
    try {
      var query = _supabase.from('grades').select();
      
      if (studentId != null) {
        // Fetch grades specifically for this student (if direct assignment is used)
        query = query.eq('student_id', studentId);
      }
      if (groupId != null) {
        // Fetch grades for the group the student belongs to
        query = query.eq('group_id', groupId);
      }

      final response = await query.order('created_at', ascending: false);
      state = (response as List).map((json) => Grade.fromJson(json)).toList();
    } catch (e) {
      print('Error fetching grades: $e');
    }
  }

  Future<bool> addGrade({
    required String subject,
    String? doctor,
    String? note,
    String? studentId,
    String? groupId,
    File? file,
  }) async {
    String? fileUrl;
    final gradeId = const Uuid().v4();

    try {
      if (file != null) {
        final userId = _supabase.auth.currentUser?.id;
        if (userId == null) {
          print('Error: User not authenticated for file upload.');
          return false;
        }
        
        // 1. Upload to 'grades' bucket
        final fileName = '$userId/$gradeId/${file.path.split('/').last}';
        
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
        'id': gradeId, // Use the generated ID
        'subject': subject,
        'doctor': doctor,
        'note': note,
        'student_id': studentId,
        'group_id': groupId,
        'file_url': fileUrl,
        'created_at': DateTime.now().toIso8601String(),
      };

      // 3. Insert into 'grades' table
      await _supabase.from('grades').insert(newGrade);
      
      print('Grade inserted successfully into database.');

      // Refresh state
      await fetchGrades(studentId: studentId, groupId: groupId);
      return true;
    } on StorageException catch (e) {
      print('StorageException during file upload: ${e.message}');
      return false;
    } on PostgrestException catch (e) {
      print('PostgrestException during database insert: ${e.message}');
      // Optional: Attempt to delete the file if the DB insert failed
      if (fileUrl != null) {
        try {
          final fileName = fileUrl.split('/').last;
          await _supabase.storage.from('grades').remove([fileName]);
          print('Cleaned up uploaded file due to DB insert failure.');
        } catch (e) {
          print('Failed to clean up file: $e');
        }
      }
      return false;
    } catch (e) {
      print('General Error adding grade: $e');
      return false;
    }
  }
}
