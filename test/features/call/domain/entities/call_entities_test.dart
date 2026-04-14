import 'package:darshan_app/features/call/domain/entities/consumer_entity.dart';
import 'package:darshan_app/features/call/domain/entities/local_media_entity.dart';
import 'package:darshan_app/features/call/domain/entities/media_kind.dart';
import 'package:darshan_app/features/call/domain/entities/peer_entity.dart';
import 'package:darshan_app/features/call/domain/entities/producer_entity.dart';
import 'package:darshan_app/features/call/domain/entities/room_entity.dart';
import 'package:darshan_app/features/call/domain/entities/transport_entity.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../utils/call_test_constants.dart';

void main() {
  // ─── ProducerEntity ────────────────────────────────────────────────────────
  group('ProducerEntity', () {
    test('supports value equality via Equatable', () {
      const a = ProducerEntity(
        id: tProducerId,
        kind: MediaKind.audio,
        isPaused: false,
        isScreenShare: false,
      );
      const b = ProducerEntity(
        id: tProducerId,
        kind: MediaKind.audio,
        isPaused: false,
        isScreenShare: false,
      );
      expect(a, equals(b));
    });

    test('two producers with different ids are not equal', () {
      const a = ProducerEntity(id: 'p-1', kind: MediaKind.audio, isPaused: false, isScreenShare: false);
      const b = ProducerEntity(id: 'p-2', kind: MediaKind.audio, isPaused: false, isScreenShare: false);
      expect(a, isNot(equals(b)));
    });

    test('props includes all fields', () {
      expect(
        tAudioProducer.props,
        [tProducerId, MediaKind.audio, false, false],
      );
    });
  });

  // ─── ConsumerEntity ────────────────────────────────────────────────────────
  group('ConsumerEntity', () {
    test('supports value equality via Equatable', () {
      final a = ConsumerEntity(
        id: tConsumerId,
        producerId: tRemoteProducerId,
        peerId: tPeerId,
        kind: MediaKind.video,
        isPaused: false,
        rtpParameters: tRtpParameters,
      );
      final b = ConsumerEntity(
        id: tConsumerId,
        producerId: tRemoteProducerId,
        peerId: tPeerId,
        kind: MediaKind.video,
        isPaused: false,
        rtpParameters: tRtpParameters,
      );
      expect(a, equals(b));
    });

    test('props includes rtpParameters', () {
      expect(tConsumer.props.contains(tRtpParameters), isTrue);
    });
  });

  // ─── PeerEntity ────────────────────────────────────────────────────────────
  group('PeerEntity', () {
    test('supports value equality', () {
      const a = PeerEntity(
        id: tHostPeerId,
        displayName: tDisplayName,
        producers: [tAudioProducer],
        consumers: [],
        isAudioMuted: false,
        isCameraOff: false,
        isScreenSharing: false,
      );
      const b = PeerEntity(
        id: tHostPeerId,
        displayName: tDisplayName,
        producers: [tAudioProducer],
        consumers: [],
        isAudioMuted: false,
        isCameraOff: false,
        isScreenSharing: false,
      );
      expect(a, equals(b));
    });

    test('peer with empty producers list is valid', () {
      expect(tGuestPeer.producers, isEmpty);
    });
  });

  // ─── RoomEntity ────────────────────────────────────────────────────────────
  group('RoomEntity', () {
    test('supports value equality', () {
      final a = RoomEntity(
        id: tRoomId,
        hostPeerId: tHostPeerId,
        peers: const [tHostPeer],
        createdAt: DateTime(2026, 4, 14, 10, 0, 0),
        isActive: true,
      );
      final b = RoomEntity(
        id: tRoomId,
        hostPeerId: tHostPeerId,
        peers: const [tHostPeer],
        createdAt: DateTime(2026, 4, 14, 10, 0, 0),
        isActive: true,
      );
      expect(a, equals(b));
    });

    test('room with 0 peers is valid (edge: initializeData with empty peers)', () {
      expect(tRoomEmpty.peers, isEmpty);
      expect(tRoomEmpty.isActive, isTrue);
    });

    test('props contains all fields', () {
      expect(tRoom.props.contains(tRoomId), isTrue);
      expect(tRoom.props.contains(tHostPeerId), isTrue);
    });
  });

  // ─── TransportEntity ───────────────────────────────────────────────────────
  group('TransportEntity', () {
    test('supports value equality', () {
      final a = TransportEntity(
        id: 'transport-001',
        iceParameters: tIceParameters,
        iceCandidates: tIceCandidates,
        dtlsParameters: tDtlsParameters,
        sctpParameters: null,
      );
      final b = TransportEntity(
        id: 'transport-001',
        iceParameters: tIceParameters,
        iceCandidates: tIceCandidates,
        dtlsParameters: tDtlsParameters,
        sctpParameters: null,
      );
      expect(a, equals(b));
    });

    test('sctpParameters defaults to null when omitted', () {
      expect(tTransport.sctpParameters, isNull);
    });
  });

  // ─── LocalMediaEntity ──────────────────────────────────────────────────────
  group('LocalMediaEntity', () {
    test('localStream may be null before initialization', () {
      expect(tLocalMedia.localStream, isNull);
    });

    test('isFrontCamera is flipped in switched variant', () {
      expect(tLocalMedia.isFrontCamera, isTrue);
      expect(tLocalMediaSwitched.isFrontCamera, isFalse);
    });

    test('availableDevices can be empty list (emulator scenario)', () {
      expect(tLocalMedia.availableDevices, isEmpty);
    });
  });

  // ─── MediaKind ─────────────────────────────────────────────────────────────
  group('MediaKind', () {
    test('has exactly two values: audio and video', () {
      expect(MediaKind.values, containsAll([MediaKind.audio, MediaKind.video]));
      expect(MediaKind.values.length, 2);
    });
  });
}
