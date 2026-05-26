import '../database/database_helper.dart';
import '../models/table_model.dart';
import '../core/enums/table_status.dart';
import 'table_service.dart';

class SqliteTableService implements TableService {
  final DatabaseHelper _dbHelper = DatabaseHelper.instance;

  @override
  Future<List<DiningTable>> getTablesByUserId(String userId) async {
    final dataList = await _dbHelper.getAllTablesFromDb(userId);

    return dataList.map((item) {
      return DiningTable(
        id: item['id']?.toString() ?? '',
        name: item['name'] ?? '',
        seats: item['seats'] ?? 0,
        status: switch (item['status']) {
          'TRONG' => TableStatus.empty,
          'CO_KHACH' => TableStatus.occupied,
          'DA_DAT' => TableStatus.reserved,
          _ => TableStatus.empty,
        },
      );
    }).toList();
  }

  @override
  Future<void> addTable(String userId, String name, int seats) async {
    final db = await _dbHelper.database;
    await db.insert('tables', {
      'id': DateTime.now().millisecondsSinceEpoch.toString(),
      'user_id': userId,
      'name': name,
      'seats': seats,
      'status': 'TRONG',
    });
  }

  @override
  Future<void> updateTableStatus(String userId, String id, TableStatus newStatus) async {
    String dbStatus = switch (newStatus) {
      TableStatus.occupied => 'CO_KHACH',
      TableStatus.reserved => 'DA_DAT',
      _ => 'TRONG',
    };
    await _dbHelper.updateTableStatusInDb(userId, id, dbStatus);
  }

  @override
  Future<void> deleteTable(String userId, String id) async {
    final db = await _dbHelper.database;
    await db.delete('tables', where: 'user_id = ? AND id = ?', whereArgs: [userId, id]);
  }
}
