import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../data/order_repository.dart';
import '../model/restaurant_order.dart';

final orderRepositoryProvider = Provider<OrderRepository>(
  (ref) => OrderRepository(),
);

class OrderQuery {
  final String restaurantId;
  final String status;
  final String tableId;

  const OrderQuery({
    required this.restaurantId,
    this.status = '',
    this.tableId = '',
  });

  @override
  bool operator ==(Object other) {
    return other is OrderQuery &&
        other.restaurantId == restaurantId &&
        other.status == status &&
        other.tableId == tableId;
  }

  @override
  int get hashCode => Object.hash(restaurantId, status, tableId);
}

final ordersProvider = FutureProvider.autoDispose
    .family<List<RestaurantOrder>, OrderQuery>((ref, query) async {
      final repository = ref.read(orderRepositoryProvider);

      return repository.getOrders(
        restaurantId: query.restaurantId,
        status: query.status,
        tableId: query.tableId,
      );
    });
