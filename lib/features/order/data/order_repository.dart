import '../../../core/network/api_client.dart';
import '../model/restaurant_order.dart';

class OrderRepository {
  Future<List<RestaurantOrder>> getOrders({
    required String restaurantId,
    String status = '',
    String tableId = '',
  }) async {
    final response = await ApiClient.dio.get(
      '/restaurants/$restaurantId/orders',
      queryParameters: {
        if (status.isNotEmpty) 'status': status,

        if (tableId.isNotEmpty) 'tableId': tableId,
      },
    );

    final List data = response.data['data'] ?? [];

    return data
        .map((json) => RestaurantOrder.fromJson(json as Map<String, dynamic>))
        .toList();
  }

  Future<RestaurantOrder> getOrder(String orderId) async {
    final response = await ApiClient.dio.get('/orders/$orderId');

    return RestaurantOrder.fromJson(response.data['data']);
  }

  Future<RestaurantOrder> updateStatus({
    required String orderId,
    required String status,
  }) async {
    final response = await ApiClient.dio.patch(
      '/orders/$orderId/status',
      data: {'status': status},
    );

    return RestaurantOrder.fromJson(response.data['data']);
  }
}
