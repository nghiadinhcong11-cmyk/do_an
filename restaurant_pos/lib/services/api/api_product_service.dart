import '../../models/product.dart';
import 'api_client.dart';

class ApiProductService {
  final ApiClient _apiClient;

  ApiProductService(this._apiClient);

  Future<List<Product>> getAllProducts() async {
    final List<dynamic> data = await _apiClient.get('/products');
    return data.map((json) => Product.fromJson(json)).toList();
  }

  Future<Product> createProduct(Product product) async {
    final data = await _apiClient.post('/products', product.toJson());
    return Product.fromJson(data);
  }

  Future<void> updateProduct(Product product) async {
    await _apiClient.put('/products/${product.id}', product.toJson());
  }

  Future<void> deleteProduct(String id) async {
    await _apiClient.delete('/products/$id');
  }
}
