import 'package:cached_network_image/cached_network_image.dart';
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
  ApiService apiService = ApiService();

  List<ProductDataOfProductResponse> products = [];

  List<Variance> varianceList = [];

  Future<String?> addProduct(Product product, File imageFile) async {
    String? message;
    String fileUrl = await FirebaseStorageService()
        .uploadFile(imageFile, '${product.name} image', 'product images');
    product.imageUrl = fileUrl;

    var response = await apiService.postRequest(
        url: '${ApiConstants.baseUrl}/product', body: product.toJson());
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

    var response = await apiService.putRequest(
        url: '${ApiConstants.baseUrl}/product/${products[index].productId}',
        body: product.toJson());
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
        url: '${ApiConstants.baseUrl}/product/${products[index].productId}');
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
        await apiService.getRequest(url: '${ApiConstants.baseUrl}/product');
    if (response != null) {
      ProductResponse productResponse = ProductResponse.fromJson(response);
      message = productResponse.message;
      if (productResponse.message == 'Products retrieved successfully') {
        products = productResponse.productData;
        notifyListeners();
      }
    }
    return message;
  }
}
