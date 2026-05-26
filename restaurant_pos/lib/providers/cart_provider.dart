import 'package:flutter/material.dart';
import '../models/product.dart';

class CartItem {
  final Product product;
  int quantity;

  CartItem({required this.product, this.quantity = 1});
}

class CartProvider with ChangeNotifier {
  final Map<String, List<CartItem>> _tableCarts = {};
  final double vatRate = 0.03;

  Future<void> loadAllCarts([String userId = 'admin']) async {
    // Cart is now in-memory only on mobile; source of truth is API orders.
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
    final index = currentCart.indexWhere((item) => item.product.id == product.id);

    if (index >= 0) {
      currentCart[index].quantity++;
    } else {
      currentCart.add(CartItem(product: product));
    }

    notifyListeners();
  }

  Future<void> updateQuantity(String tableId, String productId, int delta) async {
    if (!_tableCarts.containsKey(tableId)) return;

    final currentCart = _tableCarts[tableId]!;
    final index = currentCart.indexWhere((item) => item.product.id == productId);

    if (index >= 0) {
      final newQuantity = currentCart[index].quantity + delta;

      if (newQuantity <= 0) {
        await removeFromCart(tableId, productId);
      } else {
        currentCart[index].quantity = newQuantity;
        notifyListeners();
      }
    }
  }

  Future<void> removeFromCart(String tableId, String productId) async {
    if (_tableCarts.containsKey(tableId)) {
      _tableCarts[tableId]!.removeWhere((item) => item.product.id == productId);
      notifyListeners();
    }
  }

  double getSubTotalPriceByTable(String tableId) {
    final currentCart = _tableCarts[tableId] ?? [];
    return currentCart.fold(0, (sum, item) => sum + (item.product.price * item.quantity));
  }

  double getVatByTable(String tableId) {
    return getSubTotalPriceByTable(tableId) * vatRate;
  }

  double getTableTotalPrice(String tableId) {
    return getSubTotalPriceByTable(tableId) + getVatByTable(tableId);
  }

  Future<void> clearTableCart(String tableId) async {
    _tableCarts.remove(tableId);
    notifyListeners();
  }
}
