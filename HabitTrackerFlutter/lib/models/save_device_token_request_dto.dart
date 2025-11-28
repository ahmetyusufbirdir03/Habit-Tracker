class SaveDeviceTokenRequestDto {
  final String userId;
  final String token;
  final String platform;

  SaveDeviceTokenRequestDto({required this.userId, required this.token, required this.platform});

  Map<String, dynamic> toJson() {
    return {
      'userId': userId,
      'token': token,
      'platform': platform,
    };
  }
}