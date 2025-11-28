import 'package:dio/dio.dart';
import 'package:flutter/cupertino.dart';
import 'package:habit_tracker_mobile/models/list_dto.dart';
import '../base/logger.dart';
import '../models/SecialReminder/SpecialReminderDto.dart';
import '../models/response_dto.dart';
import 'dio_service.dart';

class SpecialReminderService {
  final _logger = logger;
  final _dioService = DioService();
  late final _dio = _dioService.createDio(trustSelfSigned: true);
  SpecialReminderService();

  Future<ResponseDto<ListDto<SpecialReminderDto>>> getSpecialRemindersAsync(String habitGroupId) async{
    try {
      final response = await _dio.get(
        '/SpecialReminder/GetGroupSpecialReminders/$habitGroupId',
        options: Options(validateStatus: (status) => true),
      );
      return ResponseDto<ListDto<SpecialReminderDto>>(
        data: ListDto.fromJson(response.data, (json) => SpecialReminderDto.fromJson(json)),
        statusCode: response.data['statusCode'],
        message: response.data['message'],
        errors: response.data['errors'] == null
            ? null
            : List<String>.from(response.data['errors']),
      );
    } on DioException catch (e) {
      if (e.type == DioExceptionType.connectionError ||
          e.type == DioExceptionType.connectionTimeout ||
          e.type == DioExceptionType.unknown) {
        throw Exception("🚫 Sunucuya ulaşılamadı: ${e.message}");
      } else {
        rethrow;
      }
    }
  }

  Future<ResponseDto> createSpecialReminderAsync({
    required String habitGroupId,
    String? title,
    int? month,
    int? day,
    String? description
  }) async {
    final requestData = {
      'habitGroupId' : habitGroupId,
      'title' : title,
      'description' : description,
      'month' : month,
      'day' : day
    };
    try {
      final response = await _dio.post(
        '/SpecialReminder/CreateReminder',
        data: requestData,
        options: Options(
          validateStatus: (status) => true,
          sendTimeout: const Duration(seconds: 5),
          receiveTimeout: const Duration(seconds: 5),
        ),
      );
      return ResponseDto.fromJson(response.data, null);
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

  Future<ResponseDto> deleteSpecialReminderAsync(String reminderId) async {
    try{
      final response = await _dio.delete(
        '/SpecialReminder/DeleteReminder/$reminderId',
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