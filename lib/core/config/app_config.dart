class AppConfig {
  static const String apiBaseUrl = String.fromEnvironment(
    'API_BASE_URL',
    defaultValue: 'http://localhost:8080/api/v1',
  );

  static const String serverBaseUrl = String.fromEnvironment(
    'SERVER_BASE_URL',
    defaultValue: 'http://localhost:8080',
  );

  static const String customerWebUrl = String.fromEnvironment(
    'CUSTOMER_WEB_URL',
    defaultValue: 'http://localhost:3000',
  );

  static String imageUrl(String? path) {
    if (path == null || path.isEmpty) {
      return '';
    }

    if (path.startsWith('http://') || path.startsWith('https://')) {
      return path;
    }

    return '$serverBaseUrl$path';
  }

  static String customerOrderUrl(String tableToken) {
    return '$customerWebUrl/?tableToken=$tableToken';
  }
}
