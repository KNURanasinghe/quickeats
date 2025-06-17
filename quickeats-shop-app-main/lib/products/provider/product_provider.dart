import 'package:cached_network_image/cached_network_image.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:io';

import 'package:shop_app/services/firebase_storage_service.dart';
import 'package:shop_app/network/api_service.dart';
import 'package:shop_app/network/api_constants.dart';
import 'package:flutter/cupertino.dart';
import 'package:shop_app/products/models/product.dart';
import 'package:shop_app/products/models/variance.dart';

class ProductProvider with ChangeNotifier {
  final List<String> categories = [
    "Dairy",
    "Produce",
    "Frozen foods",
    "Meat",
    "Bakery",
    "Snack foods",
    "Others"
  ];

  final Map<String, int> categoryIds = {
    "Dairy": 1,
    "Produce": 2,
    "Frozen foods": 3,
    "Meat": 4,
    "Bakery": 5,
    "Snack foods": 6,
    "Others": 7,
  };

  // Method to get category ID by name
  int? getCategoryIdByName(String categoryName) {
    return categoryIds[categoryName];
  }

  ApiService apiService = ApiService();

  List<ProductDataOfProductResponse> products = [];

  List<Variance> varianceList = [];

  SharedPreferences? sharedPreferences;

  int? shopId;

  Future<void> initSharedPreferences() async {
    sharedPreferences ??= await SharedPreferences.getInstance();
    shopId ??= sharedPreferences!.getInt('shop id');
    print('Shop ID from shared preferences: $shopId');
  }

  Future<String?> addProduct(Product product, File imageFile) async {
    String? message;

    await initSharedPreferences();

    // Set shop ID and category ID
    product.shopId = shopId;
    // Make sure category ID is preserved (it should already be set from UI)

    // Upload image first
    String fileUrl = await FirebaseStorageService()
        .uploadFile(imageFile, '${product.name} image', 'product images');
    product.imageUrl = fileUrl;

    // Debug print after setting all values
    print('Adding product with all data: ${product.toJson()}');

    var response = await apiService.postRequest(
        url: '${ApiConstants.baseUrl}/foods', body: product.toJson());
    print('add product res $response    ${ApiConstants.baseUrl}/foods');
    if (response != null) {
      ProductResponse productResponse = ProductResponse.fromJson(response);
      message = productResponse.message;

      if (productResponse.message == 'Product created successfully') {
        products = productResponse.productData;
      }
    }
    notifyListeners();

    return message;
  }

  void addVariance(Variance variance) {
    varianceList.add(variance);
    notifyListeners();
  }

  Future<String?> editProduct(Product product, int index) async {
    String? message;

    await initSharedPreferences();

    product.shopId = shopId;

    Map<String, dynamic> productJson = product.toJson();
    productJson['shop_id'] = shopId;

    var response = await apiService.postRequest(
        url: '${ApiConstants.baseUrl}/foods/${productJson['shop_id']}',
        body: productJson);
    if (response != null) {
      ProductResponse productResponse = ProductResponse.fromJson(response);

      message = productResponse.message;
      if (productResponse.message == 'Product updated successfully') {
        products[index] = productResponse.productData[0];
        notifyListeners();
      }
    }
    return message;
  }

  Future<String?> deleteProduct(int index) async {
    String? message;

    var response = await apiService.deleteRequest(
        url: '${ApiConstants.baseUrl}/foods/${products[index].productId}');
    if (response != null) {
      ProductResponse productResponse = ProductResponse.fromJson(response);
      message = productResponse.message;
      if (productResponse.message == 'Product deleted successfully') {
        CachedNetworkImage.evictFromCache(products[index].imageUrl);
        products.removeAt(index);
        notifyListeners();
      }
    }
    return message;
  }

  Future<String?> getAllProducts() async {
    String? message;
    var response =
        await apiService.getRequest(url: '${ApiConstants.baseUrl}/foods');
    print('get all products res $response    ${ApiConstants.baseUrl}/foods');
    if (response != null) {
      ProductResponse productResponse = ProductResponse.fromJson(response);
      message = productResponse.message;
      if (productResponse.message == 'Food items retrieved successfully') {
        print('Products retrieved: ${productResponse.productData.length}');
        products = productResponse.productData;
        notifyListeners();
      }
    }
    return message;
  }
}
