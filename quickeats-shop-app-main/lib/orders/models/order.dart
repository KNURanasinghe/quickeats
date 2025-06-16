class Order {
  String message;
  List<OrderData> orderData;

  Order({
    required this.message,
    required this.orderData,
  });

  factory Order.fromJson(dynamic json) {
    if (json['data'] != null) {
      if (json['data'] is List) {
        return Order(
            message: json['message'],
            orderData: (json['data'] as List)
                .map((value) => OrderData.fromJson(value))
                .toList());
      } else {
        return Order(
            message: json['message'],
            orderData: [OrderData.fromJson(json['data'])]);
      }
    } else {
      return Order(message: json['message'], orderData: []);
    }
  }
}

class OrderData {
  int orderId;
  String status;
  int customerId;
  int shopId;
  double total;
  String? type;
  String? address;
  String? streetOrApartmentNo;
  String? deliveryInstruction;
  String? spatialInstruction;
  int? driverId;
  List<ItemsOfOrder> items;
  CustomerOfOrder customerOfOrder;
  OrderData(
      {required this.orderId,
      required this.shopId,
      required this.customerId,
      required this.status,
      required this.total,
      this.type,
      this.address,
      this.deliveryInstruction,
      this.spatialInstruction,
      this.streetOrApartmentNo,
      this.driverId,
      required this.items,
      required this.customerOfOrder});

  factory OrderData.fromJson(dynamic json) {
    return OrderData(
        orderId: json['id'],
        customerId: json['customer_id'],
        shopId: json['shop_id'],
        status: json['status'],
        total: (json['total_price'] as num).toDouble(),
        items: json['order_products'] is List
            ? (json['order_products'] as List<dynamic>)
                .map((item) => ItemsOfOrder.fromJson(item))
                .toList()
            : json['order_products'] != null
                ? [ItemsOfOrder.fromJson(json['order_products'])]
                : [],
        spatialInstruction: json['spatial_instruction'],
        deliveryInstruction: json['delivery_instruction'],
        streetOrApartmentNo: json['street_or_apartment_no'],
        type: json['type'],
        address: json['address'],
        driverId: json['driver_id'],
        customerOfOrder: CustomerOfOrder.fromJson(json['customers']));
  }
}

class ItemsOfOrder {
  int id;
  int orderId;
  int productId;
  int? foodVariantId;
  int quantity;

  double price;
  List<FoodOfOrder> foodOfOrder;
  ItemsOfOrder(
      {required this.id,
      required this.orderId,
      required this.productId,
      this.foodVariantId,
      required this.quantity,
      required this.price,
      required this.foodOfOrder});

  factory ItemsOfOrder.fromJson(dynamic json) {
    return ItemsOfOrder(
        id: json['id'],
        orderId: json['order_id'],
        productId: json['product_id'],
        foodVariantId: json['food_variant_id'],
        quantity: json['quantity'],
        price: (json['price'] as num).toDouble(),
        foodOfOrder: json['foods'] is List
            ? (json['foods'] as List)
                .map((item) => FoodOfOrder.fromJson(item))
                .toList()
            : json['foods'] != null
                ? [FoodOfOrder.fromJson(json['foods'])]
                : []);
  }
}

class CustomerOfOrder {
  int id;
  String name;
  String mobileNumber;
  String email;

  CustomerOfOrder({
    required this.id,
    required this.name,
    required this.mobileNumber,
    required this.email,
  });

  factory CustomerOfOrder.fromJson(dynamic json) {
    return CustomerOfOrder(
        id: json['id'],
        name: json['name'],
        mobileNumber: json['mobile'],
        email: json['email']);
  }
}

class FoodOfOrder {
  int id;
  String name;
  double price;
  String imageUrl;
  String description;

  FoodOfOrder({
    required this.id,
    required this.name,
    required this.price,
    required this.imageUrl,
    required this.description,
  });
  factory FoodOfOrder.fromJson(dynamic json) {
    return FoodOfOrder(
        id: json['id'],
        name: json['name'],
        price: (json['price'] as num).toDouble(),
        imageUrl: json['image'],
        description: json['description']);
  }
}
