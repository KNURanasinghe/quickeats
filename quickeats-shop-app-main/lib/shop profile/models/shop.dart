class Shop {
  String? message;
  List<ShopData>? shopData;

  Shop({
    required this.message,
    required this.shopData,
  });

  factory Shop.fromJson(dynamic json) {
    if (json['data'] != null) {
      if (json['data'] is List) {
        return Shop(
            // message: json['status'],
            message: json['status'].toString(),
            shopData: (json['data'] as List)
                .map((value) => ShopData.fromJson(value))
                .toList());
      } else {
        return Shop(
            message: json['status'],
            shopData: [ShopData.fromJson(json['data'])]);
      }
    } else {
      //return Shop(message: json['status'], shopData: []);
      return Shop(message: json['status'].toString(), shopData: []);
    }
  }
}

class ShopData {
  int? id;
  String? email;
  String? mobile;
  String? nic;
  String? address;
  String? image;
  String? banner;
  String? description;
  String? category;
  String? openingTime;
  String? closingTime;
  double? latitude;
  double? longitude;
  bool? isActive;
  String? createdAt;
  String? updatedAt;
  bool? verified;
  String? ownerName;
  String? shopName;
  String? certificate;
  String? fcmToken;
  bool? isDeleted;

  ShopData({
    required this.id,
    required this.email,
    required this.mobile,
    required this.nic,
    this.address,
    required this.image,
    this.banner,
    required this.description,
    this.category,
    this.openingTime,
    this.closingTime,
    this.latitude,
    this.longitude,
    required this.isActive,
    required this.createdAt,
    required this.updatedAt,
    required this.verified,
    required this.ownerName,
    required this.shopName,
    this.certificate,
    required this.fcmToken,
    required this.isDeleted,
  });

  factory ShopData.fromJson(Map<String, dynamic> json) {
    return ShopData(
      id: json['id'],
      email: json['email'],
      mobile: json['mobile'],
      nic: json['nic'],
      address: json['address'],
      image: json['image'] ?? '',
      banner: json['banner'] ?? '',
      description: json['description'] ?? '',
      category: json['category'],
      openingTime: json['opening_time'],
      closingTime: json['closing_time'],
      latitude: json['latitude'] != null
          ? double.tryParse(json['latitude'].toString())
          : null,
      longitude: json['longitude'] != null
          ? double.tryParse(json['longitude'].toString())
          : null,
      isActive: json['is_active'],
      createdAt: json['created_at'],
      updatedAt: json['updated_at'],
      verified: json['verified'],
      ownerName: json['owner_name'],
      shopName: json['shop_name'],
      certificate: json['certificate'],
      fcmToken: json['fcm_token'],
      isDeleted: json['is_deleted'],
    );
  }
}
