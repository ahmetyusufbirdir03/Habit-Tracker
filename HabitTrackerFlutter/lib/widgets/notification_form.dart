import 'package:flutter/material.dart';
import 'package:firebase_messaging/firebase_messaging.dart';

class NotificationForm {
  static void showForegroundNotification(
      BuildContext context, RemoteMessage message) {
    final notification = message.notification;
    if (notification == null) return;
    showDialog(
      context: context,
      builder: (ctx) {
        return AlertDialog(
          title: Text(notification.title ?? "Bildirim"),
          content: Text(notification.body ?? ""),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(ctx).pop(),
              child: const Text("Kapat"),
            ),
          ],
        );
      },
    );
  }
}
