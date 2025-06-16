class ShopDetails {
  int shopId;
  String name;
  String address;
  String selectedCategory;
  String openTime;
  String closeTime;
  String description;

  ShopDetails({
    required this.shopId,
    required this.name,
    required this.address,
    required this.selectedCategory,
    required this.openTime,
    required this.closeTime,
    required this.description,
  });

  Map<String, dynamic> toJson() {
    final map = <String, dynamic>{};
    map['shopId'] = shopId;
    map['name'] = name;
    map['address'] = address;
    map['category'] = selectedCategory;
    map['openingTime'] = openTime;
    map['closingTime'] = closeTime;
    map['description'] = description;
    return map;
  }
}

class ShopDetailsResponse {
  final String? message;
  final String? errorMessage;

  const ShopDetailsResponse({
    this.message,
    this.errorMessage,
  });

  factory ShopDetailsResponse.fromJson(Map<String, dynamic> json) {
    if (json['message'] == 'Details added successfully') {
      return ShopDetailsResponse(
        message: json['message'],
      );
    } else {
      return ShopDetailsResponse(
        errorMessage: json['error'] != null ? json['error']['message']: json['message'],
      );
    }
  }
}
