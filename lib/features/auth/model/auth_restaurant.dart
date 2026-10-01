class AuthRestaurant {
  final String id;
  final String name;
  final String status;

  const AuthRestaurant({
    required this.id,
    required this.name,
    required this.status,
  });

  factory AuthRestaurant.fromJson(Map<String, dynamic> json) {
    return AuthRestaurant(
      id: json['id'] ?? '',
      name: json['name'] ?? '',
      status: json['status'] ?? '',
    );
  }
}
