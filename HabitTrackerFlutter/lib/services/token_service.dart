import 'package:dio/dio.dart';
import 'package:habit_tracker_mobile/models/response_dto.dart';
import 'package:jwt_decoder/jwt_decoder.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dio_service.dart';

class TokenService {
  static const String _accessTokenKey = 'auth_token';
  static const String _refreshTokenKey = 'refresh_token';
  static const String _expiryTimeKey = 'token_expiry_time';
  final _dioService = DioService();
  late final Dio _dio = _dioService.createDio(trustSelfSigned: true);

  // save tokens
  Future<void> saveTokens({
    String? accessToken,
    String? refreshToken,
    DateTime? expiryTime
  }) async {
    final prefs = await SharedPreferences.getInstance();
    if(accessToken != null){
      prefs.setString(_accessTokenKey, accessToken);
    }
    if(refreshToken != null){
      prefs.setString(_refreshTokenKey, refreshToken);
    }
    prefs.setString(_expiryTimeKey, expiryTime.toString());
    print("accessToken : $accessToken");
    print("refreshToken : $refreshToken");
    print("expiryTime : $expiryTime");
  }

  // read access token
  Future<String?> getAccessToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_accessTokenKey);
  }

  // read refresh token
  Future<String?> getRefreshToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_refreshTokenKey);
  }

  // read expiry time
  Future<DateTime?> getExpiryTime() async {
    final prefs = await SharedPreferences.getInstance();
    final expiryTimeString = prefs.getString(_expiryTimeKey);
    if (expiryTimeString == null || expiryTimeString.isEmpty) return null;
    return DateTime.tryParse(expiryTimeString)?.toUtc();
  }

  // set tokens
  Future<bool> setTokensAsync(String accessToken, String refreshToken, String expiryTime) async {
    final prefs = await SharedPreferences.getInstance();
    prefs.setString(_accessTokenKey, accessToken);
    prefs.setString(_refreshTokenKey, refreshToken);
    prefs.setString(_expiryTimeKey, expiryTime);
    return true;
  }

  // delete tokens
  static Future<void> deleteTokensAsync() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_accessTokenKey);
    await prefs.remove(_refreshTokenKey);
    await prefs.remove(_expiryTimeKey);
  }

  //refresh tokens
  Future<ResponseDto> refreshAccessTokenAsync() async {
    final refreshToken = await getRefreshToken();
    if (refreshToken == null) {
      return ResponseDto(statusCode: 401, errors: ["Unauthorized"]);
    }
    try {
      final response = await _dio.post(
        '/Auth/RefreshAccessToken',
        data: {'refreshToken': refreshToken},
        options: Options(validateStatus: (status) => true),
      );

      if (response.data['data'] != null) {
        final Map<String, dynamic> data = response.data['data'];
        await setTokensAsync(
          data['accessToken'],
          data['refreshToken'],
          data['expirationTime'],
        );

        return ResponseDto(
          statusCode: 200,
          message: response.data?['message'],
          data: data,
        );
      } else {
        final responseErrors = response.data['errors'];
        final List<String>? errorMessages =
        responseErrors != null ? List<String>.from(responseErrors) : null;

        return ResponseDto(
          statusCode: response.statusCode ?? 400,
          errors: errorMessages,
        );
      }
    } on DioException catch (e) {
      if (e.type == DioExceptionType.connectionError ||
          e.type == DioExceptionType.connectionTimeout ||
          e.type == DioExceptionType.unknown) {
        return ResponseDto(
          statusCode: 0,
          errors: ["Sunucuya ulaşılamıyor. Lütfen internet bağlantınızı kontrol edin."],
        );
      } else {
        return ResponseDto(
          statusCode: -1,
          errors: ["Bilinmeyen bir hata oluştu: ${e.message}"],
        );
      }
    }
  }
  // access token check
  bool isAccessTokenValid(String? accessToken)  {
    if(accessToken == null) {
      return false;
    }
    DateTime expirationDate = JwtDecoder.getExpirationDate(accessToken);
    return expirationDate.isAfter(DateTime.now().toUtc());
  }
}