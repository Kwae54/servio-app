class ActiveSession {
  final String sessionId;
  final String tableId;
  final String tableNo;
  final String status;
  final DateTime? openedAt;
  final int orderCount;
  final int subtotalSatang;

  const ActiveSession({
    required this.sessionId,
    required this.tableId,
    required this.tableNo,
    required this.status,
    required this.openedAt,
    required this.orderCount,
    required this.subtotalSatang,
  });

  factory ActiveSession.fromJson(Map<String, dynamic> json) {
    return ActiveSession(
      sessionId: json['sessionId'] ?? '',
      tableId: json['tableId'] ?? '',
      tableNo: json['tableNo'] ?? '',
      status: json['status'] ?? '',
      openedAt: json['openedAt'] == null
          ? null
          : DateTime.tryParse(json['openedAt']),
      orderCount: json['orderCount'] ?? 0,
      subtotalSatang: json['subtotalSatang'] ?? 0,
    );
  }
}
