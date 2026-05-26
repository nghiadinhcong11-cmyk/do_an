import '../models/table_model.dart';
import '../core/enums/table_status.dart';

abstract class TableService {
  Future<List<DiningTable>> getTablesByUserId(String userId);
  Future<void> addTable(String userId, String name, int seats);
  Future<void> updateTableStatus(String userId, String id, TableStatus newStatus);
  Future<void> deleteTable(String userId, String id);
}
