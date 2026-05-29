import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter/foundation.dart'; // Thêm để kiểm tra kIsWeb
import '../../providers/auth_provider.dart';
import '../../providers/table_provider.dart';
import '../../providers/cart_provider.dart';
import '../../providers/request_provider.dart';
import '../../models/order_request.dart';
import '../../services/api/auth_api_service.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  bool _obscurePassword = true;
  bool _isLoading = false;
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final AuthApiService _authApiService = AuthApiService();

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _handleLogin() async {
    final email = _emailController.text.trim();
    final password = _passwordController.text.trim();

    if (email.isEmpty || password.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Vui long nhap day du thong tin'), backgroundColor: Colors.orange),
      );
      return;
    }

    setState(() => _isLoading = true);

    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final tableProvider = Provider.of<TableProvider>(context, listen: false);
    final cartProvider = Provider.of<CartProvider>(context, listen: false);
    final requestProvider = Provider.of<RequestProvider>(context, listen: false);
    final messenger = ScaffoldMessenger.of(context);
    final navigator = Navigator.of(context);

    try {
      final session = await _authApiService.login(username: email, password: password);
      
      // Kiểm tra nếu là Admin tổng mà đăng nhập trên App (Mobile)
      final bool isSystemAdmin = session.role.toLowerCase() == 'admin' || session.role.toLowerCase() == 'superadmin';
      if (isSystemAdmin && !kIsWeb) {
        if (mounted) {
          setState(() => _isLoading = false);
          messenger.showSnackBar(
            const SnackBar(content: Text('Tài khoản Admin chỉ có thể đăng nhập trên trình duyệt Web'), backgroundColor: Colors.orange),
          );
        }
        return;
      }

      final userId = '${session.restaurantId}:${session.username}';
      authProvider.loginWithSession(userId: userId, session: session);
      
      tableProvider.initRealtime(
        session.token, 
        session.restaurantId,
        onRequestReceived: (requestJson) {
          requestProvider.addRequest(OrderRequest.fromJson(requestJson));
          // Optionally show a local notification or snackbar
        },
      );

      await tableProvider.fetchAndSetTables(userId);
      await cartProvider.loadAllCarts(userId);

      if (!mounted) return;
      messenger.showSnackBar(
        SnackBar(content: Text('Dang nhap thanh cong: ${session.username}'), backgroundColor: Colors.green),
      );
      navigator.pushReplacementNamed('/home');
    } catch (e) {
      if (mounted) {
        messenger.showSnackBar(
          SnackBar(content: Text('Dang nhap that bai: $e'), backgroundColor: Colors.red),
        );
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0.5,
        title: const Text('Đăng nhập', style: TextStyle(color: Colors.black87, fontSize: 20)),
      ),
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 400),
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 24.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                const SizedBox(height: 40),
                Container(
                  width: 120,
                  height: 120,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(24),
                    image: const DecorationImage(image: AssetImage('assets/images/logo.png'), fit: BoxFit.cover),
                  ),
                ),
                const SizedBox(height: 16),
                const Text('FokaPOS', style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold, color: Colors.black87)),
                const Text('Quản lý quán ăn & cafe', style: TextStyle(fontSize: 15, color: Colors.grey)),
                const SizedBox(height: 32),
                TextField(
                  controller: _emailController,
                  keyboardType: TextInputType.emailAddress,
                  decoration: InputDecoration(
                    labelText: 'Tên đăng nhập / Email',
                    prefixIcon: const Icon(Icons.person_outline),
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: _passwordController,
                  obscureText: _obscurePassword,
                  decoration: InputDecoration(
                    labelText: 'Mật khẩu',
                    prefixIcon: const Icon(Icons.lock_outline),
                    suffixIcon: IconButton(
                      icon: Icon(_obscurePassword ? Icons.visibility_outlined : Icons.visibility_off_outlined),
                      onPressed: () => setState(() => _obscurePassword = !_obscurePassword),
                    ),
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                ),
                const SizedBox(height: 24),
                SizedBox(
                  width: double.infinity,
                  height: 52,
                  child: ElevatedButton.icon(
                    onPressed: _isLoading ? null : _handleLogin,
                    icon: _isLoading
                        ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                        : const Icon(Icons.login, color: Colors.white),
                    label: const Text('Đăng nhập', style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold)),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.green.shade600,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      elevation: 0,
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    const Expanded(child: Divider()),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      child: Text('Hoặc', style: TextStyle(color: Colors.grey.shade600)),
                    ),
                    const Expanded(child: Divider()),
                  ],
                ),
                const SizedBox(height: 16),
                TextButton(
                  onPressed: () {
                    // Xử lý vào thẳng với tư cách Khách vãng lai
                    Provider.of<AuthProvider>(context, listen: false).logout(); // Đảm bảo trạng thái sạch
                    Navigator.pushReplacementNamed(context, '/home');
                  },
                  child: Text('Vào với tư cách Khách vãng lai', style: TextStyle(color: Colors.blue.shade700, fontWeight: FontWeight.bold, decoration: TextDecoration.underline)),
                ),
                const SizedBox(height: 12),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: Text(
                    'Để đăng ký tài khoản mới, vui lòng truy cập website quản trị của chúng tôi.',
                    textAlign: TextAlign.center,
                    style: TextStyle(color: Colors.grey.shade500, fontSize: 12, fontStyle: FontStyle.italic),
                  ),
                ),
                const SizedBox(height: 40),
             ],
            ),
          ),
        ),
      ),
    );
  }
}
