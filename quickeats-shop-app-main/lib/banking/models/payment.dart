class Payment {
  String paymentId;
  int amount;
  String status;
  String method;
  String date;

  Payment({
    required this.paymentId,
    required this.amount,
    required this.status,
    required this.method,
    required this.date,
  });
}
