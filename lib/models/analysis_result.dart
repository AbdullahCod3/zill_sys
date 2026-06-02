import 'package:equatable/equatable.dart';

import 'answer_option.dart';
import 'citation.dart';
import 'enums.dart';

/// The structured result of one analysis cycle (PRD §11). The base JSON shape
/// matches the model contract exactly; [options] is a demo-only UI extension
/// (the cockpit shows 3 candidate replies, one recommended).
class AnalysisResult extends Equatable {
  final String language; // 'ar' | 'en'
  final String problemSummary;
  final String suggestedAnswer;
  final List<AnswerOption> options;
  final List<Citation> citations;
  final int angerScore; // 0–10
  final bool escalationRequested;
  final Confidence confidence;

  const AnalysisResult({
    required this.language,
    required this.problemSummary,
    required this.suggestedAnswer,
    required this.citations,
    required this.angerScore,
    required this.escalationRequested,
    required this.confidence,
    this.options = const [],
  });

  factory AnalysisResult.fromJson(Map<String, dynamic> json) {
    final citations = (json['citations'] as List<dynamic>? ?? [])
        .map((e) => Citation.fromJson(e as Map<String, dynamic>))
        .toList();
    return AnalysisResult(
      language: json['language'] as String? ?? 'en',
      problemSummary: json['problem_summary'] as String? ?? '',
      suggestedAnswer: json['suggested_answer'] as String? ?? '',
      citations: citations,
      angerScore: (json['anger_score'] as num?)?.toInt() ?? 0,
      escalationRequested: json['escalation_requested'] as bool? ?? false,
      confidence: ConfidenceCodec.fromCode(json['confidence'] as String?),
    );
  }

  Map<String, dynamic> toJson() => {
    'language': language,
    'problem_summary': problemSummary,
    'suggested_answer': suggestedAnswer,
    'citations': citations.map((c) => c.toJson()).toList(),
    'anger_score': angerScore,
    'escalation_requested': escalationRequested,
    'confidence': confidence.code,
  };

  @override
  List<Object?> get props => [
    language,
    problemSummary,
    suggestedAnswer,
    options,
    citations,
    angerScore,
    escalationRequested,
    confidence,
  ];
}
