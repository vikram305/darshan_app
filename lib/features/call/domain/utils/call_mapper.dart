import '../entities/consumer_entity.dart';
import '../entities/local_media_entity.dart';
import '../entities/media_kind.dart';
import '../entities/peer_entity.dart';
import '../entities/producer_entity.dart';
import '../entities/room_entity.dart';
import '../entities/transport_entity.dart';

/// Static, side-effect-free converters from Data models to Domain entities.
/// Direction is always Model → Entity; never Entity → Model.
/// All methods accept nullable fields and provide safe defaults where needed.
abstract class CallMapper {
  CallMapper._();

  static ProducerEntity toProducerEntity(dynamic model) {
    return ProducerEntity(
      id: model.id as String,
      kind: model.kind == 'audio' ? MediaKind.audio : MediaKind.video,
      isPaused: model.isPaused as bool,
      isScreenShare: model.isScreenShare as bool,
    );
  }

  static ConsumerEntity toConsumerEntity(dynamic model) {
    return ConsumerEntity(
      id: model.id as String,
      producerId: model.producerId as String,
      peerId: model.peerId as String,
      kind: model.kind == 'audio' ? MediaKind.audio : MediaKind.video,
      isPaused: model.isPaused as bool,
      rtpParameters: Map<String, dynamic>.from(model.rtpParameters as Map),
    );
  }

  static PeerEntity toPeerEntity(dynamic model) {
    final producers = (model.producers as List)
        .map((p) => toProducerEntity(p))
        .toList();
    final consumers = (model.consumers as List)
        .map((c) => toConsumerEntity(c))
        .toList();
    return PeerEntity(
      id: model.id as String,
      displayName: model.displayName as String,
      producers: producers,
      consumers: consumers,
      isAudioMuted: model.isAudioMuted as bool,
      isCameraOff: model.isCameraOff as bool,
      isScreenSharing: model.isScreenSharing as bool,
    );
  }

  static RoomEntity toRoomEntity(dynamic model) {
    final peers = (model.peers as List)
        .map((p) => toPeerEntity(p))
        .toList();
    return RoomEntity(
      id: model.id as String,
      hostPeerId: model.hostPeerId as String,
      peers: peers,
      createdAt: model.createdAt is DateTime
          ? model.createdAt as DateTime
          : DateTime.parse(model.createdAt as String),
      isActive: model.isActive as bool,
    );
  }

  static TransportEntity toTransportEntity(dynamic model) {
    return TransportEntity(
      id: model.id as String,
      iceParameters: Map<String, dynamic>.from(model.iceParameters as Map),
      iceCandidates: (model.iceCandidates as List)
          .map((c) => Map<String, dynamic>.from(c as Map))
          .toList(),
      dtlsParameters: Map<String, dynamic>.from(model.dtlsParameters as Map),
      sctpParameters: model.sctpParameters != null
          ? Map<String, dynamic>.from(model.sctpParameters as Map)
          : null,
    );
  }

  static LocalMediaEntity toLocalMediaEntity(dynamic model) {
    return LocalMediaEntity(
      localStream: model.localStream,
      isMicEnabled: model.isMicEnabled as bool,
      isCameraEnabled: model.isCameraEnabled as bool,
      isFrontCamera: model.isFrontCamera as bool,
      availableDevices: List.from(model.availableDevices as List),
    );
  }
}
