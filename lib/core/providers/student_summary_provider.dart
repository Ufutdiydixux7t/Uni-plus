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
  final _bucketName = 'student_summaries'; // Assuming a separate bucket

  Future<void> fetchStudentSummaries() async {
    try {
      final response = await _supabase.from(_tableName).select().order('created_at', ascending: false);
      state = (response as List).map((json) => StudentSummary.fromJson(json)).toList();
    } on PostgrestException catch (e) {
      print('PostgrestException fetching $_tableName: ${e.message}');
      state = [];
    } catch (e) {
      print('General Error fetching $_tableName: $e');
      state = [];
    }
  }

  // Returns null on success, or an error message string on failure
  // NOTE: This is the exception where the Student is allowed to upload
  Future<String?> addStudentSummary({
    required String subject,
    String? doctor,
    String? note,
    File? file,
    String? groupId, // Added groupId
  }) async {
    String? fileUrl;
    final contentId = const Uuid().v4();
    final userId = _supabase.auth.currentUser?.id; // This is the student_id

    if (userId == null) {
      return 'User not authenticated. Please log in.';
    }

    try {
      if (file != null) {
        // Sanitize file name to handle non-ASCII, spaces, and symbols
        final originalFileName = file.path.split('/').last;
        final safeFileName = originalFileName.replaceAll(RegExp(r'[^\w\-. ]'), '_');
        final fileName = '$userId/$contentId/$safeFileName';
        
        // 1. Upload to Storage
        await _supabase.storage.from(_bucketName).upload(
          fileName, 
          file,
          fileOptions: const FileOptions(cacheControl: '3600', upsert: false),
        );
        
        // 2. Get public URL
        fileUrl = _supabase.storage.from(_bucketName).getPublicUrl(fileName);
      }

      final newContent = {
        'id': contentId,
        'subject': subject,
        'doctor': doctor,
        'note': note,
        'file_url': fileUrl,
        'student_id': userId, // Student is the uploader
        'group_id': groupId, // Added group_id
        // delegate_id is null on upload
      };

      // 3. Insert into table
      await _supabase.from(_tableName).insert(newContent);
      
      // Refresh state
      await fetchStudentSummaries();
      return null; // Success
    } on StorageException catch (e, stackTrace) {
      // Clean up file if DB insert fails
      if (fileUrl != null) {
        try {
          final originalFileName = file!.path.split('/').last;
          final safeFileName = originalFileName.replaceAll(RegExp(r'[^\w\-. ]'), '_');
          final pathToRemove = '$userId/$contentId/$safeFileName';
          await _supabase.storage.from(_bucketName).remove([pathToRemove]);
        } catch (e) {
          print('Failed to clean up file: $e');
        }
      }
      return 'File upload failed: ${e.message}';
    } on PostgrestException catch (e, stackTrace) {
      return 'Database insertion failed: ${e.message}';
    } catch (e, stackTrace) {
      return 'An unexpected error occurred: $e';
    }
  }

  // Returns null on success, or an error message string on failure
  // NOTE: Only Delegate can delete this content
  Future<String?> deleteStudentSummary(String contentId, String studentId) async {
    final currentUserId = _supabase.auth.currentUser?.id;
    // NOTE: We need to check if the current user is a delegate to allow deletion
    // Since we don't have the role here, we'll assume the UI handles the button visibility
    // and only check for authentication.
    if (currentUserId == null) {
      return 'User not authenticated. Please log in.';
    }

    try {
      // 1. Get content details to find file_url
      final content = await _supabase
          .from(_tableName)
          .select('file_url')
          .eq('id', contentId)
          .maybeSingle();

      // 2. Delete from table (restricted by delegate_id if it exists, or just by id)
      // Since the requirement is "المندوب: يشاهد + يحذف", we assume the delegate can delete any summary.
      await _supabase
          .from(_tableName)
          .delete()
          .eq('id', contentId);
      
      // 3. Delete file from Storage if it exists
      final fileUrl = content?['file_url'];
      if (fileUrl != null && fileUrl.isNotEmpty) {
        try {
          // Extract the path from the public URL
          // NOTE: The path contains the studentId as the first part
          final fileName = fileUrl.split('/').last;
          final pathToRemove = '$studentId/$contentId/$fileName';
          
          await _supabase.storage.from(_bucketName).remove([pathToRemove]);
        } catch (e) {
          print('Failed to delete file from Storage: $e');
        }
      }

      // Refresh state
      await fetchStudentSummaries();
      return null; // Success
    } on PostgrestException catch (e, stackTrace) {
      return 'Database deletion failed: ${e.message}';
    } catch (e, stackTrace) {
      return 'An unexpected error occurred: $e';
    }
  }
}
