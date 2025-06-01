class LoginResponse {
  String? token;
/*
  String refreshToken;
  Shop shop;
*/
  LoginResponse(
      {required this.token, /*required this.refreshToken, required this.shop*/});

  factory LoginResponse.fromJson(dynamic json) {
    return LoginResponse(
        token: json['token'],
/*        refreshToken: json['refreshToken'],
        shop: Shop.fromJson(json['shop'])*/);
  }
}

/*
class Shop {
  String name;
  String email;
  String mobileNumber;
  String nic;

  Shop({
    required this.name,
    required this.email,
    required this.mobileNumber,
    required this.nic,
  });

  factory Shop.fromJson(dynamic json) {
    return Shop(
        name: json['name'],
        email: json['email'],
        mobileNumber: json['mobile'],
        nic: json['nic']);
  }
}
*/
