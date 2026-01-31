import 'dart:convert';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../storage/secure_storage_service.dart';
import '../models/content_item.dart';

final contentProvider = StateNotifierProvider<ContentNotifier, List<ContentItem>>((ref) {
  return ContentNotifier();
});

class ContentNotifier extends StateNotifier<List<ContentItem>> {
  ContentNotifier() : super([]) {
    fetchContent();
  }

  final _supabase = Supabase.instance.client;
  final _tableName = 'content_items'; // Assuming this table exists for generic content

  Future<void> fetchContent() async {
    try {
      // For now, we'll keep using local storage for generic content if table doesn't exist
      // but ideally this should be migrated to Supabase like others.
      // To ensure updates are visible, we'll try to fetch from Supabase if possible.
      final response = await _supabase.from(_tableName).select().order('created_at', ascending: false);
      state = (response as List).map((item) => ContentItem.fromJson(item)).toList();
      print('Fetched ${state.length} content items from Supabase');
    } catch (e) {
      print('Supabase fetch failed for content_items, falling back to local storage: $e');
      _loadFromLocalStorage();
    }
  }

  Future<void> _loadFromLocalStorage() async {
    final data = await SecureStorageService.storage.read(key: 'uniplus_content');
    if (data != null) {
      final List<dynamic> decoded = jsonDecode(data);
      state = decoded.map((item) => ContentItem.fromJson(item)).toList();
    }
  }

  Future<void> addContent({
    required String title,
    required String description,
    required String category,
    required String fileName,
    String? filePath,
    required String uploaderName,
  }) async {
    final newItem = ContentItem(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      title: title,
      description: description,
      category: category,
      fileName: fileName,
      filePath: filePath,
      uploaderName: uploaderName,
      date: DateTime.now(),
    );
    
    state = [...state, newItem];
    
    try {
      // Try to save to Supabase
      await _supabase.from(_tableName).insert({
        'id': newItem.id,
        'title': newItem.title,
        'description': newItem.description,
        'category': newItem.category,
        'file_name': newItem.fileName,
        'file_path': newItem.filePath,
        'uploader_name': newItem.uploaderName,
        'created_at': newItem.date.toIso8601String(),
      });
    } catch (e) {
      print('Supabase insert failed for content_items, saving locally: $e');
      await _saveToLocalStorage();
    }
  }

  Future<void> deleteContent(String id) async {
    state = state.where((item) => item.id != id).toList();
    try {
      await _supabase.from(_tableName).delete().eq('id', id);
    } catch (e) {
      print('Supabase delete failed for content_items, updating local storage: $e');
      await _saveToLocalStorage();
    }
  }

  Future<void> _saveToLocalStorage() async {
    final data = jsonEncode(state.map((item) => item.toJson()).toList());
    await SecureStorageService.storage.write(key: 'uniplus_content', value: data);
  }

  List<ContentItem> getByCategory(String category) {
    return state.where((item) => item.category == category).toList();
  }
}
