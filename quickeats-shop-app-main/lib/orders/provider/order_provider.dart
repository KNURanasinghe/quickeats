import 'package:shop_app/network/api_constants.dart';
import 'package:shop_app/network/api_service.dart';
import 'package:shop_app/orders/models/order.dart';
import 'package:flutter/material.dart';

class OrderProvider with ChangeNotifier {
  List<OrderData> orderList = [];
  ApiService apiService = ApiService();
  Order? allOrders;

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

  Future<String?> updateOrderStatus(String status, int index) async {
    String? message;
    var response = await apiService.patchRequest(
        url: '${ApiConstants.baseUrl}/orders/status',
        body: {"id": orderList[index].orderId, "status": status});
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

  Future<String?> searchOrders(String query) async {
    String? message;
    var response = await apiService.getRequest(
        url: '${ApiConstants.baseUrl}/orders/search?text=$query');
    if (response != null) {
      Order order = Order.fromJson(response);
      message = order.message;
      orderList = order.orderData;

      notifyListeners();
    }
    return message;
  }

  Future<String?> getOrderById(int id) async {
    String? message;
    var response =
        await apiService.getRequest(url: '${ApiConstants.baseUrl}/orders/$id');
    if (response != null) {
      Order order = Order.fromJson(response);
      message = order.message;
      if (order.message == 'Order retrieved successfully') {
        orderList = order.orderData;
        notifyListeners();
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
