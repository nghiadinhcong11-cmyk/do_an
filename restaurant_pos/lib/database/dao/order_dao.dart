import '../../models/order.dart';
import '../../models/order_item.dart';
import '../../models/product.dart';
import '../database_helper.dart';
import 'package:sqflite/sqflite.dart';

class OrderDao {
  final DatabaseHelper _dbHelper = DatabaseHelper.instance;

  // 1. Lấy thông tin chung của 1 hóa đơn từ DB bằng Order ID
  Future<OrderModel?> getOrderById(String orderId) async {
    final db = await _dbHelper.database;
    final List<Map<String, dynamic>> maps = await db.query(
      'orders',
      where: 'id = ?',
      whereArgs: [orderId],
    );

    if (maps.isNotEmpty) {
      return OrderModel.fromMap(maps.first);
    }
    return null;
  }

  // 2. Lấy danh sách chi tiết các món ăn của hóa đơn đó (Bảng order_items nối với bảng products)
  Future<List<OrderItem>> getOrderItems(String orderId) async {
    final db = await _dbHelper.database;

    // Sử dụng câu lệnh JOIN SQL để lấy tên món ăn và giá từ bảng product luôn
    final List<Map<String, dynamic>> results = await db.rawQuery('''
      SELECT oi.quantity, p.id AS product_id, p.name, p.price 
      FROM order_items oi
      JOIN products p ON oi.product_id = p.id
      WHERE oi.order_id = ?
    ''', [orderId]);

    return results.map((item) {
      return OrderItem(
        product: Product(
          id: item['product_id'].toString(),
          name: item['name'],
          price: (item['price'] as num).toDouble(),
          category: '',
        ),
        quantity: item['quantity'],
      );
    }).toList();
  }

  Future<void> insertOrder(txn, OrderModel order) async {
    await txn.insert(
      'orders',
      order.toMap(),
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
        'product_id': item.product.id,
        'quantity': item.quantity,
        'price': item.product.price,
      });
    }
  }

  Future<void> upsertProducts(
    txn,
    List<OrderItem> items,
  ) async {
    for (final item in items) {
      await txn.insert(
        'products',
        {
          'id': item.product.id,
          'name': item.product.name,
          'price': item.product.price,
          'cost_price': item.product.costPrice,
          'category': item.product.category,
        },
        conflictAlgorithm: ConflictAlgorithm.replace,
      );
    }
  }

  Future<List<OrderModel>> getOrdersByDateRange(
    DateTime start,
    DateTime end,
  ) async {
    final db = await _dbHelper.database;

    final List<Map<String, dynamic>> maps = await db.query(
      'orders',
      where: 'date_time BETWEEN ? AND ?',
      whereArgs: [
        start.toIso8601String(),
        end.toIso8601String(),
      ],
    );

    return maps.map((e) => OrderModel.fromMap(e)).toList();
  }

  /// Lấy danh sách các món bán chạy nhất trong khoảng thời gian
  Future<List<Map<String, dynamic>>> getTopSellingProducts(
    DateTime start,
    DateTime end, {
    int limit = 5,
  }) async {
    final db = await _dbHelper.database;
    return await db.rawQuery('''
      SELECT p.name, SUM(oi.quantity) as total_quantity, SUM(oi.quantity * p.price) as total_revenue
      FROM order_items oi
      JOIN orders o ON oi.order_id = o.id
      JOIN products p ON oi.product_id = p.id
      WHERE o.date_time BETWEEN ? AND ?
      GROUP BY p.id
      ORDER BY total_quantity DESC
      LIMIT ?
    ''', [start.toIso8601String(), end.toIso8601String(), limit]);
  }
}
