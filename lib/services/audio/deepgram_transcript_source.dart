import 'dart:async';
import 'dart:convert';
import 'dart:typed_data';

import 'package:web_socket_channel/web_socket_channel.dart';

import '../../core/constants/webrtc_config.dart';
import '../../models/enums.dart';
import '../../models/transcript_line.dart';
import 'audio_source.dart';
import 'pcm_capture.dart';

/// Real [AudioSource] backed by Deepgram streaming STT (PRD §12).
///
/// Captures the local mic as linear16 PCM and streams it to the backend
/// `/transcribe` relay tagged with [role]; the relay opens a Deepgram socket and
/// returns diarized (role-labelled) transcript lines. The agent constructs this
/// with `consumeTranscript: true` (renders the merged transcript); the customer
/// uses `consumeTranscript: false` (uplink only — its lines are routed to the
/// agent server-side).
class DeepgramTranscriptSource implements AudioSource {
  DeepgramTranscriptSource({
    required this.role,
    required this.lang,
    this.consumeTranscript = true,
  });

  /// `agent` or `customer` — also the speaker label for this stream's lines.
  final String role;

  /// `ar` or `en` — passed to Deepgram as the language.
  final String lang;

  /// Whether to surface inbound transcript lines (agent) or just uplink (customer).
  final bool consumeTranscript;

  final PcmCapture _capture = PcmCapture();
  final _controller = StreamController<TranscriptLine>.broadcast();
  WebSocketChannel? _ws;
  StreamSubscription<Uint8List>? _frameSub;
  StreamSubscription<dynamic>? _wsSub;
  bool _running = false;

  @override
  Stream<TranscriptLine> get transcript => _controller.stream;

  @override
  bool get isRunning => _running;

  @override
  Future<void> start() async {
    if (_running) return;
    _running = true;

    await _capture.start();
    final ws = WebSocketChannel.connect(
      Uri.parse(
        WebRtcConfig.transcribeUrl(
          role: role,
          lang: lang,
          sampleRate: _capture.sampleRate,
        ),
      ),
    );
    _ws = ws;

    // Mic PCM → backend relay → Deepgram.
    _frameSub = _capture.frames.listen((bytes) => ws.sink.add(bytes));

    if (consumeTranscript) {
      _wsSub = ws.stream.listen((raw) {
        if (raw is! String) return;
        try {
          final m = jsonDecode(raw) as Map<String, dynamic>;
          if (m['type'] != 'transcript') return;
          _controller.add(
            TranscriptLine(
              speaker: SpeakerCodec.fromCode(m['speaker'] as String?),
              text: m['text'] as String? ?? '',
              language: m['lang'] as String? ?? lang,
              at: DateTime.tryParse(m['at'] as String? ?? '') ?? DateTime.now(),
              isFinal: m['final'] as bool? ?? true,
            ),
          );
        } catch (_) {
          // Ignore malformed frames.
        }
      });
    }
  }

  @override
  Future<void> stop() async {
    _running = false;
    await _frameSub?.cancel();
    _frameSub = null;
    await _wsSub?.cancel();
    _wsSub = null;
    await _capture.stop();
    await _ws?.sink.close();
    _ws = null;
  }

  @override
  Future<void> dispose() async {
    await stop();
    if (!_controller.isClosed) await _controller.close();
  }
}
