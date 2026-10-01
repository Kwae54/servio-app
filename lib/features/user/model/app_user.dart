class AppUser {
  final String id;
  final String username;
  final String displayName;
  final String role;
  final String status;

  const AppUser({
    required this.id,
    required this.username,
    required this.displayName,
    required this.role,
    required this.status,
  });

  factory AppUser.fromJson(Map<String, dynamic> json) {
    return AppUser(
      id: json['id'] ?? '',
      username: json['username'] ?? '',
      displayName: json['displayName'] ?? '',
      role: json['role'] ?? '',
      status: json['status'] ?? '',
    );
  }

  bool get isActive => status == 'ACTIVE';
}
