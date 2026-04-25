import 'package:equatable/equatable.dart';
import 'package:fpdart/fpdart.dart';
import 'package:flutter_webrtc/flutter_webrtc.dart';
import '../../../../core/error/failure.dart';
import '../../../../core/usecase/success.dart';
import '../entities/call_event.dart';
import '../entities/consumer_entity.dart';
import '../entities/local_media_entity.dart';
import '../entities/media_kind.dart';
import '../entities/producer_entity.dart';
import '../entities/room_entity.dart';

/// Domain contract for all call-related operations.
/// The implementation lives in the data layer and is injected at runtime.
/// Every method returns `Either<Failure, Success<T>>` — never throws.
abstract class CallRepository {
  /// Stream of real-time server events (peers joining, media producers, etc.)
  Stream<CallEvent> get onCallEvent;

  /// Creates a new room on the server and returns it with the host peer pre-populated.

  Future<Either<Failure, Success<RoomEntity>>> createRoom({
    required String displayName,
  });

  /// Joins an existing room by [roomId] and returns the full room including all current peers.
  /// Returns [RoomNotFoundFailure] if the room does not exist.
  /// Returns [RoomFullFailure] if the room has reached its peer limit.
  Future<Either<Failure, Success<RoomEntity>>> joinRoom({
    required String roomId,
    required String displayName,
  });

  /// Signals a clean disconnect from the server for the given [roomId] and [peerId].
  /// Must be called even if no media was produced (joined but never enabled camera).
  Future<Either<Failure, Success<void>>> leaveRoom({
    required String roomId,
    required String peerId,
  });

  /// Publishes a media track to the room via the send transport.
  /// Returns [TransportFailure] if the WebRTC send transport is not yet initialized.
  /// Returns [MediaPermissionFailure] if the OS denies access to the requested [track].
  Future<Either<Failure, Success<ProducerEntity>>> produce({
    required String roomId,
    required MediaKind kind,
    required MediaStreamTrack track,
    required MediaStream stream,
  });

  /// Requests consumption of a remote producer, returning a [ConsumerEntity] with RTP params
  /// ready to pass to the Mediasoup Device for rendering in `RTCVideoView`.
  Future<Either<Failure, Success<ConsumerEntity>>> consume({
    required String roomId,
    required String producerId,
    required String peerId,
  });

  /// Pauses or resumes (never closes) a local producer on the server.
  /// [pause] = true → pause; false → resume.
  Future<Either<Failure, Success<void>>> toggleAudio({
    required String producerId,
    required bool pause,
  });

  /// Pauses or resumes a local video producer on the server.
  /// [pause] = true → pause; false → resume.
  Future<Either<Failure, Success<void>>> toggleCamera({
    required String producerId,
    required bool pause,
  });

  /// Flips the active camera between front and rear without touching the socket.
  /// Delegates exclusively to the `WebRTCDatasource`.
  Future<Either<Failure, Success<LocalMediaEntity>>> switchCamera();

  /// Requests mic/camera access, enumerates devices, and returns the live [LocalMediaEntity].
  /// Returns [MediaPermissionFailure] if the OS denies permission.
  Future<Either<Failure, Success<LocalMediaEntity>>> initLocalMedia({
    required bool enableAudio,
    required bool enableVideo,
  });
}
