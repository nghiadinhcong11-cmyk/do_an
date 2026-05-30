import 'package:flutter/material.dart';
import '../models/product.dart';
import '../database/database_helper.dart';

class CartItem {
  final Product product;
  int quantity;

  CartItem({required this.product, this.quantity = 1});
}

class CartProvider with ChangeNotifier {
  final Map<String, List<CartItem>> _tableCarts = {};
  final double vatRate = 0.03;
  final DatabaseHelper _dbHelper = DatabaseHelper.instance;

  Future<void> loadAllCarts([String userId = 'admin']) async {
    // Load cart items for all tables from local DB
    try {
      final tables = await _dbHelper.getAllTablesFromDb(userId);
      for (var t in tables) {
        final tableId = t['id']?.toString() ?? '';
        if (tableId.isEmpty) continue;
        final rows = await _dbHelper.getCartItems(tableId);
        if (rows.isNotEmpty) {
          _tableCarts[tableId] = rows.map((r) {
            final product = Product.fromJson(r);
            final qty = (r['quantity'] as num?)?.toInt() ?? 0;
            return CartItem(product: product, quantity: qty);
          }).toList();
        }
      }
    } catch (_) {}
    notifyListeners();
  }

  Future<void> loadCart(String tableId, [String userId = 'admin']) async {
    final rows = await _dbHelper.getCartItems(tableId);
    _tableCarts[tableId] = rows.map((r) {
      final product = Product.fromJson(r);
      final qty = (r['quantity'] as num?)?.toInt() ?? 0;
      return CartItem(product: product, quantity: qty);
    }).toList();
    notifyListeners();
  }

  List<CartItem> getItemsByTable(String tableId) {
    return _tableCarts[tableId] ?? [];
  }

  Future<void> addToCart(String tableId, Product product) async {
    if (!_tableCarts.containsKey(tableId)) {
      _tableCarts[tableId] = [];
    }

    final currentCart = _tableCarts[tableId]!;
    final index =
        currentCart.indexWhere((item) => item.product.id == product.id);

    if (index >= 0) {
      currentCart[index].quantity++;
      await _dbHelper.insertCartItem(
          tableId, product.id, currentCart[index].quantity);
    } else {
      currentCart.add(CartItem(product: product));
      await _dbHelper.insertCartItem(tableId, product.id, 1);
    }

    notifyListeners();
  }

  Future<void> updateQuantity(
      String tableId, String productId, int delta) async {
    if (!_tableCarts.containsKey(tableId)) return;

    final currentCart = _tableCarts[tableId]!;
    final index =
        currentCart.indexWhere((item) => item.product.id == productId);

    if (index >= 0) {
      final newQuantity = currentCart[index].quantity + delta;

      if (newQuantity <= 0) {
        await removeFromCart(tableId, productId);
      } else {
        currentCart[index].quantity = newQuantity;
        await _dbHelper.insertCartItem(tableId, productId, newQuantity);
        notifyListeners();
      }
    }
  }

  Future<void> removeFromCart(String tableId, String productId) async {
    if (_tableCarts.containsKey(tableId)) {
      _tableCarts[tableId]!.removeWhere((item) => item.product.id == productId);
      await _dbHelper.deleteCartItem(tableId, productId);
      notifyListeners();
    }
  }

  double getSubTotalPriceByTable(String tableId) {
    final currentCart = _tableCarts[tableId] ?? [];
    return currentCart.fold(
        0, (sum, item) => sum + (item.product.price * item.quantity));
  }

  double getVatByTable(String tableId) {
    return getSubTotalPriceByTable(tableId) * vatRate;
  }

  double getTableTotalPrice(String tableId) {
    return getSubTotalPriceByTable(tableId) + getVatByTable(tableId);
  }

  Future<void> clearTableCart(String tableId) async {
    _tableCarts.remove(tableId);
    await _dbHelper.clearCart(tableId);
    notifyListeners();
  }
}
