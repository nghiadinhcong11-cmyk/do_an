import 'package:flutter/material.dart';
import '../../core/utils/app_format.dart';
import '../../database/database_helper.dart';
import '../menu/menu_screen.dart';
import '../../core/enums/table_status.dart';
import '../../models/table_model.dart';

class TableMapScreen extends StatefulWidget {
  const TableMapScreen({super.key});

  @override
  State<TableMapScreen> createState() => _TableMapScreenState();
}

class _TableMapScreenState extends State<TableMapScreen> {
  final DatabaseHelper _dbHelper = DatabaseHelper.instance;

  // Hàm chuyển đổi dữ liệu từ Map của SQLite sang List<DiningTable> để UI sử dụng
  Future<List<DiningTable>> _fetchTables() async {
    final List<Map<String, dynamic>> data =
        await _dbHelper.getAllTablesFromDb();
    return data
        .map((item) => DiningTable(
              id: item['id']?.toString() ?? '',
              name: item['name'] ?? '',
              seats: item['seats'] ?? 0,
              status: TableStatus.values.firstWhere(
                (s) => s.name == item['status'],
                orElse: () => TableStatus.empty,
              ),
            ))
        .toList();
  }

  // Hàm xử lý khi chủ quán click vào bàn
  void _handleTableTap(DiningTable table) async {
    if (table.status == TableStatus.empty) {
      // 1. Cập nhật trạng thái 'CÓ KHÁCH' xuống SQLite và làm mới UI
      await _dbHelper.updateTableStatusInDb(table.id, 'CO_KHACH');
      setState(() {});

      if (mounted) {
        final scaffoldMessenger = ScaffoldMessenger.of(context);
        final navigator = Navigator.of(context);

        scaffoldMessenger.showSnackBar(
          SnackBar(
            content: Text('Đang mở thực đơn cho ${table.name}'),
            backgroundColor: Colors.blue,
            duration: const Duration(seconds: 1),
          ),
        );

        // 2. TỰ ĐỘNG CHUYỂN HƯỚNG SANG MÀN HÌNH THỰC ĐƠN
        navigator.push(
          MaterialPageRoute(
            builder: (context) => MenuScreen(
              tableId: table.id,
              tableName: table.name,
            ),
          ),
        ).then((_) {
          if (mounted) {
            setState(() {});
          }
        });
      }
    } else {
      _showTableActionDialog(table);
    }
  }

  // Hộp thoại tùy chọn nhanh cho bàn đang có khách
  void _showTableActionDialog(DiningTable table) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(table.name),
        content: const Text(
            'Bàn này hiện đang có khách ngồi. Bạn muốn thực hiện thao tác nào?'),
        actions: [
          // 1. NÚT XEM HÓA ĐƠN / THÊM MÓN
          TextButton(
            onPressed: () {
              Navigator.pop(context); // Đóng hộp thoại alert trước

              // Chuyển hướng sang màn hình Menu của bàn đang ngồi để xem hoặc thêm món
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => MenuScreen(
                    tableId: table.id,
                    tableName: table.name,
                  ),
                ),
              ).then((_) =>
                  setState(() {})); // Reload lại sơ đồ bàn khi quay về
            },
            child: const Text('Xem hóa đơn'),
          ),

          // 2. NÚT GIẢI PHÓNG BÀN VỀ TRẠNG THÁI TRỐNG
          TextButton(
            onPressed: () async {
              final navigator = Navigator.of(context);
              final messenger = ScaffoldMessenger.of(context);
              // Cập nhật trạng thái 'TRỐNG' vào file SQLite cục bộ của máy
              await _dbHelper.updateTableStatusInDb(table.id, 'TRONG');

              if (mounted) {
                navigator.pop(); // Đóng hộp thoại alert
                setState(
                    () {}); // Làm mới toàn bộ sơ đồ lưới bàn ăn

                messenger.showSnackBar(
                  SnackBar(
                      content:
                          Text('Đã trả bàn ${table.name} thành trống!'),
                      backgroundColor: Colors.green),
                );
              }
            },
            child: const Text('Trả bàn trống',
                style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey.shade100,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0.5,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black87),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'Sơ đồ bàn',
          style: TextStyle(color: Colors.black87, fontSize: 18),
        ),
      ),
      body: FutureBuilder<List<DiningTable>>(
        future: _fetchTables(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return Center(
                child: Text('Lỗi tải dữ liệu: ${snapshot.error}'));
          }

          final tablesList = snapshot.data ?? [];

          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: double.infinity,
                color: Colors.white,
                padding: const EdgeInsets.symmetric(
                    horizontal: 16.0, vertical: 12.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Sơ đồ bàn',
                      style: TextStyle(fontSize: 20, color: Colors.black87, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '${tablesList.length} bàn trong quán',
                      style:
                          TextStyle(fontSize: 14, color: Colors.grey.shade600),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),

              Expanded(
                child: GridView.builder(
                  padding: const EdgeInsets.symmetric(horizontal: 16.0),
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    crossAxisSpacing: 16.0,
                    mainAxisSpacing: 16.0,
                    childAspectRatio: 1.25,
                  ),
                  itemCount: tablesList.length,
                  itemBuilder: (context, index) {
                    final table = tablesList[index];
                    return GestureDetector(
                      onTap: () => _handleTableTap(table),
                      child: _buildTableCard(table),
                    );
                  },
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  // Widget giao diện của từng ô bàn lẻ
  Widget _buildTableCard(DiningTable table) {
    final isOccupied = table.status == TableStatus.occupied;

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isOccupied ? Colors.orange.shade300 : Colors.grey.shade200,
          width: isOccupied ? 1.5 : 1.0,
        ),
        boxShadow: const [
          BoxShadow(
            color: Colors.black12,
            blurRadius: 4,
          ),
        ],
      ),
      child: Stack(
        children: [
          Positioned(
            top: 12,
            right: 12,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: isOccupied ? Colors.orange : Colors.teal,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                AppFormat.tableStatusLabel(table.status),
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 10,
                ),
              ),
            ),
          ),

          Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const SizedBox(height: 12),
                Icon(
                  Icons.chair_alt_outlined,
                  size: 32,
                  color: isOccupied ? Colors.orange : Colors.grey.shade400,
                ),
                const SizedBox(height: 8),
                Text(
                  table.name,
                  style: const TextStyle(
                    fontSize: 16,
                    color: Colors.black87,
                    fontWeight: FontWeight.bold
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  '${table.seats} ghế',
                  style: TextStyle(
                    fontSize: 13,
                    color: Colors.grey.shade500,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
