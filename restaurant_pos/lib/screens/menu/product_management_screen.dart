import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../models/product.dart';
import '../../providers/auth_provider.dart';
import '../../providers/product_provider.dart';
import '../../widgets/cards/product_card.dart';
import '../../widgets/common/app_drawer.dart';

import '../../services/api/api_product_service.dart';

class ProductManagementScreen extends StatefulWidget {
  const ProductManagementScreen({super.key});

  @override
  State<ProductManagementScreen> createState() => _ProductManagementScreenState();
}

class _ProductManagementScreenState extends State<ProductManagementScreen> {
  Future<void> _refreshProducts() async {
    final auth = Provider.of<AuthProvider>(context, listen: false);
    await Provider.of<ProductProvider>(context, listen: false).fetchProducts(auth.userId ?? 'admin');
  }

  void _toggleProductStatus(Product product, String type, bool value) async {
    final auth = Provider.of<AuthProvider>(context, listen: false);
    final service = ApiProductService(auth.apiClient);
    try {
      if (type == 'availability') {
        await service.toggleAvailability(product.id, value);
      } else {
        await service.toggleBestSeller(product.id, value);
      }
      _refreshProducts();
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Lỗi: $e')));
      }
    }
  }

  void _showEditProductDialog(Product product) {
    final nameController = TextEditingController(text: product.name);
    final priceController = TextEditingController(text: product.price.toString());
    final costPriceController = TextEditingController(text: product.costPrice.toString());
    final categoryController = TextEditingController(text: product.category);

    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Sửa món ăn'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(controller: nameController, decoration: const InputDecoration(labelText: 'Tên món')),
              TextField(controller: priceController, decoration: const InputDecoration(labelText: 'Giá bán'), keyboardType: TextInputType.number),
              TextField(controller: costPriceController, decoration: const InputDecoration(labelText: 'Giá vốn'), keyboardType: TextInputType.number),
              TextField(controller: categoryController, decoration: const InputDecoration(labelText: 'Danh mục')),
            ],
          ),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(dialogContext), child: const Text('Hủy')),
          ElevatedButton(
            onPressed: () async {
              if (nameController.text.isEmpty || priceController.text.isEmpty) return;
              final provider = Provider.of<ProductProvider>(dialogContext, listen: false);
              final navigator = Navigator.of(dialogContext);
              await provider.updateProduct(Product(
                id: product.id,
                name: nameController.text.trim(),
                price: double.tryParse(priceController.text) ?? 0,
                costPrice: double.tryParse(costPriceController.text) ?? 0,
                category: categoryController.text.trim().isEmpty ? 'Khác' : categoryController.text.trim(),
                isAvailable: product.isAvailable,
                isBestSeller: product.isBestSeller,
              ));
              if (!mounted) return;
              navigator.pop();
              setState(() {});
            },
            child: const Text('Lưu'),
          ),
        ],
      ),
    );
  }
    final nameController = TextEditingController();
    final priceController = TextEditingController();
    final costPriceController = TextEditingController();
    final categoryController = TextEditingController();

    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Them mon moi'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(controller: nameController, decoration: const InputDecoration(labelText: 'Ten mon')),
              TextField(controller: priceController, decoration: const InputDecoration(labelText: 'Gia ban'), keyboardType: TextInputType.number),
              TextField(controller: costPriceController, decoration: const InputDecoration(labelText: 'Gia von'), keyboardType: TextInputType.number),
              TextField(controller: categoryController, decoration: const InputDecoration(labelText: 'Danh muc')),
            ],
          ),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(dialogContext), child: const Text('Huy')),
          ElevatedButton(
            onPressed: () async {
              if (nameController.text.isEmpty || priceController.text.isEmpty) return;
              final provider = Provider.of<ProductProvider>(dialogContext, listen: false);
              final navigator = Navigator.of(dialogContext);
              await provider.addProduct(Product(
                id: '0',
                name: nameController.text.trim(),
                price: double.tryParse(priceController.text) ?? 0,
                costPrice: double.tryParse(costPriceController.text) ?? 0,
                category: categoryController.text.trim().isEmpty ? 'Khac' : categoryController.text.trim(),
              ));
              if (!mounted) return;
              navigator.pop();
              setState(() {});
            },
            child: const Text('Luu'),
          ),
        ],
      ),
    );
  }

  void _confirmDelete(Product product) {
    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Xac nhan xoa'),
        content: Text('Ban co chac chan muon xoa mon "${product.name}"?'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(dialogContext), child: const Text('Huy')),
          TextButton(
            onPressed: () async {
              final provider = Provider.of<ProductProvider>(dialogContext, listen: false);
              final navigator = Navigator.of(dialogContext);
              await provider.deleteProduct(product.id);
              if (!mounted) return;
              navigator.pop();
              setState(() {});
            },
            child: const Text('Xoa', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final auth = Provider.of<AuthProvider>(context);
    
    return Scaffold(
      backgroundColor: Colors.grey[50],
      drawer: const AppDrawer(currentRoute: '/menu'),
      appBar: AppBar(
        leading: Builder(builder: (context) => IconButton(icon: const Icon(Icons.menu, color: Colors.black), onPressed: () => Scaffold.of(context).openDrawer())),
        title: const Text('Quản lý thực đơn', style: TextStyle(color: Colors.black)),
        backgroundColor: Colors.white,
      ),
      body: FutureBuilder<void>(
        future: _refreshProducts(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) return const Center(child: CircularProgressIndicator());
          final products = Provider.of<ProductProvider>(context).products;
          return Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              children: [
                if (auth.isOwner)
                  SizedBox(
                    width: double.infinity,
                    height: 48,
                    child: ElevatedButton.icon(
                      onPressed: _showAddProductDialog,
                      icon: const Icon(Icons.add, color: Colors.white),
                      label: const Text('Thêm món mới', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.blue.shade700,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      ),
                    ),
                  ),
                if (auth.isOwner) const SizedBox(height: 16),
                Expanded(
                  child: products.isEmpty
                      ? const Center(child: Text('Chưa có món ăn nào'))
                      : ListView.builder(
                          itemCount: products.length,
                          itemBuilder: (context, index) => ProductCard(
                            product: products[index],
                            onEdit: auth.isOwner ? () => _showEditProductDialog(products[index]) : null,
                            onDelete: auth.isOwner ? () => _confirmDelete(products[index]) : null,
                            onToggleAvailable: auth.isOwner ? (val) => _toggleProductStatus(products[index], 'availability', val) : null,
                            onToggleBestSeller: auth.isOwner ? (val) => _toggleProductStatus(products[index], 'bestseller', val) : null,
                          ),
                        ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
