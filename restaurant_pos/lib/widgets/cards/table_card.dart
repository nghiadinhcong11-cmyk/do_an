import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../models/table_model.dart';
import '../../core/utils/app_format.dart';
import '../../screens/menu/menu_screen.dart';
import '../../screens/order/order_screen.dart';
import '../../core/enums/table_status.dart';
import '../../providers/table_provider.dart';
import '../../providers/auth_provider.dart';

class TableCard extends StatelessWidget {
  final DiningTable table;
  const TableCard({super.key, required this.table});

  @override
  Widget build(BuildContext context) {
    final auth = Provider.of<AuthProvider>(context, listen: false);
    Color statusColor =
        table.status == TableStatus.empty ? Colors.orange : Colors.teal;

    return Container(
      margin: const EdgeInsets.only(bottom: 16.0),
      padding: const EdgeInsets.all(16.0),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: const [
          BoxShadow(
            color: Colors.black12,
            blurRadius: 4,
          ),
        ],
      ),
      child: Column(
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    table.name,
                    style: const TextStyle(
                      color: Color(0xFF1E88E5),
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '${table.seats} ghế',
                    style: const TextStyle(color: Colors.grey, fontSize: 14),
                  ),
                ],
              ),
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
                decoration: BoxDecoration(
                  color: statusColor,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  AppFormat.tableStatusLabel(table.status),
                  style: const TextStyle(color: Colors.white, fontSize: 13),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              if (table.status == TableStatus.occupied)
                _buildButton('Xem hóa đơn', Colors.green.shade50, Colors.green, () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => OrderScreen(
                        tableId: table.id.toString(),
                        tableName: table.name,
                      ),
                    ),
                  );
                }),
              if (table.status == TableStatus.occupied) const SizedBox(width: 8),
              _buildButton('Thêm món', Colors.blue.shade50, Colors.blue, () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => MenuScreen(
                      tableId: table.id.toString(),
                      tableName: table.name,
                    ),
                  ),
                );
              }),
              if (auth.isOwner) ...[
                const SizedBox(width: 12),
                _buildButton('Sửa', Colors.grey.shade200, Colors.black87, () {}),
                const SizedBox(width: 12),
                _buildButton('Xóa', Colors.red.shade50, Colors.red, () {
                  showDialog(
                    context: context,
                    builder: (ctx) => AlertDialog(
                      title: const Text('Xác nhận xóa'),
                      content: Text('Bạn có chắc muốn xóa ${table.name}?'),
                      actions: [
                        TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Hủy')),
                        TextButton(
                          onPressed: () {
                            Provider.of<TableProvider>(context, listen: false).deleteTable(table.id);
                            Navigator.pop(ctx);
                          }, 
                          child: const Text('Xóa', style: TextStyle(color: Colors.red))
                        ),
                      ],
                    )
                  );
                }),
              ],
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildButton(
      String text, Color bgColor, Color textColor, VoidCallback onTap) {
    return TextButton(
      onPressed: onTap,
      style: TextButton.styleFrom(
        backgroundColor: bgColor,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      ),
      child: Text(text,
          style: TextStyle(color: textColor, fontWeight: FontWeight.bold)),
    );
  }
}
