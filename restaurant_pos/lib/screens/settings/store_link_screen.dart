import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:qr_flutter/qr_flutter.dart';

import '../../services/backup_service.dart';

class StoreLinkScreen extends StatefulWidget {
  const StoreLinkScreen({super.key});

  @override
  State<StoreLinkScreen> createState() => _StoreLinkScreenState();
}

class _StoreLinkScreenState extends State<StoreLinkScreen> {
  // Thông tin cố định của chủ quán
  final String userEmail = 'kimngocle1508@gmail.com';
  final String userRole = 'OWNER';
  final String storeName = 'Cà phê Anh Khoa';
  final String storeId = 'gLCyMIgSe5';

  @override
  void initState() {
    super.initState();
    _triggerAutoBackup();
  }

  Future<void> _triggerAutoBackup() async {
    await Future.delayed(Duration.zero);
    final backupService = BackupService();
    String? path = await backupService.backupDatabase();

    if (path != null && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
              'Hệ thống đã tự động sao lưu dữ liệu quán!'),
          backgroundColor: Colors.teal,
          duration: Duration(seconds: 3),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0.5,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black87),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'Thông tin liên kết quán',
          style: TextStyle(
              color: Colors.black87, fontWeight: FontWeight.bold, fontSize: 18),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            const SizedBox(height: 8),

            // CARD 1: THÔNG TIN CHỦ QUÁN
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.green.shade600,
                borderRadius: BorderRadius.circular(16),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('Người dùng:',
                      style: TextStyle(color: Colors.white70, fontSize: 14)),
                  const SizedBox(height: 2),
                  Text(userEmail,
                      style: const TextStyle(
                          color: Colors.white,
                          fontSize: 16,
                          fontWeight: FontWeight.bold)),
                  const SizedBox(height: 2),
                  Text('Role: $userRole',
                      style: const TextStyle(
                          color: Colors.white,
                          fontSize: 15,
                          fontWeight: FontWeight.bold)),
                ],
              ),
            ),
            const SizedBox(height: 16),

            // CARD 2: CHI TIẾT MÃ QR CỦA QUÁN
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(vertical: 24, horizontal: 16),
              decoration: BoxDecoration(
                color: Colors.blue.shade600,
                borderRadius: BorderRadius.circular(16),
              ),
              child: Column(
                children: [
                  const Text('Quán đang kết nối:',
                      style: TextStyle(color: Colors.white70, fontSize: 14)),
                  const SizedBox(height: 4),
                  Text(storeName,
                      style: const TextStyle(
                          color: Colors.white,
                          fontSize: 18,
                          fontWeight: FontWeight.bold)),
                  const SizedBox(height: 20),

                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(16)),
                    child: QrImageView(
                      data: storeId,
                      version: QrVersions.auto,
                      size: 160.0,
                    ),
                  ),
                  const SizedBox(height: 20),

                  Text('ID Quán: $storeId',
                      style: const TextStyle(
                          color: Colors.white,
                          fontSize: 15,
                          fontWeight: FontWeight.w500)),
                  const SizedBox(height: 12),

                  SizedBox(
                    height: 38,
                    child: ElevatedButton(
                      onPressed: () {
                        Clipboard.setData(ClipboardData(text: storeId));
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                              content:
                                  Text('Đã sao chép ID quán vào bộ nhớ tạm!')),
                        );
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.white,
                        foregroundColor: Colors.blue,
                        elevation: 0,
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(20)),
                        padding: const EdgeInsets.symmetric(horizontal: 24),
                      ),
                      child: const Text('Copy ID',
                          style: TextStyle(
                              fontWeight: FontWeight.bold)),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),

            SizedBox(
              width: double.infinity,
              height: 50,
              child: OutlinedButton.icon(
                onPressed: () async {
                  final backupService = BackupService();
                  final messenger = ScaffoldMessenger.of(context);
                  // Logic thực tế nên có file picker. 
                  // Ở đây giữ logic cũ nhưng sửa lỗi
                  String backupFilePath = '/storage/emulated/0/Download/Backup_pos.db';

                  bool isRestored =
                      await backupService.restoreDatabase(backupFilePath);

                  if (mounted) {
                    if (isRestored) {
                      messenger.showSnackBar(
                        const SnackBar(
                          content: Text(
                              'Khôi phục dữ liệu thành công! Hãy khởi động lại ứng dụng.'),
                          backgroundColor: Colors.green,
                        ),
                      );
                    } else {
                      messenger.showSnackBar(
                        const SnackBar(
                          content: Text(
                              'Khôi phục thất bại. Không tìm thấy file .db hợp lệ.'),
                          backgroundColor: Colors.redAccent,
                        ),
                      );
                    }
                  }
                },
                icon: const Icon(Icons.settings_backup_restore,
                    color: Color(0xFF0288D1)),
                label: const Text(
                  'Khôi phục từ file sao lưu',
                  style: TextStyle(
                      color: Colors.blue,
                      fontWeight: FontWeight.bold,
                      fontSize: 15),
                ),
                style: OutlinedButton.styleFrom(
                  side: const BorderSide(color: Colors.blue, width: 1.5),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12)),
                ),
              ),
            ),
            const SizedBox(height: 16),

            SizedBox(
              width: double.infinity,
              height: 54,
              child: ElevatedButton(
                onPressed: () => _showDisconnectDialog(context),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.red.shade50,
                  foregroundColor: Colors.red,
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12)),
                  elevation: 0,
                  side: BorderSide(color: Colors.red.shade100),
                ),
                child: const Text(
                  'Hủy liên kết quán',
                  style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showDisconnectDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Cảnh báo hệ thống'),
          content: const Text(
              'Hành động này sẽ xóa cấu hình liên kết hiện tại của quán. Bạn có chắc chắn muốn tiếp tục?'),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Quay lại'),
            ),
            TextButton(
              onPressed: () {
                Navigator.pop(context);
                SystemNavigator.pop();
              },
              child: const Text('Xác nhận xóa',
                  style: TextStyle(
                      color: Colors.red, fontWeight: FontWeight.bold)),
            ),
          ],
        );
      },
    );
  }
}
