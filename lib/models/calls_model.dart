import 'package:equatable/equatable.dart';

import '../core/utils/json_time.dart';
import 'citation.dart';
import 'transcript_line.dart';

/// Firestore `calls/{callId}` (PRD §10). Written by the backend at call end; in
/// this phase it's assembled client-side for the call-summary view.
class CallsModel extends Equatable {
  final String callId;
  final String agentId;
  final String agentName;
  final String customerId;
  final String customerName;
  final DateTime? startedAt;
  final DateTime? endedAt;
  final int durationSec;
  final String language;
  final String issueCategory;
  final List<TranscriptLine> transcript;
  final bool angerAlertFired;
  final double angerPeakScore;
  final bool suggestionUsed;
  final bool escalated;
  final String? supervisorId;
  final List<Citation> citations;
  final String outcome; // resolved / transferred / dropped

  const CallsModel({
    required this.callId,
    required this.agentId,
    this.agentName = '',
    required this.customerId,
    this.customerName = '',
    this.startedAt,
    this.endedAt,
    this.durationSec = 0,
    this.language = 'en',
    this.issueCategory = '',
    this.transcript = const [],
    this.angerAlertFired = false,
    this.angerPeakScore = 0,
    this.suggestionUsed = false,
    this.escalated = false,
    this.supervisorId,
    this.citations = const [],
    this.outcome = 'resolved',
  });

  factory CallsModel.fromJson(Map<String, dynamic> json, {String? id}) =>
      CallsModel(
        callId: id ?? json['call_id'] as String? ?? '',
        agentId: json['agent_id'] as String? ?? '',
        agentName: json['agent_name'] as String? ?? '',
        customerId: json['customer_id'] as String? ?? '',
        customerName: json['customer_name'] as String? ?? '',
        startedAt: parseTimestamp(json['started_at']),
        endedAt: parseTimestamp(json['ended_at']),
        durationSec: (json['duration_sec'] as num?)?.toInt() ?? 0,
        language: json['language'] as String? ?? 'en',
        issueCategory: json['issue_category'] as String? ?? '',
        transcript: (json['transcript'] as List<dynamic>? ?? [])
            .map((e) => TranscriptLine.fromJson(e as Map<String, dynamic>))
            .toList(),
        angerAlertFired: json['anger_alert_fired'] as bool? ?? false,
        angerPeakScore: (json['anger_peak_score'] as num?)?.toDouble() ?? 0,
        suggestionUsed: json['suggestion_used'] as bool? ?? false,
        escalated: json['escalated'] as bool? ?? false,
        supervisorId: json['supervisor_id'] as String?,
        citations: (json['citations'] as List<dynamic>? ?? [])
            .map((e) => Citation.fromJson(e as Map<String, dynamic>))
            .toList(),
        outcome: json['outcome'] as String? ?? 'resolved',
      );

  Map<String, dynamic> toJson() => {
    'agent_id': agentId,
    'agent_name': agentName,
    'customer_id': customerId,
    'customer_name': customerName,
    'started_at': dateTimeToJson(startedAt),
    'ended_at': dateTimeToJson(endedAt),
    'duration_sec': durationSec,
    'language': language,
    'issue_category': issueCategory,
    'transcript': transcript.map((t) => t.toJson()).toList(),
    'anger_alert_fired': angerAlertFired,
    'anger_peak_score': angerPeakScore,
    'suggestion_used': suggestionUsed,
    'escalated': escalated,
    'supervisor_id': supervisorId,
    'citations': citations.map((c) => c.toJson()).toList(),
    'outcome': outcome,
  };

  CallsModel copyWith({
    String? callId,
    String? agentId,
    String? agentName,
    String? customerId,
    String? customerName,
    DateTime? startedAt,
    DateTime? endedAt,
    int? durationSec,
    String? language,
    String? issueCategory,
    List<TranscriptLine>? transcript,
    bool? angerAlertFired,
    double? angerPeakScore,
    bool? suggestionUsed,
    bool? escalated,
    String? supervisorId,
    List<Citation>? citations,
    String? outcome,
  }) => CallsModel(
    callId: callId ?? this.callId,
    agentId: agentId ?? this.agentId,
    agentName: agentName ?? this.agentName,
    customerId: customerId ?? this.customerId,
    customerName: customerName ?? this.customerName,
    startedAt: startedAt ?? this.startedAt,
    endedAt: endedAt ?? this.endedAt,
    durationSec: durationSec ?? this.durationSec,
    language: language ?? this.language,
    issueCategory: issueCategory ?? this.issueCategory,
    transcript: transcript ?? this.transcript,
    angerAlertFired: angerAlertFired ?? this.angerAlertFired,
    angerPeakScore: angerPeakScore ?? this.angerPeakScore,
    suggestionUsed: suggestionUsed ?? this.suggestionUsed,
    escalated: escalated ?? this.escalated,
    supervisorId: supervisorId ?? this.supervisorId,
    citations: citations ?? this.citations,
    outcome: outcome ?? this.outcome,
  );

  @override
  List<Object?> get props => [
    callId,
    agentId,
    agentName,
    customerId,
    customerName,
    startedAt,
    endedAt,
    durationSec,
    language,
    issueCategory,
    transcript,
    angerAlertFired,
    angerPeakScore,
    suggestionUsed,
    escalated,
    supervisorId,
    citations,
    outcome,
  ];
}
