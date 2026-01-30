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
    try {
      String? fileUrl;
      if (file != null) {
        final fileName = '${DateTime.now().millisecondsSinceEpoch}_${const Uuid().v4()}_${file.path.split('/').last}';
        
        // 1. Upload to 'grades' bucket
        final uploadResponse = await _supabase.storage.from('grades').upload(
          fileName, 
          file,
          fileOptions: const FileOptions(cacheControl: '3600', upsert: false),
        );

        // Check for upload success
        if (uploadResponse.isNotEmpty) {
          // 2. Get public URL
          fileUrl = _supabase.storage.from('grades').getPublicUrl(fileName);
          print('File uploaded successfully. Public URL: $fileUrl');
        } else {
          print('File upload failed: Upload response was empty.');
          return false;
        }
      }

      final newGrade = {
        'id': const Uuid().v4(),
        'subject': subject,
        'doctor': doctor,
        'note': note,
        'student_id': studentId,
        'group_id': groupId,
        'file_url': fileUrl,
        'created_at': DateTime.now().toIso8601String(),
      };

      // 3. Insert into 'grades' table
      final insertResponse = await _supabase.from('grades').insert(newGrade).select();
      
      if (insertResponse.isEmpty) {
        print('Database insertion failed: Insert response was empty.');
        return false;
      }
      
      print('Grade inserted successfully into database.');

      // Refresh state
      await fetchGrades(studentId: studentId, groupId: groupId);
      return true;
    } catch (e, stackTrace) {
      print('Error adding grade: $e');
      print('Stack Trace: $stackTrace');
      return false;
    }
  }
}
