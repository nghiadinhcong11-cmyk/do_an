class Product {
  final String id;
  final String name;
  final double price;
  final double costPrice;
  final String category;
  final String? imageUrl;
  final bool isAvailable;
  final bool isBestSeller;

  Product({
    required this.id,
    required this.name,
    required this.price,
    this.costPrice = 0.0,
    this.category = 'Khac',
    this.imageUrl,
    this.isAvailable = true,
    this.isBestSeller = false,
  });

  factory Product.fromJson(Map<String, dynamic> json) {
    return Product(
      id: json['id']?.toString() ?? '',
      name: json['name'] ?? '',
      price: (json['price'] as num?)?.toDouble() ?? 0.0,
      costPrice: (json['costPrice'] as num?)?.toDouble() ?? 0.0,
      category: json['category'] ?? 'Khac',
      imageUrl: json['imageUrl'],
      isAvailable: json['isAvailable'] ?? json['is_available'] ?? true,
      isBestSeller: json['isBestSeller'] ?? json['is_best_seller'] ?? false,
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
      'isAvailable': isAvailable,
      'isBestSeller': isBestSeller,
    };
  }

  // To maintain compatibility with existing code using 'imagePath'
  String? get imagePath => imageUrl;
}
