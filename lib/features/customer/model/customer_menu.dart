class CustomerMenuItem {
  final String id;
  final String name;
  final String description;
  final int priceSatang;
  final String? imageUrl;
  final int sortOrder;

  const CustomerMenuItem({
    required this.id,
    required this.name,
    required this.description,
    required this.priceSatang,
    required this.imageUrl,
    required this.sortOrder,
  });

  factory CustomerMenuItem.fromJson(Map<String, dynamic> json) {
    return CustomerMenuItem(
      id: json['id'] ?? '',
      name: json['name'] ?? '',
      description: json['description'] ?? '',
      priceSatang: json['priceSatang'] ?? 0,
      imageUrl: json['imageUrl'],
      sortOrder: json['sortOrder'] ?? 0,
    );
  }
}

class CustomerMenuCategory {
  final String id;
  final String name;
  final int sortOrder;
  final List<CustomerMenuItem> items;

  const CustomerMenuCategory({
    required this.id,
    required this.name,
    required this.sortOrder,
    required this.items,
  });

  factory CustomerMenuCategory.fromJson(Map<String, dynamic> json) {
    final rawItems = json['items'] as List? ?? [];

    return CustomerMenuCategory(
      id: json['id'] ?? '',
      name: json['name'] ?? '',
      sortOrder: json['sortOrder'] ?? 0,

      items: rawItems
          .map(
            (item) => CustomerMenuItem.fromJson(item as Map<String, dynamic>),
          )
          .toList(),
    );
  }
}
