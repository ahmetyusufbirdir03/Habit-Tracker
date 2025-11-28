import 'package:dio/dio.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:habit_tracker_mobile/models/Login/login_request_dto.dart';
import 'package:habit_tracker_mobile/screens/auth_screen.dart';
import 'package:habit_tracker_mobile/services/dio_service.dart';
import 'package:habit_tracker_mobile/services/token_service.dart';
import 'package:habit_tracker_mobile/services/user_service.dart';
import 'package:habit_tracker_mobile/services/user_session_service.dart';
import '../base/logger.dart';
import '../models/Login/login_response_dto.dart';
import '../models/register/register_response_dto.dart';
import '../models/response_dto.dart';

class AuthService {
  final _logger = logger;
  final _tokenService = TokenService();
  final _userService = UserService();
  final _dioService = DioService();
  late final Dio _dio = _dioService.createDio(trustSelfSigned: true);


  AuthService();
  Future<ResponseDto<RegisterResponseDto>> register({
    required String username,
    required String email,
    required String password,
    required String phoneNumber,
  }) async {
    final requestData = {
      'UserName': username,
      'Email': email,
      'Password': password,
      'PhoneNumber': phoneNumber,
    };

    try {
      final response = await _dio.post(
        '/Auth/Register',
        data: requestData,
        options: Options(
          validateStatus: (status) => true,
          sendTimeout: const Duration(seconds: 5),
          receiveTimeout: const Duration(seconds: 5),
        ),
      );
      final parsedResponse = ResponseDto.fromJson(
        response.data,
            (json) => RegisterResponseDto.fromJson(json as Map<String, dynamic>),
      );

      if (parsedResponse.isSuccess && parsedResponse.data != null) {
        await _tokenService.saveTokens(
          accessToken: parsedResponse.data!.accessToken ?? "",
          refreshToken: parsedResponse.data!.refreshToken ?? "",
          expiryTime: parsedResponse.data!.expiration ??
              DateTime.now().add(const Duration(minutes: 2)).toUtc(),
        );

        final userResponse = await _userService.getUserAsync();
        if (userResponse.isSuccess && userResponse.data != null) {
          UserSessionService().setUser(userResponse.data!);
        }
      }
      return parsedResponse;
    }on DioException catch (e) {
      if (e.type == DioExceptionType.connectionError ||
          e.type == DioExceptionType.connectionTimeout ||
          e.type == DioExceptionType.unknown) {
        debugPrint("🚫 Sunucuya bağlanılamadı: ${e.message}");
        throw Exception("Sunucuya ulaşılamıyor. Lütfen internet bağlantınızı kontrol edin.");
      } else {
        rethrow;
      }
    }
  }

  Future<ResponseDto<LoginResponseDto>> loginAsync({
    required String email,
    required String password,
  }) async {
    final request = LoginRequestDto(email: email, password: password);

    try {
      final response = await _dio.post(
        '/Auth/Login',
        data: request.toJson(),
        options: Options(
          validateStatus: (status) => true,
          sendTimeout: const Duration(seconds: 30),
          receiveTimeout: const Duration(seconds: 30),
        ),
      );

      final parsedResponse = ResponseDto.fromJson(
        response.data,
            (json) => LoginResponseDto.fromJson(json as Map<String, dynamic>),
      );

      if (parsedResponse.isSuccess && parsedResponse.data != null) {
        await _tokenService.saveTokens(
          accessToken: parsedResponse.data!.accessToken ?? "",
          refreshToken: parsedResponse.data!.refreshToken ?? "",
          expiryTime: parsedResponse.data!.expiration ??
              DateTime.now().add(const Duration(minutes: 2)).toUtc(),
        );

        final userResponse = await _userService.getUserAsync();
        if (userResponse.isSuccess && userResponse.data != null) {
          UserSessionService().setUser(userResponse.data!);
        }
      }
      return parsedResponse;
    } on DioException catch (e) {
      if (e.type == DioExceptionType.connectionError ||
          e.type == DioExceptionType.connectionTimeout ||
          e.type == DioExceptionType.unknown) {
        debugPrint("🚫 Sunucuya bağlanılamadı: ${e.message}");
        throw Exception(
            "Sunucuya ulaşılamıyor. Lütfen internet bağlantınızı kontrol edin.");
      } else {
        rethrow;
      }
    }
  }

  static Future<void> logout(BuildContext context) async {
    try {
      await TokenService.deleteTokensAsync();
      Navigator.of(context).pushAndRemoveUntil(
        MaterialPageRoute(builder: (context) => AuthScreen()),
            (route) => false,
      );
      debugPrint("Kullanıcı başarıyla çıkış yaptı.");
    } catch (e) {
      debugPrint("Logout sırasında hata: $e");
    }
  }

  Future<bool> checkAuthStatusAsync() async {
    bool isAccessTokenValid = _tokenService.isAccessTokenValid(await _tokenService.getAccessToken());
    if(isAccessTokenValid){
      _logger.i("Access token is valid.");
      return true;
    }else{
      final response = await _tokenService.refreshAccessTokenAsync();
      if (response.statusCode == 200) {
        return true;
      } else {
        return false;
      }
    }
  }
}

