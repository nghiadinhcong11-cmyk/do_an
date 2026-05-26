import '../../models/table_model.dart';
import '../../core/enums/table_status.dart';
import '../table_service.dart';
import 'api_client.dart';

class ApiTableService implements TableService {
  final ApiClient _apiClient;

  ApiTableService(this._apiClient);

  @override
  Future<List<DiningTable>> getTablesByUserId(String userId) async {
    final List<dynamic> data = await _apiClient.get('/tables');
    return data.map((json) => DiningTable.fromJson(json)).toList();
  }

  @override
  Future<void> addTable(String userId, String name, int seats) async {
    await _apiClient.post('/tables', {
      'name': name,
      'seats': seats,
      'status': 'TRONG',
    });
  }

  @override
  Future<void> updateTableStatus(String userId, String id, TableStatus newStatus) async {
    String statusStr = switch (newStatus) {
      TableStatus.occupied => 'CO_KHACH',
      TableStatus.reserved => 'DA_DAT',
      _ => 'TRONG',
    };
    await _apiClient.patch('/tables/$id/status', statusStr);
  }

  @override
  Future<void> deleteTable(String userId, String id) async {
    await _apiClient.delete('/tables/$id');
  }
}
