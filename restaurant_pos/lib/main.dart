import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:restaurant_pos/screens/main_screen.dart';
import 'package:restaurant_pos/screens/login/register_screen.dart';
import 'package:restaurant_pos/screens/order/request_list_screen.dart';
import 'package:restaurant_pos/screens/settings/store_settings_screen.dart';
import 'package:restaurant_pos/screens/settings/profile_screen.dart';
import 'providers/table_provider.dart';
import 'providers/cart_provider.dart';
import 'providers/order_provider.dart';
import 'screens/login/login_screen.dart';
import 'screens/home/home_screen.dart';
import 'screens/tables/table_management_screen.dart';
import 'screens/order/order_management_screen.dart';
import 'screens/menu/product_management_screen.dart';
import 'screens/expenses/expense_screen.dart';
import 'screens/statistics/statistics_screen.dart';
import 'screens/history/history_screen.dart';
import 'providers/auth_provider.dart';
import 'providers/request_provider.dart';
import 'providers/product_provider.dart';
import 'services/api/api_product_service.dart';
import 'services/api/api_table_service.dart';
import 'services/table_service.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AuthProvider()),
        ChangeNotifierProvider(create: (_) => RequestProvider()),
        ProxyProvider<AuthProvider, TableService>(
          update: (_, auth, __) => ApiTableService(auth.apiClient),
        ),
        ChangeNotifierProxyProvider<TableService, TableProvider>(
          create: (_) => TableProvider(),
          update: (_, service, provider) => provider!..setService(service),
        ),
        ProxyProvider<AuthProvider, ApiProductService>(
          update: (_, auth, __) => ApiProductService(auth.apiClient),
        ),
        ChangeNotifierProxyProvider<ApiProductService, ProductProvider>(
          create: (_) => ProductProvider(),
          update: (_, service, provider) => provider!..setApiService(service),
        ),
        ChangeNotifierProvider(create: (_) => CartProvider()),
        ChangeNotifierProvider(create: (_) => OrderProvider()),
      ],
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'FokaPOS',
      initialRoute: '/',
      routes: {
        '/': (context) => const LoginScreen(),
        '/home': (context) => const MainScreen(),
        '/table_management': (context) => const TableManagementScreen(),
        '/orders': (context) => const OrderManagementScreen(),
        '/menu': (context) => const ProductManagementScreen(),
        '/expenses': (context) => const ExpenseScreen(),
        '/statistics': (context) => const StatisticsScreen(),
        '/history': (context) => const HistoryScreen(),
        '/register': (context) => const RegisterScreen(),
        '/store-settings': (context) => const StoreSettingsScreen(),
        '/profile': (context) => const ProfileScreen(),
        '/requests': (context) => const RequestListScreen(),
      },
    );
  }
}
