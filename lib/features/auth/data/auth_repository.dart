import '../../../core/network/api_client.dart';
import '../../../core/storage/token_storage.dart';

import '../model/auth_restaurant.dart';
import '../model/auth_state.dart';
import '../model/auth_user.dart';

class AuthRepository {
  Future<AuthState> login({
    required String username,
    required String password,
  }) async {
    final response = await ApiClient.dio.post(
      '/auth/login',
      data: {'username': username, 'password': password},
    );

    final data = response.data['data'] as Map<String, dynamic>;

    final token = data['accessToken'] as String;

    await TokenStorage.saveAccessToken(token);

    // หลัง Login แล้วโหลดข้อมูลล่าสุด
    return me();
  }

  Future<AuthState> me() async {
    final response = await ApiClient.dio.get('/auth/me');

    final data = response.data['data'] as Map<String, dynamic>;

    final user = AuthUser.fromJson(data['user']);

    final restaurantJson = data['restaurants'] as List? ?? [];

    final restaurants = restaurantJson
        .map((e) => AuthRestaurant.fromJson(e))
        .toList();

    return AuthState(user: user, restaurants: restaurants);
  }

  Future<void> logout() async {
    await TokenStorage.clear();
  }
}
