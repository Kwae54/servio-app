import '../../../core/network/api_client.dart';
import '../model/dining_table.dart';

class DiningTableRepository {
  Future<List<DiningTable>> getTables(String restaurantId) async {
    final response = await ApiClient.dio.get(
      '/restaurants/$restaurantId/tables',
    );

    final List data = response.data['data'] ?? [];

    return data
        .map((json) => DiningTable.fromJson(json as Map<String, dynamic>))
        .toList();
  }

  Future<DiningTable> getTable(String tableId) async {
    final response = await ApiClient.dio.get('/tables/$tableId');

    return DiningTable.fromJson(response.data['data']);
  }

  Future<DiningTable> createTable({
    required String restaurantId,
    required String tableNo,
    String? tableName,
  }) async {
    final response = await ApiClient.dio.post(
      '/restaurants/$restaurantId/tables',
      data: {
        'tableNo': tableNo,
        'tableName': tableName?.trim().isEmpty == true
            ? null
            : tableName?.trim(),
      },
    );

    return DiningTable.fromJson(response.data['data']);
  }

  Future<DiningTable> updateTable({
    required String tableId,
    required String tableNo,
    String? tableName,
  }) async {
    final response = await ApiClient.dio.put(
      '/tables/$tableId',
      data: {
        'tableNo': tableNo,
        'tableName': tableName?.trim().isEmpty == true
            ? null
            : tableName?.trim(),
      },
    );

    return DiningTable.fromJson(response.data['data']);
  }

  Future<DiningTable> updateStatus({
    required String tableId,
    required String status,
  }) async {
    final response = await ApiClient.dio.patch(
      '/tables/$tableId/status',
      data: {'status': status},
    );

    return DiningTable.fromJson(response.data['data']);
  }

  Future<Map<String, dynamic>> openSession(String tableId) async {
    final response = await ApiClient.dio.post('/tables/$tableId/open-session');

    return Map<String, dynamic>.from(response.data['data']);
  }

  Future<void> moveSession({
    required String sourceTableId,
    required String targetTableId,
  }) async {
    await ApiClient.dio.post(
      '/tables/$sourceTableId/move-session',
      data: {'targetTableId': targetTableId},
    );
  }
}
