import 'package:dio/dio.dart';
import 'package:flutter/cupertino.dart';
import 'package:habit_tracker_mobile/models/Habit/habit_dto.dart';
import '../base/logger.dart';
import '../base/period_type_enum.dart';
import '../models/Habit/create_habit_dto.dart';
import '../models/response_dto.dart';
import 'dio_service.dart';

class HabitService {
  final _logger = logger;
  final _dioService = DioService();
  late final _dio = _dioService.createDio(trustSelfSigned: true);
  HabitService();

  Future<ResponseDto<HabitListDto>> getHabitsAsync(String groupId) async {
    try {
      final response = await _dio.get(
        '/Habit/GetGroupHabits/$groupId',
        options: Options(validateStatus: (status) => true),
      );
      return ResponseDto<HabitListDto>(
        data: HabitListDto.fromJson(response.data),
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

  Future<ResponseDto> deleteHabitAsync(String id) async {
    try{
      final response = await _dio.delete(
        '/Habit/DeleteHabit/$id',
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

  Future<ResponseDto> createHabitAsync({
    String? name,
    PeriodType? periodType,
    int? frequency,
    String? habitGroupId,
    String? notes,
  }) async {
    final request = CreateHabitDto(
      name: name,
      periodType: periodType!.value,
      frequency: frequency,
      habitGroupId: habitGroupId,
      notes: notes,
    );

    try {
      final response = await _dio.post(
        '/Habit/CreateHabit',
        data: request.toJson(),
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

  Future<ResponseDto<HabitDto>> updateHabitAsync({
    required String id,
    String? name,
    int? periodType,
    int? frequency,
    String? notes,
  }) async {
    final Map<String, dynamic> requestData = {
      'id': id,
      'name' : name,
      'periodType': periodType,
      'frequency': frequency,
      'notes': notes,
    };
    try {
      final response = await _dio.patch(
        '/Habit/UpdateHabit',
        data: requestData,
        options: Options(
          validateStatus: (status) => true,
          sendTimeout: const Duration(seconds: 5),
          receiveTimeout: const Duration(seconds: 5),
        ),
      );
      return ResponseDto.fromJson(
        response.data,
            (json) => HabitDto.fromJson(json as Map<String, dynamic>),
      );
    } on DioException catch (e) {
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

  Future<ResponseDto> updateHabitNoteAsync(
    String habitId,
    String? notes,
  ) async {

    final Map<String, dynamic> requestData = {
      'habitId': habitId,
      'note': notes,
    };
    try {
      final response = await _dio.patch(
        '/Habit/UpdateHabitNote',
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
        _logger.e("Sunucuya bağlanılamadı: ${e.message}");
        throw Exception("Sunucuya ulaşılamıyor. Lütfen internet bağlantınızı kontrol edin.");
      } else {
        rethrow;
      }
    }
  }

}
