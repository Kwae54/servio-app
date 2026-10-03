class AuthRestaurant {
  final String id;
  final String name;
  final String? imageUrl;
  final String status;

  const AuthRestaurant({
    required this.id,
    required this.name,
    required this.imageUrl,
    required this.status,
  });

  factory AuthRestaurant.fromJson(Map<String, dynamic> json) {
    return AuthRestaurant(
      id: json['id'] ?? '',
      name: json['name'] ?? '',
      imageUrl: json['imageUrl'],
      status: json['status'] ?? '',
    );
  }
}
