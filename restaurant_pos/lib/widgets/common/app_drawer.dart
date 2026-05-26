import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/auth_provider.dart';

class AppDrawer extends StatelessWidget {
  final String currentRoute;

  const AppDrawer({super.key, required this.currentRoute});

  @override
  Widget build(BuildContext context) {
    final auth = Provider.of<AuthProvider>(context);

    return Drawer(
      backgroundColor: Colors.white,
      child: SafeArea(
        child: Column(
          children: [
            Container(
              padding: const EdgeInsets.all(20.0),
              width: double.infinity,
              decoration: const BoxDecoration(
                border: Border(bottom: BorderSide(color: Colors.black12, width: 0.5)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'FokaPOS Mobile',
                    style: TextStyle(fontSize: 18, color: Color(0xFF1E88E5), fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 4),
                  Text(auth.userName ?? 'Nhân viên vận hành',
                      style: const TextStyle(fontSize: 14, color: Colors.black87, fontWeight: FontWeight.w500)),
                  Text(auth.token != null ? 'Chế độ: Đám mây' : 'Chế độ: Ngoại tuyến',
                      style: const TextStyle(fontSize: 11, color: Colors.grey)),
                ],
              ),
            ),
            const SizedBox(height: 12),

            Expanded(
              child: ListView(
                padding: const EdgeInsets.symmetric(horizontal: 16.0),
                children: [
                  _buildDrawerItem(context, 'Trang chủ', '/home', Icons.home_rounded),
                  _buildDrawerItem(context, 'Bán hàng (Sơ đồ bàn)', '/table_management', Icons.table_restaurant_rounded),
                  _buildDrawerItem(context, 'Đơn hàng đang mở', '/orders', Icons.receipt_long_rounded),
                  _buildDrawerItem(context, 'Lịch sử thanh toán', '/history', Icons.history_rounded),
                  const Divider(),
                  _buildDrawerItem(context, 'Nhập hàng / Chi phí', '/expenses', Icons.account_balance_wallet_rounded),
                  _buildDrawerItem(context, 'Danh mục món ăn', '/menu', Icons.restaurant_menu_rounded),
                ],
              ),
            ),

            Padding(
              padding: const EdgeInsets.all(16.0),
              child: SizedBox(
                width: double.infinity,
                height: 48,
                child: OutlinedButton.icon(
                  onPressed: () {
                    Provider.of<AuthProvider>(context, listen: false).logout();
                    Navigator.pushReplacementNamed(context, '/');
                  },
                  icon: const Icon(Icons.logout, color: Colors.red, size: 18),
                  label: const Text('Đăng xuất', style: TextStyle(color: Colors.red, fontSize: 15)),
                  style: OutlinedButton.styleFrom(
                    side: const BorderSide(color: Colors.red),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDrawerItem(BuildContext context, String title, String routeName, IconData icon) {
    final bool isSelected = currentRoute == routeName;

    return Container(
      margin: const EdgeInsets.only(bottom: 4.0),
      decoration: BoxDecoration(
        color: isSelected ? Colors.blue.shade50 : Colors.transparent,
        borderRadius: BorderRadius.circular(8),
      ),
      child: ListTile(
        leading: Icon(icon, color: isSelected ? Colors.blue : Colors.black54, size: 22),
        title: Text(title, style: TextStyle(color: isSelected ? Colors.blue : Colors.black87, fontSize: 14, fontWeight: isSelected ? FontWeight.bold : FontWeight.normal)),
        onTap: () {
          Navigator.pop(context);
          if (!isSelected) {
            Navigator.pushReplacementNamed(context, routeName);
          }
        },
      ),
    );
  }
}
