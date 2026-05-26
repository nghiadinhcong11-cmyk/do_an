import 'dart:io';
import 'package:excel/excel.dart';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';
import '../database/database_helper.dart';
import 'package:intl/intl.dart';

class ExportService {
  final DatabaseHelper _dbHelper = DatabaseHelper.instance;

  Future<void> exportReportToExcel(DateTime start, DateTime end) async {
    final excel = Excel.createExcel();
    
    // --- SHEET 1: DOANH THU (ORDERS) ---
    Sheet sheetOrders = excel['Doanh Thu'];
    sheetOrders.appendRow([
      TextCellValue('ID Hóa Đơn'), 
      TextCellValue('Bàn'), 
      TextCellValue('Thời Gian'), 
      TextCellValue('Tổng Tiền'), 
      TextCellValue('Số Món')
    ]);

    final db = await _dbHelper.database;
    final List<Map<String, dynamic>> orderMaps = await db.query(
      'orders',
      where: 'date_time BETWEEN ? AND ?',
      whereArgs: [start.toIso8601String(), end.toIso8601String()],
      orderBy: 'date_time DESC',
    );

    for (var row in orderMaps) {
      sheetOrders.appendRow([
        TextCellValue(row['invoice_no'].toString()),
        TextCellValue(row['table_id'].toString()),
        TextCellValue(row['date_time'].toString()),
        DoubleCellValue((row['total_amount'] as num).toDouble()),
        IntCellValue((row['item_count'] as num).toInt()),
      ]);
    }

    // --- SHEET 2: CHI PHÍ (EXPENSES) ---
    Sheet sheetExpenses = excel['Chi Phí'];
    sheetExpenses.appendRow([
      TextCellValue('ID'), 
      TextCellValue('Nội Dung'), 
      TextCellValue('Số Tiền'), 
      TextCellValue('Phân Loại'), 
      TextCellValue('Ngày Chi')
    ]);

    final List<Map<String, dynamic>> expenseMaps = await _dbHelper.getAllExpenses();
    for (var row in expenseMaps) {
      DateTime expenseDate = DateTime.parse(row['date']);
      if (expenseDate.isAfter(start.subtract(const Duration(seconds: 1))) && 
          expenseDate.isBefore(end.add(const Duration(seconds: 1)))) {
        sheetExpenses.appendRow([
          TextCellValue(row['id'].toString()),
          TextCellValue(row['title'].toString()),
          DoubleCellValue((row['amount'] as num).toDouble()),
          TextCellValue(row['category'].toString()),
          TextCellValue(row['date'].toString()),
        ]);
      }
    }

    // --- SHEET 3: CHI TIẾT MÓN BÁN CHẠY ---
    Sheet sheetProducts = excel['Món Bán Chạy'];
    sheetProducts.appendRow([
      TextCellValue('Tên Món'), 
      TextCellValue('Số Lượng'), 
      TextCellValue('Doanh Thu')
    ]);
    
    final List<Map<String, dynamic>> topProducts = await db.rawQuery('''
      SELECT p.name, SUM(oi.quantity) as total_quantity, SUM(oi.quantity * p.price) as total_revenue
      FROM order_items oi
      JOIN orders o ON oi.order_id = o.id
      JOIN products p ON oi.product_id = p.id
      WHERE o.date_time BETWEEN ? AND ?
      GROUP BY p.id
      ORDER BY total_quantity DESC
    ''', [start.toIso8601String(), end.toIso8601String()]);

    for (var row in topProducts) {
      sheetProducts.appendRow([
        TextCellValue(row['name'].toString()),
        IntCellValue((row['total_quantity'] as num).toInt()),
        DoubleCellValue((row['total_revenue'] as num).toDouble()),
      ]);
    }

    // Lưu file
    var fileBytes = excel.save();
    final directory = await getTemporaryDirectory();
    final String fileName = "Bao_cao_${DateFormat('yyyyMMdd').format(start)}_${DateFormat('yyyyMMdd').format(end)}.xlsx";
    final File file = File('${directory.path}/$fileName');
    
    if (fileBytes != null) {
      await file.writeAsBytes(fileBytes);
      await Share.shareXFiles([XFile(file.path)], text: 'Báo cáo doanh thu và chi phí');
    }
  }
}
