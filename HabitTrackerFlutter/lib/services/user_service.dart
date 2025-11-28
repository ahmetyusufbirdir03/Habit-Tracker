import 'package:dio/dio.dart';
import 'package:habit_tracker_mobile/base/logger.dart';
import 'package:habit_tracker_mobile/models/response_dto.dart';
import 'package:habit_tracker_mobile/models/user_dto.dart';
import 'package:habit_tracker_mobile/services/dio_service.dart';
import 'package:habit_tracker_mobile/services/token_service.dart';
import 'package:habit_tracker_mobile/services/user_session_service.dart';
import 'package:jwt_decoder/jwt_decoder.dart';

class UserService {
  final _logger = logger;
  final _tokenService = TokenService();
  final _dioService = DioService();
  late final _dio = _dioService.createDio(trustSelfSigned: true);

  UserService();

  // USER GET
  Future<ResponseDto<UserDto>> getUserAsync() async {
    // ACCESS TOKEN GET
    final accessToken = await _tokenService.getAccessToken();
    if(accessToken == null){
      return ResponseDto(message:"Access token not found!" ,statusCode: 401);
    }

    // TOKEN EMAIL PARSE
    final decodedToken = JwtDecoder.decode(accessToken);
    final email = decodedToken["email"] ?? "";
    if(email.isEmpty){
      return ResponseDto(message: "User not found!", statusCode: 404);
    }

    // EMAIL ENCODE
    final encodedEmail = Uri.encodeComponent(email);

    // API REQUEST
    try {
      final response = await _dio.get(
        '/User/GetUserByEmail/$encodedEmail',
        options: Options(
          validateStatus: (status) => true,
        ),
      );
      return ResponseDto<UserDto>.fromJson(
        response.data,
            (json) => UserDto.fromJson(json as Map<String, dynamic>),
      );
    } on DioException catch (e) {
      if (e.type == DioExceptionType.connectionError ||
          e.type == DioExceptionType.connectionTimeout ||
          e.type == DioExceptionType.unknown) {
        _logger.e("🚫 Sunucuya bağlanılamadı: ${e.message}");
        throw Exception("Sunucuya ulaşılamıyor. Lütfen internet bağlantınızı kontrol edin.");
      } else {
        rethrow;
      }
    }
  }

  //USER UPDATE
  Future<ResponseDto<UserDto>> updateUserAsync({
      required String id,
      required String username,
      required String email,
      required String phoneNumber}) async {

    bool isEmailChanged = email.isNotEmpty;
    final requestData = {
      'Id': id,
      'UserName': username,
      'Email': email,
      'PhoneNumber': phoneNumber,
    };

    // API REQUEST
    try {
      final response = await _dio.post(
        '/User/Update',
        data: requestData,
        options: Options(
          validateStatus: (status) => true,
          sendTimeout: const Duration(seconds: 5),
          receiveTimeout: const Duration(seconds: 5),
        ),
      );
      final parsedResponse = ResponseDto<UserDto>.fromJson(
        response.data,
            (json) => UserDto.fromJson(json as Map<String, dynamic>),
      );

      if (parsedResponse.isSuccess && parsedResponse.data != null) {
        if(isEmailChanged){
          final refreshResponse = await _tokenService.refreshAccessTokenAsync();
          if(refreshResponse.statusCode != 200){
            return ResponseDto(
                statusCode: refreshResponse.statusCode,
                errors: refreshResponse.errors,
                data: null
            );
          }
          final userResponse = await getUserAsync();
          if (userResponse.isSuccess && userResponse.data != null) {
            UserSessionService().setUser(userResponse.data!);
          }
        }
      }
      return parsedResponse;

    }on DioException catch (e) {
      if (e.type == DioExceptionType.connectionError ||
          e.type == DioExceptionType.connectionTimeout ||
          e.type == DioExceptionType.unknown) {
        _logger.e("Sunucuya bağlanılamadı: ${e.message}");
        throw Exception("Sunucuya ulaşılamıyor. Lütfen internet bağlantınızı kontrol edin.");
      } else {
        rethrow;
      }
    }
  }

  //USER DELETE
  Future<ResponseDto> deleteUserAsync(String id) async{
    try{
      final response = await _dio.delete(
        '/User/Delete/$id',
        options: Options(
          validateStatus: (status) => true,
        ),
      );
      return ResponseDto.fromJson(response.data, null);
    } on DioException catch (e) {
      if (e.type == DioExceptionType.connectionError ||
          e.type == DioExceptionType.connectionTimeout ||
          e.type == DioExceptionType.unknown) {
        _logger.e("🚫 Sunucuya bağlanılamadı: ${e.message}");
        throw Exception("Sunucuya ulaşılamıyor. Lütfen internet bağlantınızı kontrol edin.");
      } else {
        rethrow;
      }
    }
  }
}
