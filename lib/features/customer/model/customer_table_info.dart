class CustomerTableInfo {
  final String restaurantId;
  final String restaurantName;
  final String? restaurantImageUrl;

  final String tableId;
  final String tableNo;
  final String? tableName;

  const CustomerTableInfo({
    required this.restaurantId,
    required this.restaurantName,
    required this.restaurantImageUrl,
    required this.tableId,
    required this.tableNo,
    required this.tableName,
  });

  factory CustomerTableInfo.fromJson(Map<String, dynamic> json) {
    return CustomerTableInfo(
      restaurantId: json['restaurantId'] ?? '',

      restaurantName: json['restaurantName'] ?? '',

      restaurantImageUrl: json['restaurantImageUrl'],

      tableId: json['tableId'] ?? '',

      tableNo: json['tableNo'] ?? '',

      tableName: json['tableName'],
    );
  }
}
