import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/enums/table_status.dart';
import '../../core/utils/app_format.dart';
import '../../models/product.dart';
import '../../providers/auth_provider.dart';
import '../../providers/cart_provider.dart';
import '../../providers/product_provider.dart';
import '../../providers/table_provider.dart';
import '../order/order_screen.dart';

class MenuScreen extends StatefulWidget {
  final String tableId;
  final String tableName;

  const MenuScreen({super.key, required this.tableId, required this.tableName});

  @override
  State<MenuScreen> createState() => _MenuScreenState();
}

class _MenuScreenState extends State<MenuScreen> with SingleTickerProviderStateMixin {
  TabController? _tabController;
  List<Product> _allProducts = [];
  List<Product> _filteredProducts = [];
  List<String> _categories = [];
  bool _isLoading = true;
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    final productProvider = Provider.of<ProductProvider>(context, listen: false);
    final auth = Provider.of<AuthProvider>(context, listen: false);
    await productProvider.fetchProducts(auth.userId ?? 'admin');

    final loadedProducts = productProvider.products;
    final categoriesSet = <String>{};
    for (final p in loadedProducts) {
      categoriesSet.add(p.category);
    }
    if (categoriesSet.isEmpty) {
      categoriesSet.add('Tat ca');
    }
    final categoriesList = categoriesSet.toList()..sort();

    if (!mounted) return;
    setState(() {
      _allProducts = loadedProducts;
      _filteredProducts = loadedProducts;
      _categories = categoriesList;
      _tabController?.dispose();
      _tabController = TabController(length: _categories.length, vsync: this);
      _isLoading = false;
    });
  }

  void _filterSearch(String query) {
    setState(() {
      if (query.isEmpty) {
        _filteredProducts = _allProducts;
      } else {
        _filteredProducts = _allProducts.where((p) => p.name.toLowerCase().contains(query.toLowerCase())).toList();
      }
    });
  }

  @override
  void dispose() {
    _tabController?.dispose();
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final cartProvider = Provider.of<CartProvider>(context);
    final currentCart = cartProvider.getItemsByTable(widget.tableId);
    final totalItems = currentCart.fold(0, (sum, item) => sum + item.quantity);
    final totalPrice = cartProvider.getSubTotalPriceByTable(widget.tableId);

    return Scaffold(
      appBar: AppBar(
        title: Text('Thuc don - ${widget.tableName}'),
        bottom: _isLoading || _tabController == null
            ? null
            : PreferredSize(
                preferredSize: const Size.fromHeight(110),
                child: Column(
                  children: [
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                      child: TextField(
                        controller: _searchController,
                        onChanged: _filterSearch,
                        decoration: const InputDecoration(hintText: 'Tim mon nhanh...', prefixIcon: Icon(Icons.search)),
                      ),
                    ),
                    TabBar(
                      controller: _tabController,
                      isScrollable: _categories.length > 3,
                      tabs: _categories.map((cat) => Tab(text: cat)).toList(),
                    ),
                  ],
                ),
              ),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _searchController.text.isNotEmpty
              ? _buildMenuGrid('')
              : TabBarView(
                  controller: _tabController,
                  children: _categories.map((cat) => _buildMenuGrid(cat)).toList(),
                ),
      bottomNavigationBar: totalItems > 0
          ? SafeArea(
              child: Container(
                padding: const EdgeInsets.all(16),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('$totalItems mon trong gio hang'),
                        Text(AppFormat.money(totalPrice), style: const TextStyle(fontWeight: FontWeight.bold)),
                      ],
                    ),
                    ElevatedButton(
                      onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => OrderScreen(tableId: widget.tableId, tableName: widget.tableName))),
                      child: const Text('Xem gio hang'),
                    ),
                  ],
                ),
              ),
            )
          : null,
    );
  }

  Widget _buildMenuGrid(String category) {
    final filteredProducts = category.isEmpty ? _filteredProducts : _filteredProducts.where((p) => p.category == category).toList();
    if (filteredProducts.isEmpty) {
      return const Center(child: Text('Khong co mon nao trong danh muc nay'));
    }

    return GridView.builder(
      padding: const EdgeInsets.all(16),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount: 2, crossAxisSpacing: 12, mainAxisSpacing: 12, childAspectRatio: 0.75),
      itemCount: filteredProducts.length,
      itemBuilder: (context, index) {
        final product = filteredProducts[index];
        return Card(
          child: Column(
            children: [
              Expanded(child: Center(child: Text(product.name, maxLines: 2, overflow: TextOverflow.ellipsis))),
              Text(AppFormat.money(product.price)),
              IconButton(
                onPressed: () {
                  Provider.of<CartProvider>(context, listen: false).addToCart(widget.tableId, product);
                  Provider.of<TableProvider>(context, listen: false).updateTableStatus(widget.tableId, TableStatus.occupied);
                },
                icon: const Icon(Icons.add_circle),
              ),
            ],
          ),
        );
      },
    );
  }
}
