class ShopDocuments {
  int shopId;
  String certificateFile;
  String? logoFile;
  String? bannerFile;
  double latitude;
  double longitude;

  ShopDocuments({
    required this.shopId,
    required this.certificateFile,
    this.logoFile,
    this.bannerFile,
    required this.latitude,
    required this.longitude,
  });

  Map<String, dynamic> toJson() => {
        'shopId': shopId,
        'certificateFile': certificateFile,
        'logoFile': logoFile,
        'bannerFile': bannerFile,
        'latitude': latitude,
        'longitude': longitude,
      };
}


class ShopDocumentsResponse {
  final String? message;
  final String? errorMessage;

  const ShopDocumentsResponse({
    this.message,
    this.errorMessage,
  });

  factory ShopDocumentsResponse.fromJson(Map<String, dynamic> json) {
    if (json['message'] == 'Documents uploaded successfully') {
      return ShopDocumentsResponse(
        message: json['message'],
      );
    } else {
      return ShopDocumentsResponse(
        errorMessage: json['error'] != null? json['error']['message']: json['message'],
      );
    }
  }
}
