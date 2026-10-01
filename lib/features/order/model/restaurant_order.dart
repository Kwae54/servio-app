import 'order_item.dart';

class RestaurantOrder {
  final String id;
  final String sessionId;

  final String? tableId;
  final String? tableNo;

  final String orderNo;
  final String orderCode;
  final String status;

  final int totalSatang;

  final String? customerNote;

  final DateTime? createdAt;
  final DateTime? acceptedAt;
  final DateTime? completedAt;
  final DateTime? cancelledAt;

  final List<OrderItem> items;

  const RestaurantOrder({
    required this.id,
    required this.sessionId,
    required this.tableId,
    required this.tableNo,
    required this.orderNo,
    required this.orderCode,
    required this.status,
    required this.totalSatang,
    required this.customerNote,
    required this.createdAt,
    required this.acceptedAt,
    required this.completedAt,
    required this.cancelledAt,
    required this.items,
  });

  factory RestaurantOrder.fromJson(Map<String, dynamic> json) {
    final rawItems =
        json['items'] as List? ?? json['orderItems'] as List? ?? [];

    return RestaurantOrder(
      id: json['id'] ?? '',
      sessionId: json['sessionId'] ?? '',

      tableId: json['tableId'],
      tableNo: json['tableNo'],

      orderNo: json['orderNo'] ?? '',
      orderCode: json['orderCode'] ?? '',
      status: json['status'] ?? '',

      totalSatang: json['totalSatang'] ?? 0,

      customerNote: json['customerNote'],

      createdAt: _parseDate(json['createdAt']),

      acceptedAt: _parseDate(json['acceptedAt']),

      completedAt: _parseDate(json['completedAt']),

      cancelledAt: _parseDate(json['cancelledAt']),

      items: rawItems
          .map((item) => OrderItem.fromJson(item as Map<String, dynamic>))
          .toList(),
    );
  }
}

DateTime? _parseDate(dynamic value) {
  if (value == null) {
    return null;
  }

  return DateTime.tryParse(value.toString());
}
