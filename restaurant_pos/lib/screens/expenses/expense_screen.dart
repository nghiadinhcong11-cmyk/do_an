import 'package:flutter/material.dart' as m;
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import '../../providers/auth_provider.dart';
import '../../services/api/api_expense_service.dart';
import '../../widgets/common/app_drawer.dart';

class ExpenseScreen extends m.StatefulWidget {
  const ExpenseScreen({super.key});

  @override
  m.State<ExpenseScreen> createState() => _ExpenseScreenState();
}

class _ExpenseScreenState extends m.State<ExpenseScreen> {
  final currencyFormat = NumberFormat('#,###', 'vi_VN');
  final m.TextEditingController _titleController = m.TextEditingController();
  final m.TextEditingController _amountController = m.TextEditingController();
  String _selectedCategory = 'Nhap hang';

  @override
  void dispose() {
    _titleController.dispose();
    _amountController.dispose();
    super.dispose();
  }

  ApiExpenseService _service() {
    final auth = Provider.of<AuthProvider>(context, listen: false);
    return ApiExpenseService(auth.apiClient);
  }

  Future<List<Map<String, dynamic>>> _loadExpenses() => _service().getAllExpenses();

  void _showAddExpenseDialog() {
    m.showDialog(
      context: context,
      builder: (context) => m.StatefulBuilder(
        builder: (context, setDialogState) => m.AlertDialog(
          title: const m.Text('Them khoan chi phi', style: m.TextStyle(fontSize: 18)),
          content: m.SingleChildScrollView(
            child: m.Column(
              mainAxisSize: m.MainAxisSize.min,
              children: [
                m.TextField(controller: _titleController, decoration: const m.InputDecoration(labelText: 'Noi dung chi')),
                const m.SizedBox(height: 8),
                m.TextField(controller: _amountController, keyboardType: m.TextInputType.number, decoration: const m.InputDecoration(labelText: 'So tien (d)')),
                const m.SizedBox(height: 16),
                m.DropdownButtonFormField<String>(
                  initialValue: _selectedCategory,
                  decoration: const m.InputDecoration(labelText: 'Phan loai'),
                  items: const [
                    m.DropdownMenuItem(value: 'Nhap hang', child: m.Text('Chi phi nhap hang')),
                    m.DropdownMenuItem(value: 'Luong', child: m.Text('Chi phi luong')),
                    m.DropdownMenuItem(value: 'Khac', child: m.Text('Chi phi khac')),
                  ],
                  onChanged: (value) {
                    if (value != null) {
                      setDialogState(() => _selectedCategory = value);
                    }
                  },
                ),
              ],
            ),
          ),
          actions: [
            m.TextButton(onPressed: () => m.Navigator.pop(context), child: const m.Text('Huy')),
            m.ElevatedButton(
              onPressed: () async {
                if (_titleController.text.isEmpty || _amountController.text.isEmpty) return;
                await _service().createExpense({
                  'title': _titleController.text,
                  'amount': double.tryParse(_amountController.text) ?? 0.0,
                  'category': _selectedCategory,
                  'dateUtc': DateTime.now().toUtc().toIso8601String(),
                });

                _titleController.clear();
                _amountController.clear();
                if (!context.mounted) return;
                m.Navigator.pop(context);
                setState(() {});
              },
              child: const m.Text('Luu'),
            ),
          ],
        ),
      ),
    );
  }

  @override
  m.Widget build(m.BuildContext context) {
    return m.Scaffold(
      drawer: const AppDrawer(currentRoute: '/expenses'),
      appBar: m.AppBar(
        leading: m.Builder(builder: (context) => m.IconButton(icon: const m.Icon(m.Icons.menu), onPressed: () => m.Scaffold.of(context).openDrawer())),
        title: const m.Text('Quan ly chi phi'),
      ),
      body: m.FutureBuilder<List<Map<String, dynamic>>>(
        future: _loadExpenses(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == m.ConnectionState.waiting) return const m.Center(child: m.CircularProgressIndicator());
          if (snapshot.hasError) return m.Center(child: m.Text('Loi tai du lieu: ${snapshot.error}'));

          final expenseList = snapshot.data ?? [];
          if (expenseList.isEmpty) return const m.Center(child: m.Text('Chua co khoan chi phi nao.'));

          final totalExpense = expenseList.fold<double>(0.0, (sum, item) => sum + ((item['amount'] as num?)?.toDouble() ?? 0.0));

          return m.Column(children: [
            m.Container(
              width: double.infinity,
              padding: const m.EdgeInsets.all(16),
              child: m.Text('Tong chi: ${currencyFormat.format(totalExpense)} d', style: const m.TextStyle(fontSize: 20, color: m.Colors.redAccent)),
            ),
            m.Expanded(
              child: m.ListView.builder(
                itemCount: expenseList.length,
                itemBuilder: (context, index) {
                  final item = expenseList[index];
                  final amount = ((item['amount'] as num?)?.toDouble() ?? 0.0);
                  final id = item['id']?.toString() ?? '';
                  return m.ListTile(
                    title: m.Text(item['title']?.toString() ?? ''),
                    subtitle: m.Text('Loai: ${item['category'] ?? ''}'),
                    trailing: m.Row(mainAxisSize: m.MainAxisSize.min, children: [
                      m.Text('- ${currencyFormat.format(amount)} d'),
                      m.IconButton(
                        onPressed: () async {
                          await _service().deleteExpense(id);
                          setState(() {});
                        },
                        icon: const m.Icon(m.Icons.delete_outline),
                      ),
                    ]),
                  );
                },
              ),
            ),
          ]);
        },
      ),
      floatingActionButton: m.FloatingActionButton(onPressed: _showAddExpenseDialog, child: const m.Icon(m.Icons.add)),
    );
  }
}
