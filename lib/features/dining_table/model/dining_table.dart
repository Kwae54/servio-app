class DiningTable {
  final String id;
  final String restaurantId;
  final String tableNo;
  final String? tableName;
  final String status;

  const DiningTable({
    required this.id,
    required this.restaurantId,
    required this.tableNo,
    required this.tableName,
    required this.status,
  });

  factory DiningTable.fromJson(Map<String, dynamic> json) {
    return DiningTable(
      id: json['id'] ?? '',
      restaurantId: json['restaurantId'] ?? '',
      tableNo: json['tableNo'] ?? '',
      tableName: json['tableName'],
      status: json['status'] ?? '',
    );
  }

  bool get isAvailable => status == 'AVAILABLE';

  bool get isOccupied => status == 'OCCUPIED';

  bool get isInactive => status == 'INACTIVE';
}
