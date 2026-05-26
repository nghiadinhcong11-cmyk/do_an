import '../database/database_helper.dart';
import '../database/dao/order_dao.dart';
import '../models/order.dart';
import '../models/order_item.dart';

class PlaceOrderInput {
  final String tableId;
  final List<OrderItem> items;
  final double vatRate;

  PlaceOrderInput({
    required this.tableId,
    required this.items,
    this.vatRate = 0.03,
  });
}

class OrderService {
  final DatabaseHelper _dbHelper;
  final OrderDao _orderDao;

  OrderService({DatabaseHelper? dbHelper, OrderDao? orderDao})
      : _dbHelper = dbHelper ?? DatabaseHelper.instance,
        _orderDao = orderDao ?? OrderDao();

  Future<OrderModel> placeOrder(PlaceOrderInput input) async {
    if (input.tableId.trim().isEmpty) {
      throw ArgumentError('tableId must not be empty');
    }
    if (input.items.isEmpty) {
      throw ArgumentError('Order must contain at least one item');
    }
    if (input.vatRate < 0 || input.vatRate > 1) {
      throw ArgumentError('vatRate must be in range 0..1');
    }
    for (final item in input.items) {
      if (item.quantity <= 0) {
        throw ArgumentError('Item quantity must be > 0');
      }
      if (item.product.price < 0) {
        throw ArgumentError('Item price must be >= 0');
      }
    }

    final now = DateTime.now();
    final orderId = _generateOrderId(now);
    final invoiceNo = _generateInvoiceNo(now);
    final lookupCode = _generateLookupCode(now);

    final subTotal = input.items.fold<double>(
      0,
      (sum, item) => sum + (item.product.price * item.quantity),
    );
    final vatAmount = subTotal * input.vatRate;
    final totalAmount = subTotal + vatAmount;

    final order = OrderModel(
      id: orderId,
      tableId: input.tableId,
      dateTime: now,
      invoiceNo: invoiceNo,
      lookupCode: lookupCode,
      subTotal: subTotal,
      vatAmount: vatAmount,
      totalAmount: totalAmount,
      itemCount: input.items.fold<int>(0, (sum, item) => sum + item.quantity),
      status: 'paid',
      type: input.tableId == 'mang_di' ? 'takeaway' : 'dine_in',
      isSynced: false,
    );

    final db = await _dbHelper.database;
    await db.transaction((txn) async {
      await _orderDao.upsertProducts(txn, input.items);
      await _orderDao.insertOrder(txn, order);
      await _orderDao.insertOrderItems(txn, orderId, input.items);
      if (input.tableId != 'mang_di') {
        final affected = await txn.update(
          'tables',
          {'status': 'TRONG'},
          where: 'id = ?',
          whereArgs: [input.tableId],
        );
        if (affected == 0) {
          throw StateError('Table not found: ${input.tableId}');
        }
      }
    });

    return order;
  }

  String _generateOrderId(DateTime now) {
    return '${now.microsecondsSinceEpoch}';
  }

  String _generateInvoiceNo(DateTime now) {
    final y = now.year.toString().padLeft(4, '0');
    final m = now.month.toString().padLeft(2, '0');
    final d = now.day.toString().padLeft(2, '0');
    final h = now.hour.toString().padLeft(2, '0');
    final min = now.minute.toString().padLeft(2, '0');
    final s = now.second.toString().padLeft(2, '0');
    return 'INV-$y$m$d-$h$min$s';
  }

  String _generateLookupCode(DateTime now) {
    final base = now.millisecondsSinceEpoch.toRadixString(36).toUpperCase();
    return 'LKP-$base';
  }
}
