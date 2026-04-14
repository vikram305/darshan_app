import 'package:equatable/equatable.dart';
import 'package:flutter_webrtc/flutter_webrtc.dart';

/// Represents the local device's raw camera/microphone stream state before it is sent to the server.
/// Lives exclusively in `BaseUiCubit` memory; it is never persisted or serialized.
/// [localStream] is null until `InitLocalMediaUsecase` succeeds.
class LocalMediaEntity extends Equatable {
  /// The live WebRTC stream from `getUserMedia`. Null before initialization or after cleanup.
  final MediaStream? localStream;

  /// Whether the microphone track is currently enabled.
  final bool isMicEnabled;

  /// Whether the camera track is currently enabled.
  final bool isCameraEnabled;

  /// True when the front (selfie) camera is active; false for rear camera.
  final bool isFrontCamera;

  /// All enumerated audio/video devices available on the current device.
  final List<MediaDeviceInfo> availableDevices;

  const LocalMediaEntity({
    required this.localStream,
    required this.isMicEnabled,
    required this.isCameraEnabled,
    required this.isFrontCamera,
    required this.availableDevices,
  });

  @override
  List<Object?> get props => [localStream, isMicEnabled, isCameraEnabled, isFrontCamera, availableDevices];
}
