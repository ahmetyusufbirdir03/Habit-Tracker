class LoginResponseDto{
  String? accessToken;
  String? refreshToken;
  DateTime? expiration;

  LoginResponseDto({
    required this.accessToken,
    required this.refreshToken,
    required this.expiration
  });

  factory LoginResponseDto.fromJson(Map<String, dynamic>? json) {
    if (json == null) {
      throw ArgumentError('JSON data for RegisterResponseDto cannot be null.');
    }
    return LoginResponseDto(
      accessToken: json['token'] as String?,
      refreshToken: json['refreshToken'] as String?,
      expiration: json['expiration'] != null
          ? DateTime.parse(json['expiration'] as String)
          : null,
    );
  }
}