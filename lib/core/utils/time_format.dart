import 'package:intl/intl.dart';

/// Formats a duration in seconds as `mm:ss` (matches the prototype's `fmt`).
String formatMmss(int totalSeconds) {
  final m = (totalSeconds ~/ 60).toString().padLeft(2, '0');
  final s = (totalSeconds % 60).toString().padLeft(2, '0');
  return '$m:$s';
}

/// Formats a date as e.g. `Apr 3, 2026` for compact display (e.g. issue dates).
String formatShortDate(DateTime d) => DateFormat('MMM d, yyyy').format(d);
