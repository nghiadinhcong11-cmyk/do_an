import '../../models/app_session.dart';
import 'api_client.dart';

class AuthApiService {
  final ApiClient _apiClient;

  AuthApiService({ApiClient? apiClient}) : _apiClient = apiClient ?? ApiClient();

  Future<AppSession> login({
    required String username,
    required String password,
  }) async {
    final data = await _apiClient.post('/auth/login', {
      'username': username,
      'password': password,
    });

    return _toSession(data, username);
  }

  Future<AppSession> register({
    required String username,
    required String password,
    required String restaurantName,
    String? phone,
    String role = 'owner',
  }) async {
    final data = await _apiClient.post('/auth/register', {
      'username': username,
      'password': password,
      'restaurantName': restaurantName,
      'phone': phone,
      'role': role,
    });

    return _toSession(data, username);
  }

  AppSession _toSession(dynamic data, String fallbackUsername) {
    return AppSession(
      token: data['token']?.toString() ?? '',
      username: data['username']?.toString() ?? fallbackUsername,
      role: data['role']?.toString() ?? 'staff',
      restaurantId: data['restaurantId']?.toString() ?? '',
      branchId: data['branchId']?.toString().isEmpty == true ? null : data['branchId']?.toString(),
      bankCode: data['bankCode']?.toString(),
      bankAccountNumber: data['bankAccountNumber']?.toString(),
      bankAccountName: data['bankAccountName']?.toString(),
    );
  }
}
