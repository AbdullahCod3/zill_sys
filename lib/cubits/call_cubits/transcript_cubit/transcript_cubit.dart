import 'dart:async';

import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../models/transcript_line.dart';
import '../../../services/audio/audio_source.dart';

part 'transcript_state.dart';

/// Accumulates the live diarized transcript from an [AudioSource]. Source-
/// agnostic (rule #1): it only consumes the transcript stream.
class TranscriptCubit extends Cubit<TranscriptState> {
  TranscriptCubit() : super(const TranscriptInitial());

  StreamSubscription<TranscriptLine>? _sub;
  final List<TranscriptLine> _lines = [];

  /// Subscribe to a source's transcript. Replaces any prior subscription.
  void bind(AudioSource source) {
    _sub?.cancel();
    _sub = source.transcript.listen((line) {
      _lines.add(line);
      emit(TranscriptUpdated(List.unmodifiable(_lines)));
    });
  }

  /// Append a scripted line directly (e.g. the follow-up utterance injected when
  /// the agent re-reads the call). Keeps the demo deterministic without routing
  /// through the audio source.
  void addLine(TranscriptLine line) {
    _lines.add(line);
    emit(TranscriptUpdated(List.unmodifiable(_lines)));
  }

  /// Concatenated customer text — what a real analysis cycle would embed.
  String get customerText => _lines
      .where((l) => l.speaker.name == 'customer')
      .map((l) => l.text)
      .join(' ');

  void clear() {
    _lines.clear();
    emit(const TranscriptInitial());
  }

  @override
  Future<void> close() {
    _sub?.cancel();
    return super.close();
  }
}
