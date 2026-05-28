import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/request_provider.dart';
import '../../models/order_request.dart';
import 'package:intl/intl.dart';

import '../../providers/cart_provider.dart';
import '../../models/product.dart';

class RequestListScreen extends StatelessWidget {
  const RequestListScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Yêu cầu từ khách'),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        elevation: 0.5,
      ),
      body: Consumer<RequestProvider>(
        builder: (context, provider, child) {
          final requests = provider.requests;
          if (requests.isEmpty) {
            return const Center(child: Text('Không có yêu cầu mới'));
          }
          return ListView.builder(
            itemCount: requests.length,
            itemBuilder: (context, index) {
              final request = requests[index];
              return _buildRequestCard(context, request, provider);
            },
          );
        },
      ),
    );
  }

  Future<void> _handleConfirm(BuildContext context, OrderRequest request, RequestProvider provider) async {
    final cartProvider = Provider.of<CartProvider>(context, listen: false);
    
    // If it's an order request, add items to the table's cart
    if (request.type == RequestType.order && request.items != null) {
      for (var item in request.items!) {
        // We need a proper Product object, but for now we add what we have
        await cartProvider.addItem(request.tableId, Product(
          id: item.productId,
          name: item.productName,
          price: 0, // In real scenario, price would be fetched from ProductProvider
        ), quantity: item.quantity);
      }
      
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Đã thêm món vào bàn ${request.tableName}')),
        );
      }
    }

    provider.updateRequestStatus(request.id, RequestStatus.confirmed);
  }

  Widget _buildRequestCard(BuildContext context, OrderRequest request, RequestProvider provider) {
    Color typeColor = Colors.blue;
    String typeText = 'Gọi món';
    if (request.type == RequestType.callStaff) {
      typeColor = Colors.orange;
      typeText = 'Gọi nhân viên';
    } else if (request.type == RequestType.payment) {
      typeColor = Colors.green;
      typeText = 'Thanh toán';
    }

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                  decoration: BoxDecoration(color: typeColor.withOpacity(0.1), borderRadius: BorderRadius.circular(20)),
                  child: Text(typeText, style: TextStyle(color: typeColor, fontWeight: FontWeight.bold, fontSize: 12)),
                ),
                Text(DateFormat('HH:mm').format(request.createdAt), style: const TextStyle(color: Colors.grey, fontSize: 12)),
              ],
            ),
            const SizedBox(height: 12),
            Text('Bàn: ${request.tableName}', style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            if (request.items != null && request.items!.isNotEmpty) ...[
              const SizedBox(height: 8),
              const Divider(),
              ...request.items!.map((item) => Padding(
                padding: const EdgeInsets.symmetric(vertical: 2),
                child: Row(
                  children: [
                    Text('${item.quantity}x ', style: const TextStyle(fontWeight: FontWeight.bold)),
                    Expanded(child: Text(item.productName)),
                  ],
                ),
              )),
            ],
            if (request.note != null && request.note!.isNotEmpty) ...[
              const SizedBox(height: 8),
              Text('Ghi chú: ${request.note}', style: const TextStyle(fontStyle: FontStyle.italic, color: Colors.grey)),
            ],
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: () => provider.updateRequestStatus(request.id, RequestStatus.cancelled),
                    child: const Text('Từ chối'),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: ElevatedButton(
                    onPressed: () => _handleConfirm(context, request, provider),
                    style: ElevatedButton.styleFrom(backgroundColor: Colors.blue),
                    child: const Text('Xác nhận', style: TextStyle(color: Colors.white)),
                  ),
                ),
              ],
            )
          ],
        ),
      ),
    );
  }
}
