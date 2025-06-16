class ShopWallet {
  final double? totalEarnings;
  final double? receivedAmount;
  final double? returnedCanceledValue;
  final double? pendingAmount;
  final List<Order>? latestOrders;

  ShopWallet({
    required this.totalEarnings,
    required this.receivedAmount,
    required this.returnedCanceledValue,
    required this.pendingAmount,
    required this.latestOrders,
  });

  factory ShopWallet.fromJson(Map<String, dynamic> json) {
    return ShopWallet(
      totalEarnings: (json['total_earnings'] ?? 0).toDouble(),
      receivedAmount: (json['received_amount'] ?? 0).toDouble(),
      returnedCanceledValue: (json['returned_canceled_value'] ?? 0).toDouble(),
      pendingAmount: (json['pending_amount'] ?? 0).toDouble(),
      latestOrders: json['latest_orders'] is List
          ? (json['latest_orders'] as List<dynamic>)
              .map((order) => Order.fromJson(order))
              .toList()
          : json['latest_orders'] != null
              ? [Order.fromJson(json['latest_orders'])]
              : [],
    );
  }
}

class Order {
  int? id;
  int? customerId;
  int? shopId;
  int? driverId;
  double? totalPrice;
  double? deliveryFee;
  String? status;
  String? type;
  String? address;
  String? streetOrApartmentNo;
  String? deliveryInstruction;
  String? spatialInstruction;
  String? createdAt;
  String? updatedAt;
  bool? isDeleted;
  double? longitude;
  double? latitude;
  Customer? customers;
  Driver? driver;
  WalletInfo? walletInfo;

  Order({
    required this.id,
    required this.customerId,
    required this.shopId,
    this.driverId,
    required this.totalPrice,
    required this.deliveryFee,
    required this.status,
    this.type,
    required this.address,
    required this.streetOrApartmentNo,
    required this.deliveryInstruction,
    required this.spatialInstruction,
    required this.createdAt,
    required this.updatedAt,
    required this.isDeleted,
    required this.longitude,
    required this.latitude,
    required this.customers,
    this.driver,
    required this.walletInfo,
  });

  factory Order.fromJson(Map<String, dynamic> json) {
    return Order(
      id: json['id'],
      customerId: json['customer_id'],
      shopId: json['shop_id'],
      driverId: json['driver_id'],
      totalPrice: double.parse(json['total_price'] ?? '0.0'),
      deliveryFee: double.parse(json['delivery_fee'] ?? '0'),
      status: json['status'],
      type: json['type'],
      address: json['address'],
      streetOrApartmentNo: json['street_or_apartment_no'],
      deliveryInstruction: json['delivery_instruction'],
      spatialInstruction: json['spatial_instruction'],
      createdAt: json['created_at'],
      updatedAt: json['updated_at'],
      isDeleted: json['is_deleted'],
      longitude: double.tryParse(json['longitude'] ?? '0') ?? 0.0,
      latitude: double.tryParse(json['latitude'] ?? '0') ?? 0.0,
      customers: Customer.fromJson(json['customers']),
      driver: json['driver'] != null ? Driver.fromJson(json['driver']) : null,
      walletInfo: WalletInfo.fromJson(json['wallet_info']),
    );
  }
}

class Customer {
  int? id;
  String? name;
  String? email;
  String? mobile;
  bool? isActive;
  String? createdAt;
  String? updatedAt;
  bool? isDeleted;

  Customer({
    required this.id,
    required this.name,
    required this.email,
    required this.mobile,
    required this.isActive,
    required this.createdAt,
    required this.updatedAt,
    required this.isDeleted,
  });

  factory Customer.fromJson(Map<String, dynamic> json) {
    return Customer(
      id: json['id'],
      name: json['name'],
      email: json['email'],
      mobile: json['mobile'],
      isActive: json['is_active'],
      createdAt: json['created_at'],
      updatedAt: json['updated_at'],
      isDeleted: json['is_deleted'],
    );
  }
}

class Driver {
  Driver();

  factory Driver.fromJson(Map<String, dynamic> json) {
    return Driver();
  }
}

class WalletInfo {
  final double amount;
  final bool paid;
  final bool completed;

  WalletInfo({
    required this.amount,
    required this.paid,
    required this.completed,
  });

  factory WalletInfo.fromJson(Map<String, dynamic> json) {
    return WalletInfo(
      amount: (json['amount'] ?? 0).toDouble(),
      paid: json['paid'],
      completed: json['completed'],
    );
  }
}
