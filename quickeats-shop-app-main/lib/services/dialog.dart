// lib/services/dialog.dart

import 'package:flutter/material.dart';
import 'package:shop_app/network/api_service.dart';
import 'package:shop_app/network/api_constants.dart';
import 'package:shop_app/main.dart';

void showOrderDialog(
    BuildContext context,
    String title,
    String body,
    VoidCallback onViewOrder,
    ) {
  showDialog(
    context: context,
    barrierDismissible: false,
    builder: (BuildContext context) {
      return AlertDialog(
        title: Text(title),
        content: Text(body),
        actions: [
          TextButton(
            onPressed: () async {
              Navigator.of(context).pop();
              onViewOrder();
            },
            child: const Text('View Order'),
          ),
        ],
      );
    },
  );
}

void showOrderAcceptRejectDialog(
    BuildContext context,
    int orderId,
    VoidCallback onAccept,
    ) {
  final ApiService apiService = ApiService();

  showDialog(
    context: context,
    barrierDismissible: false,
    builder: (BuildContext context) {
      return AlertDialog(
        title: const Text('New Order'),
        content: const Text('Do you want to accept or reject this order?'),
        actions: [
          TextButton(
            onPressed: () async {
              try {
                // Call API to reject order
                await apiService.postRequest(
                  url: '${ApiConstants.baseUrl}/orders/reject-order',
                  body: {"orderId": orderId},
                );

                if (context.mounted) {
                  Navigator.of(context).pop();

                  // Navigate back to dashboard (assuming it's the first route)
                  Navigator.popUntil(navigatorKey.currentContext!, (route) => route.isFirst);

                  // Show rejection message
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Order rejected successfully'),
                      backgroundColor: Colors.red,
                    ),
                  );
                }
              } catch (e) {
                if (context.mounted) {
                  Navigator.of(context).pop(); // Close dialog on error too

                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('Failed to reject order: $e'),
                      backgroundColor: Colors.red,
                    ),
                  );
                }
              }
            },
            child: const Text('Reject', style: TextStyle(color: Colors.red)),
          ),
          TextButton(
            onPressed: () async {
              try {
                // Call API to accept order
                await apiService.postRequest(
                  url: '${ApiConstants.baseUrl}/orders/accept-order',
                  body: {"orderId": orderId},
                );

                if (context.mounted) {
                  Navigator.of(context).pop();
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Order accepted successfully'),
                      backgroundColor: Colors.green,
                    ),
                  );
                  // Call the onAccept callback to navigate to order details
                  onAccept();
                }
              } catch (e) {
                if (context.mounted) {
                  Navigator.of(context).pop(); // Close dialog on error too

                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('Failed to accept order: $e'),
                      backgroundColor: Colors.red,
                    ),
                  );
                }
              }
            },
            child: const Text('Accept', style: TextStyle(color: Colors.green)),
          ),
        ],
      );
    },
  );
}