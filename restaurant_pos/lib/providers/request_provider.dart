import 'package:flutter/material.dart';
import '../models/order_request.dart';

class RequestProvider with ChangeNotifier {
  final List<OrderRequest> _requests = [];
  
  List<OrderRequest> get requests => _requests.where((r) => r.status == RequestStatus.pending).toList();
  List<OrderRequest> get allRequests => _requests;

  void addRequest(OrderRequest request) {
    _requests.insert(0, request);
    notifyListeners();
  }

  void updateRequestStatus(String requestId, RequestStatus status) {
    final index = _requests.indexWhere((r) => r.id == requestId);
    if (index != -1) {
      // In a real app, you'd send this to the API
      final updated = OrderRequest(
        id: _requests[index].id,
        tableId: _requests[index].tableId,
        tableName: _requests[index].tableName,
        type: _requests[index].type,
        createdAt: _requests[index].createdAt,
        items: _requests[index].items,
        note: _requests[index].note,
        status: status,
      );
      _requests[index] = updated;
      notifyListeners();
    }
  }

  int get pendingCount => _requests.where((r) => r.status == RequestStatus.pending).length;
}
