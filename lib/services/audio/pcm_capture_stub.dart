import 'dart:typed_data';

/// Non-web stub (Dart VM / tests). Real audio capture only exists on web; this
/// keeps the codebase compiling off-web. See `pcm_capture_web.dart`.
class PcmCapture {
  Future<void> start() async {
    throw UnsupportedError('PcmCapture is only available on the web.');
  }

  Stream<Uint8List> get frames => const Stream.empty();

  int get sampleRate => 48000;

  Future<void> stop() async {}
}
