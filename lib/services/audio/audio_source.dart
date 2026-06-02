import '../../models/enums.dart';
import '../../models/transcript_line.dart';

/// A scripted utterance: speak [text] after [delay] from session start.
/// (Demo content; a real source produces these from live STT instead.)
class ScriptedUtterance {
  final Duration delay;
  final Speaker speaker;
  final String text;
  final String language;

  const ScriptedUtterance({
    required this.delay,
    required this.speaker,
    required this.text,
    required this.language,
  });
}

/// Abstraction over the call's audio + transcription (CLAUDE.md rule #1).
///
/// The demo implementation is [SimulatedWebRtcSource]; a future `SoftphoneSource`
/// can replace it without touching transcript/answer/escalation logic, which all
/// consume only this interface.
abstract class AudioSource {
  /// Diarized transcript lines, emitted live once [start] is called.
  Stream<TranscriptLine> get transcript;

  /// Begin capturing/transcribing now ("Get Answer" — PRD §6). Speech before
  /// this call is not captured.
  Future<void> start();

  /// Halt capture and transcription.
  Future<void> stop();

  bool get isRunning;

  /// Release resources (close the stream).
  Future<void> dispose();
}
