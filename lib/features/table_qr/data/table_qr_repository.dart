import '../../../core/network/api_client.dart';
import '../model/table_qr.dart';

class TableQRRepository {
  Future<TableQR> getOrCreateQR(String tableId) async {
    final response = await ApiClient.dio.get('/tables/$tableId/qr');

    return TableQR.fromJson(response.data['data']);
  }

  Future<TableQR> rotateQR(String tableId) async {
    final response = await ApiClient.dio.post('/tables/$tableId/qr/rotate');

    return TableQR.fromJson(response.data['data']);
  }
}
