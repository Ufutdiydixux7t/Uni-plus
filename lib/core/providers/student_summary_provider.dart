import 'dart:io';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:uuid/uuid.dart';
import '../models/student_summary_model.dart';

final studentSummaryProvider = StateNotifierProvider<StudentSummaryNotifier, List<StudentSummary>>((ref) {
  return StudentSummaryNotifier();
});

class StudentSummaryNotifier extends StateNotifier<List<StudentSummary>> {
  StudentSummaryNotifier() : super([]);

  final _supabase = Supabase.instance.client;
  final _tableName = 'student_summaries';
  final _bucketName = 'student_summaries';

  Future<void> fetchStudentSummaries({bool isDelegate = false}) async {
    final user = _supabase.auth.currentUser;
    if (user == null) return;

    try {
      var query = _supabase.from(_tableName).select();
      
      if (isDelegate) {
        final profile = await _supabase.from('profiles').select('join_code').eq('id', user.id).maybeSingle();
        if (profile != null && profile['join_code'] != null) {
          final group = await _supabase.from('groups').select('delegate_id').eq('join_code', profile['join_code']).maybeSingle();
          if (group != null) {
            query = query.eq('delegate_id', group['delegate_id']);
          }
        }
      } else {
        query = query.eq('student_id', user.id);
      }

      final response = await query.order('created_at', ascending: false);
      state = (response as List).map((json) => StudentSummary.fromJson(json)).toList();
    } catch (e) {
      print('Error fetching student summaries: $e');
      state = [];
    }
  }

  Future<String?> sendSummary({
    required String subject,
    required String doctor,
    required String note,
    File? file,
    String? fileName,
  }) async {
    final user = _supabase.auth.currentUser;
    if (user == null) return 'User not authenticated';

    try {
      String? fileUrl;

      if (file != null && fileName != null) {
        final fileExt = fileName.split('.').last;
        final sanitizedFileName = '${DateTime.now().millisecondsSinceEpoch}_${const Uuid().v4()}.$fileExt';
        final filePath = '${user.id}/$sanitizedFileName';

        await _supabase.storage.from(_bucketName).upload(filePath, file);
        
        fileUrl = _supabase.storage.from(_bucketName).getPublicUrl(filePath);
      }

      final profile = await _supabase.from('profiles').select('join_code').eq('id', user.id).maybeSingle();
      String? delegateId;
      
      if (profile != null && profile['join_code'] != null) {
        final group = await _supabase.from('groups').select('delegate_id').eq('join_code', profile['join_code']).maybeSingle();
        delegateId = group?['delegate_id'];
      }

      final newSummary = {
        'id': const Uuid().v4(),
        'student_id': user.id,
        'delegate_id': delegateId,
        'subject': subject,
        'doctor': doctor,
        'note': note,
        'file_url': fileUrl,
      };

      await _supabase.from(_tableName).insert(newSummary);
      
      await fetchStudentSummaries(isDelegate: false);
      return null; // Success
    } on StorageException catch (e) {
      return 'Storage Error: ${e.message}';
    } on PostgrestException catch (e) {
      return 'Database Error: ${e.message}';
    } catch (e) {
      return 'Error: $e';
    }
  }

  Future<String?> deleteSummary(String id) async {
    try {
      await _supabase.from(_tableName).delete().eq('id', id);
      await fetchStudentSummaries(isDelegate: true);
      return null;
    } catch (e) {
      return e.toString();
    }
  }
}
