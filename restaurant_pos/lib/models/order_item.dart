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

  factory OrderItem.fromJson(
      Map<String, dynamic> json, List<Product> products) {
    final productId = json['productId'] ??
        json['product_id'] ??
        json['ProductId'] ??
        json['Product_Id'];
    final product = products.firstWhere(
      (p) => p.id == productId,
      orElse: () => Product(
          id: productId?.toString() ?? 'unknown',
          name: 'Unknown',
          price: (json['price'] ?? json['Price'] as num?)?.toDouble() ?? 0.0),
    );

    // Robust quantity parsing: accept camelCase or PascalCase from backend
    final qVal =
        json['quantity'] ?? json['Quantity'] ?? json['qty'] ?? json['Qty'];
    int qty = 0;
    if (qVal == null) {
      qty = 0;
    } else if (qVal is int) {
      qty = qVal;
    } else if (qVal is num) {
      qty = qVal.toInt();
    } else {
      qty = int.tryParse(qVal.toString()) ?? 0;
    }

    final pVal = json['price'] ?? json['Price'];
    double? parsedPrice;
    if (pVal != null) {
      if (pVal is num) {
        parsedPrice = pVal.toDouble();
      } else {
        parsedPrice = double.tryParse(pVal.toString()) ?? 0.0;
      }
    }

    return OrderItem(
      product: product,
      quantity: qty,
      price: parsedPrice,
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
