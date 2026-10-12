/// DTO mapping OpenIddict /connect/userinfo response.
class UserInfoDto {
  final String sub;
  final String? name;
  final String? email;
  final dynamic role;
  final dynamic permission;
  final String? academicSessionId;

  const UserInfoDto({
    required this.sub,
    this.name,
    this.email,
    this.role,
    this.permission,
    this.academicSessionId,
  });

  factory UserInfoDto.fromJson(Map<String, dynamic> json) {
    return UserInfoDto(
      sub: json['sub'] as String,
      name: json['name'] as String?,
      email: json['email'] as String?,
      role: json['role'],
      permission: json['permission'],
      academicSessionId: json['academic_session_id'] as String?,
    );
  }

  List<String> get rolesList {
    if (role == null) return [];
    if (role is List) return (role as List).map((e) => e.toString()).toList();
    return [role.toString()];
  }

  List<String> get permissionsList {
    if (permission == null) return [];
    if (permission is List) {
      return (permission as List).map((e) => e.toString()).toList();
    }
    return [permission.toString()];
  }
}
