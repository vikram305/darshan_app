import 'package:flutter/material.dart';
import 'package:flutter_webrtc/flutter_webrtc.dart';

class VideoRendererWidget extends StatefulWidget {
  final MediaStream? stream;
  final bool isLocal;
  final bool mirror;

  const VideoRendererWidget({
    super.key,
    required this.stream,
    this.isLocal = false,
    this.mirror = false,
  });

  @override
  State<VideoRendererWidget> createState() => _VideoRendererWidgetState();
}

class _VideoRendererWidgetState extends State<VideoRendererWidget> {
  final RTCVideoRenderer _renderer = RTCVideoRenderer();
  bool _isRendererInitialized = false;

  @override
  void initState() {
    super.initState();
    _initRenderer();
  }

  Future<void> _initRenderer() async {
    await _renderer.initialize();
    if (mounted) {
      setState(() {
        _isRendererInitialized = true;
      });
      if (widget.stream != null) {
        _renderer.srcObject = widget.stream;
      }
    }
  }

  @override
  void didUpdateWidget(covariant VideoRendererWidget oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.stream != oldWidget.stream && _isRendererInitialized) {
      _renderer.srcObject = widget.stream;
      setState(() {});
    }
  }

  @override
  void dispose() {
    _renderer.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (!_isRendererInitialized) {
      return const Center(
        child: CircularProgressIndicator(),
      );
    }

    if (widget.stream == null || widget.stream!.getVideoTracks().isEmpty || !widget.stream!.getVideoTracks().first.enabled) {
      // Stream is null or video is disabled
      return Container(
        color: Colors.black87,
        child: const Center(
          child: Icon(
            Icons.videocam_off,
            color: Colors.white54,
            size: 48,
          ),
        ),
      );
    }

    return RTCVideoView(
      _renderer,
      objectFit: RTCVideoViewObjectFit.RTCVideoViewObjectFitCover,
      mirror: widget.isLocal || widget.mirror,
    );
  }
}
