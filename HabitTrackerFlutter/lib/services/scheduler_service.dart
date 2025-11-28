import 'package:dio/dio.dart';
import 'package:flutter/cupertino.dart';
import 'package:habit_tracker_mobile/base/logger.dart';
import 'package:habit_tracker_mobile/models/Schedulers/DailyScheduler/daily_scheduler_request_dto.dart';
import 'package:habit_tracker_mobile/models/Schedulers/MonthlyScheduler/monthly_scheduler_request_dto.dart';
import 'package:habit_tracker_mobile/models/Schedulers/WeeklyScheduler/weekly_scheduler_dto.dart';
import 'package:habit_tracker_mobile/models/list_dto.dart';
import 'package:habit_tracker_mobile/services/dio_service.dart';

import '../models/Schedulers/DailyScheduler/daily_scheduler_dto.dart';
import '../models/Schedulers/MonthlyScheduler/monthly_scheduler_dto.dart';
import '../models/Schedulers/WeeklyScheduler/weekly_scheduler_request_dto.dart';
import '../models/response_dto.dart';

class SchedulerService{
  final _logger = logger;
  final _dioService = DioService();
  late final _dio = _dioService.createDio(trustSelfSigned: true);

  //DAILY SCHEDULER
  Future<ResponseDto<ListDto<DailySchedulerDto>>> getDailySchedulersAsync(String habitId) async{
    try {
      final response = await _dio.get(
        '/DailySchedule/GetHabitDailySchedules/$habitId',
        options: Options(validateStatus: (status) => true),
      );
      return ResponseDto<ListDto<DailySchedulerDto>>(
        data: ListDto.fromJson(response.data, (json) => DailySchedulerDto.fromJson(json)),
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

  Future<ResponseDto> createDailySchedulersAsync(DailySchedulerRequestDto request) async {
    try {
      final response = await _dio.post(
        '/DailySchedule/CreateDailySchedule',
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

  Future<ResponseDto> updateDailySchedulerAsync(String id,String reminderTime) async {
    final request = {
      'Id' : id,
      'ReminderTime' : reminderTime
    };
    try {
      final response = await _dio.patch(
        '/DailySchedule/UpdateDailySchedule',
        data: request,
        options: Options(
          validateStatus: (status) => true,
          sendTimeout: const Duration(seconds: 5),
          receiveTimeout: const Duration(seconds: 5),
        ),
      );
      return ResponseDto.fromJson(response.data, null);

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

  Future<ResponseDto> completeDailySchedulerAsync(String schedulerId) async {
    try {
      final response = await _dio.post(
        '/DailySchedule/CompleteDailyScheduler/$schedulerId',
        options: Options(
          validateStatus: (status) => true,
          sendTimeout: const Duration(seconds: 10),
          receiveTimeout: const Duration(seconds: 10),
        ),
      );
      return ResponseDto.fromJson(response.data, null);

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

  //WEEKLY SCHEDULER
  Future<ResponseDto<ListDto<WeeklySchedulerDto>>> getWeeklySchedulersAsync(String habitId) async{
    try {
      final response = await _dio.get(
        '/WeeklyScheduler/GetHabitWeeklySchedules/$habitId',
        options: Options(validateStatus: (status) => true),
      );
      return ResponseDto<ListDto<WeeklySchedulerDto>>(
        data: ListDto.fromJson(response.data, (json) => WeeklySchedulerDto.fromJson(json)),
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

  Future<ResponseDto> createWeeklySchedulersAsync(String habitId,List<WeeklySchedulerRequestDto> request) async {
    final requestData = {
      'habitId' : habitId,
      'schedules' : request.map((e) => e.toJson()).toList()
    };
    try {
      final response = await _dio.post(
        '/WeeklyScheduler/CreateWeeklySchedule',
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

  Future<ResponseDto> updateWeeklySchedulerAsync(
  { required String id,
    required int dayOfWeek,
    required String reminderTime
  }) async {
    final request = {
      'id' : id,
      'dayOfWeek' : dayOfWeek,
      'reminderTime' : reminderTime
    };
    try {
      final response = await _dio.patch(
        '/WeeklyScheduler/UpdateWeeklyScheduler',
        data: request,
        options: Options(
          validateStatus: (status) => true,
          sendTimeout: const Duration(seconds: 5),
          receiveTimeout: const Duration(seconds: 5),
        ),
      );
      return ResponseDto.fromJson(response.data, null);

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

  Future<ResponseDto> completeWeeklySchedulerAsync(String schedulerId) async {
    try {
      final response = await _dio.patch(
        '/WeeklyScheduler/CompleteWeeklyScheduler/$schedulerId',
        options: Options(
          validateStatus: (status) => true,
          sendTimeout: const Duration(seconds: 5),
          receiveTimeout: const Duration(seconds: 5),
        ),
      );
      return ResponseDto.fromJson(response.data, null);
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

  //MONTHLY SCHEDULER
  Future<ResponseDto<ListDto<MonthlySchedulerDto>>> getMonthlySchedulersAsync(String habitId) async{
    try {
      final response = await _dio.get(
        '/MonthlyScheduler/GetMonthlySchedulers/$habitId',
        options: Options(validateStatus: (status) => true),
      );
      return ResponseDto<ListDto<MonthlySchedulerDto>>(
        data: ListDto.fromJson(response.data, (json) => MonthlySchedulerDto.fromJson(json)),
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

  Future<ResponseDto> createMonthlySchedulersAsync(String habitId,List<MonthlySchedulerRequestDto> request) async {
    final requestData = {
      'habitId' : habitId,
      'schedules' : request.map((e) => e.toJson()).toList()
    };
    try {
      final response = await _dio.post(
        '/MonthlyScheduler/CreateMonthlySchedule',
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

  Future<ResponseDto> updateMonthlySchedulerAsync(
      { required String id,
        required int dayOfMonth,
        required String reminderTime
      }) async {
    final request = {
      'id' : id,
      'dayOfMonth' : dayOfMonth,
      'reminderTime' : reminderTime
    };
    try {
      final response = await _dio.patch(
        '/MonthlyScheduler/UpdateMonthlySchedulers',
        data: request,
        options: Options(
          validateStatus: (status) => true,
          sendTimeout: const Duration(seconds: 5),
          receiveTimeout: const Duration(seconds: 5),
        ),
      );
      return ResponseDto.fromJson(response.data, null);

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

  Future<ResponseDto> completeMonthlySchedulerAsync(String schedulerId) async {
    try {
      final response = await _dio.patch(
        '/MonthlyScheduler/CompleteMonthlyScheduler/$schedulerId',
        options: Options(
          validateStatus: (status) => true,
          sendTimeout: const Duration(seconds: 5),
          receiveTimeout: const Duration(seconds: 5),
        ),
      );
      return ResponseDto.fromJson(response.data, null);
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

}