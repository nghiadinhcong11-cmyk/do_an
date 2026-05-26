import '../database/database_helper.dart';
import '../models/order.dart';
import 'api/api_client.dart';
import 'api/api_order_service.dart';
import 'api/api_product_service.dart';
import 'package:flutter/material.dart';

class SyncService {
  final DatabaseHelper _dbHelper = DatabaseHelper.instance;
  final ApiClient _apiClient;

  SyncService(this._apiClient);

  Future<int> syncOrders() async {
    final db = await _dbHelper.database;
    final apiOrderService = ApiOrderService(_apiClient);
    final apiProductService = ApiProductService(_apiClient);

    // 1. Get products from API first to map IDs correctly
    final products = await apiProductService.getAllProducts();

    // 2. Get unsynced orders from SQLite
    final unsyncedData = await db.query('orders', where: 'is_synced = 0');
    int syncedCount = 0;

    for (var row in unsyncedData) {
      try {
        final orderId = row['id'].toString();

        // Get items for this order
        final itemsData = await db
            .query('order_items', where: 'order_id = ?', whereArgs: [orderId]);

        // We need to fetch product info for each item from SQLite to match with API products
        List<Map<String, dynamic>> itemsWithProducts = [];
        for (var itemRow in itemsData) {
          final pData = await db.query('products',
              where: 'id = ?', whereArgs: [itemRow['product_id']]);
          if (pData.isNotEmpty) {
            itemsWithProducts.add({...itemRow, 'product': pData.first});
          }
        }

        final order = OrderModel.fromJson({
          ...row,
          'items': itemsWithProducts
              .map((i) => {
                    'productId': i['product_id'],
                    'quantity': i['quantity'],
                    'price': i['price']
                  })
              .toList()
        }, products);

        await apiOrderService.createOrder(order);

        // Mark as synced in SQLite
        await db.update('orders', {'is_synced': 1},
            where: 'id = ?', whereArgs: [orderId]);
        syncedCount++;
      } catch (e) {
        debugPrint('Error syncing order ${row['id']}: $e');
      }
    }
    return syncedCount;
  }
}
