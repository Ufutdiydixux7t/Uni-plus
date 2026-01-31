import 'dart:io';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:uuid/uuid.dart';
import '../models/daily_report_model.dart';

final dailyReportProvider = StateNotifierProvider<DailyReportNotifier, List<DailyReport>>((ref) {
  return DailyReportNotifier();
});

class DailyReportNotifier extends StateNotifier<List<DailyReport>> {
  DailyReportNotifier() : super([]);

  final _supabase = Supabase.instance.client;
  final _tableName = 'daily_reports';
  final _bucketName = 'daily_reports';

  Future<void> fetchDailyReports() async {
    try {
      // Fetch all reports for now to ensure visibility
      final response = await _supabase
          .from(_tableName)
          .select()
          .order('created_at', ascending: false);
      state = (response as List).map((json) => DailyReport.fromJson(json)).toList();
      print('Fetched ${state.length} daily reports');
    } on PostgrestException catch (e) {
      print('PostgrestException fetching $_tableName: ${e.message}');
      state = [];
    } catch (e) {
      print('General Error fetching $_tableName: $e');
      state = [];
    }
  }

  // Returns null on success, or an error message string on failure
  Future<String?> addDailyReport({
    required String subject,
    String? doctor,
    String? room,
    String? day,
    File? file,
    String? groupId,
  }) async {
    String? fileUrl;
    final contentId = const Uuid().v4();
    final userId = _supabase.auth.currentUser?.id;

    if (userId == null) {
      return 'User not authenticated. Please log in.';
    }

    try {
      if (file != null) {
        final originalFileName = file.path.split('/').last;
        final safeFileName = originalFileName.replaceAll(RegExp(r'[^\w\-. ]'), '_');
        final fileName = '$userId/$contentId/$safeFileName';
        
        await _supabase.storage.from(_bucketName).upload(
          fileName, 
          file,
          fileOptions: const FileOptions(cacheControl: '3600', upsert: false),
        );
        
        fileUrl = _supabase.storage.from(_bucketName).getPublicUrl(fileName);
      }

      final newContent = {
        'id': contentId,
        'subject': subject,
        'doctor': doctor,
        'room': room,
        'day': day,
        'file_url': fileUrl,
        'delegate_id': userId,
        'group_id': groupId,
      };

      await _supabase.from(_tableName).insert(newContent);
      
      // Refresh state
      await fetchDailyReports();
      return null; // Success
    } on StorageException catch (e) {
      return 'File upload failed: ${e.message}';
    } on PostgrestException catch (e) {
      return 'Database insertion failed: ${e.message}';
    } catch (e) {
      return 'An unexpected error occurred: $e';
    }
  }

  // Returns null on success, or an error message string on failure
  Future<String?> deleteDailyReport(String contentId, String delegateId) async {
    final currentUserId = _supabase.auth.currentUser?.id;
    if (currentUserId == null) {
      return 'User not authenticated. Please log in.';
    }
    
    if (currentUserId != delegateId) {
      return 'You are not authorized to delete this report.';
    }

    try {
      final content = await _supabase
          .from(_tableName)
          .select('file_url')
          .eq('id', contentId)
          .maybeSingle();

      await _supabase
          .from(_tableName)
          .delete()
          .eq('id', contentId);
      
      final fileUrl = content?['file_url'];
      if (fileUrl != null && fileUrl.isNotEmpty) {
        try {
          final fileName = fileUrl.split('/').last;
          final pathToRemove = '$currentUserId/$contentId/$fileName';
          await _supabase.storage.from(_bucketName).remove([pathToRemove]);
        } catch (e) {
          print('Failed to delete file from Storage: $e');
        }
      }

      // Refresh state
      await fetchDailyReports();
      return null; // Success
    } on PostgrestException catch (e) {
      return 'Database deletion failed: ${e.message}';
    } catch (e) {
      return 'An unexpected error occurred: $e';
    }
  }
}
