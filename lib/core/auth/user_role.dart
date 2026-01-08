enum UserRole {
  student,
  delegate,
  admin,
}

extension UserRoleX on UserRole {
  String get value => name;

  static UserRole fromString(String? role) {
    switch (role) {
      case 'delegate':
        return UserRole.delegate;
      case 'admin':
        return UserRole.admin;
      case 'student':
      default:
        return UserRole.student;
    }
  }
}