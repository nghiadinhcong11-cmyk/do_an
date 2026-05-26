import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../database/database_helper.dart';
import '../../widgets/common/app_drawer.dart';
import '../../core/utils/app_format.dart';
import '../../providers/auth_provider.dart';
import '../../services/sync_service.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final DatabaseHelper _dbHelper = DatabaseHelper.instance;
  bool _isSyncing = false;

  double _todayRevenue = 0;
  int _todayOrdersCount = 0;
  int _activeTablesCount = 0;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadDashboardData();
  }

  Future<void> _handleSync() async {
    final auth = Provider.of<AuthProvider>(context, listen: false);
    if (auth.token == null) return;

    setState(() => _isSyncing = true);
    try {
      final syncService = SyncService(auth.apiClient);
      final count = await syncService.syncOrders();
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Ð? ð?ng b? thành công $count ðõn hàng'), backgroundColor: Colors.green));
        _loadDashboardData();
      }
    } catch (e) {
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('L?i ð?ng b?: $e'), backgroundColor: Colors.red));
    } finally {
      if (mounted) setState(() => _isSyncing = false);
    }
  }

  Future<void> _loadDashboardData() async {
    try {
      final orders = await _dbHelper.getAllOrders();
      final tables = await _dbHelper.getAllTablesFromDb();

      double revenue = 0;
      int orderCount = 0;
      String today = DateTime.now().toIso8601String().substring(0, 10);

      for (var o in orders) {
        if (o['date_time'].toString().startsWith(today)) {
          revenue += (o['total_amount'] as num).toDouble();
          orderCount++;
        }
      }

      int activeTables = tables.where((t) => t['status'] == 'CO_KHACH').length;

      if (mounted) {
        setState(() {
          _todayRevenue = revenue;
          _todayOrdersCount = orderCount;
          _activeTablesCount = activeTables;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final auth = Provider.of<AuthProvider>(context);
    
    return Scaffold(
      backgroundColor: Colors.grey.shade50,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        title: const Text('FokaPOS', style: TextStyle(color: Colors.black87, fontWeight: FontWeight.bold)),
        actions: [
          if (auth.token != null)
            IconButton(
              icon: _isSyncing 
                ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2))
                : const Icon(Icons.cloud_upload_outlined, color: Colors.blue),
              onPressed: _isSyncing ? null : _handleSync,
            ),
        ],
      ),
      drawer: const AppDrawer(currentRoute: '/home'),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : RefreshIndicator(
              onRefresh: _loadDashboardData,
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  children: [
                    _buildStatusCard(auth),
                    const SizedBox(height: 16),
                    _buildStatRow(),
                    const SizedBox(height: 24),
                    _buildActionGrid(context),
                  ],
                ),
              ),
            ),
    );
  }

  Widget _buildStatusCard(AuthProvider auth) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.blue.shade600,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [BoxShadow(color: Colors.blue.withValues(alpha: 0.3), blurRadius: 10, offset: const Offset(0, 4))],
      ),
      child: Row(
        children: [
          const CircleAvatar(backgroundColor: Colors.white24, child: Icon(Icons.person, color: Colors.white)),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(auth.userName ?? 'Nhân viên', style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16)),
                Text(auth.token != null ? 'H? th?ng tr?c tuy?n' : 'Ch? ð? ngo?i tuy?n', style: const TextStyle(color: Colors.white70, fontSize: 12)),
              ],
            ),
          ),
          if (_activeTablesCount > 0)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
              decoration: BoxDecoration(color: Colors.orange, borderRadius: BorderRadius.circular(20)),
              child: Text('$_activeTablesCount bàn m?', style: const TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.bold)),
            )
        ],
      ),
    );
  }

  Widget _buildStatRow() {
    return Row(
      children: [
        _buildSmallStat('Ðõn hàng', '$_todayOrdersCount', Colors.blue),
        const SizedBox(width: 12),
        _buildSmallStat('Doanh thu', AppFormat.money(_todayRevenue), Colors.green),
      ],
    );
  }

  Widget _buildSmallStat(String title, String value, Color color) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(16), border: Border.all(color: Colors.black12)),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(title, style: const TextStyle(color: Colors.grey, fontSize: 12)),
            const SizedBox(height: 4),
            Text(value, style: TextStyle(color: color, fontSize: 18, fontWeight: FontWeight.bold)),
          ],
        ),
      ),
    );
  }

  Widget _buildActionGrid(BuildContext context) {
    return GridView.count(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      crossAxisCount: 2,
      mainAxisSpacing: 16,
      crossAxisSpacing: 16,
      childAspectRatio: 1.1,
      children: [
        _buildActionButton(context, 'Bán hàng', Icons.grid_view_rounded, Colors.indigo, '/table_management'),
        _buildActionButton(context, 'Hóa ðõn', Icons.receipt_long_outlined, Colors.teal, '/orders'),
        _buildActionButton(context, 'Nh?p kho', Icons.add_shopping_cart_rounded, Colors.orange, '/expenses'),
        _buildActionButton(context, 'Th?c ðõn', Icons.restaurant_menu_rounded, Colors.pink, '/menu'),
      ],
    );
  }

  Widget _buildActionButton(BuildContext context, String label, IconData icon, Color color, String route) {
    return InkWell(
      onTap: () => Navigator.pushNamed(context, route).then((_) => _loadDashboardData()),
      child: Container(
        decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(20), border: Border.all(color: Colors.black12)),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, color: color, size: 32),
            const SizedBox(height: 12),
            Text(label, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
          ],
        ),
      ),
    );
  }
}
