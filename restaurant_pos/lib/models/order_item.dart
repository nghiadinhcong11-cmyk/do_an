class OrderItem {
  final int id;
  final String orderId;
  final String productId;
  final String? productName;
  final double unitPrice;
  final int quantity;
  final double lineTotal;
  final String? notes;

  OrderItem({
    required this.id,
    required this.orderId,
    required this.productId,
    this.productName,
    required this.unitPrice,
    required this.quantity,
    required this.lineTotal,
    this.notes,
  });

  factory OrderItem.fromJson(Map<String, dynamic> json) {
    return OrderItem(
      id: (json['id'] as num?)?.toInt() ?? 0,
      orderId: json['orderId']?.toString() ?? '',
      productId: json['productId']?.toString() ?? '',
      productName: json['productName'],
      unitPrice: (json['unitPrice'] as num?)?.toDouble() ?? 0.0,
      quantity: (json['quantity'] as num?)?.toInt() ?? 0,
      lineTotal: (json['lineTotal'] as num?)?.toDouble() ?? 0.0,
      notes: json['notes'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'orderId': orderId,
      'productId': productId,
      'productName': productName,
      'unitPrice': unitPrice,
      'quantity': quantity,
      'lineTotal': lineTotal,
      'notes': notes,
    };
  }
}
