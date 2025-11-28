// main.dart
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:habit_tracker_mobile/screens/auth_screen.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:habit_tracker_mobile/services/firebase_service.dart';
import 'firebase_options.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  if(Platform.isAndroid || Platform.isIOS) {
    final firebaseService = FirebaseService();
    await firebaseService.initNotifications();
    String? token = await firebaseService.getToken();
  }
  runApp(const MyApp());
}

final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      navigatorKey: navigatorKey,
      title: '',
      home: AuthScreen(),
    );
  }
}