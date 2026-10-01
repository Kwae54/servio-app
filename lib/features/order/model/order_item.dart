class OrderItem {
  final String id;
  final String? menuItemId;
  final String menuItemName;
  final int unitPriceSatang;
  final int quantity;
  final int totalSatang;
  final String? note;
  final String status;

  const OrderItem({
    required this.id,
    required this.menuItemId,
    required this.menuItemName,
    required this.unitPriceSatang,
    required this.quantity,
    required this.totalSatang,
    required this.note,
    required this.status,
  });

  factory OrderItem.fromJson(Map<String, dynamic> json) {
    return OrderItem(
      id: json['id'] ?? '',
      menuItemId: json['menuItemId'],
      menuItemName: json['menuItemName'] ?? json['menuItemNameSnapshot'] ?? '',
      unitPriceSatang:
          json['unitPriceSatang'] ?? json['unitPriceSnapshotSatang'] ?? 0,
      quantity: json['quantity'] ?? 0,
      totalSatang: json['totalSatang'] ?? 0,
      note: json['note'],
      status: json['status'] ?? '',
    );
  }
}
