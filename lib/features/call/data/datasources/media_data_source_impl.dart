import 'package:darshan_app/core/error/exception.dart';
import 'package:darshan_app/features/call/domain/entities/local_media_entity.dart';
import 'package:flutter_webrtc/flutter_webrtc.dart';
import 'media_data_source.dart';
import 'package:permission_handler/permission_handler.dart';

class MediaDataSourceImpl implements MediaDataSource {
  MediaStream? _localStream;
  bool _isFrontCamera = true;

  @override
  Future<LocalMediaEntity> getUserMedia({
    required bool enableAudio,
    required bool enableVideo,
  }) async {
    // Request permissions
    Map<Permission, PermissionStatus> statuses = await [
      if (enableAudio) Permission.microphone,
      if (enableVideo) Permission.camera,
    ].request();

    if (enableAudio && statuses[Permission.microphone] != PermissionStatus.granted) {
      throw MediaPermissionException('Microphone permission denied');
    }
    if (enableVideo && statuses[Permission.camera] != PermissionStatus.granted) {
      throw MediaPermissionException('Camera permission denied');
    }

    try {
      final Map<String, dynamic> mediaConstraints = {
        'audio': enableAudio,
        'video': enableVideo
            ? {
                'mandatory': {
                  'minWidth': '640',
                  'minHeight': '480',
                  'minFrameRate': '30',
                },
                'facingMode': 'user',
                'optional': [],
              }
            : false,
      };

      _localStream = await navigator.mediaDevices.getUserMedia(mediaConstraints);
      final devices = await enumerateDevices();

      return LocalMediaEntity(
        localStream: _localStream,
        isMicEnabled: enableAudio,
        isCameraEnabled: enableVideo,
        isFrontCamera: _isFrontCamera,
        availableDevices: devices,
      );
    } catch (e) {
      throw ServerException('Failed to get user media: $e');
    }
  }

  @override
  Future<List<MediaDeviceInfo>> enumerateDevices() async {
    try {
      return await navigator.mediaDevices.enumerateDevices();
    } catch (e) {
      throw ServerException('Failed to enumerate devices: $e');
    }
  }

  @override
  Future<LocalMediaEntity> switchCamera() async {
    if (_localStream == null) {
      throw ServerException('Local stream not initialized');
    }

    final videoTracks = _localStream!.getVideoTracks();
    if (videoTracks.isEmpty) {
      throw ServerException('No video track available to switch');
    }

    try {
      final track = videoTracks.first;
      final success = await Helper.switchCamera(track);
      if (success) {
        _isFrontCamera = !_isFrontCamera;
      }
      
      final devices = await enumerateDevices();

      return LocalMediaEntity(
        localStream: _localStream,
        isMicEnabled: _localStream!.getAudioTracks().isNotEmpty && _localStream!.getAudioTracks().first.enabled,
        isCameraEnabled: videoTracks.isNotEmpty && videoTracks.first.enabled,
        isFrontCamera: _isFrontCamera,
        availableDevices: devices,
      );
    } catch (e) {
      throw ServerException('Failed to switch camera: $e');
    }
  }
}
