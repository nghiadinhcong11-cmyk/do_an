import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/enums/table_status.dart';
import '../../core/utils/app_format.dart';
import '../../providers/cart_provider.dart';
import '../../providers/table_provider.dart';
import '../../providers/auth_provider.dart';
import '../../database/database_helper.dart';
import '../../models/order.dart';
import '../../models/order_item.dart';
import '../../services/api/api_order_service.dart';
import '../../services/api/api_restaurant_service.dart';
import 'package:qr_flutter/qr_flutter.dart';

class OrderScreen extends StatefulWidget {
  final String tableId;
  final String tableName;

  const OrderScreen({super.key, required this.tableId, required this.tableName});

  @override
  State<OrderScreen> createState() => _OrderScreenState();
}

class _OrderScreenState extends State<OrderScreen> {
  bool _isProcessing = false;
  final DatabaseHelper _dbHelper = DatabaseHelper.instance;

  Future<void> _processFinalPayment(CartProvider cartProvider) async {
    final auth = Provider.of<AuthProvider>(context, listen: false);
    final totalPrice = cartProvider.getTableTotalPrice(widget.tableId);

    // 1. Show QR Payment Dialog
    final bool? confirmed = await _showPaymentQRDialog(auth, totalPrice);
    if (confirmed != true) return;

    setState(() => _isProcessing = true);
    try {
      final currentCart = cartProvider.getItemsByTable(widget.tableId);
      final orderItems = currentCart
          .map((cartItem) => OrderItem(product: cartItem.product, quantity: cartItem.quantity))
          .toList();

      final now = DateTime.now();
      final subTotal = cartProvider.getSubTotalPriceByTable(widget.tableId);
      final vatAmount = cartProvider.getVatByTable(widget.tableId);

      final order = OrderModel(
        tableId: widget.tableId,
        dateTime: now,
        invoiceNo: 'INV-${now.millisecondsSinceEpoch}',
        lookupCode: 'LKP-${now.microsecondsSinceEpoch}',
        subTotal: subTotal,
        vatAmount: vatAmount,
        totalAmount: totalPrice,
        type: widget.tableId == 'mang_di' ? 'takeaway' : 'dine_in',
        status: 'paid',
        itemCount: orderItems.fold<int>(0, (sum, item) => sum + item.quantity),
        items: orderItems,
      );

      await ApiOrderService(auth.apiClient).createOrder(order);

      // 2. Success: Clear cart and set table EMPTY
      await cartProvider.clearTableCart(widget.tableId);
      if (mounted) {
        await Provider.of<TableProvider>(context, listen: false)
            .updateTableStatus(widget.tableId, TableStatus.empty);
      }

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Thanh toán thành công bàn ${widget.tableName}!'), backgroundColor: Colors.green),
        );
        Navigator.popUntil(context, (route) => route.isFirst);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Lỗi thanh toán: $e'), backgroundColor: Colors.redAccent),
        );
      }
    } finally {
      if (mounted) setState(() => _isProcessing = false);
    }
  }

  Future<bool?> _showPaymentQRDialog(AuthProvider auth, double amount) async {
    setState(() => _isProcessing = true);
    
    // Luôn lấy thông tin ngân hàng mới nhất từ Server trước khi hiện QR
    try {
      final restaurantService = ApiRestaurantService(auth.apiClient);
      final info = await restaurantService.getMyRestaurantInfo();
      
      auth.updateBankInfo(
        code: info['bankCode']?.toString(),
        number: info['bankAccountNumber']?.toString(),
        name: info['bankAccountName']?.toString(),
      );
    } catch (e) {
      debugPrint('Không thể cập nhật thông tin ngân hàng: $e');
      // Nếu lỗi mạng, vẫn tiếp tục dùng thông tin cũ trong auth nếu có
    } finally {
      setState(() => _isProcessing = false);
    }

    String? bankCode = auth.bankCode;
    String? bankAccount = auth.bankAccountNumber;
    String? bankOwner = auth.bankAccountName;

    if (bankAccount == null || bankCode == null) {
      return showDialog<bool>(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text('Thiếu thông tin thanh toán'),
          content: const Text('Chủ quán chưa thiết lập tài khoản ngân hàng trên Web. Vui lòng thanh toán tiền mặt.'),
          actions: [
            TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('Hủy')),
            ElevatedButton(onPressed: () => Navigator.pop(context, true), child: const Text('Đã nhận tiền mặt')),
          ],
        ),
      );
    }

    final String vietQrUrl = 'https://img.vietqr.io/image/$bankCode-$bankAccount-compact.png?amount=${amount.toInt()}&addInfo=Thanh%20toan%20${widget.tableName}&accountName=${Uri.encodeComponent(bankOwner ?? '')}';

    return showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text('Quét mã thanh toán', textAlign: TextAlign.center, style: TextStyle(fontWeight: FontWeight.bold)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: Colors.grey.shade200),
              ),
              child: QrImageView(
                data: vietQrUrl,
                version: QrVersions.auto,
                size: 200.0,
              ),
            ),
            const SizedBox(height: 16),
            Text(AppFormat.money(amount), style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.redAccent)),
            const SizedBox(height: 8),
            Text('STK: $bankAccount', style: const TextStyle(fontWeight: FontWeight.w500)),
            Text('Ngân hàng: $bankCode', style: const TextStyle(color: Colors.grey)),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('Quay lại')),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(backgroundColor: Colors.green),
            child: const Text('Xác nhận đã trả tiền', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
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
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black87),
          onPressed: _isProcessing ? null : () => Navigator.pop(context),
        ),
        title: Text('Chi tiết hóa đơn - ${widget.tableName}', 
          style: const TextStyle(color: Colors.black87, fontSize: 18, fontWeight: FontWeight.bold)),
      ),
      body: currentCart.isEmpty
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.shopping_cart_outlined, size: 64, color: Colors.grey.shade400),
                  const SizedBox(height: 16),
                  const Text('Chưa có món nào.', style: TextStyle(color: Colors.grey)),
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
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                          side: BorderSide(color: Colors.grey.shade200),
                        ),
                        elevation: 0,
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
}
