import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../../providers/auth_provider.dart';
import '../../services/api/api_order_service.dart';
import '../../services/api/api_product_service.dart';
import '../../widgets/common/app_drawer.dart';
import '../../core/utils/app_format.dart';

class HistoryScreen extends StatefulWidget {
  const HistoryScreen({super.key});

  @override
  State<HistoryScreen> createState() => _HistoryScreenState();
}

class _HistoryScreenState extends State<HistoryScreen> {
  String _formatDateTime(DateTime dateTime) => DateFormat('HH:mm - dd/MM/yyyy').format(dateTime.toLocal());

  Future<List<Map<String, dynamic>>> _loadOrders() async {
    final auth = Provider.of<AuthProvider>(context, listen: false);
    final productService = ApiProductService(auth.apiClient);
    final orderService = ApiOrderService(auth.apiClient);
    final products = await productService.getAllProducts();
    final orders = await orderService.getAllOrders(products);
    return orders.map((o) => o.toJson()).toList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey.shade50,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0.5,
        leading: Builder(
          builder: (context) => IconButton(
            icon: const Icon(Icons.menu, color: Colors.black87),
            onPressed: () => Scaffold.of(context).openDrawer(),
          ),
        ),
        title: const Text('Lịch sử đơn hàng', style: TextStyle(color: Colors.black87, fontWeight: FontWeight.bold)),
      ),
      drawer: const AppDrawer(currentRoute: '/history'),
鼓      body: FutureBuilder<List<Map<String, dynamic>>>(
        future: _loadOrders(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) return const Center(child: CircularProgressIndicator());
          if (snapshot.hasError) return Center(child: Text('Loi tai du lieu: ${snapshot.error}'));

          final ordersList = snapshot.data ?? [];
          if (ordersList.isEmpty) return const Center(child: Text('Chua co hoa don nao.'));

          final totalRevenue = ordersList.fold(0.0, (sum, item) => sum + ((item['totalAmount'] as num?)?.toDouble() ?? 0.0));
          return Column(
            children: [
              Padding(
                padding: const EdgeInsets.all(16),
                child: Text('Tong doanh thu: ${AppFormat.money(totalRevenue)}', style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
              ),
              Expanded(
                child: ListView.builder(
                  itemCount: ordersList.length,
                  itemBuilder: (context, index) {
                    final order = ordersList[index];
                    final amount = ((order['totalAmount'] as num?)?.toDouble() ?? 0.0);
                    final dateTime = DateTime.tryParse(order['dateTimeUtc']?.toString() ?? '') ?? DateTime.now();
                    final invoice = order['invoiceNo']?.toString() ?? order['id']?.toString() ?? '';
                    return ListTile(
                      title: Text('Hoa don #$invoice'),
                      subtitle: Text(_formatDateTime(dateTime)),
                      trailing: Text(AppFormat.money(amount)),
                    );
                  },
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}
