import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/auth_provider.dart';
import '../../widgets/common/app_drawer.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final auth = Provider.of<AuthProvider>(context);

    return Scaffold(
      backgroundColor: Colors.grey.shade50,
      appBar: AppBar(
        leading: Builder(
          builder: (context) => IconButton(
            icon: const Icon(Icons.menu, color: Colors.black87),
            onPressed: () => Scaffold.of(context).openDrawer(),
          ),
        ),
        title: const Text('Tài khoản cá nhân', style: TextStyle(color: Colors.black87, fontWeight: FontWeight.bold)),
        backgroundColor: Colors.white,
        elevation: 0.5,
        centerTitle: true,
      ),
      drawer: const AppDrawer(currentRoute: '/profile'),
      body: SingleChildScrollView(
鼓        padding: const EdgeInsets.all(20.0),
        child: Column(
          children: [
            const SizedBox(height: 20),
            const CircleAvatar(
              radius: 50,
              backgroundColor: Colors.blue,
              child: Icon(Icons.person, size: 50, color: Colors.white),
            ),
            const SizedBox(height: 16),
            Text(
              auth.userName ?? 'Người dùng',
              style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
            ),
            Text(
              _getRoleText(auth),
              style: TextStyle(fontSize: 14, color: Colors.grey.shade600),
            ),
            const SizedBox(height: 32),
            _buildInfoCard(context, auth),
            const SizedBox(height: 40),
            SizedBox(
              width: double.infinity,
              height: 52,
              child: ElevatedButton.icon(
                onPressed: () {
                  auth.logout();
                  Navigator.of(context).pushNamedAndRemoveUntil('/', (route) => false);
                },
                icon: const Icon(Icons.logout),
                label: const Text('Đăng xuất', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.red.shade600,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  elevation: 0,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _getRoleText(AuthProvider auth) {
    if (auth.isSuperAdmin) return 'Quản trị viên hệ thống';
    if (auth.isOwner) return 'Chủ cửa hàng';
    if (auth.isStaff) return 'Nhân viên vận hành';
    if (auth.isCustomer) return 'Khách hàng thân thiết';
    return 'Khách vãng lai';
  }

  Widget _buildInfoCard(BuildContext context, AuthProvider auth) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.black12),
      ),
      child: Column(
        children: [
          _buildInfoRow(Icons.badge_outlined, 'Mã định danh', auth.userId ?? 'N/A'),
          const Divider(height: 24),
          _buildInfoRow(Icons.restaurant_outlined, 'Mã nhà hàng', auth.restaurantId ?? 'N/A'),
          if (auth.branchId != null) ...[
            const Divider(height: 24),
            _buildInfoRow(Icons.location_city_outlined, 'Chi nhánh', auth.branchId!),
          ],
        ],
      ),
    );
  }

  Widget _buildInfoRow(IconData icon, String label, String value) {
    return Row(
      children: [
        Icon(icon, size: 20, color: Colors.blue.shade700),
        const SizedBox(width: 12),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(label, style: const TextStyle(fontSize: 12, color: Colors.grey)),
            Text(value, style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w500)),
          ],
        ),
      ],
    );
  }
}
