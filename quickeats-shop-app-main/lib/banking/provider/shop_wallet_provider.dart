// shop_wallet_provider.dart
import 'package:shop_app/network/api_service.dart';
import 'package:shop_app/network/api_constants.dart';
import 'package:flutter/cupertino.dart';
import 'package:shop_app/banking/models/wallet.dart';

class ShopWalletProvider with ChangeNotifier {
  ShopWallet? shopWallet;
  List<dynamic> paymentList = []; // Added paymentList property

  ApiService apiService = ApiService();

  Future<void> getShopWallet() async {
    try {
      var response =
      await apiService.getRequest(url: '${ApiConstants.baseUrl}/wallet');
      if (response != null) {
        shopWallet = ShopWallet.fromJson(response);
        // Assuming the response contains a payment history list
        // Adjust this based on your actual API response structure
        paymentList = response['payments'] ?? [];
        notifyListeners();
      }
    } catch (e) {
      // Handle error appropriately in production
      print('Error fetching wallet: $e');
    }
  }
}

