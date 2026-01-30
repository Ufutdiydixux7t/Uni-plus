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
      } else {
        // If no group ID, return empty list (or fetch all if RLS is disabled)
        // Since RLS is disabled, we'll fetch all for now if no group ID is provided
        // In a real app, this would be restricted by RLS.
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
        // 'created_at' will be set by the database default
      };

      // 3. Insert into 'grades' table
      await _supabase.from('grades').insert(newGrade);
      
      print('Grade inserted successfully into database.');

      // Refresh state
      await fetchGrades(groupId: groupId);
      return true;
    } on StorageException catch (e) {
      print('StorageException during file upload: ${e.message}');
      return false;
    } on PostgrestException catch (e) {
      print('PostgrestException during database insert: ${e.message}');
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
    } catch (e) {
      print('General Error adding grade: $e');
      return false;
    }
  }
}
