class Payment {
  final String id;
  final String sessionId;
  final int amountSatang;
  final String? method;
  final String status;
  final String? transactionRef;
  final DateTime? paidAt;

  const Payment({
    required this.id,
    required this.sessionId,
    required this.amountSatang,
    required this.method,
    required this.status,
    required this.transactionRef,
    required this.paidAt,
  });

  factory Payment.fromJson(Map<String, dynamic> json) {
    return Payment(
      id: json['id'] ?? '',
      sessionId: json['sessionId'] ?? '',
      amountSatang: json['amountSatang'] ?? 0,
      method: json['method'],
      status: json['status'] ?? '',
      transactionRef: json['transactionRef'],
      paidAt: json['paidAt'] == null ? null : DateTime.tryParse(json['paidAt']),
    );
  }
}
