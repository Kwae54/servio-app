class Restaurant {
  final String id;
  final String name;
  final String? imageUrl;
  final String status;

  const Restaurant({
    required this.id,
    required this.name,
    required this.imageUrl,
    required this.status,
  });

  factory Restaurant.fromJson(Map<String, dynamic> json) {
    return Restaurant(
      id: json['id'] ?? '',
      name: json['name'] ?? '',
      imageUrl: json['imageUrl'],
      status: json['status'] ?? '',
    );
  }

  bool get isActive => status == 'ACTIVE';
}
