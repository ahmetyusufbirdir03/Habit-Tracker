import 'package:dio/dio.dart';
import 'package:flutter/cupertino.dart';
import 'package:habit_tracker_mobile/models/HabitGroup/habit_group_dto.dart';

import '../base/logger.dart';
import '../models/HabitGroup/habit_group_create_dto.dart';
import '../models/response_dto.dart';
import 'dio_service.dart';

class HabitGroupService{
  final _logger = logger;
  final _dioService = DioService();
  late final Dio _dio = _dioService.createDio(trustSelfSigned: true);

  HabitGroupService();

  Future<ResponseDto<HabitGroupListDto>> getHabitGroupsOfUserAsync(String id) async{
    try{
      final response = await _dio.get(
        '/HabitGroup/GetAllHabitGroupsByUserId/$id',
        options: Options(
          validateStatus: (status) => true,
        ),
      );
      return ResponseDto<HabitGroupListDto>(
        data: HabitGroupListDto.fromJson(response.data),
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
        _logger.e("🚫 Sunucuya bağlanılamadı: ${e.message}");
        throw Exception("Sunucuya ulaşılamıyor. Lütfen internet bağlantınızı kontrol edin.");
      } else {
        rethrow;
      }
    }
  }

  Future<ResponseDto> deleteHabitGroup(String id) async {
    try{
      final response = await _dio.delete(
        '/HabitGroup/DeleteHabitGroup/$id',
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

  Future<ResponseDto> updateHabitGroupAsync({
    required String id,
    required String name,
}) async {
    final requestData = {
      'Id': id,
      'Name': name
    };

    // API REQUEST
    try {
      final response = await _dio.patch(
        '/HabitGroup/UpdateHabitGroup',
        data: requestData,
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

  Future<ResponseDto> createHabitGroupAsync(String userId, String name) async {
    final request = CreateHabitGroupDto(userId: userId, name: name);

    try {
      final response = await _dio.post(
        '/HabitGroup/CreateHabitGroup',
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
}