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

  /// When `true`, the live transcript comes from real Deepgram streaming STT
  /// (browser mic → backend `/transcribe` → Deepgram). When `false`, the
  /// scripted `SimulatedWebRtcSource` is used (no key needed). Requires the
  /// backend to have `DEEPGRAM_API_KEY` set and the page served over HTTPS.
  static const bool useRealTranscription = true;

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

  /// `wss://<host>/transcribe?room=…&role=…&lang=…&sr=…` — the Deepgram STT
  /// relay, derived from the page origin like [signalingUrl]. [sampleRate] is
  /// the rate of the linear16 PCM the browser will send (the AudioContext rate,
  /// typically 48000), so the backend can tell Deepgram the correct rate.
  static String transcribeUrl({
    required String role,
    required String lang,
    required int sampleRate,
    String? room,
  }) {
    final base = Uri.base;
    final scheme = base.scheme == 'https' ? 'wss' : 'ws';
    final authority = base.hasPort ? '${base.host}:${base.port}' : base.host;
    return '$scheme://$authority/transcribe'
        '?room=${room ?? defaultRoom}&role=$role&lang=$lang&sr=$sampleRate';
  }
}
