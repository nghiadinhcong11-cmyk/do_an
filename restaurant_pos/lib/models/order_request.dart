enum RequestType { order, callStaff, payment }
enum RequestStatus { pending, confirmed, cancelled }

class OrderRequest {
  final String id;
  final String tableId;
  final String tableName;
  final RequestType type;
  final RequestStatus status;
  final DateTime createdAt;
  final List<RequestItem>? items;
  final String? note;

  OrderRequest({
    required this.id,
    required this.tableId,
    required this.tableName,
    required this.type,
    this.status = RequestStatus.pending,
    required this.createdAt,
    this.items,
    this.note,
  });

  factory OrderRequest.fromJson(Map<String, dynamic> json) {
    return OrderRequest(
      id: json['id']?.toString() ?? '',
      tableId: json['tableId']?.toString() ?? '',
      tableName: json['tableName']?.toString() ?? '',
      type: RequestType.values.firstWhere((e) => e.name == json['type'], orElse: () => RequestType.order),
      status: RequestStatus.values.firstWhere((e) => e.name == json['status'], orElse: () => RequestStatus.pending),
      createdAt: DateTime.parse(json['createdAt'] ?? DateTime.now().toIso8601String()),
      note: json['note'],
      items: json['items'] != null 
          ? (json['items'] as List).map((i) => RequestItem.fromJson(i)).toList()
          : null,
    );
  }
}

class RequestItem {
  final String productId;
  final String productName;
  final int quantity;
  final String? note;

  RequestItem({
    required this.productId,
    required this.productName,
    required this.quantity,
    this.note,
  });

  factory RequestItem.fromJson(Map<String, dynamic> json) {
    return RequestItem(
      productId: json['productId']?.toString() ?? '',
      productName: json['productName']?.toString() ?? '',
      quantity: json['quantity'] as int? ?? 1,
      note: json['note'],
    );
  }
}
