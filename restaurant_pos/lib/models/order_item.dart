import 'product.dart';

class OrderItem {
  final Product product;
  int quantity;
  final double? price;

  OrderItem({
    required this.product,
    this.quantity = 1,
    this.price,
  });

  double get unitPrice => price ?? product.price;
  double get total => unitPrice * quantity;

  factory OrderItem.fromJson(Map<String, dynamic> json, List<Product> products) {
    final productId = json['productId'];
    final product = products.firstWhere(
      (p) => p.id == productId,
      orElse: () => Product(id: productId, name: 'Unknown', price: (json['price'] as num?)?.toDouble() ?? 0.0),
    );
    return OrderItem(
      product: product,
      quantity: json['quantity'] ?? 0,
      price: (json['price'] as num?)?.toDouble(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'productId': product.id,
      'quantity': quantity,
      'price': unitPrice,
    };
  }
}
