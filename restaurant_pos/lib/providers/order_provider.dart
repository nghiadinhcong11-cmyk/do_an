import 'package:flutter/material.dart';
import '../models/order.dart';
import '../database/database_helper.dart';
import '../services/statistics_service.dart';

class OrderProvider with ChangeNotifier {
  List<OrderModel> _orders = [];
  bool _isLoading = false;
  String _selectedFilter = 'Hôm nay';
  SalesReport? _currentReport;
  final StatisticsService _statisticsService = StatisticsService();

  List<OrderModel> get orders => [..._orders];
  bool get isLoading => _isLoading;
  String get selectedFilter => _selectedFilter;
  SalesReport? get currentReport => _currentReport;

  Future<void> fetchOrders() async {
    _isLoading = true;
    notifyListeners();

    try {
      final data = await DatabaseHelper.instance.getAllOrders();
      _orders = data.map((item) => OrderModel.fromJson(item)).toList();
    } catch (e) {
      debugPrint("Lỗi tải đơn hàng: $e");
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> changeFilter(String filter) async {
    _selectedFilter = filter;
    _isLoading = true;
    notifyListeners();

    try {
      final now = DateTime.now();
      DateTime start = DateTime(now.year, now.month, now.day);

      if (filter == 'Tháng này') {
        start = DateTime(now.year, now.month, 1);
      } else if (filter == '3 tháng') {
        start = now.subtract(const Duration(days: 90));
      } else if (filter == '6 tháng') {
        start = now.subtract(const Duration(days: 180));
      } else if (filter == '1 năm') {
        start = DateTime(now.year - 1, now.month, now.day);
      }

      final end = DateTime(now.year, now.month, now.day, 23, 59, 59);
      _currentReport = await _statisticsService.calculateReport(start, end);
    } catch (e) {
      debugPrint('Loi tai bao cao: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
}
