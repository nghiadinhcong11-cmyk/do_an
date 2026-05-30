import 'api_client.dart';

class ApiRestaurantService {
  final ApiClient _apiClient;

  ApiRestaurantService(this._apiClient);

  Future<Map<String, dynamic>> getMyRestaurantInfo() async {
    return await _apiClient.get('/restaurant/my-restaurant');
  }
}
