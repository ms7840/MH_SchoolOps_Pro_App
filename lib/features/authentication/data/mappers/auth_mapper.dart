import 'package:jwt_decoder/jwt_decoder.dart';
import '../../domain/entities/auth_token.dart';
import '../../domain/entities/user_profile.dart';
import '../dto/token_response_dto.dart';
import '../dto/user_info_dto.dart';

/// Mappers converting auth DTOs and JWT claims to domain entities.
extension TokenResponseDtoMapper on TokenResponseDto {
  AuthToken toDomain() {
    final expiresAt = DateTime.now().add(Duration(seconds: expiresIn));
    return AuthToken(
      accessToken: accessToken,
      refreshToken: refreshToken,
      tokenType: tokenType,
      expiresIn: expiresIn,
      expiresAt: expiresAt,
    );
  }
}

extension UserInfoDtoMapper on UserInfoDto {
  UserProfile toDomain() {
    return UserProfile(
      userId: sub,
      userName: name ?? '',
      email: email ?? '',
      roles: rolesList,
      permissions: permissionsList,
      academicSessionId: academicSessionId,
    );
  }
}

class JwtClaimsMapper {
  const JwtClaimsMapper._();

  /// Decodes and maps JWT claims into a UserProfile if /connect/userinfo is unavailable.
  static UserProfile fromToken(String accessToken) {
    if (!JwtDecoder.isExpired(accessToken)) {
      final decoded = JwtDecoder.decode(accessToken);

      final sub = decoded['sub'] as String? ?? '';
      final name = decoded['name'] as String? ?? '';
      final email = decoded['email'] as String? ?? '';

      final rawRole = decoded['role'];
      final List<String> roles;
      if (rawRole is List) {
        roles = rawRole.map((e) => e.toString()).toList();
      } else if (rawRole != null) {
        roles = [rawRole.toString()];
      } else {
        roles = [];
      }

      final rawPermission = decoded['permission'];
      final List<String> permissions;
      if (rawPermission is List) {
        permissions = rawPermission.map((e) => e.toString()).toList();
      } else if (rawPermission != null) {
        permissions = [rawPermission.toString()];
      } else {
        permissions = [];
      }

      final academicSessionId = decoded['academic_session_id'] as String?;

      return UserProfile(
        userId: sub,
        userName: name,
        email: email,
        roles: roles,
        permissions: permissions,
        academicSessionId: academicSessionId,
      );
    }

    return const UserProfile(
      userId: '',
      userName: '',
      email: '',
    );
  }
}
