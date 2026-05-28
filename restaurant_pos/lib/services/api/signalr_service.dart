import 'package:signalr_netcore/signalr_client.dart';
import 'api_config.dart';

class SignalRService {
  HubConnection? _hubConnection;
  final String _token;
  final String _restaurantId;

  SignalRService(this._token, this._restaurantId);

  Future<void> initTableHub({
    required Function(String tableId, String status) onTableStatusChanged,
    Function(Map<String, dynamic> request)? onRequestReceived,
  }) async {
    final serverUrl = ApiConfig.baseUrl.replaceAll('/api', '/hubs/tables');
    
    _hubConnection = HubConnectionBuilder()
        .withUrl(serverUrl, options: HttpConnectionOptions(
          accessTokenFactory: () async => _token,
        ))
        .withAutomaticReconnect()
        .build();

    _hubConnection?.on("tableStatusChanged", (List<Object?>? arguments) {
      if (arguments != null && arguments.length >= 2) {
        final tableId = arguments[0].toString();
        final status = arguments[1].toString();
        onTableStatusChanged(tableId, status);
      }
    });

    _hubConnection?.on("requestReceived", (List<Object?>? arguments) {
      if (arguments != null && arguments.isNotEmpty) {
        final request = arguments[0] as Map<String, dynamic>;
        onRequestReceived?.call(request);
      }
    });

    await _hubConnection?.start();
    await _hubConnection?.invoke("JoinRestaurantGroup", args: [_restaurantId]);
  }

  Future<void> sendRequest(Map<String, dynamic> request) async {
    await _hubConnection?.invoke("SendRequestToStaff", args: [_restaurantId, request]);
  }

  Future<void> stop() async {
    await _hubConnection?.stop();
  }
}
