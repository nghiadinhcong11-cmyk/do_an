import 'package:flutter/material.dart';
import '../services/api/api_product_service.dart';
import '../models/product.dart';

class ProductProvider with ChangeNotifier {
  List<Product> _products = [];
  ApiProductService? _apiService;
  String? _currentUserId;

  List<Product> get products => [..._products];

  void setApiService(ApiProductService? service) {
    _apiService = service;
  }

  Future<void> fetchProducts([String userId = 'admin']) async {
    _currentUserId = userId;
    if (_apiService == null) {
      throw Exception('API service not available. Please login first.');
    }
    _products = await _apiService!.getAllProducts();
    notifyListeners();
  }

  Future<void> addProduct(Product product) async {
    if (_apiService == null) {
      throw Exception('API service not available. Please login first.');
    }
    await _apiService!.createProduct(product);
    await fetchProducts(_currentUserId ?? 'admin');
  }

  Future<void> updateProduct(Product product) async {
    if (_apiService == null) {
      throw Exception('API service not available. Please login first.');
    }
    await _apiService!.updateProduct(product);
    await fetchProducts(_currentUserId ?? 'admin');
  }

  Future<void> deleteProduct(String id) async {
    if (_apiService == null) {
      throw Exception('API service not available. Please login first.');
    }
    await _apiService!.deleteProduct(id);
    _products.removeWhere((p) => p.id == id);
    notifyListeners();
  }
}
