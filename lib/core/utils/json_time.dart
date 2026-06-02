/// Timestamp ⇄ DateTime helpers for the data-access boundary.
///
/// This phase has no live Firestore, so we avoid a hard dependency on
/// `cloud_firestore`'s `Timestamp`. [parseTimestamp] accepts whatever the source
/// hands us — ISO string, epoch millis, an existing [DateTime], or an object
/// exposing `toDate()` (Firestore `Timestamp`) — so live reads drop in later
/// without touching the models.
DateTime? parseTimestamp(dynamic value) {
  if (value == null) return null;
  if (value is DateTime) return value;
  if (value is int) return DateTime.fromMillisecondsSinceEpoch(value);
  if (value is String) return DateTime.tryParse(value);
  try {
    // Firestore Timestamp exposes toDate().
    final dynamic d = (value as dynamic).toDate();
    if (d is DateTime) return d;
  } catch (_) {
    /* not a Timestamp */
  }
  return null;
}

/// Serializes a [DateTime] for storage (ISO 8601). Replace with `Timestamp`
/// when wiring live Firestore writes.
String? dateTimeToJson(DateTime? value) => value?.toIso8601String();
