class TableQR {
  final String id;
  final String tableId;
  final String tableNo;
  final String restaurantId;
  final String token;
  final bool active;

  const TableQR({
    required this.id,
    required this.tableId,
    required this.tableNo,
    required this.restaurantId,
    required this.token,
    required this.active,
  });

  factory TableQR.fromJson(Map<String, dynamic> json) {
    return TableQR(
      id: json['id'] ?? '',
      tableId: json['tableId'] ?? '',
      tableNo: json['tableNo'] ?? '',
      restaurantId: json['restaurantId'] ?? '',
      token: json['token'] ?? '',
      active: json['active'] ?? false,
    );
  }
}
