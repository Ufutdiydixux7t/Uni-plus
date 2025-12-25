import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../storage/secure_storage_service.dart';

class UserState {
  final String name;
  final String role;
  final String? classCode;

  const UserState({
    required this.name,
    required this.role,
    this.classCode,
  });
}

final userProvider =
StateNotifierProvider<UserNotifier, UserState?>(
      (ref) => UserNotifier(),
);

class UserNotifier extends StateNotifier<UserState?> {
  UserNotifier() : super(null);

  Future<void> loadUser() async {
    final name = await SecureStorageService.getName();
    final role = await SecureStorageService.getRole();
    final code = await SecureStorageService.getClassCode();

    if (name != null && role != null) {
      state = UserState(
        name: name,
        role: role,
        classCode: code,
      );
    }
  }

  Future<void> logout() async {
    await SecureStorageService.clear();
    state = null;
  }
}