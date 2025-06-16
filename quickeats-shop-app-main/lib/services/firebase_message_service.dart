// lib/services/firebase_message_service.dart

import 'package:shop_app/orders/models/order.dart';
import 'package:shop_app/network/api_service.dart';
import 'package:shop_app/network/api_constants.dart';
import 'package:shop_app/main.dart';
import 'package:shop_app/orders/pages/returned_order.dart';
import 'package:shop_app/orders/pages/selected_order.dart';
import 'package:firebase_messaging/firebase_messaging.dart';

import 'package:flutter/material.dart';
// Import dialog.dart with prefix to avoid naming conflicts
import 'package:shop_app/services/dialog.dart' as app_dialog;
import 'package:shop_app/services/notification_service.dart';

class FirebaseMessageService {
  FirebaseMessageService._privateConstructor();

  static final FirebaseMessageService _instance =
  FirebaseMessageService._privateConstructor();

  factory FirebaseMessageService() {
    return _instance;
  }

  final FirebaseMessaging messaging = FirebaseMessaging.instance;
  NotificationService notificationService = NotificationService();
  ApiService apiService = ApiService();

  Future<void> getFCMToken() async {
    String? token = await FirebaseMessaging.instance.getToken();
    await apiService.postRequest(
        url: '${ApiConstants.baseUrl}/auth/save-fcm-token',
        body: {"fcmToken": token});
  }

  void navigateToOrderDetail(int orderId, bool isReturnedOrder) {
    if (isReturnedOrder) {
      Navigator.push(
        navigatorKey.currentContext!,
        MaterialPageRoute(
          builder: (context) => ReturnedOrder(
              orders: OrderData(
                  orderId: 0,
                  shopId: 0,
                  customerId: 0,
                  status: '',
                  total: 0,
                  items: [],
                  customerOfOrder: CustomerOfOrder(
                      id: 0, name: '', mobileNumber: '', email: '')),
              orderIndex: 0,
              orderId: orderId),
        ),
      );
    } else {
      Navigator.push(
        navigatorKey.currentContext!,
        MaterialPageRoute(
          builder: (context) => SelectedOrder(
              orders: OrderData(
                  orderId: 0,
                  shopId: 0,
                  customerId: 0,
                  status: '',
                  total: 0,
                  items: [],
                  customerOfOrder: CustomerOfOrder(
                      id: 0, name: '', mobileNumber: '', email: '')),
              orderIndex: 0,
              orderId: orderId),
        ),
      );
    }
  }

  // Show notification when the app is in foreground
  void _handleInAppMessage(RemoteMessage message) {
    if (message.notification != null) {
      final orderId = int.parse(message.data['orderId']);

      // Show notification with the appropriate title and body
      notificationService.showOrderNotification(
        message.notification!.title ?? 'New Order',
        message.notification!.body ?? 'You have received a new order',
        message.data['type'] ?? 'new_order',
        orderId,
      );
    }
  }

  // Handle when a notification is tapped to open the app
  void _handleNotificationOpenedApp(RemoteMessage message) {
    if (message.notification != null) {
      if (message.data['type'] == 'new_order') {
        final orderId = int.parse(message.data['orderId']);

        // Ensure we're on the dashboard before showing the dialog
        // First navigate to the dashboard (root route)
        Navigator.popUntil(navigatorKey.currentContext!, (route) => route.isFirst);

        // Then show the dialog
        app_dialog.showOrderAcceptRejectDialog(
          navigatorKey.currentContext!,
          orderId,
              () {
            // Navigate to order details after accepting
            navigateToOrderDetail(orderId, false);
          },
        );
      } else {
        // For other notification types, just navigate directly
        navigateToOrderDetail(
          int.parse(message.data['orderId']),
          message.data['type'] == 'returned_order',
        );
      }
    }
  }

  void initializeFCM() async {
    notificationService.initializeNotifications();

    // Handle foreground messages
    FirebaseMessaging.onMessage.listen(_handleInAppMessage);

    // Handle when app is opened from a notification
    FirebaseMessaging.onMessageOpenedApp.listen(_handleNotificationOpenedApp);

    // Check if app was opened from a terminated state notification
    RemoteMessage? initialMessage = await FirebaseMessaging.instance.getInitialMessage();
    if (initialMessage != null) {
      // Handle initialMessage after a delay to ensure app is fully initialized
      Future.delayed(const Duration(milliseconds: 500), () {
        _handleNotificationOpenedApp(initialMessage);
      });
    }
  }
}