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
      // The query will automatically respect RLS policies based on the authenticated user.
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
    try {
      String? fileUrl;
      if (file != null) {
        final userId = _supabase.auth.currentUser?.id;
        if (userId == null) {
          print('Error: User not authenticated for file upload.');
          return false;
        }
        
        // Use the authenticated user's ID in the file path to help with RLS policy on Storage
        final fileName = '$userId/${DateTime.now().millisecondsSinceEpoch}_${const Uuid().v4()}_${file.path.split('/').last}';
        
        // 1. Upload to 'grades' bucket using the authenticated user's session
        // This requires a Storage RLS policy that allows 'insert' for authenticated users.
        await _supabase.storage.from('grades').upload(
          fileName, 
          file,
          fileOptions: const FileOptions(cacheControl: '3600', upsert: false),
        );

        // 2. Get public URL
        // NOTE: Supabase Storage getPublicUrl does not throw an error, it just constructs the URL.
        fileUrl = _supabase.storage.from('grades').getPublicUrl(fileName);
        print('File uploaded successfully. Public URL: $fileUrl');
      }

      final newGrade = {
        'id': const Uuid().v4(),
        'subject': subject,
        'doctor': doctor,
        'note': note,
        // Assuming grades are group-wide, student_id is not set here unless it's a specific student's grade.
        // For group-wide grades, we rely on group_id.
        'group_id': groupId,
        'file_url': fileUrl,
        'created_at': DateTime.now().toIso8601String(),
      };

      // 3. Insert into 'grades' table
      // This requires a Database RLS policy that allows 'insert' for authenticated users (delegates).
      await _supabase.from('grades').insert(newGrade);
      
      print('Grade inserted successfully into database.');

      // Refresh state
      await fetchGrades(studentId: studentId, groupId: groupId);
      return true;
    } catch (e, stackTrace) {
      // If RLS is not configured correctly, the error will be caught here.
      print('Error adding grade (likely RLS issue): $e');
      print('Stack Trace: $stackTrace');
      return false;
    }
  }
}
