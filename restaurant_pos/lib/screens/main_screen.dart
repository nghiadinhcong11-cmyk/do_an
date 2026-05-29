import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/auth_provider.dart';
import '../widgets/common/app_drawer.dart';
import 'home/home_screen.dart';
import 'tables/table_management_screen.dart';
import 'order/order_management_screen.dart';
import 'history/history_screen.dart';
import 'settings/store_settings_screen.dart';
import 'settings/profile_screen.dart';
import 'statistics/statistics_screen.dart';

class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  int _selectedIndex = 0;

  List<Widget> _getScreens(AuthProvider auth) {
    if (auth.isSuperAdmin) {
      return [
        const Center(child: Text('Hệ thống Quản trị Tổng (Chỉ dành cho Web)', style: TextStyle(fontSize: 24))),
        const Center(child: Text('Quản lý danh sách Nhà hàng')),
        const Center(child: Text('Quản lý người dùng hệ thống')),
        const Center(child: Text('Cấu hình hệ thống')),
        const StoreSettingsScreen(),
      ];
    }
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
        const ProfileScreen(),
      ];
    } else {
      // For Guests
      return [
        const HomeScreen(),
        const TableManagementScreen(), // Limited view
        const HistoryScreen(), // Maybe empty
        const ProfileScreen(),
      ];
    }
  }

  List<String> _getRoutes(AuthProvider auth) {
    if (auth.isOwner) {
      return ['/home', '/table_management', '/orders', '/statistics', '/store-settings'];
    } else if (auth.isStaff) {
      return ['/home', '/table_management', '/orders', '/history', '/profile'];
    } else {
      return ['/home', '/table_management', '/history', '/profile'];
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
    if (auth.isSuperAdmin) {
      return const [
        BottomNavigationBarItem(icon: Icon(Icons.dashboard_customize), label: 'Tổng quan'),
        BottomNavigationBarItem(icon: Icon(Icons.storefront), label: 'Nhà hàng'),
        BottomNavigationBarItem(icon: Icon(Icons.people_alt_outlined), label: 'Người dùng'),
        BottomNavigationBarItem(icon: Icon(Icons.admin_panel_settings_outlined), label: 'Hệ thống'),
        BottomNavigationBarItem(icon: Icon(Icons.settings), label: 'Cài đặt'),
      ];
    }
    if (auth.isGuest) {
      return const [
        BottomNavigationBarItem(icon: Icon(Icons.home_outlined), activeIcon: Icon(Icons.home), label: 'Trang chủ'),
        BottomNavigationBarItem(icon: Icon(Icons.table_restaurant_outlined), activeIcon: Icon(Icons.table_restaurant), label: 'Sơ đồ bàn'),
        BottomNavigationBarItem(icon: Icon(Icons.history_outlined), activeIcon: Icon(Icons.history), label: 'Lịch sử'),
        BottomNavigationBarItem(icon: Icon(Icons.person_outline), activeIcon: Icon(Icons.person), label: 'Tài khoản'),
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
      BottomNavigationBarItem(
        icon: Icon(auth.isOwner ? Icons.settings_outlined : Icons.person_outline), 
        activeIcon: Icon(auth.isOwner ? Icons.settings : Icons.person), 
        label: auth.isOwner ? 'Cài đặt' : 'Tài khoản',
      ),
    ];
  }
}
