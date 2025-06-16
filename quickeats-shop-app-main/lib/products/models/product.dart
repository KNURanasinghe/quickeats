class Product {
  final String name;
  final double price;
  final String description;
  String? imageUrl;
  final int quantity;
  int? shopId;
  int? categoryId;

  Product({
    required this.name,
    required this.price,
    required this.description,
    this.imageUrl,
    required this.quantity,
    this.shopId,
    this.categoryId,
  });

  Map<String, dynamic> toJson() {
    final map = <String, dynamic>{};
    map['name'] = name;
    map['price'] = price;
    map['description'] = description;
    map['image'] = imageUrl;
    map['stock'] = quantity;

    // Include shop_id and category_id separately with their own null checks
    if (shopId != null) {
      map['shop_id'] = shopId;
    }
    if (categoryId != null) {
      map['category_id'] = categoryId;
    }

    return map;
  }
}

class ProductResponse {
  String message;
  List<ProductDataOfProductResponse> productData;

  ProductResponse({
    required this.message,
    required this.productData,
  });

  factory ProductResponse.fromJson(dynamic json) {
    if (json['data'] != null) {
      if (json['data'] is List) {
        return ProductResponse(
            message: json['message'],
            productData: (json['data'] as List)
                .map((value) => ProductDataOfProductResponse.fromJson(value))
                .toList());
      } else {
        return ProductResponse(
            message: json['message'],
            productData: [ProductDataOfProductResponse.fromJson(json['data'])]);
      }
    } else {
      return ProductResponse(message: json['message'], productData: []);
    }
  }
}

class ProductDataOfProductResponse {
  int shopId;
  int productId;
  String name;
  double price;
  String description;
  String imageUrl;
  int quantity;

  ProductDataOfProductResponse({
    required this.shopId,
    required this.productId,
    required this.name,
    required this.price,
    required this.description,
    required this.imageUrl,
    required this.quantity,
  });

  factory ProductDataOfProductResponse.fromJson(Map<String, dynamic> json) {
    return ProductDataOfProductResponse(
      shopId: json['shop_id'],
      productId: json['id'],
      name: json['name'],
      price: (json['price'] as num).toDouble(),
      description: json['description'],
      imageUrl: json['image'],
      quantity: json['stock'],
    );
  }
}
