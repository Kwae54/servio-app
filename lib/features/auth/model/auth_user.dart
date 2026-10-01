class AuthUser {
  final String id;
  final String username;
  final String displayName;
  final String role;
  final String status;

  const AuthUser({
    required this.id,
    required this.username,
    required this.displayName,
    required this.role,
    required this.status,
  });

  factory AuthUser.fromJson(Map<String, dynamic> json) {
    return AuthUser(
      id: json['id'] ?? '',
      username: json['username'] ?? '',
      displayName: json['displayName'] ?? '',
      role: json['role'] ?? '',
      status: json['status'] ?? '',
    );
  }

  bool get isSuperAdmin => role == 'SUPER_ADMIN';

  bool get isAdmin => role == 'ADMIN';

  bool get isRestaurantUser => role == 'RESTAURANT_USER';
}
