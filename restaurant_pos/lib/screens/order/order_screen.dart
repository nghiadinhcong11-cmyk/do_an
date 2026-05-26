import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/utils/app_format.dart';
import '../../providers/cart_provider.dart';
import '../../providers/table_provider.dart';
import '../../providers/auth_provider.dart';
import '../../models/order.dart';
import '../../models/order_item.dart';
import '../../services/api/api_order_service.dart';

class OrderScreen extends StatefulWidget {
  final String tableId;
  final String tableName;

  const OrderScreen({super.key, required this.tableId, required this.tableName});

  @override
  State<OrderScreen> createState() => _OrderScreenState();
}

class _OrderScreenState extends State<OrderScreen> {
  bool _isProcessing = false;

  Future<void> _processFinalPayment(CartProvider cartProvider) async {
    final currentCart = cartProvider.getItemsByTable(widget.tableId);
    setState(() => _isProcessing = true);

    try {
      final orderItems = currentCart
          .map((cartItem) => OrderItem(product: cartItem.product, quantity: cartItem.quantity))
          .toList();

      final now = DateTime.now();
      final subTotal = orderItems.fold<double>(0, (sum, item) => sum + item.total);
      final vatAmount = subTotal * cartProvider.vatRate;
      final totalAmount = subTotal + vatAmount;

      final order = OrderModel(
        tableId: widget.tableId,
        dateTime: now,
        invoiceNo: 'INV-${now.millisecondsSinceEpoch}',
        lookupCode: 'LKP-${now.microsecondsSinceEpoch}',
        subTotal: subTotal,
        vatAmount: vatAmount,
        totalAmount: totalAmount,
        type: widget.tableId == 'mang_di' ? 'takeaway' : 'dine_in',
        status: 'paid',
        itemCount: orderItems.fold<int>(0, (sum, item) => sum + item.quantity),
        items: orderItems,
      );

      final auth = Provider.of<AuthProvider>(context, listen: false);
      await ApiOrderService(auth.apiClient).createOrder(order);

      await cartProvider.clearTableCart(widget.tableId);
      if (mounted) {
        await Provider.of<TableProvider>(context, listen: false).fetchAndSetTables(auth.userId ?? 'admin');
      }

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Thanh toan thanh cong ban ${widget.tableName}!'), backgroundColor: Colors.green),
        );
        Navigator.popUntil(context, (route) => route.isFirst);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Thanh toan that bai: $e'), backgroundColor: Colors.redAccent),
        );
      }
    } finally {
      if (mounted) setState(() => _isProcessing = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final cartProvider = Provider.of<CartProvider>(context);
    final currentCart = cartProvider.getItemsByTable(widget.tableId);
    final totalPrice = cartProvider.getTableTotalPrice(widget.tableId);

    return Scaffold(
      backgroundColor: Colors.grey.shade100,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0.5,
        leading: IconButton(icon: const Icon(Icons.arrow_back, color: Colors.black87), onPressed: _isProcessing ? null : () => Navigator.pop(context)),
        title: Text('Chi tiet hoa don - ${widget.tableName}', style: const TextStyle(color: Colors.black87, fontSize: 18, fontWeight: FontWeight.bold)),
      ),
      body: currentCart.isEmpty
          ? const Center(child: Text('Chua co mon nao trong danh sach.'))
          : Column(
              children: [
                Expanded(
                  child: ListView.builder(
                    padding: const EdgeInsets.all(16.0),
                    itemCount: currentCart.length,
                    itemBuilder: (context, index) {
                      final item = currentCart[index];
                      return ListTile(
                        title: Text(item.product.name),
                        subtitle: Text(AppFormat.money(item.product.price)),
                        trailing: Text(AppFormat.money(item.product.price * item.quantity)),
                      );
                    },
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(16),
                  child: SizedBox(
                    width: double.infinity,
                    height: 54,
                    child: ElevatedButton(
                      onPressed: _isProcessing ? null : () => _processFinalPayment(cartProvider),
                      child: _isProcessing
                          ? const SizedBox(width: 22, height: 22, child: CircularProgressIndicator(strokeWidth: 2.4, valueColor: AlwaysStoppedAnimation(Colors.white)))
                          : Text('Xac nhan Thanh toan ${AppFormat.money(totalPrice)}', style: const TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold)),
                    ),
                  ),
                ),
              ],
            ),
    );
  }
}
