import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../models/order.dart';
import '../../providers/auth_provider.dart';
import '../../services/api/api_order_service.dart';
import '../../services/api/api_product_service.dart';
import '../../widgets/cards/order_card.dart';
import '../../widgets/common/app_drawer.dart';

class OrderManagementScreen extends StatefulWidget {
  const OrderManagementScreen({super.key});

  @override
  State<OrderManagementScreen> createState() => _OrderManagementScreenState();
}

class _OrderManagementScreenState extends State<OrderManagementScreen> {
  Future<List<OrderModel>> _loadOrders() async {
    final auth = Provider.of<AuthProvider>(context, listen: false);
    final products = await ApiProductService(auth.apiClient).getAllProducts();
    return ApiOrderService(auth.apiClient).getAllOrders(products);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: AppBar(
        leading: Builder(builder: (context) => IconButton(icon: const Icon(Icons.menu), onPressed: () => Scaffold.of(context).openDrawer())),
        title: const Text('Quan ly don hang'),
      ),
      drawer: const AppDrawer(currentRoute: '/orders'),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: FutureBuilder<List<OrderModel>>(
          future: _loadOrders(),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) return const Center(child: CircularProgressIndicator());
            if (snapshot.hasError) return Center(child: Text('Loi: ${snapshot.error}'));
            final orders = snapshot.data ?? [];
            if (orders.isEmpty) return const Center(child: Text('Chua co don hang nao duoc tao'));
            return ListView.builder(
              itemCount: orders.length,
              itemBuilder: (context, index) => OrderCard(order: orders[index]),
            );
          },
        ),
      ),
    );
  }
}
