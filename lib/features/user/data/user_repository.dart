import '../../../core/network/api_client.dart';

import '../model/app_user.dart';
import '../model/user_restaurant.dart';

class UserRepository {
  Future<List<AppUser>> getUsers({String search = ''}) async {
    final response = await ApiClient.dio.get(
      '/users',
      queryParameters: {if (search.trim().isNotEmpty) 'search': search.trim()},
    );

    final List data = response.data['data'] ?? [];

    return data
        .map((json) => AppUser.fromJson(json as Map<String, dynamic>))
        .toList();
  }

  Future<AppUser> createUser({
    required String username,
    required String password,
    required String displayName,
    required String role,
  }) async {
    final response = await ApiClient.dio.post(
      '/users',
      data: {
        'username': username,
        'password': password,
        'displayName': displayName,
        'role': role,
      },
    );

    return AppUser.fromJson(response.data['data']);
  }

  Future<AppUser> updateStatus({
    required String userId,
    required String status,
  }) async {
    final response = await ApiClient.dio.patch(
      '/users/$userId/status',
      data: {'status': status},
    );

    return AppUser.fromJson(response.data['data']);
  }

  Future<List<UserRestaurant>> getRestaurants() async {
    final response = await ApiClient.dio.get('/restaurants');

    final List data = response.data['data'] ?? [];

    return data
        .map((json) => UserRestaurant.fromJson(json as Map<String, dynamic>))
        .toList();
  }

  Future<List<UserRestaurant>> getUserRestaurants(String userId) async {
    final response = await ApiClient.dio.get('/users/$userId/restaurants');

    final List data = response.data['data'] ?? [];

    return data
        .map((json) => UserRestaurant.fromJson(json as Map<String, dynamic>))
        .toList();
  }

  Future<void> assignRestaurant({
    required String userId,
    required String restaurantId,
  }) async {
    await ApiClient.dio.post(
      '/users/$userId/restaurants',
      data: {'restaurantId': restaurantId},
    );
  }

  Future<void> removeRestaurant({
    required String userId,
    required String restaurantId,
  }) async {
    await ApiClient.dio.delete('/users/$userId/restaurants/$restaurantId');
  }
}
