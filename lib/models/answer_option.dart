import 'package:equatable/equatable.dart';

import 'enums.dart';

/// One of the candidate replies Shadow suggests in the cockpit. Strings are
/// already resolved to the active language by the producing service/cubit.
class AnswerOption extends Equatable {
  /// Short category label, e.g. "Resolve billing & confirm outage".
  final String tag;

  /// Agent-ready reply text.
  final String text;

  /// Ranking tier (drives the badge + highlight).
  final AnswerTier tier;

  const AnswerOption({
    required this.tag,
    required this.text,
    this.tier = AnswerTier.recommended,
  });

  /// True for the single top-ranked option.
  bool get recommended => tier == AnswerTier.recommended;

  @override
  List<Object?> get props => [tag, text, tier];
}
