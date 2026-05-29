class AppSession {
  final String token;
  final String username;
  final String role;
  final String restaurantId;
  final String? branchId;
  final String? bankCode;
  final String? bankAccountNumber;
  final String? bankAccountName;

  const AppSession({
    required this.token,
    required this.username,
    required this.role,
    required this.restaurantId,
    this.branchId,
    this.bankCode,
    this.bankAccountNumber,
    this.bankAccountName,
  });
}
