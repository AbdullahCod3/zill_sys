import 'dart:convert';

import 'package:dart_frog/dart_frog.dart';
import 'package:dart_frog_web_socket/dart_frog_web_socket.dart';

/// In-memory rooms: roomId → connected peers. A 2-person demo needs no DB.
final Map<String, List<WebSocketChannel>> _rooms = {};

/// `/signal?room=demo&role=customer|agent` — a thin relay.
///
/// - When the **second** peer joins a room, both get `{"type":"peer-ready"}`
///   (the customer then sends the offer, the agent waits for it).
/// - Any message from one peer is relayed verbatim to the other.
/// - On disconnect, the remaining peer gets `{"type":"bye"}`.
Future<Response> onRequest(RequestContext context) async {
  final room = context.request.uri.queryParameters['room'] ?? 'demo';

  final handler = webSocketHandler((channel, protocol) {
    final peers = _rooms.putIfAbsent(room, () => []);
    peers.add(channel);

    if (peers.length == 2) {
      final ready = jsonEncode({'type': 'peer-ready'});
      for (final peer in peers) {
        peer.sink.add(ready);
      }
    }

    channel.stream.listen(
      (message) {
        // Relay to the other peer(s) in the room.
        for (final peer in peers) {
          if (peer != channel) peer.sink.add(message);
        }
      },
      onDone: () {
        peers.remove(channel);
        final bye = jsonEncode({'type': 'bye'});
        for (final peer in peers) {
          peer.sink.add(bye);
        }
        if (peers.isEmpty) _rooms.remove(room);
      },
      onError: (_) {
        peers.remove(channel);
        if (peers.isEmpty) _rooms.remove(room);
      },
    );
  });

  return handler(context);
}
