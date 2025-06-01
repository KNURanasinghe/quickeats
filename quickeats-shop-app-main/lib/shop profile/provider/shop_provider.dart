import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:http/http.dart' as http;
import 'package:path/path.dart';
import 'package:shop_app/network/api_constants.dart';
import 'package:shop_app/network/api_service.dart';
import 'package:shop_app/shop profile/models/shop.dart';

class ShopProvider with ChangeNotifier {
  Shop? shop;
  ApiService apiService = ApiService();

  /* Future<String?> getShopProfile() async {
    String? message;
    var response = await apiService.getRequest(
      url: '${ApiConstants.baseUrl}/shop/profile',
    );
    if (response != null) {
      shop = Shop.fromJson(response);
      message = shop?.message;
      notifyListeners();
    }
    return message;
  }*/
  Future<String?> getShopProfile() async {
    await Future.delayed(const Duration(seconds: 1));

    shop = Shop.fromJson({
      "status": true,
      "data": [
        {
          "id": 1,
          "email": "test@example.com",
          "mobile": "1234567890",
          "nic": "123456789V",
          "address": "Test Address",
          "image": "https://via.placeholder.com/150",
          "banner": "https://via.placeholder.com/800x200",
          "description": "A test shop",
          "category": "Test Category",
          "opening_time": "08:00",
          "closing_time": "22:00",
          "latitude": "6.9271",
          "longitude": "79.8612",
          "is_active": true,
          "created_at": "2023-01-01",
          "updated_at": "2023-01-01",
          "verified": true,
          "owner_name": "John Doe",
          "shop_name": "Demo Shop",
          "certificate": null,
          "fcm_token": "some-token",
          "is_deleted": false
        }
      ]
    });

    notifyListeners();
    return "success";
  }

  Future<bool> updateShopImage({
    required File file,
    required bool isBanner,
  }) async {
    try {
      final fileName = basename(file.path);
      final ref = FirebaseStorage.instance.ref().child(
          'shop_images/${DateTime.now().millisecondsSinceEpoch}_$fileName');

      final uploadTask = await ref.putFile(file);
      final downloadUrl = await uploadTask.ref.getDownloadURL();

      final url = isBanner
          ? '${ApiConstants.baseUrl}/shop/update-banner-url'
          : '${ApiConstants.baseUrl}/shop/update-profile-url';

      final response = await http.post(
        Uri.parse(url),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'shopId': shop?.shopData?[0].id,
          'imageUrl': downloadUrl,
        }),
      );

      if (response.statusCode == 200) {
        if (isBanner) {
          shop?.shopData?[0].banner = downloadUrl;
        } else {
          shop?.shopData?[0].image = downloadUrl;
        }
        notifyListeners();
        return true;
      } else {
        return false;
      }
    } catch (e) {
      debugPrint('Upload error: $e');
      return false;
    }
  }

  Future<bool> updateShopDetails({
    required String shopName,
    required String description,
    required String address,
    required String ownerName,
    required String email,
    required String mobile,
  }) async {
    try {
      final url = '${ApiConstants.baseUrl}/shop/update-details';

      final response = await http.post(
        Uri.parse(url),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'shopId': shop?.shopData?[0].id,
          'shopName': shopName,
          'description': description,
          'address': address,
          'ownerName': ownerName,
          'email': email,
          'mobile': mobile,
        }),
      );

      if (response.statusCode == 200) {
        final updatedShop = shop?.shopData?[0];
        if (updatedShop != null) {
          updatedShop.shopName = shopName;
          updatedShop.description = description;
          updatedShop.address = address;
          updatedShop.ownerName = ownerName;
          updatedShop.email = email;
          updatedShop.mobile = mobile;
        }
        notifyListeners();
        return true;
      } else {
        debugPrint("Update failed: ${response.body}");
        return false;
      }
    } catch (e) {
      debugPrint("Update error: $e");
      return false;
    }
  }
}
