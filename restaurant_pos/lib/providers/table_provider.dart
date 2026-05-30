import 'package:flutter/foundation.dart';
import '../models/table_model.dart';
import '../core/enums/table_status.dart';
import '../services/table_service.dart';
import '../services/sqlite_table_service.dart';

import '../services/api/signalr_service.dart';

class TableProvider with ChangeNotifier {
  List<DiningTable> _tables = [];
  TableService _tableService = SqliteTableService();
  String? _currentUserId;
  SignalRService? _signalRService;

  List<DiningTable> get tables => [..._tables];

  void setService(TableService service) {
    _tableService = service;
  }

  void initRealtime(String token, String restaurantId,
      {Function(Map<String, dynamic>)? onRequestReceived}) {
    _signalRService?.stop();
    _signalRService = SignalRService(token, restaurantId);
    _signalRService!.initTableHub(
      onTableStatusChanged: (tableId, status) {
        _updateLocalTableStatus(tableId, status);
      },
      onRequestReceived: onRequestReceived,
    );
  }

  void _updateLocalTableStatus(String tableId, String status) {
    final index = _tables.indexWhere((t) => t.id == tableId);
    if (index != -1) {
      TableStatus newStatus = TableStatus.empty;
      if (status == 'CO_KHACH') newStatus = TableStatus.occupied;
      if (status == 'DA_DAT') newStatus = TableStatus.reserved;

      final oldTable = _tables[index];
      _tables[index] = DiningTable(
        id: oldTable.id,
        name: oldTable.name,
        seats: oldTable.seats,
        status: newStatus,
      );
      notifyListeners();
    }
  }

  Future<void> fetchAndSetTables([String userId = 'admin']) async {
    _currentUserId = userId;
    try {
      _tables = await _tableService.getTablesByUserId(userId);
    } catch (e) {
      // Fallback to local sqlite service when API fails or offline
      _tableService = SqliteTableService();
      _tables = await _tableService.getTablesByUserId(userId);
    }
    notifyListeners();
  }

  Future<void> addTable(String name, int seats) async {
    if (_currentUserId == null) return;
    await _tableService.addTable(_currentUserId!, name, seats);
    await fetchAndSetTables(_currentUserId!);
  }

  Future<void> updateTableStatus(String id, TableStatus newStatus) async {
    if (_currentUserId == null) return;
    await _tableService.updateTableStatus(_currentUserId!, id, newStatus);

    final index = _tables.indexWhere((table) => table.id == id);
    if (index != -1) {
      final oldTable = _tables[index];
      _tables[index] = DiningTable(
        id: oldTable.id,
        name: oldTable.name,
        seats: oldTable.seats,
        status: newStatus,
      );
      notifyListeners();
    }
  }

  Future<void> deleteTable(String id) async {
    if (_currentUserId == null) return;
    await _tableService.deleteTable(_currentUserId!, id);
    _tables.removeWhere((table) => table.id == id);
    notifyListeners();
  }
}
