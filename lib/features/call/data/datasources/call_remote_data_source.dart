import 'package:flutter_webrtc/flutter_webrtc.dart';
import '../../domain/entities/media_kind.dart';
import '../models/producer_model.dart';
import '../models/consumer_model.dart';
import '../models/room_model.dart';

abstract class CallRemoteDataSource {
  /// Stream of real-time events from the server (peers joining, producers, etc.)
  Stream<Map<String, dynamic>> get onEvent;

  /// Emits 'createRoom' socket event.
  Future<RoomModel> createRoom(String displayName);

  /// Emits 'joinRoom' socket event.
  Future<RoomModel> joinRoom(String roomId, String displayName);

  /// Emits 'leaveRoom' socket event.
  Future<void> leaveRoom(String roomId, String peerId);

  /// Emits 'produce' socket event and handles transport signaling.
  Future<ProducerModel> produce({
    required String roomId,
    required MediaKind kind,
    required MediaStreamTrack track,
  });

  /// Emits 'consume' socket event and handles transport signaling.
  Future<ConsumerModel> consume({
    required String roomId,
    required String producerId,
    required String peerId,
  });

  /// Emits 'pauseProducer' / 'resumeProducer' events.
  Future<void> toggleAudio({required String producerId, required bool pause});

  /// Emits 'pauseProducer' / 'resumeProducer' events.
  Future<void> toggleCamera({required String producerId, required bool pause});
}
