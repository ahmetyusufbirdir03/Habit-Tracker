import 'package:dio/dio.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

import '../models/response_dto.dart';
import '../models/save_device_token_request_dto.dart';
import 'dio_service.dart';


@pragma('vm:entry-point')
Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  await Firebase.initializeApp();
  if (kDebugMode) {
    print("Background message handled: ${message.messageId}");
  }
}


class FirebaseService {
  final firebaseMessaging = FirebaseMessaging.instance;
  late final Dio _dio;

  final _localNotificationsPlugin = FlutterLocalNotificationsPlugin();

  FirebaseService() {
    _dio = DioService().createDio(trustSelfSigned: true);
  }

  final _androidChannel = const AndroidNotificationChannel(
    'mobile_notification_channel',
    'Mobile Notifications',
    description: 'Mobile Notifications',
    importance: Importance.max,
  );

  Future<void> requestPermission() async {
    final messaging = FirebaseMessaging.instance;

    final settings = await messaging.requestPermission(
      alert: true,
      announcement: false,
      badge: true,
      carPlay: false,
      criticalAlert: false,
      provisional: false,
      sound: true,
    );

    if (kDebugMode) {
      print('Permission granted: ${settings.authorizationStatus}');
    }
  }

  Future<void> startBackgroundMessaging() async {
    FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);
  }

  Future<void> initNotifications() async {
    await getToken();
    await requestPermission();

    const androidInit = AndroidInitializationSettings('@mipmap/ic_launcher');
    const iosInit = DarwinInitializationSettings();

    const initSettings = InitializationSettings(android: androidInit, iOS: iosInit);

    await _localNotificationsPlugin.initialize(initSettings);

    await _localNotificationsPlugin
        .resolvePlatformSpecificImplementation<AndroidFlutterLocalNotificationsPlugin>()
        ?.createNotificationChannel(_androidChannel);

    await firebaseMessaging.setForegroundNotificationPresentationOptions(
      alert: true,
      badge: true,
      sound: true,
    );

    FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);

    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      RemoteNotification? notification = message.notification;
      AndroidNotification? android = message.notification?.android;

      if (notification != null && android != null) {
        _localNotificationsPlugin.show(
          notification.hashCode,
          notification.title,
          notification.body,
          NotificationDetails(
            android: AndroidNotificationDetails(
              _androidChannel.id,
              _androidChannel.name,
              channelDescription: _androidChannel.description,
              icon: 'ic_alarm_clock',
              color: Colors.blue,
            ),
          ),
        );
      }
    });
  }

  Future<ResponseDto> saveDeviceTokenAsync(SaveDeviceTokenRequestDto request) async{
    try {
      final response = await _dio.post(
        '/UserDevice/SaveDevice',
        data: request.toJson(),
        options: Options(validateStatus: (status) => true),
      );
      return ResponseDto(
        data: null,
        statusCode: response.data['statusCode'] ?? response.statusCode,
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

  Future<ResponseDto> deleteDeviceTokenAsync(String? deviceTokenId) async {
    try{
      final response = await _dio.delete(
        '/UserDevice/DeleteDeviceUser/$deviceTokenId',
        options: Options(validateStatus: (status) => true),
      );
      return ResponseDto.fromJson(response.data, null);
    }on DioException catch (e) {
      if (e.type == DioExceptionType.connectionError ||
          e.type == DioExceptionType.connectionTimeout ||
          e.type == DioExceptionType.unknown) {
        throw Exception("🚫 Sunucuya ulaşılamadı: ${e.message}");
      } else {
        rethrow;
      }
    }
  }

  Future<String?> getToken() async {
    var token = await firebaseMessaging.getToken();
    debugPrint(token);
    return token;
  }
}