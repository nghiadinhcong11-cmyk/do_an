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
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.shopping_cart_outlined, size: 64, color: Colors.grey.shade400),
                  const SizedBox(height: 16),
                  const Text('Chưa có món nào trong danh sách.', style: TextStyle(color: Colors.grey)),
                  const SizedBox(height: 24),
                  ElevatedButton(
                    onPressed: () => Navigator.pop(context),
                    child: const Text('Quay lại chọn món'),
                  ),
                ],
              ),
            )
          : Column(
              children: [
                Expanded(
                  child: ListView.builder(
                    padding: const EdgeInsets.all(16.0),
                    itemCount: currentCart.length,
                    itemBuilder: (context, index) {
                      final item = currentCart[index];
                      return Card(
                        margin: const EdgeInsets.only(bottom: 12),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        elevation: 0,
                        borderOnForeground: true,
                        side: BorderSide(color: Colors.grey.shade200),
                        child: Padding(
                          padding: const EdgeInsets.all(12.0),
                          child: Row(
                            children: [
                              Container(
                                width: 50,
                                height: 50,
                                decoration: BoxDecoration(
                                  color: Colors.blue.shade50,
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: const Icon(Icons.restaurant, color: Colors.blue),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(item.product.name, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                                    Text(AppFormat.money(item.product.price), style: TextStyle(color: Colors.blue.shade700, fontWeight: FontWeight.w500)),
                                  ],
                                ),
                              ),
                              Row(
                                children: [
                                  IconButton(
                                    icon: const Icon(Icons.remove_circle_outline, color: Colors.grey),
                                    onPressed: () => cartProvider.updateQuantity(widget.tableId, item.product.id, -1),
                                  ),
                                  Text('${item.quantity}', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                                  IconButton(
                                    icon: const Icon(Icons.add_circle_outline, color: Colors.blue),
                                    onPressed: () => cartProvider.updateQuantity(widget.tableId, item.product.id, 1),
                                  ),
                                  const SizedBox(width: 4),
                                  IconButton(
                                    icon: const Icon(Icons.delete_outline, color: Colors.red),
                                    onPressed: () => cartProvider.removeFromCart(widget.tableId, item.product.id),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
                ),
                _buildSummarySection(cartProvider, totalPrice),
              ],
            ),
    );
  }

  Widget _buildSummarySection(CartProvider cartProvider, double total) {
    final subTotal = cartProvider.getSubTotalPriceByTable(widget.tableId);
    final vat = cartProvider.getVatByTable(widget.tableId);

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10, offset: const Offset(0, -4))],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text('Tạm tính', style: TextStyle(color: Colors.grey)),
              Text(AppFormat.money(subTotal)),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text('Thuế VAT (3%)', style: TextStyle(color: Colors.grey)),
              Text(AppFormat.money(vat)),
            ],
          ),
          const Divider(height: 24),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text('TỔNG CỘNG', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
              Text(AppFormat.money(total), style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 20, color: Colors.redAccent)),
            ],
          ),
          const SizedBox(height: 20),
          SizedBox(
            width: double.infinity,
            height: 54,
            child: ElevatedButton(
              onPressed: _isProcessing ? null : () => _processFinalPayment(cartProvider),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.green.shade600,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                elevation: 0,
              ),
              child: _isProcessing
                  ? const CircularProgressIndicator(color: Colors.white)
                  : const Text('XÁC NHẬN THANH TOÁN', style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold)),
            ),
          ),
        ],
      ),
    );
  }
    );
  }
}
