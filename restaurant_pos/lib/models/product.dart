class Product {
  final String id;
  final String name;
  final double price;
  final double costPrice;
  final String category;
  final String? imageUrl;

  Product({
    required this.id,
    required this.name,
    required this.price,
    this.costPrice = 0.0,
    this.category = 'Khac',
    this.imageUrl,
  });

  factory Product.fromJson(Map<String, dynamic> json) {
    return Product(
      id: json['id']?.toString() ?? '',
      name: json['name'] ?? '',
      price: (json['price'] as num?)?.toDouble() ?? 0.0,
      costPrice: (json['costPrice'] as num?)?.toDouble() ?? 0.0,
      category: json['category'] ?? 'Khac',
      imageUrl: json['imageUrl'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'price': price,
      'costPrice': costPrice,
      'category': category,
      'imageUrl': imageUrl,
    };
  }

  // To maintain compatibility with existing code using 'imagePath'
  String? get imagePath => imageUrl;
}
