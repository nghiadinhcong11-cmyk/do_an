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
      id: (json['id'] ?? json['Id'])?.toString() ?? '',
      tableId: (json['tableId'] ?? json['TableId'])?.toString() ?? '',
      tableName: (json['tableName'] ?? json['TableName'])?.toString() ?? '',
      type: RequestType.values.firstWhere(
        (e) => e.name == (json['type'] ?? json['Type']), 
        orElse: () => RequestType.order
      ),
      status: RequestStatus.values.firstWhere(
        (e) => e.name == (json['status'] ?? json['Status']), 
        orElse: () => RequestStatus.pending
      ),
      createdAt: DateTime.parse((json['createdAt'] ?? json['CreatedAtUtc'] ?? DateTime.now().toIso8601String())),
      note: json['note'] ?? json['Note'],
      items: (json['items'] ?? json['Items']) != null 
          ? ((json['items'] ?? json['Items']) as List).map((i) => RequestItem.fromJson(i)).toList()
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
      productId: (json['productId'] ?? json['ProductId'])?.toString() ?? '',
      productName: (json['productName'] ?? json['ProductName'])?.toString() ?? '',
      quantity: (json['quantity'] ?? json['Quantity']) as int? ?? 1,
      note: json['note'] ?? json['Note'],
    );
  }
}
