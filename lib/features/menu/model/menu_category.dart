class MenuCategory {
  final String id;
  final String restaurantId;
  final String name;
  final int sortOrder;
  final bool active;

  const MenuCategory({
    required this.id,
    required this.restaurantId,
    required this.name,
    required this.sortOrder,
    required this.active,
  });

  factory MenuCategory.fromJson(Map<String, dynamic> json) {
    return MenuCategory(
      id: json['id'] ?? '',
      restaurantId: json['restaurantId'] ?? '',
      name: json['name'] ?? '',
      sortOrder: json['sortOrder'] ?? 0,
      active: json['active'] ?? false,
    );
  }
}
