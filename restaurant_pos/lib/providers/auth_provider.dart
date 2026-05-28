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

  String? get userId => _userId;
  String? get userName => _userName;
  String? get token => _token;
  String? get role => _role;
  String? get restaurantId => _restaurantId;
  String? get branchId => _branchId;
  bool get isAuthenticated => _userId != null && _token != null;

  bool get isOwner => _role?.toLowerCase() == 'owner';
  bool get isStaff => _role?.toLowerCase() == 'staff';
  bool get isGuest => _role?.toLowerCase() == 'guest' || _role?.toLowerCase() == 'customer';

  void loginWithSession({required String userId, required AppSession session}) {
    _userId = userId;
    _userName = session.username;
    _token = session.token;
    _role = session.role;
    _restaurantId = session.restaurantId;
    _branchId = session.branchId;
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
    apiClient.setToken(null);
    notifyListeners();
  }
}
