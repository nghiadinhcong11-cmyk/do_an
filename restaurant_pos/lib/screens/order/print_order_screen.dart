import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../core/utils/app_format.dart';
import '../../database/dao/order_dao.dart';
import '../../models/order.dart';
import '../../models/order_item.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'dart:ui' as ui;
import 'dart:io';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';
// removed unused dart:typed_data import

class PrintOrderScreen extends StatefulWidget {
  final String
      orderId; // Nhận ID Hóa đơn từ màn hình trước truyền sang để tìm trong DB

  const PrintOrderScreen({super.key, required this.orderId});

  @override
  State<PrintOrderScreen> createState() => _PrintOrderScreenState();
}

class _PrintOrderScreenState extends State<PrintOrderScreen> {
  final OrderDao _orderDao = OrderDao();
  final dateFormat = DateFormat('HH:mm:ss dd/MM/yyyy');

  Future<void> _exportQr(OrderModel order) async {
    final String data = order.lookupCode.isNotEmpty
        ? order.lookupCode
        : order.invoiceNo.isNotEmpty
            ? order.invoiceNo
            : (order.id ?? '');

    final String trimmed = data.trim();
    if (trimmed.isEmpty) throw Exception('Mã tra cứu rỗng, không thể xuất QR');

    final painter = QrPainter(
      data: trimmed,
      version: QrVersions.auto,
      gapless: true,
      dataModuleStyle: const QrDataModuleStyle(color: Colors.black),
      eyeStyle:
          const QrEyeStyle(eyeShape: QrEyeShape.square, color: Colors.black),
    );

    const ui.ImageByteFormat format = ui.ImageByteFormat.png;

    try {
      final picData = await painter.toImageData(1024, format: format);
      if (picData == null) throw Exception('Không thể tạo ảnh QR');

      final bytes = picData.buffer.asUint8List();
      final tempDir = await getTemporaryDirectory();
      final safeName = trimmed.replaceAll(RegExp(r'[^A-Za-z0-9_\-]'), '_');
      final file = File('${tempDir.path}/qr_$safeName.png');
      await file.writeAsBytes(bytes);

      await Share.shareXFiles([XFile(file.path)],
          text: 'Mã tra cứu hóa đơn: $trimmed');
    } catch (e) {
      throw Exception('Lỗi khi tạo hoặc chia sẻ QR: $e');
    }
  }

