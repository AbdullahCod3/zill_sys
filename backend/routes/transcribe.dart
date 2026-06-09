import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:dart_frog/dart_frog.dart';
import 'package:dart_frog_web_socket/dart_frog_web_socket.dart';
import 'package:web_socket_channel/io.dart';

/// Per-room registry of the **agent's** transcript socket, so transcripts
/// derived from the customer's audio can be routed to the agent's UI. A 2-person
/// demo needs no DB.
final Map<String, WebSocketChannel> _agentByRoom = {};

/// `/transcribe?room=demo&role=agent|customer&lang=ar|en&sr=48000`
///
/// Per-browser, role-based streaming STT relay (PRD §12). Each browser streams
/// its own mic as linear16 PCM frames; this route opens an outbound Deepgram
/// connection per client, tags every transcript with the connection's `role`
/// (the speaker label — no diarization guessing), and forwards it to the room's
/// agent socket. The agent's own audio routes back to itself, so agent lines
/// appear too.
Future<Response> onRequest(RequestContext context) async {
  final params = context.request.uri.queryParameters;
  final room = params['room'] ?? 'demo';
  final role = params['role'] ?? 'customer';
  final lang = params['lang'] ?? 'en';
  final sampleRate = params['sr'] ?? '48000';

  final apiKey = Platform.environment['DEEPGRAM_API_KEY'];

  final handler = webSocketHandler((channel, protocol) {
    if (apiKey == null || apiKey.isEmpty) {
      channel.sink.add(
        jsonEncode({'type': 'error', 'message': 'DEEPGRAM_API_KEY not set'}),
      );
      channel.sink.close();
      return;
    }

    if (role == 'agent') _agentByRoom[room] = channel;

    final dgUri = Uri.parse(
      'wss://api.deepgram.com/v1/listen'
      '?model=nova-3&language=$lang'
      '&encoding=linear16&sample_rate=$sampleRate&channels=1'
      '&punctuate=true&smart_format=true'
      '&interim_results=true&utterance_end_ms=1000&endpointing=300',
    );

    WebSocketChannel? dg;
    Timer? keepAlive;

    // Accumulates the current utterance's finalized segments so one spoken
    // sentence is committed as a single bubble (not 2–3 per Deepgram `is_final`).
    var utter = '';

    // Send one transcript message to the room's agent socket. `isFinal` marks a
    // committed bubble; partials stream the in-progress utterance for low latency.
    void emit(String text, {required bool isFinal}) {
      if (text.trim().isEmpty) return;
      _agentByRoom[room]?.sink.add(
        jsonEncode({
          'type': 'transcript',
          'speaker': role,
          'text': text,
          'lang': lang,
          'final': isFinal,
          'at': DateTime.now().toUtc().toIso8601String(),
        }),
      );
    }

    // Anything queued before the Deepgram socket finishes connecting.
    final pending = <List<int>>[];

    void cleanup() {
      keepAlive?.cancel();
      dg?.sink.close();
      if (_agentByRoom[room] == channel) _agentByRoom.remove(room);
    }

    // Open the outbound Deepgram socket (server-side dart:io allows the
    // Authorization header on the handshake).
    WebSocket.connect(
      dgUri.toString(),
      headers: {'Authorization': 'Token $apiKey'},
    ).then((socket) {
      final dgChannel = IOWebSocketChannel(socket);
      dg = dgChannel;

      // Flush anything captured during the connect handshake.
      for (final frame in pending) {
        dgChannel.sink.add(frame);
      }
      pending.clear();

      keepAlive = Timer.periodic(const Duration(seconds: 8), (_) {
        dgChannel.sink.add(jsonEncode({'type': 'KeepAlive'}));
      });

      dgChannel.stream.listen(
        (raw) {
          if (raw is! String) return;
          final Map<String, dynamic> msg;
          try {
            msg = jsonDecode(raw) as Map<String, dynamic>;
          } catch (_) {
            return;
          }
          // End-of-utterance signal (utterance_end_ms): flush whatever finals
          // we've accumulated as one committed bubble.
          if (msg['type'] == 'UtteranceEnd') {
            if (utter.isNotEmpty) {
              emit(utter, isFinal: true);
              utter = '';
            }
            return;
          }

          if (msg['type'] != 'Results') return;

          final alts =
              (msg['channel'] as Map?)?['alternatives'] as List? ?? const [];
          final txt = alts.isEmpty
              ? ''
              : (alts.first as Map?)?['transcript'] as String? ?? '';

          if (msg['is_final'] == true) {
            // A finalized segment: append it to the current utterance.
            if (txt.trim().isNotEmpty) {
              utter = utter.isEmpty ? txt : '$utter $txt';
            }
            if (msg['speech_final'] == true) {
              // Deepgram detected the end of speech → commit the bubble.
              emit(utter, isFinal: true);
              utter = '';
            } else {
              // More may follow before the endpoint; stream what we have.
              emit(utter, isFinal: false);
            }
          } else {
            // Interim hypothesis: stream committed-so-far + the live guess.
            final live = utter.isEmpty ? txt : '$utter $txt';
            emit(live, isFinal: false);
          }
        },
        onDone: cleanup,
        onError: (_) => cleanup(),
      );
    }).catchError((_) {
      channel.sink.add(
        jsonEncode({'type': 'error', 'message': 'Deepgram connect failed'}),
      );
    });

    // Client → Deepgram: forward binary PCM frames.
    channel.stream.listen(
      (data) {
        if (data is List<int>) {
          final socket = dg;
          if (socket != null) {
            socket.sink.add(data);
          } else {
            pending.add(data);
          }
        }
      },
      onDone: () {
        dg?.sink.add(jsonEncode({'type': 'CloseStream'}));
        cleanup();
      },
      onError: (_) => cleanup(),
    );
  });

  return handler(context);
}
