import '../../../core/network/api_client.dart';

import '../model/customer_menu.dart';
import '../model/customer_table_info.dart';
import '../../order/model/restaurant_order.dart';

class CustomerRepository {
  Future<CustomerTableInfo> getSessionInfo(String sessionToken) async {
    final response = await ApiClient.dio.get(
      '/public/session',
      queryParameters: {'sessionToken': sessionToken},
    );

    return CustomerTableInfo.fromJson(response.data['data']);
  }

  Future<List<CustomerMenuCategory>> getMenu(String sessionToken) async {
    final response = await ApiClient.dio.get(
      '/public/menu',
      queryParameters: {'sessionToken': sessionToken},
    );

    final List data = response.data['data']['categories'] ?? [];

    return data
        .map(
          (category) =>
              CustomerMenuCategory.fromJson(category as Map<String, dynamic>),
        )
        .toList();
  }

  Future<Map<String, dynamic>> createOrder({
    required String sessionToken,
    required String customerNote,
    required List<Map<String, dynamic>> items,
  }) async {
    final response = await ApiClient.dio.post(
      '/public/orders',
      data: {
        'sessionToken': sessionToken,
        'customerNote': customerNote,
        'items': items,
      },
    );

    return Map<String, dynamic>.from(response.data['data']);
  }

  Future<List<RestaurantOrder>> getOrders(String sessionToken) async {
    final response = await ApiClient.dio.get(
      '/public/orders',
      queryParameters: {'sessionToken': sessionToken},
    );

    final List data = response.data['data'] ?? [];

    return data
        .map((json) => RestaurantOrder.fromJson(json as Map<String, dynamic>))
        .toList();
  }

  Future<Map<String, dynamic>> getOrderingStatus(String sessionToken) async {
    final response = await ApiClient.dio.get(
      '/public/ordering-status',
      queryParameters: {'sessionToken': sessionToken},
    );

    return Map<String, dynamic>.from(response.data['data']);
  }
}
