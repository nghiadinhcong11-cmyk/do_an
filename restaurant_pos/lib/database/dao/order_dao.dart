import '../../models/order.dart';
import '../../models/order_item.dart';
import '../../models/product.dart';
import '../database_helper.dart';
import 'package:sqflite/sqflite.dart';

class OrderDao {
  final DatabaseHelper _dbHelper = DatabaseHelper.instance;

  Future<OrderModel?> getOrderById(String orderId) async {
    final db = await _dbHelper.database;
    final List<Map<String, dynamic>> maps = await db.query(
      'orders',
      where: 'id = ?',
      whereArgs: [orderId],
    );

    if (maps.isNotEmpty) {
      return OrderModel.fromJson(maps.first);
    }
    return null;
  }

  Future<List<OrderItem>> getOrderItems(String orderId) async {
    final db = await _dbHelper.database;

    final List<Map<String, dynamic>> results = await db.rawQuery('''
      SELECT oi.quantity, p.id AS product_id, p.name, p.price, p.restaurantId
      FROM order_items oi
      JOIN products p ON oi.product_id = p.id
      WHERE oi.order_id = ?
    ''', [orderId]);

    return results.map((item) {
      final product = Product(
          id: item['product_id'].toString(),
          restaurantId: item['restaurantId']?.toString() ?? '',
          name: item['name'],
          price: (item['price'] as num).toDouble(),
        );
      return OrderItem(
        productId: product.id,
        productName: product.name,
        unitPrice: product.price,
        quantity: item['quantity'],
        lineTotal: product.price * item['quantity'],
        product: product,
      );
    }).toList();
  }

  Future<void> insertOrder(txn, OrderModel order) async {
    await txn.insert(
      'orders',
      order.toJson(),
    );
  }

  Future<void> insertOrderItems(
    txn,
    String orderId,
    List<OrderItem> items,
  ) async {
    for (final item in items) {
      await txn.insert('order_items', {
        'order_id': orderId,
        'product_id': item.productId,
        'quantity': item.quantity,
        'unitPrice': item.unitPrice,
        'lineTotal': item.lineTotal,
      });
    }
  }

  Future<void> upsertProducts(
    txn,
    List<OrderItem> items,
  ) async {
    for (final item in items) {
      if (item.product != null) {
        await txn.insert(
          'products',
          item.product!.toJson(),
          conflictAlgorithm: ConflictAlgorithm.replace,
        );
      }
    }
  }

  Future<List<OrderModel>> getOrdersByDateRange(
    DateTime start,
    DateTime end,
  ) async {
    final db = await _dbHelper.database;

    final List<Map<String, dynamic>> maps = await db.query(
      'orders',
      where: 'createdAtUtc BETWEEN ? AND ?',
      whereArgs: [
        start.toIso8601String(),
        end.toIso8601String(),
      ],
    );

    return maps.map((e) => OrderModel.fromJson(e)).toList();
  }

  Future<List<Map<String, dynamic>>> getTopSellingProducts(
    DateTime start,
    DateTime end, {
    int limit = 5,
  }) async {
    final db = await _dbHelper.database;
    return await db.rawQuery('''
      SELECT p.name, SUM(oi.quantity) as total_quantity, SUM(oi.quantity * oi.unitPrice) as total_revenue
      FROM order_items oi
      JOIN orders o ON oi.order_id = o.id
      JOIN products p ON oi.product_id = p.id
      WHERE o.createdAtUtc BETWEEN ? AND ?
      GROUP BY p.id
      ORDER BY total_quantity DESC
      LIMIT ?
    ''', [start.toIso8601String(), end.toIso8601String(), limit]);
  }
}
