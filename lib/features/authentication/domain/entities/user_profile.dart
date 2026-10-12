/// Pure Dart domain entity representing the authenticated user context.
class UserProfile {
  final String userId;
  final String userName;
  final String email;
  final List<String> roles;
  final List<String> permissions;
  final String? academicSessionId;

  const UserProfile({
    required this.userId,
    required this.userName,
    required this.email,
    this.roles = const [],
    this.permissions = const [],
    this.academicSessionId,
  });

  /// Evaluates whether the user is in the Student / Parent persona.
  bool get isStudentOrParent {
    final lowerRoles = roles.map((r) => r.toLowerCase()).toList();
    return lowerRoles.contains('student') || lowerRoles.contains('parent');
  }

  /// Evaluates whether the user is in the Staff / Teacher / Admin persona.
  bool get isStaffOrTeacher {
    final lowerRoles = roles.map((r) => r.toLowerCase()).toList();
    return lowerRoles.contains('teacher') ||
        lowerRoles.contains('staff') ||
        lowerRoles.contains('admin') ||
        lowerRoles.contains('principal') ||
        !isStudentOrParent;
  }

  bool hasRole(String role) {
    return roles.any((r) => r.equalsIgnoreCase(role));
  }

  bool hasPermission(String page, String action) {
    final target = '$page:$action'.toLowerCase();
    return permissions.any((p) => p.toLowerCase() == target);
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is UserProfile &&
          runtimeType == other.runtimeType &&
          userId == other.userId;

  @override
  int get hashCode => userId.hashCode;
}

extension _StringExt on String {
  bool equalsIgnoreCase(String other) => toLowerCase() == other.toLowerCase();
}
