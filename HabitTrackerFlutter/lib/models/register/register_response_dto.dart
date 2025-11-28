class RegisterResponseDto {
  String? accessToken;
  String? refreshToken;
  DateTime? expiration;

  RegisterResponseDto({
    required this.accessToken,
    required this.refreshToken,
    required this.expiration,
  });

  factory RegisterResponseDto.fromJson(Map<String, dynamic>? json) {
    if (json == null) {
      throw ArgumentError('JSON data for RegisterResponseDto cannot be null.');
    }
    return RegisterResponseDto(
      accessToken: json['token'] as String?,
      refreshToken: json['refreshToken'] as String?,
      expiration: json['expiration'] != null
          ? DateTime.parse(json['expiration'] as String)
          : null,
    );
  }
}