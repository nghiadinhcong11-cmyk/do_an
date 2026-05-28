import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:restaurant_pos/widgets/common/app_drawer.dart';
import '../../providers/table_provider.dart';
import '../../widgets/cards/table_card.dart';

class TableManagementScreen extends StatefulWidget {
  const TableManagementScreen({super.key});

  @override
  State<TableManagementScreen> createState() => _TableManagementScreenState();
}

class _TableManagementScreenState extends State<TableManagementScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<TableProvider>(context, listen: false).fetchAndSetTables();
    });
  }

  void _showAddTableDialog() {
    final nameController = TextEditingController();
    final seatsController = TextEditingController(text: '4');

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Thêm bàn mới'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(controller: nameController, decoration: const InputDecoration(labelText: 'Tên bàn (vd: Bàn 5)')),
            TextField(controller: seatsController, decoration: const InputDecoration(labelText: 'Số ghế'), keyboardType: TextInputType.number),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Hủy')),
          ElevatedButton(
            onPressed: () async {
              if (nameController.text.isNotEmpty) {
                final navigator = Navigator.of(context);
                
                await Provider.of<TableProvider>(context, listen: false)
                    .addTable(nameController.text, int.parse(seatsController.text));
                
                if (mounted) {
                  navigator.pop();
                }
              }
            },
            child: const Text('Lưu'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final tableProvider = Provider.of<TableProvider>(context);
    final auth = Provider.of<AuthProvider>(context);

    return Scaffold(
      backgroundColor: Colors.grey.shade100,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0.5,
        leading: Builder(
          builder: (context) => IconButton(
            icon: const Icon(Icons.menu, color: Colors.black87),
            onPressed: () => Scaffold.of(context).openDrawer(),
          ),
        ),
        title: const Text(
          'Sơ đồ bàn',
          style: TextStyle(
              color: Colors.black87, fontWeight: FontWeight.bold, fontSize: 20),
        ),
      ),
      drawer: const AppDrawer(currentRoute: '/table_management'),
      body: Column(
        children: [
          if (auth.isOwner)
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton.icon(
                  onPressed: _showAddTableDialog,
                  icon: const Icon(Icons.add, color: Colors.white),
                  label: const Text('Thêm bàn mới',
                      style: TextStyle(
                          color: Colors.white,
                          fontSize: 16,
                          fontWeight: FontWeight.bold)),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blue.shade700,
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12)),
                    elevation: 1,
                  ),
                ),
              ),
            ),
          Expanded(
            child: tableProvider.tables.isEmpty 
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.table_bar_outlined, size: 64, color: Colors.grey.shade400),
                      const SizedBox(height: 16),
                      Text(auth.isOwner ? 'Chưa có bàn nào. Hãy thêm bàn để bắt đầu.' : 'Hiện chưa có bàn nào trong hệ thống.', 
                        style: TextStyle(color: Colors.grey.shade600)),
                    ],
                  ),
                )
              : RefreshIndicator(
                  onRefresh: () => tableProvider.fetchAndSetTables(),
                  child: ListView.builder(
                    padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
                    itemCount: tableProvider.tables.length,
                    itemBuilder: (context, index) {
                      return TableCard(table: tableProvider.tables[index]);
                    },
                  ),
                ),
          ),
        ],
      ),
    );
  }
}
