import 'order_item.dart';

class OrderModel {
  final String id;
  final String restaurantId;
  final String? branchId;
  final String tableId;
  final String? customerId;
  final String? voucherId;
  final int? createdByUserId;
  final String invoiceNo;
  final String lookupCode;
  final String? type;
  final String? status;
  final String? paymentMethod;
  final String? paymentStatus;
  final String? paymentContent;
  final String? paymentReference;
  final int itemCount;
  final double subTotal;
  final double discountAmount;
  final double vatAmount;
  final double totalAmount;
  final String? notes;
  final DateTime? paidAtUtc;
  final DateTime createdAtUtc;

  final List<OrderItem> items;

  OrderModel({
    required this.id,
    required this.restaurantId,
    this.branchId,
    required this.tableId,
    this.customerId,
    this.voucherId,
    this.createdByUserId,
    required this.invoiceNo,
    required this.lookupCode,
    this.type,
    this.status,
    this.paymentMethod,
    this.paymentStatus,
    this.paymentContent,
    this.paymentReference,
    required this.itemCount,
    required this.subTotal,
    this.discountAmount = 0.0,
    this.vatAmount = 0.0,
    required this.totalAmount,
    this.notes,
    this.paidAtUtc,
    required this.createdAtUtc,
    required this.items,
  });

  factory OrderModel.fromJson(Map<String, dynamic> json) {
    return OrderModel(
      id: json['id']?.toString() ?? '',
      restaurantId: json['restaurantId']?.toString() ?? '',
      branchId: json['branchId']?.toString(),
      tableId: json['tableId']?.toString() ?? '',
      customerId: json['customerId']?.toString(),
      voucherId: json['voucherId']?.toString(),
      createdByUserId: (json['createdByUserId'] as num?)?.toInt(),
      invoiceNo: json['invoiceNo'] ?? '',
      lookupCode: json['lookupCode'] ?? '',
      type: json['type'],
      status: json['status'],
      paymentMethod: json['paymentMethod'],
      paymentStatus: json['paymentStatus'],
      paymentContent: json['paymentContent'],
      paymentReference: json['paymentReference'],
      itemCount: (json['itemCount'] as num?)?.toInt() ?? 0,
      subTotal: (json['subTotal'] as num?)?.toDouble() ?? 0.0,
      discountAmount: (json['discountAmount'] as num?)?.toDouble() ?? 0.0,
      vatAmount: (json['vatAmount'] as num?)?.toDouble() ?? 0.0,
      totalAmount: (json['totalAmount'] as num?)?.toDouble() ?? 0.0,
      notes: json['notes'],
      paidAtUtc: json['paidAtUtc'] != null ? DateTime.tryParse(json['paidAtUtc']) : null,
      createdAtUtc: DateTime.tryParse(json['createdAtUtc'] ?? '') ?? DateTime.now(),
      items: (json['items'] as List?)?.map((i) => OrderItem.fromJson(i)).toList() ?? [],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'restaurantId': restaurantId,
      'branchId': branchId,
      'tableId': tableId,
      'customerId': customerId,
      'voucherId': voucherId,
      'createdByUserId': createdByUserId,
      'invoiceNo': invoiceNo,
      'lookupCode': lookupCode,
      'type': type,
      'status': status,
      'paymentMethod': paymentMethod,
      'paymentStatus': paymentStatus,
      'paymentContent': paymentContent,
      'paymentReference': paymentReference,
      'itemCount': itemCount,
      'subTotal': subTotal,
      'discountAmount': discountAmount,
      'vatAmount': vatAmount,
      'totalAmount': totalAmount,
      'notes': notes,
      'paidAtUtc': paidAtUtc?.toIso8601String(),
      'createdAtUtc': createdAtUtc.toIso8601String(),
      'items': items.map((i) => i.toJson()).toList(),
    };
  }

  // Compatibility getter
  DateTime get dateTimeUtc => createdAtUtc;
}
