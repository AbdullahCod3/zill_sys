import 'dart:async';

import '../../models/transcript_line.dart';
import 'audio_source.dart';

/// Demo [AudioSource] that replays a scripted, timed transcript instead of
/// streaming real WebRTC audio to Deepgram. Downstream logic can't tell the
/// difference — it only sees [transcript] events (rule #1).
class SimulatedWebRtcSource implements AudioSource {
  SimulatedWebRtcSource(this._script);

  final List<ScriptedUtterance> _script;
  final _controller = StreamController<TranscriptLine>.broadcast();
  final List<Timer> _timers = [];
  bool _running = false;

  @override
  Stream<TranscriptLine> get transcript => _controller.stream;

  @override
  bool get isRunning => _running;

  @override
  Future<void> start() async {
    if (_running) return;
    _running = true;
    for (final u in _script) {
      _timers.add(
        Timer(u.delay, () {
          if (!_running) return;
          _controller.add(
            TranscriptLine(
              speaker: u.speaker,
              text: u.text,
              language: u.language,
              at: DateTime.now(),
            ),
          );
        }),
      );
    }
  }

  @override
  Future<void> stop() async {
    _running = false;
    for (final t in _timers) {
      t.cancel();
    }
    _timers.clear();
  }

  @override
  Future<void> dispose() async {
    await stop();
    await _controller.close();
  }
}
