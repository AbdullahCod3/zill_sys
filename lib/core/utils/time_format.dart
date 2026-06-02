/// Formats a duration in seconds as `mm:ss` (matches the prototype's `fmt`).
String formatMmss(int totalSeconds) {
  final m = (totalSeconds ~/ 60).toString().padLeft(2, '0');
  final s = (totalSeconds % 60).toString().padLeft(2, '0');
  return '$m:$s';
}
