import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import '../auth/user_role.dart';

class SecureStorageService {
  static const FlutterSecureStorage _storage = FlutterSecureStorage();
  static FlutterSecureStorage get storage => _storage;

  static const String _keyRole = 'user_role';
  static const String _keyName = 'user_name';
  static const String _keyClassCode = 'class_code';
  static const String _welcomeKey = 'has_seen_welcome';

  static Future<void> saveUser({
    required UserRole role,
    required String name,
    String? classCode,
  }) async {
    await _storage.write(key: _keyRole, value: role.name);
    await _storage.write(key: _nameKey, value: name);
    if (classCode != null && classCode.isNotEmpty) {
      await _storage.write(key: _keyClassCode, value: classCode);
    }
  }

  static const String _nameKey = 'user_name';

  static Future<UserRole> getUserRole() async {
    final value = await _storage.read(key: _keyRole);
    return UserRoleX.fromString(value);
  }

  static Future<String?> getName() async {
    return _storage.read(key: _keyName);
  }

  static Future<String?> getClassCode() async {
    return _storage.read(key: _keyClassCode);
  }

  static Future<void> clearUser() async {
    await _storage.deleteAll();
  }

  static Future<void> logout() async {
    await _storage.deleteAll();
  }

  static Future<void> setWelcomeSeen() async {
    await _storage.write(key: _welcomeKey, value: 'true');
  }

  static Future<bool> hasSeenWelcome() async {
    final value = await _storage.read(key: _welcomeKey);
    return value == 'true';
  }
}
