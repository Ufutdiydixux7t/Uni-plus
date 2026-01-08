import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import '../auth/user_role.dart';

class SecureStorageService {
  // ================= CORE =================

  /// لا تستخدم const هنا ❌
  static final FlutterSecureStorage _storage =
  const FlutterSecureStorage();

  // ================= KEYS =================

  static const String _keyRole = 'user_role';
  static const String _keyName = 'user_name';
  static const String _keyClassCode = 'class_code';
  static const String _welcomeKey = 'has_seen_welcome';

  // ================= SAVE =================

  /// حفظ بيانات المستخدم (Student / Delegate / Admin)
  static Future<void> saveUser({
    required UserRole role,
    required String name,
    String? classCode,
  }) async {
    await _storage.write(key: _keyRole, value: role.name);
    await _storage.write(key: _keyName, value: name);

    if (classCode != null && classCode.isNotEmpty) {
      await _storage.write(key: _keyClassCode, value: classCode);
    }
  }

  // ================= READ =================

  /// ❌ قديم – فقط للتوافق مع ملفات لم تُعدّل بعد
  /// لا تستخدمه في أي كود جديد
  static Future<String?> getRole() async {
    return _storage.read(key: _keyRole);
  }

  /// ✅ المعتمد – يعيد UserRole وليس String
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

  // ================= CLEAR =================

  /// ❌ قديم – اتركه فقط حتى لا تتكسر ملفات قديمة
  static Future<void> clear() async {
    await _storage.deleteAll();
  }

  /// ✅ المعتمد
  static Future<void> clearUser() async {
    await _storage.deleteAll();
  }

  // ================= WELCOME =================

  static Future<void> setWelcomeSeen() async {
    await _storage.write(key: _welcomeKey, value: 'true');
  }

  static Future<bool> hasSeenWelcome() async {
    final value = await _storage.read(key: _welcomeKey);
    return value == 'true';
  }
}