class ShopOwner {
  String name;
  String email;
  String mobileNumber;
  String nic;

  ShopOwner({
    required this.name,
    required this.email,
    required this.mobileNumber,
    required this.nic,
  });

  Map<String, dynamic> toJson() {
    final map = <String, dynamic>{};
    map['name'] = name;
    map['email'] = email;
    map['mobile'] = mobileNumber;
    map['nic'] = nic;
    return map;
  }
}

class ShopOwnerResponse {
  final String? message;
  final int? shopId;
  final String? errorMessage;

  const ShopOwnerResponse({
    this.message,
    this.shopId,
    this.errorMessage,
  });

  factory ShopOwnerResponse.fromJson(Map<String, dynamic> json) {
    final data =
        json['data'] as Map<String, dynamic>?; // Access the 'data' field
    if (json['message'] == 'Owner registered successfully' && data != null) {
      return ShopOwnerResponse(
        message: data['message'],
        shopId: data['shopId'],
      );
    } else {
      return ShopOwnerResponse(
        errorMessage:
            json['error'] != null ? json['error']['message'] : json['message'],
      );
    }
  }
}
