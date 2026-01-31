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
      final response = await _supabase.from(_tableName).select().order('created_at', ascending: false);
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

  Future<String?> addDailyReport({
    required String subject,
    required String doctor,
    required String room,
    required String day,
    File? file,
  }) async {
    String? fileUrl;
    final reportId = const Uuid().v4();
    final userId = _supabase.auth.currentUser?.id;

    if (userId == null) {
      return 'User not authenticated. Please log in.';
    }

    try {
      if (file != null) {
        final originalFileName = file.path.split('/').last;
        final safeFileName = originalFileName.replaceAll(RegExp(r'[^\w\-. ]'), '_');
        final fileName = '$userId/$reportId/$safeFileName';
        
        await _supabase.storage.from(_bucketName).upload(
          fileName, 
          file,
          fileOptions: const FileOptions(cacheControl: '3600', upsert: false),
        );
        
        fileUrl = _supabase.storage.from(_bucketName).getPublicUrl(fileName);
      }

      final newReport = {
        'id': reportId,
        'subject': subject,
        'doctor': doctor,
        'room': room,
        'day': day,
        'file_url': fileUrl,
        'delegate_id': userId,
      };

      await _supabase.from(_tableName).insert(newReport);
      
      await fetchDailyReports();
      return null; // Success
    } on StorageException catch (e) {
      return 'File upload failed: ${e.message}';
    } on PostgrestException catch (e) {
      if (fileUrl != null) {
        try {
          final originalFileName = file!.path.split('/').last;
          final safeFileName = originalFileName.replaceAll(RegExp(r'[^\w\-. ]'), '_');
          final pathToRemove = '$userId/$reportId/$safeFileName';
          await _supabase.storage.from(_bucketName).remove([pathToRemove]);
        } catch (cleanupError) {
          print('Failed to clean up file: $cleanupError');
        }
      }
      return 'Database insertion failed: ${e.message}';
    } catch (e) {
      return 'An unexpected error occurred: $e';
    }
  }

  Future<String?> deleteDailyReport(String reportId, String delegateId) async {
    final currentUserId = _supabase.auth.currentUser?.id;
    if (currentUserId == null) {
      return 'User not authenticated. Please log in.';
    }
    if (currentUserId != delegateId) {
      return 'You are not authorized to delete this report.';
    }

    try {
      final report = await _supabase
          .from(_tableName)
          .select('file_url')
          .eq('id', reportId)
          .maybeSingle();

      await _supabase
          .from(_tableName)
          .delete()
          .eq('id', reportId)
          .eq('delegate_id', currentUserId);
      
      final fileUrl = report?['file_url'];
      if (fileUrl != null && fileUrl.isNotEmpty) {
        try {
          final fileName = fileUrl.split('/').last;
          final pathToRemove = '$currentUserId/$reportId/$fileName';
          await _supabase.storage.from(_bucketName).remove([pathToRemove]);
        } catch (e) {
          print('Failed to delete file from Storage: $e');
        }
      }

      await fetchDailyReports();
      return null; // Success
    } on PostgrestException catch (e) {
      return 'Database deletion failed: ${e.message}';
    } catch (e) {
      return 'An unexpected error occurred: $e';
    }
  }
}
