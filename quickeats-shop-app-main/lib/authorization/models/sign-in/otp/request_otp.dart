class RequestOtp {
  final String mobile;
  String? errorMessage;
  RequestOtp({required this.mobile});

  fromJson(dynamic json) {
    if (json['error'] != null ) {
      errorMessage = json['error']['message'] ?? 'An error occurred';
    }
    else {
      errorMessage =  json['message'] ?? 'An error occurred';
    }
  }

  Map<String, dynamic> toJson() {
    final map = <String, dynamic>{};
    map['mobile'] = mobile;
    return map;
  }
}
