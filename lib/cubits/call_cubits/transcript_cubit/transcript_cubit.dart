import 'dart:async';

import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../models/enums.dart';
import '../../../models/transcript_line.dart';
import '../../../services/audio/audio_source.dart';

part 'transcript_state.dart';

/// Accumulates the live diarized transcript from an [AudioSource]. Source-
/// agnostic (rule #1): it only consumes the transcript stream.
class TranscriptCubit extends Cubit<TranscriptState> {
  TranscriptCubit() : super(const TranscriptInitial());

  StreamSubscription<TranscriptLine>? _sub;
  final List<TranscriptLine> _lines = [];

  /// In-progress (interim) line per speaker, rendered after the committed lines
  /// and replaced as the speaker keeps talking — so a sentence grows live and
  /// lands as one bubble instead of fragmenting.
  final Map<Speaker, TranscriptLine> _live = {};

  void _publish() {
    emit(TranscriptUpdated(List.unmodifiable([..._lines, ..._live.values])));
  }

  /// Subscribe to a source's transcript. Replaces any prior subscription.
  void bind(AudioSource source) {
    _sub?.cancel();
    _sub = source.transcript.listen((line) {
      if (line.isFinal) {
        _live.remove(line.speaker);
        _lines.add(line);
      } else {
        _live[line.speaker] = line;
      }
      _publish();
    });
  }

  /// Append a scripted line directly (e.g. the follow-up utterance injected when
  /// the agent re-reads the call). Keeps the demo deterministic without routing
  /// through the audio source.
  void addLine(TranscriptLine line) {
    _lines.add(line);
    _publish();
  }

  /// Concatenated customer text — what a real analysis cycle would embed.
  String get customerText => _lines
      .where((l) => l.speaker.name == 'customer')
      .map((l) => l.text)
      .join(' ');

  void clear() {
    _lines.clear();
    _live.clear();
    emit(const TranscriptInitial());
  }

  @override
  Future<void> close() {
    _sub?.cancel();
    return super.close();
  }
}
