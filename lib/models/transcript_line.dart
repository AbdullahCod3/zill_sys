import 'package:equatable/equatable.dart';

import 'enums.dart';

/// One diarized turn in the live transcript.
class TranscriptLine extends Equatable {
  final Speaker speaker;
  final String text;

  /// Language code of this turn ('ar' | 'en').
  final String language;
  final DateTime at;

  const TranscriptLine({
    required this.speaker,
    required this.text,
    required this.language,
    required this.at,
  });

  /// Stored shape for `calls.transcript` turn maps (PRD §10).
  Map<String, dynamic> toJson() => {
    'speaker': speaker.code,
    'text': text,
    'lang': language,
    'at': at.toIso8601String(),
  };

  factory TranscriptLine.fromJson(Map<String, dynamic> json) => TranscriptLine(
    speaker: SpeakerCodec.fromCode(json['speaker'] as String?),
    text: json['text'] as String? ?? '',
    language: json['lang'] as String? ?? 'en',
    at: DateTime.tryParse(json['at'] as String? ?? '') ?? DateTime.now(),
  );

  @override
  List<Object?> get props => [speaker, text, language, at];
}
