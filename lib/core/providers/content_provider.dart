import 'dart:convert';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../storage/secure_storage_service.dart';
import '../models/content_item.dart';

final contentProvider = StateNotifierProvider<ContentNotifier, List<ContentItem>>((ref) {
  return ContentNotifier();
});

class ContentNotifier extends StateNotifier<List<ContentItem>> {
  ContentNotifier() : super([]) {
    _loadContent();
  }

  static const String _storageKey = 'uniplus_content';

  Future<void> _loadContent() async {
    final data = await SecureStorageService.storage.read(key: _storageKey);
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
    required String uploaderName,
  }) async {
    final newItem = ContentItem(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      title: title,
      description: description,
      category: category,
      fileName: fileName,
      uploaderName: uploaderName,
      date: DateTime.now(),
    );
    state = [...state, newItem];
    await _saveToStorage();
  }

  Future<void> deleteContent(String id) async {
    state = state.where((item) => item.id != id).toList();
    await _saveToStorage();
  }

  Future<void> _saveToStorage() async {
    final data = jsonEncode(state.map((item) => item.toJson()).toList());
    await SecureStorageService.storage.write(key: _storageKey, value: data);
  }

  List<ContentItem> getByCategory(String category) {
    return state.where((item) => item.category == category).toList();
  }
}
