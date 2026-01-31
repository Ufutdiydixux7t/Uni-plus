import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:uuid/uuid.dart';
import '../models/task_model.dart';

final taskProvider = StateNotifierProvider<TaskNotifier, List<Task>>((ref) {
  return TaskNotifier();
});

class TaskNotifier extends StateNotifier<List<Task>> {
  TaskNotifier() : super([]);

  final _supabase = Supabase.instance.client;
  final _tableName = 'tasks';

  Future<void> fetchTasks() async {
    final currentGroupId = _supabase.auth.currentUser?.userMetadata?['group_id'];
    if (currentGroupId == null) {
      state = [];
      return;
    }
    try {
      final response = await _supabase
          .from(_tableName)
          .select()
          .eq('group_id', currentGroupId)
          .order('created_at', ascending: false);
      state = (response as List).map((json) => Task.fromJson(json)).toList();
    } on PostgrestException catch (e) {
      print('PostgrestException fetching $_tableName: ${e.message}');
      state = [];
    } catch (e) {
      print('General Error fetching $_tableName: $e');
      state = [];
    }
  }

  // Returns null on success, or an error message string on failure
  Future<String?> addTask({
    required String subject,
    String? doctor,
    String? note,
    String? groupId, // Added groupId
  }) async {
    final contentId = const Uuid().v4();
    final userId = _supabase.auth.currentUser?.id;

    if (userId == null) {
      return 'User not authenticated. Please log in.';
    }

    try {
      final newContent = {
        'id': contentId,
        'subject': subject,
        'doctor': doctor,
        'note': note,
        'delegate_id': userId, // Added delegate_id
        'group_id': groupId, // Added group_id
        // No file_url for tasks
      };

      // 3. Insert into table
      await _supabase.from(_tableName).insert(newContent);
      
      // Refresh state
      await fetchTasks();
      return null; // Success
    } on PostgrestException catch (e, stackTrace) {
      return 'Database insertion failed: ${e.message}';
    } on StorageException catch (e, stackTrace) {
      return 'Storage operation failed: ${e.message}';
    } catch (e, stackTrace) {
      return 'An unexpected error occurred: $e';
    }
  }

  // Returns null on success, or an error message string on failure
  Future<String?> deleteTask(String contentId, String delegateId) async {
    final currentUserId = _supabase.auth.currentUser?.id;
    if (currentUserId == null) {
      return 'User not authenticated. Please log in.';
    }
    
    // Check if the current user is the creator (delegate)
    if (currentUserId != delegateId) {
      return 'You are not authorized to delete this task.';
    }

    try {
      // 1. Delete from table
      await _supabase
          .from(_tableName)
          .delete()
          .eq('id', contentId)
          .eq('delegate_id', currentUserId);
      
      // Refresh state
      await fetchTasks();
      return null; // Success
    } on PostgrestException catch (e, stackTrace) {
      return 'Database deletion failed: ${e.message}';
    } catch (e, stackTrace) {
      return 'An unexpected error occurred: $e';
    }
  }
}
