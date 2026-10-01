class UserRestaurant {
  final String id;
  final String name;
  final String status;

  const UserRestaurant({
    required this.id,
    required this.name,
    required this.status,
  });

  factory UserRestaurant.fromJson(Map<String, dynamic> json) {
    return UserRestaurant(
      id: json['id'] ?? '',
      name: json['name'] ?? '',
      status: json['status'] ?? '',
    );
  }
}
