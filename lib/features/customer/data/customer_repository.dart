import '../../../core/network/api_client.dart';

import '../model/customer_menu.dart';
import '../model/customer_table_info.dart';
import '../../order/model/restaurant_order.dart';

class CustomerRepository {
  Future<CustomerTableInfo> getTableInfo(String tableToken) async {
    final response = await ApiClient.dio.get(
      '/public/table',

      queryParameters: {'tableToken': tableToken},
    );

    return CustomerTableInfo.fromJson(response.data['data']);
  }

  Future<List<CustomerMenuCategory>> getMenu(String tableToken) async {
    final response = await ApiClient.dio.get(
      '/public/menu',

      queryParameters: {'tableToken': tableToken},
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
    required String tableToken,
    required String customerNote,
    required List<Map<String, dynamic>> items,
  }) async {
    final response = await ApiClient.dio.post(
      '/public/orders',

      data: {
        'tableToken': tableToken,

        'customerNote': customerNote,

        'items': items,
      },
    );

    return Map<String, dynamic>.from(response.data['data']);
  }

  Future<List<RestaurantOrder>> getOrders(String tableToken) async {
    final response = await ApiClient.dio.get(
      '/public/orders',

      queryParameters: {'tableToken': tableToken},
    );

    final List data = response.data['data'] ?? [];

    return data
        .map((json) => RestaurantOrder.fromJson(json as Map<String, dynamic>))
        .toList();
  }
}
