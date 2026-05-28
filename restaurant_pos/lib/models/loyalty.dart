class LoyaltyCustomer {
  final String id;
  final String name;
  final String phone;
  final int points;
  final String rank;
  final double totalSpent;

  LoyaltyCustomer({
    required this.id,
    required this.name,
    required this.phone,
    this.points = 0,
    this.rank = 'Bronze',
    this.totalSpent = 0.0,
  });

  factory LoyaltyCustomer.fromJson(Map<String, dynamic> json) {
    return LoyaltyCustomer(
      id: json['id']?.toString() ?? '',
      name: json['name'] ?? '',
      phone: json['phone'] ?? '',
      points: json['points'] as int? ?? 0,
      rank: json['rank'] ?? 'Bronze',
      totalSpent: (json['totalSpent'] as num?)?.toDouble() ?? 0.0,
    );
  }
}

class Voucher {
  final String id;
  final String code;
  final String title;
  final double discountValue;
  final bool isPercentage;
  final double minOrderValue;
  final DateTime expiryDate;

  Voucher({
    required this.id,
    required this.code,
    required this.title,
    required this.discountValue,
    this.isPercentage = false,
    this.minOrderValue = 0.0,
    required this.expiryDate,
  });

  factory Voucher.fromJson(Map<String, dynamic> json) {
    return Voucher(
      id: json['id']?.toString() ?? '',
      code: json['code'] ?? '',
      title: json['title'] ?? '',
      discountValue: (json['discountValue'] as num?)?.toDouble() ?? 0.0,
      isPercentage: json['isPercentage'] ?? false,
      minOrderValue: (json['minOrderValue'] as num?)?.toDouble() ?? 0.0,
      expiryDate: DateTime.parse(json['expiryDate'] ?? DateTime.now().toIso8601String()),
    );
  }
}
