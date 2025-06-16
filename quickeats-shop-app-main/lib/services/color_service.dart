import 'package:flutter/material.dart';

Color getOrderStatusColor(String status) {
  switch (status) {
    case 'PLACED':
      return Colors.redAccent;
    case 'SHOP_ACCEPT':
      return Colors.orangeAccent;
    case 'PROCESS_DONE':
      return Colors.blueAccent;
    case 'DRIVER_PICKUP':
      return Colors.purpleAccent;
    case 'DELIVERED':
      return Colors.green;
    case 'RETURN':
      return Colors.deepOrange;
    case 'CANCELLED':
      return Colors.black54;
    case 'REJECTED':
      return Colors.brown;
    default:
      return Colors.grey;
  }
}
