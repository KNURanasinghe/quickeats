// lib/services/notification_service.dart

import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:shop_app/main.dart';
import 'package:shop_app/services/dialog.dart' as app_dialog;

class NotificationService {
  static final NotificationService _notificationService =
  NotificationService._internal();

  factory NotificationService() {
    return _notificationService;
  }

  NotificationService._internal();

  final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
  FlutterLocalNotificationsPlugin();

  Future<void> initializeNotifications() async {
    const AndroidInitializationSettings initializationSettingsAndroid =
    AndroidInitializationSettings('@mipmap/ic_launcher');

    const InitializationSettings initializationSettings =
    InitializationSettings(android: initializationSettingsAndroid);

    // Initialize with callback for notification selection
    await flutterLocalNotificationsPlugin.initialize(
      initializationSettings,
      onDidReceiveNotificationResponse: _onNotificationTapped,
    );
  }

  void _onNotificationTapped(NotificationResponse response) {
    // Handle notification tap
    final payload = response.payload;
    if (payload != null) {
      final payloadData = payload.split('|');
      if (payloadData.length >= 2) {
        final notificationType = payloadData[0];
        final orderId = int.parse(payloadData[1]);

        // Ensure we're on the dashboard before showing the dialog
        // First navigate to the dashboard (root route)
        Navigator.popUntil(navigatorKey.currentContext!, (route) => route.isFirst);

        if (notificationType == 'new_order') {
          // Show accept/reject dialog
          app_dialog.showOrderAcceptRejectDialog(
            navigatorKey.currentContext!,
            orderId,
                () {
              // Navigate to order detail screen
              Navigator.pushNamed(
                navigatorKey.currentContext!,
                '/selected-order',
                arguments: {'orderId': orderId},
              );
            },
          );
        } else {
          // For other notification types, navigate directly to the appropriate screen
          if (notificationType == 'returned_order') {
            Navigator.pushNamed(
              navigatorKey.currentContext!,
              '/returned-order',
              arguments: {'orderId': orderId},
            );
            //cancel order
          }else if (notificationType == 'cancel_order') {
            Navigator.pushNamed(
              navigatorKey.currentContext!,
              '/cancel_order',
              arguments:{'orderId':orderId},
            );
          
          } else {
            Navigator.pushNamed(
              navigatorKey.currentContext!,
              '/selected-order',
              arguments: {'orderId': orderId},
            );
          }
        }
      }
    }
  }

  Future<void> showOrderNotification(
      String title,
      String body,
      String type,
      int orderId,
      ) async {
    try {
      const AndroidNotificationDetails androidDetails = AndroidNotificationDetails(
        'order_channel',
        'Order Notifications',
        channelDescription: 'Notifications for new orders',
        importance: Importance.max,
        priority: Priority.high,
        sound: RawResourceAndroidNotificationSound('notification_sound'),
        playSound: true,
      );

      const NotificationDetails platformDetails = NotificationDetails(
        android: androidDetails,
      );

      // Use payload to pass information that will be used when notification is tapped
      final payload = '$type|$orderId';

      await flutterLocalNotificationsPlugin.show(
        orderId.hashCode, // Use orderId hash for unique notification ID
        title,
        body,
        platformDetails,
        payload: payload,
      );
    } catch (e) {
      print('Error showing notification: $e');
    }
  }
}