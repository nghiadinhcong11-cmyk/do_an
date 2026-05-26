import 'api_client.dart';

class ApiExpenseService {
  final ApiClient _apiClient;

  ApiExpenseService(this._apiClient);

  Future<List<Map<String, dynamic>>> getAllExpenses() async {
    final List<dynamic> data = await _apiClient.get('/expenses');
    return data.cast<Map<String, dynamic>>();
  }

  Future<void> createExpense(Map<String, dynamic> expense) async {
    await _apiClient.post('/expenses', expense);
  }

  Future<void> deleteExpense(String id) async {
    await _apiClient.delete('/expenses/$id');
  }
}
