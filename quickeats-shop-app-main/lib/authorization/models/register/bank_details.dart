class BankDetails {
  final int shopId;
  final String accountHolder;
  final String accountNumber;
  final String bankName;
  final String branchName;
  BankDetails({
    required this.shopId,
    required this.accountHolder,
    required this.accountNumber,
    required this.bankName,
    required this.branchName,
  });

  Map<String, dynamic> toJson() {
    final map = <String, dynamic>{};
    map['shopId'] = shopId;
    map['account_holder'] = accountHolder;
    map['account_number'] = accountNumber;
    map['bank_name'] = bankName;
    map['branch_name'] = branchName;
    return map;
  }
}

class BankDetailsResponse {
  final String? message;
  final String? errorMessage;

  const BankDetailsResponse({
    this.message,
    this.errorMessage,
  });

  factory BankDetailsResponse.fromJson(Map<String, dynamic> json) {
    if (json['message'] == 'Bank details created successfully') {
      return BankDetailsResponse(
        message: json['message'],
      );
    } else {
      return BankDetailsResponse(
        errorMessage: json['error'] != null ? json['error']['message']: json['message'],
      );
    }
  }
}