  // Hàm tải đồng thời cả thông tin hóa đơn và danh sách món ăn từ DB
  Future<Map<String, dynamic>> _loadInvoiceData() async {
    final order = await _orderDao.getOrderById(widget.orderId);
    final items = await _orderDao.getOrderItems(widget.orderId);
    return {
      'order': order,
      'items': items,
    };
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey.shade300,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text('In hóa đơn', style: TextStyle(color: Colors.black)),
        centerTitle: true,
      ),
      body: FutureBuilder<Map<String, dynamic>>(
        future: _loadInvoiceData(),
        builder: (context, snapshot) {
          // 1. Trạng thái đang đợi DB trả dữ liệu
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(
                child: CircularProgressIndicator(color: Colors.green));
          }

          // 2. Trạng thái lỗi hoặc không có dữ liệu
          if (snapshot.hasError ||
              !snapshot.hasData ||
              snapshot.data!['order'] == null) {
            return const Center(
                child:
                    Text('Không tìm thấy dữ liệu hóa đơn hoặc đã xảy ra lỗi.'));
          }

          // 3. Đã lấy dữ liệu từ DB thành công -> Gán vào các biến dữ liệu động
          final OrderModel order = snapshot.data!['order'];
          final List<OrderItem> items = snapshot.data!['items'];

          return Column(
            children: [
              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(16.0),
                  child: Container(
                    padding: const EdgeInsets.all(20.0),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Column(
                      children: [
                        // CỐ ĐỊNH: Thông tin tên quán (Có thể config từ Settings DB sau)
                        const Text('Cà phê Anh Khoa',
                            style: TextStyle(fontSize: 20)),
                        const Text('Đường 31, Nghĩa Thành, TP.HCM',
                            style: TextStyle(fontSize: 13)),
                        const Text('0346987195',
                            style: TextStyle(fontSize: 13)),
                        const SizedBox(height: 10),
                        _buildDashedDivider(),

                        // ĐỘNG TỪ DB: Chi tiết hóa đơn
                        _buildTextRow('Hóa đơn:', '#${order.id}'),
                        _buildTextRow(
                            'Bàn:',
                            order.tableId == 'mang_di'
                                ? 'Đơn bán mang đi'
                                : 'Bàn ${order.tableId}'),
                        _buildTextRow(
                            'Thời gian:', dateFormat.format(order.dateTime)),
                        _buildDashedDivider(),

                        // ĐỘNG TỪ DB: Thông tin hóa đơn điện tử cơ quan thuế
                        const Align(
                          alignment: Alignment.centerLeft,
                          child: Text(
                              'Hóa đơn điện tử khởi tạo từ máy tính tiền',
                              style: TextStyle(fontSize: 13)),
                        ),
                        const SizedBox(height: 4),
                        _buildTextRow('Số HĐ:', order.invoiceNo),
                        _buildTextRow('Mã tra cứu:', order.lookupCode),
                        _buildDashedDivider(),

                        // ĐỘNG TỪ DB: Danh sách các món ăn thực tế được gọi
                        ListView.builder(
                          shrinkWrap: true,
                          physics: const NeverScrollableScrollPhysics(),
                          itemCount: items.length,
                          itemBuilder: (context, index) {
                            final item = items[index];
                            return Padding(
                              padding:
                                  const EdgeInsets.symmetric(vertical: 4.0),
                              child: Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Text('${item.product.name} x${item.quantity}',
                                      style: const TextStyle(fontSize: 14)),
                                  Text(
                                      AppFormat.money(
                                          item.product.price * item.quantity),
                                      style: const TextStyle(fontSize: 14)),
                                ],
                              ),
                            );
                          },
                        ),
                        _buildDashedDivider(),
                        _buildDashedDivider(),

                        // ĐỘNG TỪ DB: Các khoản tiền tổng hợp
                        _buildTextRow(
                            'Thành tiền', AppFormat.money(order.subTotal)),
                        const SizedBox(height: 6),
                        _buildTextRow(
                            'VAT (3%)', AppFormat.money(order.vatAmount)),
                        const SizedBox(height: 8),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const Text('TỔNG CỘNG',
                                style: TextStyle(fontSize: 16)),
                            Text(AppFormat.money(order.totalAmount),
                                style: const TextStyle(fontSize: 16)),
                          ],
                        ),
                        _buildDashedDivider(),

                        const SizedBox(height: 10),
                        const Text('CẢM ƠN QUÝ KHÁCH',
                            style: TextStyle(fontSize: 15)),
                        const Text('Hẹn gặp lại!',
                            style:
                                TextStyle(fontSize: 13, color: Colors.black54)),
                      ],
                    ),
                  ),
                ),
              ),

              // Phần nút bấm giữ nguyên cố định ở dưới đáy
              Container(
                padding: const EdgeInsets.symmetric(
                    horizontal: 16.0, vertical: 20.0),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    SizedBox(
                      width: double.infinity,
                      height: 52,
                      child: ElevatedButton.icon(
                        style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.blue,
                            shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(14))),
                        onPressed: () async {
                          // Export QR (share PNG) for order lookup code
                          final messenger = ScaffoldMessenger.of(context);
                          try {
                            await _exportQr(order);
                            if (!mounted) return;
                            messenger.showSnackBar(
                              const SnackBar(content: Text('Đã xuất QR')),
                            );
                          } catch (e) {
                            if (!mounted) return;
                            messenger.showSnackBar(SnackBar(
                                content: Text('Xuất QR thất bại: $e')));
                          }
                        },
                        icon: const Icon(Icons.qr_code, color: Colors.white),
                        label: const Text('Xuất QR',
                            style:
                                TextStyle(fontSize: 16, color: Colors.white)),
                      ),
                    ),
                    const SizedBox(height: 14),
                    SizedBox(
                      width: double.infinity,
                      height: 52,
                      child: ElevatedButton.icon(
                        style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.grey.shade300,
                            shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(14))),
                        onPressed: () {},
                        icon: const Text('✅'),
                        label: const Text('Đã xuất hóa đơn điện tử',
                            style:
                                TextStyle(fontSize: 16, color: Colors.white)),
                      ),
                    ),
                    const SizedBox(height: 14),
                    SizedBox(
                      width: double.infinity,
                      height: 52,
                      child: ElevatedButton.icon(
                        style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.green,
                            shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(14))),
                        onPressed: () {
                          // Thực hiện lệnh in Bluetooth với dữ liệu của biến `order` và `items` ở đây
                        },
                        icon: const Text('🖨️'),
                        label: const Text('In hóa đơn (Bluetooth)',
                            style:
                                TextStyle(fontSize: 16, color: Colors.white)),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildTextRow(String leftText, String rightText) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(leftText,
              style: const TextStyle(fontSize: 13, color: Colors.black87)),
          Text(rightText, style: const TextStyle(fontSize: 13)),
        ],
      ),
    );
  }

  Widget _buildDashedDivider() {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: SizedBox(
        width: double.infinity,
        height: 1,
        child: CustomPaint(
          painter: _DashedLinePainter(color: Colors.grey),
        ),
      ),
    );
  }
}

class _DashedLinePainter extends CustomPainter {
  final Color color;
  static const double _dashWidth = 4.0;
  static const double _dashSpace = 4.0;

  _DashedLinePainter({required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..strokeWidth = size.height
      ..strokeCap = StrokeCap.round;

    double startX = 0;
    while (startX < size.width) {
      final endX = startX + _dashWidth;
      canvas.drawLine(
        Offset(startX, size.height / 2),
        Offset(endX.clamp(0.0, size.width), size.height / 2),
        paint,
      );
      startX += _dashWidth + _dashSpace;
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
