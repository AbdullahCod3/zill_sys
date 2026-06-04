import 'package:flutter/material.dart';
import 'package:flutter_webrtc/flutter_webrtc.dart';

/// Hidden sink that plays the remote peer's audio. On Flutter web an
/// [RTCVideoView] backs the stream with a media element, so a 1×1 instance is
/// enough to hear the other party (no video is rendered). Mount it anywhere in
/// the connected call's widget tree.
class RemoteAudio extends StatelessWidget {
  final RTCVideoRenderer? renderer;

  const RemoteAudio({super.key, required this.renderer});

  @override
  Widget build(BuildContext context) {
    final r = renderer;
    if (r == null) return const SizedBox.shrink();
    return SizedBox(width: 1, height: 1, child: RTCVideoView(r));
  }
}
