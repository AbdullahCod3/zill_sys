/// Configuration for the real two-way call (WebRTC).
///
/// The signaling WebSocket and the Flutter web app are served from the **same
/// origin** (one local server behind a tunnel), so the signaling URL is derived
/// from the page origin at runtime — nothing here is hard-coded to a tunnel URL.
class WebRtcConfig {
  WebRtcConfig._();

  /// Master switch. When `false`, the customer/agent cubits fall back to the
  /// original timer-driven demo (no mic, no peer connection).
  static const bool useRealCall = true;

  /// Fixed room for the 2-person demo call.
  static const String defaultRoom = 'demo';

  /// ICE servers. STUN only — both machines are on the same LAN, so no TURN
  /// relay is needed (the audio connects directly peer-to-peer).
  static const Map<String, dynamic> iceServers = {
    'iceServers': [
      {
        'urls': ['stun:stun.l.google.com:19302'],
      },
    ],
  };

  /// `wss://<host>/signal?room=…&role=…` derived from the current page origin
  /// (`Uri.base` on Flutter web). An `https` page yields `wss`; `http` → `ws`.
  static String signalingUrl({required String role, String? room}) {
    final base = Uri.base;
    final scheme = base.scheme == 'https' ? 'wss' : 'ws';
    final authority = base.hasPort ? '${base.host}:${base.port}' : base.host;
    return '$scheme://$authority/signal'
        '?room=${room ?? defaultRoom}&role=$role';
  }
}
