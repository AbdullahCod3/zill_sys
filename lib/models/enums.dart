// Shared domain enums.

/// Demo customer mood — drives the scripted scenario (calm vs frustrated).
enum Mood { calm, frustrated }

/// Ranking tier of a suggested reply (prototype: Recommended / More likely / Maybe).
enum AnswerTier { recommended, likely, maybe }

/// Transcript speaker (diarization label).
enum Speaker { agent, customer }

/// Model confidence in the suggested answer (PRD §11).
enum Confidence { high, medium, low }

extension ConfidenceCodec on Confidence {
  String get code => name;
  static Confidence fromCode(String? value) => switch (value) {
    'high' => Confidence.high,
    'medium' => Confidence.medium,
    'low' => Confidence.low,
    _ => Confidence.medium,
  };
}

extension SpeakerCodec on Speaker {
  String get code => name;
  static Speaker fromCode(String? value) =>
      value == 'agent' ? Speaker.agent : Speaker.customer;
}

/// Why an escalation fired (PRD §13).
enum EscalationReason { angerThreshold, managerRequest }

extension EscalationReasonCodec on EscalationReason {
  String get code => switch (this) {
    EscalationReason.angerThreshold => 'anger_threshold',
    EscalationReason.managerRequest => 'manager_request',
  };
}
