import 'package:intl/intl.dart';
import '../enums/table_status.dart';

class AppFormat {
  static final NumberFormat _moneyFormat = NumberFormat('#,###', 'vi_VN');

  static String money(num value) {
    return '${_moneyFormat.format(value)} đ';
  }

  static String tableStatusLabel(
    TableStatus status,
  ) {
    switch (status) {
      case TableStatus.empty:
        return 'Trống';

      case TableStatus.occupied:
        return 'Đang sử dụng';

      case TableStatus.reserved:
        return 'Đã đặt';
    }
  }
}
