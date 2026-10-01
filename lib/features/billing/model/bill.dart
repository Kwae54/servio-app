class BillItem {
  final String menuItemName;
  final int unitPriceSatang;
  final int quantity;
  final int totalSatang;

  const BillItem({
    required this.menuItemName,
    required this.unitPriceSatang,
    required this.quantity,
    required this.totalSatang,
  });

  factory BillItem.fromJson(Map<String, dynamic> json) {
    return BillItem(
      menuItemName: json['menuItemName'] ?? '',
      unitPriceSatang: json['unitPriceSatang'] ?? 0,
      quantity: json['quantity'] ?? 0,
      totalSatang: json['totalSatang'] ?? 0,
    );
  }
}

class BillDiscount {
  final String id;
  final String discountName;
  final String discountType;
  final int discountValue;
  final int discountAmountSatang;
  final String? promotionCode;

  const BillDiscount({
    required this.id,
    required this.discountName,
    required this.discountType,
    required this.discountValue,
    required this.discountAmountSatang,
    required this.promotionCode,
  });

  factory BillDiscount.fromJson(Map<String, dynamic> json) {
    return BillDiscount(
      id: json['id'] ?? '',
      discountName: json['discountName'] ?? '',
      discountType: json['discountType'] ?? '',
      discountValue: json['discountValue'] ?? 0,
      discountAmountSatang: json['discountAmountSatang'] ?? 0,
      promotionCode: json['promotionCode'],
    );
  }
}

class Bill {
  final String sessionId;
  final String tableId;
  final String tableNo;
  final String sessionStatus;

  final List<BillItem> items;
  final List<BillDiscount> discounts;

  final int subtotalSatang;
  final int discountTotalSatang;
  final int totalSatang;

  const Bill({
    required this.sessionId,
    required this.tableId,
    required this.tableNo,
    required this.sessionStatus,
    required this.items,
    required this.discounts,
    required this.subtotalSatang,
    required this.discountTotalSatang,
    required this.totalSatang,
  });

  factory Bill.fromJson(Map<String, dynamic> json) {
    final rawItems = json['items'] as List? ?? [];

    final rawDiscounts = json['discounts'] as List? ?? [];

    return Bill(
      sessionId: json['sessionId'] ?? '',
      tableId: json['tableId'] ?? '',
      tableNo: json['tableNo'] ?? '',
      sessionStatus: json['sessionStatus'] ?? '',

      items: rawItems
          .map((e) => BillItem.fromJson(e as Map<String, dynamic>))
          .toList(),

      discounts: rawDiscounts
          .map((e) => BillDiscount.fromJson(e as Map<String, dynamic>))
          .toList(),

      subtotalSatang: json['subtotalSatang'] ?? 0,

      discountTotalSatang: json['discountTotalSatang'] ?? 0,

      totalSatang: json['totalSatang'] ?? 0,
    );
  }
}
