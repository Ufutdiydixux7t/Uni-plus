import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class SecureStorageService {
  static const _storage = FlutterSecureStorage();

  // Keys
  static const _keyRole = 'user_role';
  static const _keyName = 'user_name';
  static const _keyClassCode = 'class_code';

  // Save
  static Future<void> saveUser({
    required String role,
    required String name,
    String? classCode,
  }) async {
    await _storage.write(key: _keyRole, value: role);
    await _storage.write(key: _keyName, value: name);

    if (classCode != null) {
      await _storage.write(key: _keyClassCode, value: classCode);
    }
  }

  // Read
  static Future<String?> getRole() =>
      _storage.read(key: _keyRole);

  static Future<String?> getName() =>
      _storage.read(key: _keyName);

  static Future<String?> getClassCode() =>
      _storage.read(key: _keyClassCode);

  // Clear
  static Future<void> clear() async {
    await _storage.deleteAll();
  }
}