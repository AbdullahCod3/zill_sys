/// Captures the local microphone as little-endian 16-bit PCM frames for
/// streaming to the Deepgram relay.
///
/// Web-only: the real implementation uses the Web Audio API (`dart:js_interop` +
/// `package:web`). A no-op stub is exported on the Dart VM so `flutter test` /
/// `flutter analyze` still compile.
library;

export 'pcm_capture_stub.dart'
    if (dart.library.js_interop) 'pcm_capture_web.dart';
