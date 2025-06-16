class VerificationStatus {
  final bool? status;
  final String? errorMessage;

  VerificationStatus({this.status, this.errorMessage});

  factory VerificationStatus.fromJson(dynamic json) {
    // Safely extract the 'data' field
    final data = json['data'] as Map<String, dynamic>?;

    // Extract status as a string and convert to boolean
    bool? parsedStatus;
    String? statusValue;
    String? message;

    if (data != null) {
      statusValue = data['status'] as String?;
      message = data['message'] as String?;
      if (statusValue != null) {
        parsedStatus = statusValue.toLowerCase() == 'verified';
      }
    }

    return VerificationStatus(
      status: parsedStatus,
      errorMessage: message,
    );
  }
}
