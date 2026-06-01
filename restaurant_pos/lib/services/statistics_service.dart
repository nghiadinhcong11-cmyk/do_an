// lib/services/statistics_service.dart
import '../database/dao/order_dao.dart';
import '../models/order.dart';
import '../database/database_helper.dart';

class SalesReport {
  final double totalRevenue;
  final double totalExpense;
  final double netProfit;
  final int totalOrders;
  final int totalItemsSold;
  final List<Map<String, dynamic>> chartData; 
  final List<Map<String, dynamic>> topProducts;

  SalesReport({
    required this.totalRevenue,
    required this.totalExpense,
    required this.netProfit,
    required this.totalOrders,
    required this.totalItemsSold,
    required this.chartData,
    required this.topProducts,
  });
}

class StatisticsService {
  final OrderDao _orderDao = OrderDao();
  final DatabaseHelper _dbHelper = DatabaseHelper.instance;

  Future<SalesReport> calculateReport(DateTime start, DateTime end) async {
    List<OrderModel> orders = await _orderDao.getOrdersByDateRange(start, end);
    List<Map<String, dynamic>> topProducts = await _orderDao.getTopSellingProducts(start, end);

    final allExpenses = await _dbHelper.getAllExpenses();
    double totalExpense = 0;
    
    for (var e in allExpenses) {
      DateTime expenseDate = DateTime.parse(e['date']);
      if (expenseDate.isAfter(start.subtract(const Duration(seconds: 1))) && 
          expenseDate.isBefore(end.add(const Duration(seconds: 1)))) {
        totalExpense += (e['amount'] as num).toDouble();
      }
    }

    double revenue = 0;
    int itemsCount = 0;
    Map<String, double> dailyRevenueMap = {};

    for (var order in orders) {
      revenue += order.totalAmount;
      itemsCount += order.itemCount;

      String dateKey = order.createdAtUtc.toIso8601String().substring(0, 10);
      dailyRevenueMap[dateKey] = (dailyRevenueMap[dateKey] ?? 0) + order.totalAmount;
    }

    List<Map<String, dynamic>> chartData = dailyRevenueMap.entries.map((e) {
      return {'date': e.key, 'amount': e.value};
    }).toList();
    
    chartData.sort((a, b) => a['date'].compareTo(b['date']));

    return SalesReport(
      totalRevenue: revenue,
      totalExpense: totalExpense,
      netProfit: revenue - totalExpense,
      totalOrders: orders.length,
      totalItemsSold: itemsCount,
      chartData: chartData,
      topProducts: topProducts,
    );
  }
}
