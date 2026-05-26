import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:fl_chart/fl_chart.dart';
import '../../providers/order_provider.dart';
import '../../core/utils/app_format.dart';
import '../../widgets/common/app_drawer.dart';
import '../../services/export_service.dart';
import '../../services/statistics_service.dart';

class StatisticsScreen extends StatefulWidget {
  const StatisticsScreen({super.key});

  @override
  State<StatisticsScreen> createState() => _StatisticsScreenState();
}

class _StatisticsScreenState extends State<StatisticsScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<OrderProvider>().changeFilter('Hôm nay');
    });
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<OrderProvider>();
    final report = provider.currentReport;
    final exportService = ExportService();

    return Scaffold(
      backgroundColor: const Color(0xFFF5F6FA),
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
          'Báo cáo & Thống kê',
          style: TextStyle(
              color: Colors.black87, fontWeight: FontWeight.bold, fontSize: 20),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.ios_share, color: Colors.blue),
            onPressed: () async {
              DateTime now = DateTime.now();
              DateTime start = DateTime(now.year, now.month, now.day);
              if (provider.selectedFilter == 'Tháng này') {
                start = DateTime(now.year, now.month, 1);
              } else if (provider.selectedFilter == '3 tháng') {
                start = now.subtract(const Duration(days: 90));
              } else if (provider.selectedFilter == '6 tháng') {
                start = now.subtract(const Duration(days: 180));
              } else if (provider.selectedFilter == '1 năm') {
                start = DateTime(now.year - 1, now.month, now.day);
              }
              DateTime end = DateTime(now.year, now.month, now.day, 23, 59, 59);

              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Đang tạo file Excel...')),
              );
              await exportService.exportReportToExcel(start, end);
            },
          )
        ],
      ),
      drawer: const AppDrawer(currentRoute: '/statistics'),
      body: provider.isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // 1. Row các nút lọc thời gian
                  Wrap(
                    spacing: 8.0,
                    runSpacing: 8.0,
                    children: [
                      'Hôm nay',
                      'Tháng này',
                      '3 tháng',
                      '6 tháng',
                      '1 năm'
                    ].map((filterName) {
                      final bool isSel = provider.selectedFilter == filterName;
                      return GestureDetector(
                        onTap: () => context
                            .read<OrderProvider>()
                            .changeFilter(filterName),
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 16, vertical: 8),
                          decoration: BoxDecoration(
                            color: isSel
                                ? const Color(0xFF4CAF50)
                                : const Color(0xFFE0E0E0),
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Text(
                            filterName,
                            style: TextStyle(
                              color: isSel ? Colors.white : Colors.black87,
                              fontWeight:
                                  isSel ? FontWeight.bold : FontWeight.normal,
                            ),
                          ),
                        ),
                      );
                    }).toList(),
                  ),
                  const SizedBox(height: 20),

                  // 2. Dashboard tóm tắt
                  _buildSummaryGrid(report),
                  const SizedBox(height: 12),

                  // 3. Row các chỉ số phụ
                  Row(
                    children: [
                      Expanded(
                        child: _buildDashboardCard(
                          icon: '📋',
                          title: 'Đơn bán',
                          value: '${report?.totalOrders ?? 0}',
                          subValue: '${report?.totalItemsSold ?? 0} món',
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: _buildDashboardCard(
                          icon: '📦',
                          title: 'Vật tư nhập',
                          value: '0',
                          subValue: '0 đ',
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),

                  // 4. Biểu đồ doanh thu
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(16.0),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: Colors.black12, width: 0.5),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Row(
                          children: [
                            Text('📈', style: TextStyle(fontSize: 16)),
                            SizedBox(width: 6),
                            Text('Biểu đồ doanh thu',
                                style: TextStyle(
                                    color: Colors.grey, fontSize: 14)),
                          ],
                        ),
                        const SizedBox(height: 20),
                        SizedBox(
                          height: 220,
                          child: (report == null || report.chartData.isEmpty)
                              ? const Center(
                                  child: Text(
                                    'Không có dữ liệu hiển thị biểu đồ',
                                  ),
                                )
                              : LineChart(
                                  LineChartData(
                                    gridData: const FlGridData(show: false),
                                    borderData: FlBorderData(
                                      show: true,
                                      border: const Border(
                                        bottom: BorderSide(
                                            color: Colors.black87, width: 1.2),
                                        left: BorderSide(
                                            color: Colors.black87, width: 1.2),
                                      ),
                                    ),
                                    titlesData: FlTitlesData(
                                      rightTitles: const AxisTitles(
                                          sideTitles:
                                              SideTitles(showTitles: false)),
                                      topTitles: const AxisTitles(
                                          sideTitles:
                                              SideTitles(showTitles: false)),
                                      bottomTitles: AxisTitles(
                                        sideTitles: SideTitles(
                                          showTitles: true,
                                          getTitlesWidget: (val, meta) {
                                            int idx = val.toInt();
                                            if (idx >= 0 &&
                                                idx < report.chartData.length) {
                                              String rawDate =
                                                  report.chartData[idx]['date'];
                                              return Padding(
                                                padding: const EdgeInsets.only(
                                                    top: 6.0),
                                                child: Text(
                                                    rawDate.substring(5),
                                                    style: const TextStyle(
                                                        fontSize: 9)),
                                              );
                                            }
                                            return const SizedBox();
                                          },
                                        ),
                                      ),
                                    ),
                                    lineBarsData: [
                                      LineChartBarData(
                                        spots: List.generate(
                                            report.chartData.length, (index) {
                                          return FlSpot(
                                              index.toDouble(),
                                              report.chartData[index]
                                                  ['amount']);
                                        }),
                                        isCurved: report.chartData.length > 1,
                                        color: Colors.blue,
                                        barWidth: 3,
                                        isStrokeCapRound: true,
                                        dotData: const FlDotData(show: true),
                                        belowBarData: BarAreaData(
                                          show: true,
                                          color: Colors.blue.withValues(alpha: 0.1),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),

                  // 5. Danh sách món bán chạy
                  _buildTopProductsSection(report?.topProducts ?? []),

                  const SizedBox(height: 16),
                ],
              ),
            ),
    );
  }

  Widget _buildTopProductsSection(List<Map<String, dynamic>> topProducts) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16.0),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.black12, width: 0.5),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Row(
            children: [
              Text('🔥', style: TextStyle(fontSize: 16)),
              SizedBox(width: 6),
              Text('Top món bán chạy',
                  style: TextStyle(color: Colors.grey, fontSize: 14)),
            ],
          ),
          const SizedBox(height: 12),
          if (topProducts.isEmpty)
            const Center(
              child: Padding(
                padding: EdgeInsets.symmetric(vertical: 20),
                child: Text('Chưa có dữ liệu món bán chạy',
                    style: TextStyle(color: Colors.grey)),
              ),
            )
          else
            ListView.separated(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: topProducts.length,
              separatorBuilder: (context, index) => const Divider(height: 1),
              itemBuilder: (context, index) {
                final product = topProducts[index];
                return Padding(
                  padding: const EdgeInsets.symmetric(vertical: 8.0),
                  child: Row(
                    children: [
                      CircleAvatar(
                        backgroundColor: Colors.blue.shade50,
                        radius: 18,
                        child: Text('${index + 1}',
                            style: TextStyle(
                                color: Colors.blue.shade700,
                                fontWeight: FontWeight.bold,
                                fontSize: 14)),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(product['name'] ?? '',
                                style: const TextStyle(
                                    fontWeight: FontWeight.bold, fontSize: 14)),
                            Text('Đã bán: ${product['total_quantity']} món',
                                style: const TextStyle(
                                    color: Colors.grey, fontSize: 12)),
                          ],
                        ),
                      ),
                      Text(
                        AppFormat.money(product['total_revenue'] ?? 0),
                        style: const TextStyle(
                            fontWeight: FontWeight.bold, color: Colors.green),
                      ),
                    ],
                  ),
                );
              },
            ),
        ],
      ),
    );
  }

  Widget _buildSummaryGrid(SalesReport? report) {
    return Column(
      children: [
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(16.0),
          decoration: BoxDecoration(
            color: Colors.blue.shade600,
            borderRadius: BorderRadius.circular(16),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('Tổng Doanh Thu',
                  style: TextStyle(color: Colors.white70, fontSize: 14)),
              const SizedBox(height: 8),
              Text(
                AppFormat.money(report?.totalRevenue ?? 0),
                style: const TextStyle(
                    fontSize: 26,
                    fontWeight: FontWeight.bold,
                    color: Colors.white),
              ),
            ],
          ),
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: Container(
                padding: const EdgeInsets.all(16.0),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: Colors.red.shade100, width: 1),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('Tổng Chi Phí',
                        style: TextStyle(color: Colors.grey, fontSize: 13)),
                    const SizedBox(height: 4),
                    Text(
                      AppFormat.money(report?.totalExpense ?? 0),
                      style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Colors.redAccent),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Container(
                padding: const EdgeInsets.all(16.0),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: Colors.green.shade100, width: 1),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('Lợi Nhuận Ròng',
                        style: TextStyle(color: Colors.grey, fontSize: 13)),
                    const SizedBox(height: 4),
                    Text(
                      AppFormat.money(report?.netProfit ?? 0),
                      style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Colors.green),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildDashboardCard(
      {required String icon,
      required String title,
      required String value,
      required String subValue}) {
    return Container(
      padding: const EdgeInsets.all(16.0),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.black12, width: 0.5),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text(icon, style: const TextStyle(fontSize: 14)),
              const SizedBox(width: 6),
              Text(title,
                  style: const TextStyle(color: Colors.grey, fontSize: 13)),
            ],
          ),
          const SizedBox(height: 8),
          Text(value,
              style:
                  const TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
          const SizedBox(height: 4),
          Text(subValue,
              style: const TextStyle(color: Colors.grey, fontSize: 12)),
        ],
      ),
    );
  }
}
