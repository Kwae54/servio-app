class MenuItem {
  final String id;
  final String restaurantId;
  final String categoryId;
  final String name;
  final String description;
  final int priceSatang;
  final String? imageUrl;
  final bool available;
  final int sortOrder;

  const MenuItem({
    required this.id,
    required this.restaurantId,
    required this.categoryId,
    required this.name,
    required this.description,
    required this.priceSatang,
    required this.imageUrl,
    required this.available,
    required this.sortOrder,
  });

  factory MenuItem.fromJson(Map<String, dynamic> json) {
    return MenuItem(
      id: json['id'] ?? '',
      restaurantId: json['restaurantId'] ?? '',
      categoryId: json['categoryId'] ?? '',
      name: json['name'] ?? '',
      description: json['description'] ?? '',
      priceSatang: json['priceSatang'] ?? 0,
      imageUrl: json['imageUrl'],
      available: json['available'] ?? false,
      sortOrder: json['sortOrder'] ?? 0,
    );
  }
}
