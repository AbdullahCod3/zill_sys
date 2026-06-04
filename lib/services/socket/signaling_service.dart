import 'dart:async';
import 'dart:convert';

import 'package:web_socket_channel/web_socket_channel.dart';

/// Thin WebSocket client to the Dart Frog signaling relay. It carries only
/// signaling JSON (offer / answer / ICE / peer-ready / bye) between the two
/// peers — never the audio itself, which flows peer-to-peer over WebRTC.
class SignalingService {
  WebSocketChannel? _channel;
  StreamSubscription<dynamic>? _sub;
  final StreamController<Map<String, dynamic>> _messages =
      StreamController<Map<String, dynamic>>.broadcast();

  /// Decoded inbound signaling messages.
  Stream<Map<String, dynamic>> get messages => _messages.stream;

  /// Open the socket to [url] (e.g. `wss://host/signal?room=demo&role=agent`).
  void connect(String url) {
    if (_channel != null) return;
    final channel = WebSocketChannel.connect(Uri.parse(url));
    _channel = channel;
    _sub = channel.stream.listen(
      (data) {
        try {
          final decoded = jsonDecode(data as String);
          if (decoded is Map<String, dynamic>) _messages.add(decoded);
        } catch (_) {
          // Ignore malformed frames.
        }
      },
      onError: (_) {},
      onDone: () {},
      cancelOnError: false,
    );
  }

  /// Send a signaling message (JSON-encoded).
  void send(Map<String, dynamic> message) {
    _channel?.sink.add(jsonEncode(message));
  }

  /// Close the current socket but keep the service reusable — a later
  /// [connect] re-opens it (used by "Call again"). [messages] stays open.
  Future<void> disconnect() async {
    await _sub?.cancel();
    _sub = null;
    await _channel?.sink.close();
    _channel = null;
  }

  /// Close the socket and release resources.
  Future<void> dispose() async {
    await _sub?.cancel();
    await _channel?.sink.close();
    _channel = null;
    if (!_messages.isClosed) await _messages.close();
  }
}
