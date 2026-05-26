import '../core/enums/table_status.dart';

class DiningTable {
  final String id;
  final String name;
  final int seats;
  final TableStatus status;

  DiningTable({
    required this.id,
    required this.name,
    required this.seats,
    required this.status,
  });

  factory DiningTable.fromJson(Map<String, dynamic> json) {
    final raw = json['status'];
    final status = switch (raw) {
      'CO_KHACH' => TableStatus.occupied,
      'RESERVED' => TableStatus.reserved,
      _ => TableStatus.empty,
    };

    return DiningTable(
      id: json['id']?.toString() ?? '',
      name: json['name'] ?? '',
      seats: json['seats'] ?? 0,
      status: status,
    );
  }

  Map<String, dynamic> toJson() {
    final statusStr = switch (status) {
      TableStatus.occupied => 'CO_KHACH',
      TableStatus.reserved => 'RESERVED',
      TableStatus.empty => 'TRONG',
    };

    return {
      'id': id,
      'name': name,
      'seats': seats,
      'status': statusStr,
    };
  }
}
