import 'dart:io';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:uuid/uuid.dart';
import '../models/form_model.dart';

final formProvider = StateNotifierProvider<FormNotifier, List<FormModel>>((ref) {
  return FormNotifier();
});

class FormNotifier extends StateNotifier<List<FormModel>> {
  FormNotifier() : super([]);

  final _supabase = Supabase.instance.client;
  final _tableName = 'forms';
  final _bucketName = 'forms';

  Future<void> fetchForms() async {
    try {
      final response = await _supabase.from(_tableName).select().order('created_at', ascending: false);
      state = (response as List).map((json) => FormModel.fromJson(json)).toList();
      print('Fetched ${state.length} forms');
    } on PostgrestException catch (e) {
      print('PostgrestException fetching $_tableName: ${e.message}');
      state = [];
    } catch (e) {
      print('General Error fetching $_tableName: $e');
      state = [];
    }
  }

  Future<String?> addForm({
    required String subject,
    String? doctor,
    String? note,
    File? file,
    String? groupId,
  }) async {
    String? fileUrl;
    final formId = const Uuid().v4();
    final userId = _supabase.auth.currentUser?.id;

    if (userId == null) {
      return 'User not authenticated. Please log in.';
    }

    try {
      if (file != null) {
        final originalFileName = file.path.split('/').last;
        final safeFileName = originalFileName.replaceAll(RegExp(r'[^\w\-. ]'), '_');
        final fileName = '$userId/$formId/$safeFileName';
        
        await _supabase.storage.from(_bucketName).upload(
          fileName, 
          file,
          fileOptions: const FileOptions(cacheControl: '3600', upsert: false),
        );
        
        fileUrl = _supabase.storage.from(_bucketName).getPublicUrl(fileName);
      }

      final newForm = {
        'id': formId,
        'subject': subject,
        'doctor': doctor,
        'note': note,
        'file_url': fileUrl,
        'delegate_id': userId,
        'group_id': groupId,
      };

      await _supabase.from(_tableName).insert(newForm);
      
      await fetchForms();
      return null; // Success
    } on StorageException catch (e) {
      return 'File upload failed: ${e.message}';
    } on PostgrestException catch (e) {
      if (fileUrl != null) {
        try {
          final originalFileName = file!.path.split('/').last;
          final safeFileName = originalFileName.replaceAll(RegExp(r'[^\w\-. ]'), '_');
          final pathToRemove = '$userId/$formId/$safeFileName';
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

  Future<String?> deleteForm(String formId, String delegateId) async {
    final currentUserId = _supabase.auth.currentUser?.id;
    if (currentUserId == null) {
      return 'User not authenticated. Please log in.';
    }
    if (currentUserId != delegateId) {
      return 'You are not authorized to delete this form.';
    }

    try {
      final form = await _supabase
          .from(_tableName)
          .select('file_url')
          .eq('id', formId)
          .maybeSingle();

      await _supabase
          .from(_tableName)
          .delete()
          .eq('id', formId)
          .eq('delegate_id', currentUserId);
      
      final fileUrl = form?['file_url'];
      if (fileUrl != null && fileUrl.isNotEmpty) {
        try {
          final fileName = fileUrl.split('/').last;
          final pathToRemove = '$currentUserId/$formId/$fileName';
          await _supabase.storage.from(_bucketName).remove([pathToRemove]);
        } catch (e) {
          print('Failed to delete file from Storage: $e');
        }
      }

      await fetchForms();
      return null; // Success
    } on PostgrestException catch (e) {
      return 'Database deletion failed: ${e.message}';
    } catch (e) {
      return 'An unexpected error occurred: $e';
    }
  }
}
