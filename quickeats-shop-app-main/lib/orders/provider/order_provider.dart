import 'package:shop_app/network/api_constants.dart';
import 'package:shop_app/network/api_service.dart';
import 'package:shop_app/orders/models/order.dart';
import 'package:flutter/material.dart';

class OrderProvider with ChangeNotifier {
  List<OrderData> orderList = [];
  ApiService apiService = ApiService();
  Order? allOrders;

  // ✅ GET /api/orders - This looks correct
  Future<String?> getAllOrders() async {
    String? message;
    var response =
        await apiService.getRequest(url: '${ApiConstants.baseUrl}/orders');
    if (response != null) {
      allOrders = Order.fromJson(response);
      if (allOrders != null) {
        message = allOrders!.message;
        if (allOrders!.message == 'Orders retrieved successfully') {
          orderList = allOrders!.orderData;
          notifyListeners();
        }
      }
    }
    return message;
  }

  // ✅ PATCH /api/orders/{id}/status - This is correct
  Future<String?> updateOrderStatus(String status, int index) async {
    String? message;

    // Get the order ID for the path parameter
    int orderId = orderList[index].orderId;

    var response = await apiService.patchRequest(
        url: '${ApiConstants.baseUrl}/orders/$orderId/status',
        body: {"status": status});

    if (response != null) {
      Order order = Order.fromJson(response);
      message = order.message;
      if (order.message == 'Order status updated successfully' &&
          order.orderData.isNotEmpty) {
        orderList[index] = order.orderData[0];
        notifyListeners();
      }
    }
    return message;
  }

  // ❌ FIXED: PATCH /api/orders/accept/status - Missing method
  Future<String?> acceptRejectOrder(int orderId, String status) async {
    String? message;

    var response = await apiService.patchRequest(
        url: '${ApiConstants.baseUrl}/orders/accept/status',
        body: {"id": orderId, "status": status}); // Both id and status in body

    if (response != null) {
      Order order = Order.fromJson(response);
      message = order.message;
      if (order.message == 'Order acceptance status updated' ||
          order.message == 'Order acceptance status updated successfully') {
        // Update the order in the list
        int index = orderList.indexWhere((order) => order.orderId == orderId);
        if (index != -1 && order.orderData.isNotEmpty) {
          orderList[index] = order.orderData[0];
          notifyListeners();
        }
      }
    }
    return message;
  }

  // ❌ FIXED: PUT /api/orders/delivery-slot/{orderId} - Missing method
  Future<String?> setDeliverySlot(int orderId, String timeSlot) async {
    String? message;

    var response = await apiService.putRequest(
        url: '${ApiConstants.baseUrl}/orders/delivery-slot/$orderId',
        body: {"timeSlot": timeSlot});

    if (response != null) {
      // Assuming similar response structure
      message =
          response['message'] ?? 'Delivery time slot updated successfully';
      if (message == 'Delivery time slot updated successfully') {
        // Optionally refresh the order list or update specific order
        await getAllOrders(); // Refresh all orders to get updated data
      }
    }
    return message;
  }

  // ❌ FIXED: GET /api/orders/search - Wrong query parameter
  Future<String?> searchOrders(String query) async {
    String? message;
    var response = await apiService.getRequest(
        url:
            '${ApiConstants.baseUrl}/orders/search?query=$query'); // Changed 'text' to 'query'
    if (response != null) {
      Order order = Order.fromJson(response);
      message = order.message;
      orderList = order.orderData;
      notifyListeners();
    }
    return message;
  }

  // ❌ FIXED: GET /api/orders/get-order-by-id/{orderId} - Wrong endpoint
  Future<String?> getOrderById(int orderId) async {
    String? message;
    var response = await apiService.getRequest(
        url:
            '${ApiConstants.baseUrl}/orders/get-order-by-id/$orderId'); // Fixed endpoint
    if (response != null) {
      Order order = Order.fromJson(response);
      message = order.message;
      if (order.message == 'Order fetched successfully') {
        // This endpoint returns single order, so wrap in list or handle differently
        if (order.orderData.isNotEmpty) {
          // If you want to replace the list with just this order:
          orderList = order.orderData;
          // Or if you want to add/update this order in the existing list:
          // int index = orderList.indexWhere((o) => o.orderId == orderId);
          // if (index != -1) {
          //   orderList[index] = order.orderData[0];
          // } else {
          //   orderList.add(order.orderData[0]);
          // }
          notifyListeners();
        }
      }
    }
    return message;
  }

  void clearData() {
    if (allOrders != null) {
      orderList = allOrders!.orderData;
      notifyListeners();
    }
  }

  void sortOrder(String value) {
    if (value == 'ALL') {
      orderList = allOrders!.orderData;
    } else {
      orderList = allOrders!.orderData;
      orderList = orderList.where((order) => order.status == value).toList();
    }
    notifyListeners();
  }
}
