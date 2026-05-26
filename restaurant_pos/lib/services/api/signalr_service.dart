import 'package:signalr_netcore/signalr_client.dart';
import 'api_config.dart';

class SignalRService {
  HubConnection? _hubConnection;
  final String _token;
  final String _restaurantId;

  SignalRService(this._token, this._restaurantId);

  Future<void> initTableHub({
    required Function(String tableId, String status) onTableStatusChanged,
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

    await _hubConnection?.start();
    await _hubConnection?.invoke("JoinRestaurantGroup", args: [_restaurantId]);
  }

  Future<void> stop() async {
    await _hubConnection?.stop();
  }
}
