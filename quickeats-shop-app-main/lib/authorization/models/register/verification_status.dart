class VerificationStatus {
  final bool? status;
  final String? errorMessage;

  VerificationStatus({this.status, this.errorMessage});

  factory VerificationStatus.fromJson(dynamic json) {
      return VerificationStatus(
        status: json['status'],
        errorMessage: json['message'],
      );
    }
  

}