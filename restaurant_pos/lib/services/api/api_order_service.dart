import '../../models/order.dart';
import '../../models/product.dart';
import 'api_client.dart';

class ApiOrderService {
  final ApiClient _apiClient;

  ApiOrderService(this._apiClient);

  Future<List<OrderModel>> getAllOrders(List<Product> products) async {
    final List<dynamic> data = await _apiClient.get('/orders');
    return data.map((json) => OrderModel.fromJson(json)).toList();
  }

  Future<OrderModel> createOrder(OrderModel order) async {
    final data = await _apiClient.post('/orders', order.toJson());
    return OrderModel.fromJson(data);
  }

  Future<OrderModel> getOrderById(String id, List<Product> products) async {
    final data = await _apiClient.get('/orders/$id');
    return OrderModel.fromJson(data);
  }
}
