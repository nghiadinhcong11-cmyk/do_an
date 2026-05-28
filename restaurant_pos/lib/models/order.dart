import 'order_item.dart';
import 'product.dart';

class OrderModel {
  final String? id;
  final String tableId;
  final DateTime dateTime;
  final String invoiceNo;
  final String lookupCode;
  final double subTotal;
  final double vatAmount;
  final double totalAmount;
  final String? type;
  final String? status;
  final int? itemCount;
  final List<OrderItem>? items;
  final bool isSynced;
  final String? customerId;
  final String? voucherId;
  final double discountAmount;

  OrderModel({
    this.id,
    required this.tableId,
    required this.dateTime,
    required this.invoiceNo,
    required this.lookupCode,
    required this.subTotal,
    required this.vatAmount,
    required this.totalAmount,
    this.type,
    this.status,
    this.itemCount,
    this.items,
    this.isSynced = false,
    this.customerId,
    this.voucherId,
    this.discountAmount = 0.0,
  });

  DateTime get createdAt => dateTime;
  DateTime get date => dateTime;
  int get totalItemsQuantity => itemCount ?? items?.fold(0, (sum, item) => sum! + item.quantity) ?? 0;

  factory OrderModel.fromJson(Map<String, dynamic> json, [List<Product>? products]) {
    return OrderModel(
      id: json['id']?.toString(),
      tableId: json['tableId'] ?? json['table_id'] ?? '',
      dateTime: DateTime.parse(json['dateTimeUtc'] ?? json['date_time'] ?? DateTime.now().toIso8601String()),
      invoiceNo: json['invoiceNo'] ?? json['invoice_no'] ?? '',
      lookupCode: json['lookupCode'] ?? json['lookup_code'] ?? '',
      subTotal: (json['subTotal'] as num?)?.toDouble() ?? (json['sub_total'] as num?)?.toDouble() ?? 0.0,
      vatAmount: (json['vatAmount'] as num?)?.toDouble() ?? (json['vat_amount'] as num?)?.toDouble() ?? 0.0,
      totalAmount: (json['totalAmount'] as num?)?.toDouble() ?? (json['total_amount'] as num?)?.toDouble() ?? 0.0,
      type: json['type'] as String?,
      status: json['status'] as String?,
      itemCount: json['itemCount'] as int? ?? json['item_count'] as int?,
      items: json['items'] != null && products != null
          ? (json['items'] as List).map((i) => OrderItem.fromJson(i, products)).toList()
          : null,
      isSynced: (json['is_synced'] == 1 || json['isSynced'] == true),
      customerId: json['customerId']?.toString() ?? json['customer_id']?.toString(),
      voucherId: json['voucherId']?.toString() ?? json['voucher_id']?.toString(),
      discountAmount: (json['discountAmount'] as num?)?.toDouble() ?? (json['discount_amount'] as num?)?.toDouble() ?? 0.0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'tableId': tableId,
      'dateTimeUtc': dateTime.toUtc().toIso8601String(),
      'invoiceNo': invoiceNo,
      'lookupCode': lookupCode,
      'subTotal': subTotal,
      'vatAmount': vatAmount,
      'totalAmount': totalAmount,
      'type': type,
      'status': status,
      'itemCount': itemCount ?? items?.length,
      'items': items?.map((i) => i.toJson()).toList(),
      'is_synced': isSynced ? 1 : 0,
      'customerId': customerId,
      'voucherId': voucherId,
      'discountAmount': discountAmount,
    };
  }

  // Support legacy Map methods for SQLite if still needed
  factory OrderModel.fromMap(Map<String, dynamic> map) => OrderModel.fromJson(map);
  Map<String, dynamic> toMap() => toJson();
}
