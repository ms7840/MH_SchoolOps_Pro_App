/// DTO mapping OpenIddict OAuth2 token endpoint response.
class TokenResponseDto {
  final String accessToken;
  final String tokenType;
  final int expiresIn;
  final String? refreshToken;
  final String? scope;
  final String? idToken;

  const TokenResponseDto({
    required this.accessToken,
    required this.tokenType,
    required this.expiresIn,
    this.refreshToken,
    this.scope,
    this.idToken,
  });

  factory TokenResponseDto.fromJson(Map<String, dynamic> json) {
    return TokenResponseDto(
      accessToken: json['access_token'] as String,
      tokenType: json['token_type'] as String? ?? 'Bearer',
      expiresIn: json['expires_in'] as int? ?? 900,
      refreshToken: json['refresh_token'] as String?,
      scope: json['scope'] as String?,
      idToken: json['id_token'] as String?,
    );
  }

  Map<String, dynamic> toJson() => {
        'access_token': accessToken,
        'token_type': tokenType,
        'expires_in': expiresIn,
        'refresh_token': refreshToken,
        'scope': scope,
        'id_token': idToken,
      };
}
