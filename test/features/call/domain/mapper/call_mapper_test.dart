// ignore_for_file: lines_longer_than_80_chars

// ─── Mapper test model stubs ────────────────────────────────────────────────
// CallMapper accepts `dynamic` so we use plain anonymous-style classes here.
// We define simple data-holder classes to stand in for Data-layer models,
// keeping the domain layer completely free of data-layer dependencies.

import 'package:darshan_app/features/call/domain/entities/consumer_entity.dart';
import 'package:darshan_app/features/call/domain/entities/local_media_entity.dart';
import 'package:darshan_app/features/call/domain/entities/media_kind.dart';
import 'package:darshan_app/features/call/domain/entities/peer_entity.dart';
import 'package:darshan_app/features/call/domain/entities/producer_entity.dart';
import 'package:darshan_app/features/call/domain/entities/room_entity.dart';
import 'package:darshan_app/features/call/domain/entities/transport_entity.dart';
import 'package:darshan_app/features/call/domain/utils/call_mapper.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../utils/call_test_constants.dart';

// ---------------------------------------------------------------------------
// Stub model helpers (mimick Data-layer model shape)
// ---------------------------------------------------------------------------

class _ProducerModel {
  final String id;
  final String kind;
  final bool isPaused;
  final bool isScreenShare;
  _ProducerModel({required this.id, required this.kind, required this.isPaused, required this.isScreenShare});
}

class _ConsumerModel {
  final String id;
  final String producerId;
  final String peerId;
  final String kind;
  final bool isPaused;
  final Map<String, dynamic> rtpParameters;
  _ConsumerModel({
    required this.id,
    required this.producerId,
    required this.peerId,
    required this.kind,
    required this.isPaused,
    required this.rtpParameters,
  });
}

class _PeerModel {
  final String id;
  final String displayName;
  final List<dynamic> producers;
  final List<dynamic> consumers;
  final bool isAudioMuted;
  final bool isCameraOff;
  final bool isScreenSharing;
  _PeerModel({
    required this.id,
    required this.displayName,
    required this.producers,
    required this.consumers,
    required this.isAudioMuted,
    required this.isCameraOff,
    required this.isScreenSharing,
  });
}

class _RoomModel {
  final String id;
  final String hostPeerId;
  final List<dynamic> peers;
  final dynamic createdAt; // DateTime or String
  final bool isActive;
  _RoomModel({required this.id, required this.hostPeerId, required this.peers, required this.createdAt, required this.isActive});
}

class _TransportModel {
  final String id;
  final Map<String, dynamic> iceParameters;
  final List<dynamic> iceCandidates;
  final Map<String, dynamic> dtlsParameters;
  final dynamic sctpParameters;
  _TransportModel({required this.id, required this.iceParameters, required this.iceCandidates, required this.dtlsParameters, required this.sctpParameters});
}

class _LocalMediaModel {
  final dynamic localStream;
  final bool isMicEnabled;
  final bool isCameraEnabled;
  final bool isFrontCamera;
  final List<dynamic> availableDevices;
  _LocalMediaModel({required this.localStream, required this.isMicEnabled, required this.isCameraEnabled, required this.isFrontCamera, required this.availableDevices});
}

// ---------------------------------------------------------------------------
// Tests
// ---------------------------------------------------------------------------

