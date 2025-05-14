import 'dart:convert';
import 'package:pusher_client_socket/pusher_client_socket.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'capi.dart';

class PusherService {
  late PusherClient pusher;
  late PrivateChannel channel;
  final url = ApiChat.baseUrl + ApiChat.pusherAuth;
  PusherService();

  Future<void> initPusher() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('accessToken');

    if (token == null) {
      throw Exception("Token tidak ditemukan. Silakan login ulang.");
    }
    pusher = PusherClient(
      options: PusherOptions(
        key: "jiqaw1otjj4hmofqhz8n",
        cluster: "mt1",
        encrypted: false,
        host: ApiChat.baseUrl,
        wsPort: 8080,
        authOptions: PusherAuthOptions(
          url,
          headers: {
            "Authorization": "Bearer $token",
            "Content-Type": "application/json",
          },
        ),
      ),
    );

    pusher.onConnectionEstablished((_) {
      print("Koneksi berhasil dengan socket_id: ${pusher.socketId}");
    });

    pusher.onConnectionError((error) {
      print("Error koneksi: ${error.message}");
    });
  }

  void subscribeToChannel(String channelName) {
    channel = pusher.subscribe(channelName);

    channel.bind("new-message", (event) {
      final data = jsonDecode(event["data"] ?? '{}');
      print("Pesan baru: $data");
    });
  }

  void disconnect() {
    channel.unsubscribe();
    pusher.disconnect();
  }
}
