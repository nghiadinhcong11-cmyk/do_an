class Product {
  final String id;
  final String restaurantId;
  final String? categoryId;
  final String? sku;
  final String name;
  final String? description;
  final double price;
  final double costPrice;
  final String? unit;
  final String? imageUrl;
  final bool isAvailable;
  final bool isVisibleToStaff;
  final bool isBestSeller;
  final bool isArchived;
  final int displayOrder;

  Product({
    required this.id,
    required this.restaurantId,
    this.categoryId,
    this.sku,
    required this.name,
    this.description,
    required this.price,
    this.costPrice = 0.0,
    this.unit,
    this.imageUrl,
    this.isAvailable = true,
    this.isVisibleToStaff = true,
    this.isBestSeller = false,
    this.isArchived = false,
    this.displayOrder = 0,
  });

  factory Product.fromJson(Map<String, dynamic> json) {
    return Product(
      id: json['id']?.toString() ?? '',
      restaurantId: json['restaurantId']?.toString() ?? '',
      categoryId: json['categoryId']?.toString(),
      sku: json['sku'],
      name: json['name'] ?? '',
      description: json['description'],
      price: (json['price'] as num?)?.toDouble() ?? 0.0,
      costPrice: (json['costPrice'] as num?)?.toDouble() ?? 0.0,
      unit: json['unit'],
      imageUrl: json['imageUrl'],
      isAvailable: json['isAvailable'] ?? true,
      isVisibleToStaff: json['isVisibleToStaff'] ?? true,
      isBestSeller: json['isBestSeller'] ?? false,
      isArchived: json['isArchived'] ?? false,
      displayOrder: (json['displayOrder'] as num?)?.toInt() ?? 0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'restaurantId': restaurantId,
      'categoryId': categoryId,
      'sku': sku,
      'name': name,
      'description': description,
      'price': price,
      'costPrice': costPrice,
      'unit': unit,
      'imageUrl': imageUrl,
      'isAvailable': isAvailable,
      'isVisibleToStaff': isVisibleToStaff,
      'isBestSeller': isBestSeller,
      'isArchived': isArchived,
      'displayOrder': displayOrder,
    };
  }

  // Compatibility getters
  String? get imagePath => imageUrl;
  String get category => categoryId ?? 'Khác';
}