void main() {
  // ─── toProducerEntity ─────────────────────────────────────────────────────
  group('CallMapper.toProducerEntity', () {
    // MP-01
    test('MP-01: kind == "audio" maps to MediaKind.audio', () {
      final model = _ProducerModel(id: tProducerId, kind: 'audio', isPaused: false, isScreenShare: false);
      final entity = CallMapper.toProducerEntity(model);
      expect(entity.kind, MediaKind.audio);
      expect(entity.id, tProducerId);
    });

    // MP-02
    test('MP-02: kind == "video" maps to MediaKind.video', () {
      final model = _ProducerModel(id: tProducerId, kind: 'video', isPaused: false, isScreenShare: false);
      final entity = CallMapper.toProducerEntity(model);
      expect(entity.kind, MediaKind.video);
    });

    // MP-03
    test('MP-03: isPaused: true is preserved', () {
      final model = _ProducerModel(id: tProducerId, kind: 'audio', isPaused: true, isScreenShare: false);
      final entity = CallMapper.toProducerEntity(model);
      expect(entity.isPaused, isTrue);
    });

    // MP-04
    test('MP-04: isScreenShare: true is preserved', () {
      final model = _ProducerModel(id: tProducerId, kind: 'video', isPaused: false, isScreenShare: true);
      final entity = CallMapper.toProducerEntity(model);
      expect(entity.isScreenShare, isTrue);
    });

    test('MP-04b: result is correct ProducerEntity type (not mocked)', () {
      final model = _ProducerModel(id: 'p-x', kind: 'audio', isPaused: false, isScreenShare: false);
      final entity = CallMapper.toProducerEntity(model);
      expect(entity, isA<ProducerEntity>());
    });
  });

  // ─── toConsumerEntity ─────────────────────────────────────────────────────
  group('CallMapper.toConsumerEntity', () {
    // MP-05
    test('MP-05: rtpParameters map is deep-cloned (not same reference)', () {
      final rtp = <String, dynamic>{'codec': 'VP8'};
      final model = _ConsumerModel(id: tConsumerId, producerId: tRemoteProducerId, peerId: tPeerId, kind: 'video', isPaused: false, rtpParameters: rtp);
      final entity = CallMapper.toConsumerEntity(model);
      expect(entity.rtpParameters, equals(rtp));
      expect(identical(entity.rtpParameters, rtp), isFalse); // must be a new Map
    });

    // MP-06
    test('MP-06: kind == "audio" maps to MediaKind.audio', () {
      final model = _ConsumerModel(id: tConsumerId, producerId: tRemoteProducerId, peerId: tPeerId, kind: 'audio', isPaused: false, rtpParameters: tRtpParameters);
      final entity = CallMapper.toConsumerEntity(model);
      expect(entity.kind, MediaKind.audio);
    });

    // MP-07
    test('MP-07: isPaused: true propagated to ConsumerEntity', () {
      final model = _ConsumerModel(id: tConsumerId, producerId: tRemoteProducerId, peerId: tPeerId, kind: 'video', isPaused: true, rtpParameters: tRtpParameters);
      final entity = CallMapper.toConsumerEntity(model);
      expect(entity.isPaused, isTrue);
    });

    test('MP-07b: all fields mapped correctly in one shot', () {
      final model = _ConsumerModel(id: tConsumerId, producerId: tRemoteProducerId, peerId: tPeerId, kind: 'video', isPaused: false, rtpParameters: tRtpParameters);
      final entity = CallMapper.toConsumerEntity(model);
      expect(entity, isA<ConsumerEntity>());
      expect(entity.id, tConsumerId);
      expect(entity.producerId, tRemoteProducerId);
      expect(entity.peerId, tPeerId);
    });
  });

  // ─── toPeerEntity ─────────────────────────────────────────────────────────
  group('CallMapper.toPeerEntity', () {
    // MP-08
    test('MP-08: producers and consumers are mapped recursively', () {
      final prodModel = _ProducerModel(id: tProducerId, kind: 'audio', isPaused: false, isScreenShare: false);
      final consModel = _ConsumerModel(id: tConsumerId, producerId: tRemoteProducerId, peerId: tPeerId, kind: 'video', isPaused: false, rtpParameters: tRtpParameters);
      final model = _PeerModel(id: tHostPeerId, displayName: tDisplayName, producers: [prodModel], consumers: [consModel], isAudioMuted: false, isCameraOff: false, isScreenSharing: false);
      final entity = CallMapper.toPeerEntity(model);
      expect(entity.producers.length, 1);
      expect(entity.producers.first.id, tProducerId);
      expect(entity.consumers.length, 1);
      expect(entity.consumers.first.id, tConsumerId);
    });

    // MP-09
    test('MP-09: empty producers and consumers produce empty lists', () {
      final model = _PeerModel(id: tPeerId, displayName: tGuestDisplayName, producers: [], consumers: [], isAudioMuted: false, isCameraOff: false, isScreenSharing: false);
      final entity = CallMapper.toPeerEntity(model);
      expect(entity.producers, isEmpty);
      expect(entity.consumers, isEmpty);
    });

    // MP-10
    test('MP-10: all boolean flags mapped correctly', () {
      final model = _PeerModel(id: tPeerId, displayName: tGuestDisplayName, producers: [], consumers: [], isAudioMuted: true, isCameraOff: true, isScreenSharing: true);
      final entity = CallMapper.toPeerEntity(model);
      expect(entity.isAudioMuted, isTrue);
      expect(entity.isCameraOff, isTrue);
      expect(entity.isScreenSharing, isTrue);
    });
  });

  // ─── toRoomEntity ─────────────────────────────────────────────────────────
  group('CallMapper.toRoomEntity', () {
    final tDateTime = DateTime(2026, 4, 14, 10, 0, 0);
    final tDateString = '2026-04-14T10:00:00.000';

    // MP-11
    test('MP-11: createdAt already DateTime → used directly (no parsing)', () {
      final model = _RoomModel(id: tRoomId, hostPeerId: tHostPeerId, peers: [], createdAt: tDateTime, isActive: true);
      final entity = CallMapper.toRoomEntity(model);
      expect(entity.createdAt, equals(tDateTime));
    });

    // MP-12
    test('MP-12: createdAt is ISO String → parsed via DateTime.parse()', () {
      final model = _RoomModel(id: tRoomId, hostPeerId: tHostPeerId, peers: [], createdAt: tDateString, isActive: true);
      final entity = CallMapper.toRoomEntity(model);
      expect(entity.createdAt, equals(DateTime.parse(tDateString)));
    });

    // MP-13
    test('MP-13: peers list is mapped recursively', () {
      final peerModel = _PeerModel(id: tHostPeerId, displayName: tDisplayName, producers: [], consumers: [], isAudioMuted: false, isCameraOff: false, isScreenSharing: false);
      final model = _RoomModel(id: tRoomId, hostPeerId: tHostPeerId, peers: [peerModel], createdAt: tDateTime, isActive: true);
      final entity = CallMapper.toRoomEntity(model);
      expect(entity.peers.length, 1);
      expect(entity.peers.first.id, tHostPeerId);
    });

    // MP-14
    test('MP-14: isActive: false (closed room) is valid and preserved', () {
      final model = _RoomModel(id: tRoomId, hostPeerId: tHostPeerId, peers: [], createdAt: tDateTime, isActive: false);
      final entity = CallMapper.toRoomEntity(model);
      expect(entity.isActive, isFalse);
      expect(entity, isA<RoomEntity>());
    });
  });

  // ─── toTransportEntity ────────────────────────────────────────────────────
  group('CallMapper.toTransportEntity', () {
    // MP-15
    test('MP-15: sctpParameters == null → preserved as null', () {
      final model = _TransportModel(id: 'transport-001', iceParameters: tIceParameters, iceCandidates: tIceCandidates, dtlsParameters: tDtlsParameters, sctpParameters: null);
      final entity = CallMapper.toTransportEntity(model);
      expect(entity.sctpParameters, isNull);
    });

    // MP-16
    test('MP-16: sctpParameters non-null → deep-cloned to Map', () {
      final sctp = <String, dynamic>{'maxMessageSize': 262144};
      final model = _TransportModel(id: 'transport-001', iceParameters: tIceParameters, iceCandidates: tIceCandidates, dtlsParameters: tDtlsParameters, sctpParameters: sctp);
      final entity = CallMapper.toTransportEntity(model);
      expect(entity.sctpParameters, equals(sctp));
      expect(identical(entity.sctpParameters, sctp), isFalse);
    });

    // MP-17
    test('MP-17: iceCandidates list is cloned element-by-element', () {
      final candidates = [<String, dynamic>{'ip': '10.0.0.1', 'port': 3478}, <String, dynamic>{'ip': '10.0.0.2', 'port': 3479}];
      final model = _TransportModel(id: 'transport-001', iceParameters: tIceParameters, iceCandidates: candidates, dtlsParameters: tDtlsParameters, sctpParameters: null);
      final entity = CallMapper.toTransportEntity(model);
      expect(entity.iceCandidates.length, 2);
      expect(entity.iceCandidates.first['ip'], '10.0.0.1');
      expect(entity, isA<TransportEntity>());
    });
  });

  // ─── toLocalMediaEntity ───────────────────────────────────────────────────
  group('CallMapper.toLocalMediaEntity', () {
    // MP-18
    test('MP-18: all flags and null localStream mapped correctly', () {
      final model = _LocalMediaModel(localStream: null, isMicEnabled: true, isCameraEnabled: false, isFrontCamera: true, availableDevices: []);
      final entity = CallMapper.toLocalMediaEntity(model);
      expect(entity, isA<LocalMediaEntity>());
      expect(entity.localStream, isNull);
      expect(entity.isMicEnabled, isTrue);
      expect(entity.isCameraEnabled, isFalse);
      expect(entity.isFrontCamera, isTrue);
      expect(entity.availableDevices, isEmpty);
    });

    test('MP-18b: isFrontCamera: false preserved', () {
      final model = _LocalMediaModel(localStream: null, isMicEnabled: false, isCameraEnabled: false, isFrontCamera: false, availableDevices: []);
      final entity = CallMapper.toLocalMediaEntity(model);
      expect(entity.isFrontCamera, isFalse);
      expect(entity.isMicEnabled, isFalse);
    });
  });
}
