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
        query = query.eq('student_id', studentId);
      }
      if (groupId != null) {
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
        final fileName = '${DateTime.now().millisecondsSinceEpoch}_${file.path.split('/').last}';
        
        // Upload to 'grades' bucket
        await _supabase.storage.from('grades').upload(
          fileName, 
          file,
          fileOptions: const FileOptions(cacheControl: '3600', upsert: false),
        );
        
        // Get public URL
        fileUrl = _supabase.storage.from('grades').getPublicUrl(fileName);
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

      await _supabase.from('grades').insert(newGrade);
      
      // Refresh state
      await fetchGrades(studentId: studentId, groupId: groupId);
      return true;
    } catch (e) {
      print('Error adding grade: $e');
      return false;
    }
  }
}
