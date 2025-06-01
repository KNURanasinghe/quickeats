class LoginRequest {
  final String mobileNumber;
  final String otp;
  String? errorMessage;

  LoginRequest({
    required this.mobileNumber,
    required this.otp,
  });
  fromJson(dynamic json) {
    if (json['message'] != null) {
      errorMessage = json['message'];
    }
  }

  Map<String, dynamic> toJson() {
    final map = <String, dynamic>{};
    map['mobile'] = mobileNumber;
    map['otp'] = otp;
    return map;
  }
}
