import 'package:shop_app/authorization/models/register/verification_status.dart';
import 'dart:io';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:shop_app/authorization/models/sign-in/login/login_response.dart';
import 'package:shop_app/services/firebase_storage_service.dart';
import 'package:shop_app/authorization/models/register/bank_details.dart';
import 'package:shop_app/authorization/models/sign-in/login/login_request.dart';
import 'package:shop_app/authorization/models/sign-in/otp/request_otp.dart';
import 'package:flutter/material.dart';
import 'package:shop_app/authorization/models/register/shop_details.dart';
import 'package:shop_app/authorization/models/register/shop_owner.dart';
import 'package:shop_app/network/api_constants.dart';
import 'package:shop_app/network/api_service.dart';
import 'package:shop_app/authorization/models/register/shop_documents.dart';

class AuthorizationProvider with ChangeNotifier {
  ApiService apiService = ApiService();
  SharedPreferences? sharedPreferences;
  bool? statusOfRegistration;
  int? shopId;
  String? shopName;

  final List<String> bankNames = [
    'Amana Bank',
    'Axis Bank',
    'Bank of China',
    'Cargills Bank',
    'Citibank',
    'Commercial Bank of Ceylon',
    'Hatton National Bank',
    'Indian Overseas Bank',
    'Indian Bank',
    'MCB Bank',
    'National Development Bank',
    'Nations Trust Bank',
    'Pan Asia Banking Corporation',
    'DFCC Bank',
    'Deutsche Bank',
    'Habib Bank',
    'BOC bank',
    'Public Bank Berhad',
    'People’s Bank',
    'Sampath Bank',
    'Seylan Bank',
    'Standard Chartered Bank',
    'State Bank of India',
    'The Hongkong & Shanghai Banking Corporation',
    'Union Bank of Colombo',
  ];

  Future<void> initSharedPreferences() async {
    sharedPreferences ??= await SharedPreferences.getInstance();
  }

  Future<String?> step1ShopOwner(ShopOwner shopOwner) async {
    await initSharedPreferences();

    String? message;
    var response = await apiService.postRequest(
        url: '${ApiConstants.baseUrl}/shop/owner', body: shopOwner.toJson());
    if (response != null) {
      ShopOwnerResponse shopOwnerResponse =
          ShopOwnerResponse.fromJson(response);
      if (shopOwnerResponse.message == 'Owner registered successfully') {
        message = 'Owner registered successfully';
        shopId = shopOwnerResponse.shopId;
        await sharedPreferences!.setInt('shop id', shopId!);
      } else {
        message = shopOwnerResponse.errorMessage ??
            'Failed to save shop owner details.';
      }
      notifyListeners();
    }
    return message;
  }

  Future<String?> step2ShopDetails(ShopDetails shopDetails) async {
    String? message;
    var response = await apiService.postRequest(
        url: '${ApiConstants.baseUrl}/shop/details',
        body: shopDetails.toJson());
    if (response != null) {
      ShopDetailsResponse shopDetailsResponse =
          ShopDetailsResponse.fromJson(response);
      if (shopDetailsResponse.message == 'Details added successfully') {
        message = 'Details added successfully';
        shopName = shopDetails.name;
      } else {
        message =
            shopDetailsResponse.errorMessage ?? 'Failed to save shop details.';
      }

      notifyListeners();
    }
    return message;
  }

  Future<String?> step3ShopDocuments(
    ShopDocuments shopDocuments,
    File businessCertificate,
    File shopLogo,
    File shopBanner,
  ) async {
    String? message;

    String certificateUrl = await FirebaseStorageService().uploadFile(
      businessCertificate,
      '$shopName business certificate',
      'registered shop images',
    );
    shopDocuments.certificateFile = certificateUrl;

    String logoUrl = await FirebaseStorageService().uploadFile(
      shopLogo,
      '$shopName logo',
      'registered shop images',
    );
    shopDocuments.logoFile = logoUrl;

    String bannerUrl = await FirebaseStorageService().uploadFile(
      shopBanner,
      '$shopName banner',
      'registered shop images',
    );
    shopDocuments.bannerFile = bannerUrl;

    var response = await apiService.postRequest(
      url: '${ApiConstants.baseUrl}/shop/documents',
      body: shopDocuments.toJson(),
    );

    if (response != null) {
      ShopDocumentsResponse shopDocumentsResponse =
          ShopDocumentsResponse.fromJson(response);
      if (shopDocumentsResponse.message == 'Documents uploaded successfully') {
        message = 'Documents uploaded successfully';
      } else {
        message = shopDocumentsResponse.errorMessage ??
            'Failed to save shop documents.';
      }

      notifyListeners();
    }

    return message;
  }

  Future<String?> step4BankDetails(BankDetails bankDetails) async {
    String? message;
    var response = await apiService.postRequest(
        url: '${ApiConstants.baseUrl}/bank/detail', body: bankDetails.toJson());
    if (response != null) {
      BankDetailsResponse bankDetailsResponse =
          BankDetailsResponse.fromJson(response);
      if (bankDetailsResponse.message == 'Bank details created successfully') {
        message = 'Bank details created successfully';
      } else {
        message =
            bankDetailsResponse.errorMessage ?? 'Failed to save bank details.';
      }
      notifyListeners();
    }
    return message;
  }

  Future<void> verificationStatus() async {
    await initSharedPreferences();
    var response = await apiService.getRequest(
        url: '${ApiConstants.baseUrl}/shop/verification-status?shopId=$shopId');
    if (response != null) {
      VerificationStatus verificationStatus =
          VerificationStatus.fromJson(response);
      statusOfRegistration = verificationStatus.status;
      await sharedPreferences!
          .setBool('verification status', statusOfRegistration!);
      notifyListeners();
    }
  }

  Future<void> getShopIdAndVerificationStatus() async {
    await initSharedPreferences();

    shopId ??= sharedPreferences!.getInt('shop id');
    statusOfRegistration ??= sharedPreferences!.getBool('verification status');
    notifyListeners();
  }

  Future<String?> requestOtp(RequestOtp requestOtp) async {
    var response = await apiService.postRequest(
        url: '${ApiConstants.baseUrl}/auth/request-otp',
        body: requestOtp.toJson());
    if (response != null) {
      requestOtp.fromJson(response);
      notifyListeners();
      return requestOtp.errorMessage;
    }
    return null;
  }

  Future<String?> login(LoginRequest loginRequest) async {
    String? message;

    var response = await apiService.postRequest(
        url: '${ApiConstants.baseUrl}/auth/sign-in',
        body: loginRequest.toJson());
    if (response != null) {
      loginRequest.fromJson(response);
      LoginResponse loginResponse = LoginResponse.fromJson(response);
      if (loginResponse.token != null) {
        await sharedPreferences!.setString('token', loginResponse.token!);
        message = 'Login successful';
      } else {
        message = loginRequest.errorMessage;
      }
    } else {
      message = null;
    }
    notifyListeners();

    return message;
  }
}
