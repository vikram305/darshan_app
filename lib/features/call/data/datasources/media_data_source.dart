import 'package:flutter_webrtc/flutter_webrtc.dart';
import '../../domain/entities/local_media_entity.dart';

abstract class MediaDataSource {
  /// Calls [navigator.mediaDevices.getUserMedia]
  Future<LocalMediaEntity> getUserMedia({
    required bool enableAudio,
    required bool enableVideo,
  });

  /// Calls [navigator.mediaDevices.enumerateDevices]
  Future<List<MediaDeviceInfo>> enumerateDevices();

  /// Fails if front camera not found.
  Future<LocalMediaEntity> switchCamera();
}
