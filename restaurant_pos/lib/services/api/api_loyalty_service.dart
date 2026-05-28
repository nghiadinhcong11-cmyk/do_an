import '../../models/loyalty.dart';
import 'api_client.dart';

class ApiLoyaltyService {
  final ApiClient _apiClient;

  ApiLoyaltyService(this._apiClient);

  Future<LoyaltyCustomer?> getCustomerByPhone(String phone) async {
    try {
      final data = await _apiClient.get('/loyalty/customers/$phone');
      return LoyaltyCustomer.fromJson(data);
    } catch (e) {
      return null;
    }
  }

  Future<List<Voucher>> getAvailableVouchers() async {
    final List<dynamic> data = await _apiClient.get('/loyalty/vouchers');
    return data.map((json) => Voucher.fromJson(json)).toList();
  }

  Future<void> addPoints(String customerId, int points) async {
    await _apiClient.post('/loyalty/customers/$customerId/points', {'points': points});
  }
}
