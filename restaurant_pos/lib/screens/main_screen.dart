import 'package:flutter/material.dart';
import '../widgets/common/app_drawer.dart';
import 'home/home_screen.dart';
import 'tables/table_management_screen.dart';
import 'order/order_management_screen.dart';
import 'history/history_screen.dart';
import 'settings/store_settings_screen.dart';

class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  int _selectedIndex = 0;

  List<Widget> _getScreens(AuthProvider auth) {
    if (auth.isOwner) {
      return [
        const HomeScreen(),
        const TableManagementScreen(),
        const OrderManagementScreen(),
        const StatisticsScreen(),
        const StoreSettingsScreen(),
      ];
    } else if (auth.isStaff) {
      return [
        const HomeScreen(),
        const TableManagementScreen(),
        const OrderManagementScreen(),
        const HistoryScreen(),
        const StoreSettingsScreen(),
      ];
    } else {
      // For Guests
      return [
        const HomeScreen(),
        const TableManagementScreen(), // Limited view
        const HistoryScreen(), // Maybe empty
        const StoreSettingsScreen(), // Limited or hidden
      ];
    }
  }

  List<String> _getRoutes(AuthProvider auth) {
    if (auth.isOwner) {
      return ['/home', '/table_management', '/orders', '/statistics', '/store-settings'];
    } else if (auth.isStaff) {
      return ['/home', '/table_management', '/orders', '/history', '/store-settings'];
    } else {
      return ['/home', '/table_management', '/history', '/store-settings'];
    }
  }

  @override
  Widget build(BuildContext context) {
    final auth = Provider.of<AuthProvider>(context);
    final screens = _getScreens(auth);
    final routes = _getRoutes(auth);

    return Scaffold(
      drawer: AppDrawer(currentRoute: routes.length > _selectedIndex ? routes[_selectedIndex] : '/home'),
      body: IndexedStack(
        index: _selectedIndex < screens.length ? _selectedIndex : 0,
        children: screens,
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedIndex < screens.length ? _selectedIndex : 0,
        onTap: (index) {
          setState(() {
            _selectedIndex = index;
          });
        },
        type: BottomNavigationBarType.fixed,
        backgroundColor: Colors.white,
        selectedItemColor: Colors.blue.shade700,
        unselectedItemColor: Colors.grey.shade600,
        selectedLabelStyle: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12),
        unselectedLabelStyle: const TextStyle(fontSize: 12),
        items: _buildBottomNavItems(auth),
      ),
    );
  }

  List<BottomNavigationBarItem> _buildBottomNavItems(AuthProvider auth) {
    if (auth.isGuest) {
      return const [
        BottomNavigationBarItem(icon: Icon(Icons.home_outlined), activeIcon: Icon(Icons.home), label: 'Trang chủ'),
        BottomNavigationBarItem(icon: Icon(Icons.table_restaurant_outlined), activeIcon: Icon(Icons.table_restaurant), label: 'Sơ đồ bàn'),
        BottomNavigationBarItem(icon: Icon(Icons.history_outlined), activeIcon: Icon(Icons.history), label: 'Lịch sử'),
        BottomNavigationBarItem(icon: Icon(Icons.settings_outlined), activeIcon: Icon(Icons.settings), label: 'Cài đặt'),
      ];
    }

    return [
      const BottomNavigationBarItem(icon: Icon(Icons.home_outlined), activeIcon: Icon(Icons.home), label: 'Trang chủ'),
      const BottomNavigationBarItem(icon: Icon(Icons.table_restaurant_outlined), activeIcon: Icon(Icons.table_restaurant), label: 'Phòng bàn'),
      const BottomNavigationBarItem(icon: Icon(Icons.receipt_long_outlined), activeIcon: Icon(Icons.receipt_long), label: 'Đơn hàng'),
      BottomNavigationBarItem(
        icon: Icon(auth.isOwner ? Icons.bar_chart_outlined : Icons.history_outlined),
        activeIcon: Icon(auth.isOwner ? Icons.bar_chart : Icons.history),
        label: auth.isOwner ? 'Thống kê' : 'Lịch sử',
      ),
      const BottomNavigationBarItem(icon: Icon(Icons.settings_outlined), activeIcon: Icon(Icons.settings), label: 'Cài đặt'),
    ];
  }
}
