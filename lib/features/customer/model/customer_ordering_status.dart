class CustomerOrderingStatus {
  final bool canOrder;

  final String? sessionId;

  final String? sessionStatus;

  const CustomerOrderingStatus({
    required this.canOrder,
    required this.sessionId,
    required this.sessionStatus,
  });

  factory CustomerOrderingStatus.fromJson(Map<String, dynamic> json) {
    return CustomerOrderingStatus(
      canOrder: json['canOrder'] ?? false,

      sessionId: json['sessionId'],

      sessionStatus: json['sessionStatus'],
    );
  }
}
