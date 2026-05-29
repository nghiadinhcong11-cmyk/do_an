import 'package:flutter/material.dart';
import '../models/app_session.dart';
import '../services/api/api_client.dart';

class AuthProvider with ChangeNotifier {
  final ApiClient apiClient = ApiClient();

  String? _userId;
  String? _userName;
  String? _token;
  String? _role;
  String? _restaurantId;
  String? _branchId;
  String? _bankCode;
  String? _bankAccountNumber;
  String? _bankAccountName;

  String? get userId => _userId;
  String? get userName => _userName;
  String? get token => _token;
  String? get role => _role;
  String? get restaurantId => _restaurantId;
  String? get branchId => _branchId;
  String? get bankCode => _bankCode;
  String? get bankAccountNumber => _bankAccountNumber;
  String? get bankAccountName => _bankAccountName;
  bool get isAuthenticated => _userId != null && _token != null;

  bool get isOwner => _role?.toLowerCase() == 'owner';
  bool get isStaff => _role?.toLowerCase() == 'staff';
  bool get isCustomer => _role?.toLowerCase() == 'customer';
  bool get isGuest => _userId == null || _role?.toLowerCase() == 'guest';
  bool get isSuperAdmin => _role?.toLowerCase() == 'admin' || _role?.toLowerCase() == 'superadmin';

  void loginWithSession({required String userId, required AppSession session}) {
    _userId = userId;
    _userName = session.username;
    _token = session.token;
    _role = session.role;
    _restaurantId = session.restaurantId;
    _branchId = session.branchId;
    _bankCode = session.bankCode;
    _bankAccountNumber = session.bankAccountNumber;
    _bankAccountName = session.bankAccountName;
    apiClient.setToken(_token);
    notifyListeners();
  }

  void logout() {
    _userId = null;
    _userName = null;
    _token = null;
    _role = null;
    _restaurantId = null;
    _branchId = null;
    _bankCode = null;
    _bankAccountNumber = null;
    _bankAccountName = null;
    apiClient.setToken(null);
    notifyListeners();
  }
}
