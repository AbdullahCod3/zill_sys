import 'dart:async';
import 'dart:js_interop';
import 'dart:typed_data';

import 'package:web/web.dart' as web;

/// Captures the local mic as little-endian 16-bit PCM via the Web Audio API.
///
/// Opens its own `getUserMedia` mic handle (independent of flutter_webrtc's
/// stream — avoids bridging its Dart `MediaStream` to a JS one). Uses a
/// `ScriptProcessorNode`: deprecated but dependency-free (no worklet module to
/// serve); an `AudioWorklet` is the later upgrade. Float32 samples are emitted
/// at the AudioContext's native rate ([sampleRate]) — no resampling.
class PcmCapture {
  final _controller = StreamController<Uint8List>.broadcast();

  web.MediaStream? _stream;
  web.AudioContext? _ctx;
  web.MediaStreamAudioSourceNode? _source;
  web.ScriptProcessorNode? _processor;
  web.GainNode? _mute;

  Stream<Uint8List> get frames => _controller.stream;

  int get sampleRate => _ctx?.sampleRate.toInt() ?? 48000;

  Future<void> start() async {
    final constraints = web.MediaStreamConstraints(audio: true.toJS);
    final stream = await web.window.navigator.mediaDevices
        .getUserMedia(constraints)
        .toDart;
    _stream = stream;

    final ctx = web.AudioContext();
    _ctx = ctx;
    _source = ctx.createMediaStreamSource(stream);
    final processor = ctx.createScriptProcessor(4096, 1, 1);
    _processor = processor;

    processor.onaudioprocess = (web.AudioProcessingEvent event) {
      final input = event.inputBuffer.getChannelData(0).toDart;
      _controller.add(_float32ToPcm16(input));
    }.toJS;

    // Pump the processor without echoing the mic back: route through a muted
    // gain node into the destination (ScriptProcessorNode needs a downstream
    // connection to fire `onaudioprocess`).
    final mute = ctx.createGain();
    mute.gain.value = 0;
    _mute = mute;
    _source!.connect(processor);
    processor.connect(mute);
    mute.connect(ctx.destination);
  }

  Future<void> stop() async {
    _processor?.disconnect();
    _source?.disconnect();
    _mute?.disconnect();
    for (final track in _stream?.getTracks().toDart ?? const []) {
      track.stop();
    }
    final ctx = _ctx;
    if (ctx != null) await ctx.close().toDart;
    _processor = null;
    _source = null;
    _mute = null;
    _stream = null;
    _ctx = null;
    if (!_controller.isClosed) await _controller.close();
  }

  static Uint8List _float32ToPcm16(Float32List samples) {
    final bytes = Uint8List(samples.length * 2);
    final view = ByteData.view(bytes.buffer);
    for (var i = 0; i < samples.length; i++) {
      var s = samples[i];
      if (s < -1) {
        s = -1;
      } else if (s > 1) {
        s = 1;
      }
      view.setInt16(i * 2, (s * 32767).round(), Endian.little);
    }
    return bytes;
  }
}
