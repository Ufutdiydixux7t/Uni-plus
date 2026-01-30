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

  Future<void> fetchGrades({String? groupId}) async {
    try {
      var query = _supabase.from('grades').select();
      
      if (groupId != null) {
        // Fetch grades for the group the user belongs to
        query = query.eq('group_id', groupId);
      }

      final response = await query.order('created_at', ascending: false);
      state = (response as List).map((json) => Grade.fromJson(json)).toList();
    } on PostgrestException catch (e) {
      print('PostgrestException fetching grades: ${e.message}');
      state = [];
    } catch (e) {
      print('General Error fetching grades: $e');
      state = [];
    }
  }

  Future<bool> addGrade({
    required String subject,
    String? doctor,
    String? note,
    File? file,
  }) async {
    String? fileUrl;
    final gradeId = const Uuid().v4();
    final userId = _supabase.auth.currentUser?.id;

    if (userId == null) {
      print('Error: User not authenticated for file upload/insert.');
      return false;
    }

    // Get group_id for this delegate
    final groupData = await _supabase
        .from('groups')
        .select('id')
        .eq('delegate_id', userId)
        .maybeSingle();
    
    final groupId = groupData?['id'];

    if (groupId == null) {
      print('Error: Delegate does not belong to a group. Cannot add grade.');
      return false;
    }

    try {
      if (file != null) {
        // 1. Upload to 'grades' bucket
        // Use a path that includes group ID for better organization: group_id/grade_id/filename
        final fileName = '$groupId/$gradeId/${file.path.split('/').last}';
        
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
        'group_id': groupId,
        'file_url': fileUrl,
        'created_by': userId, // CRITICAL: Add created_by
        // 'created_at' will be set by the database default
      };

      // 3. Insert into 'grades' table
      await _supabase.from('grades').insert(newGrade);
      
      print('Grade inserted successfully into database.');

      // Refresh state
      await fetchGrades(groupId: groupId);
      return true;
    } on StorageException catch (e, stackTrace) {
      print('StorageException during file upload: ${e.message}');
      print('Stack Trace: $stackTrace');
      return false;
    } on PostgrestException catch (e, stackTrace) {
      print('PostgrestException during database insert: ${e.message}');
      print('Stack Trace: $stackTrace');
      // Optional: Attempt to delete the file if the DB insert failed
      if (fileUrl != null) {
        try {
          // The path for removal is the path used for upload
          final pathToRemove = '$groupId/$gradeId/${file!.path.split('/').last}';
          await _supabase.storage.from('grades').remove([pathToRemove]);
          print('Cleaned up uploaded file due to DB insert failure.');
        } catch (e) {
          print('Failed to clean up file: $e');
        }
      }
      return false;
    } catch (e, stackTrace) {
      print('General Error adding grade: $e');
      print('Stack Trace: $stackTrace');
      return false;
    }
  }

  Future<bool> deleteGrade(String gradeId, String createdBy) async {
    final currentUserId = _supabase.auth.currentUser?.id;
    if (currentUserId == null || currentUserId != createdBy) {
      print('Error: User not authorized to delete this grade.');
      return false;
    }

    try {
      // 1. Get grade details to find file_url
      final grade = await _supabase
          .from('grades')
          .select('file_url, group_id')
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
      final groupId = grade?['group_id'];
      if (fileUrl != null && fileUrl.isNotEmpty && groupId != null) {
        try {
          // Extract the path from the public URL
          // The path is expected to be: group_id/grade_id/filename
          final fileName = fileUrl.split('/').last;
          final pathToRemove = '$groupId/$gradeId/$fileName';
          
          await _supabase.storage.from('grades').remove([pathToRemove]);
          print('File deleted successfully from Storage.');
        } catch (e) {
          print('Failed to delete file from Storage: $e');
        }
      }

      // Refresh state
      final groupData = await _supabase
          .from('groups')
          .select('id')
          .eq('delegate_id', currentUserId)
          .maybeSingle();
      
      final groupIdToFetch = groupData?['id'];
      await fetchGrades(groupId: groupIdToFetch);
      return true;
    } on PostgrestException catch (e, stackTrace) {
      print('PostgrestException during grade deletion: ${e.message}');
      print('Stack Trace: $stackTrace');
      return false;
    } catch (e, stackTrace) {
      print('General Error deleting grade: $e');
      print('Stack Trace: $stackTrace');
      return false;
    }
  }
}
