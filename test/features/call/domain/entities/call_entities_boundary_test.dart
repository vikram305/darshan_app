// ignore_for_file: lines_longer_than_80_chars

// Entity boundary-state tests.
// Existing call_entities_test.dart covers the "default happy state" for each entity.
// This file covers the remaining boolean-flag boundary variants and cross-field combinations
// that appear at module boundaries (e.g., a muted + camera-off + screen-sharing peer).

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
  // ─── ENT-01/02: ProducerEntity boundary states ────────────────────────────
  group('ProducerEntity boundary states', () {
    test('ENT-01: isPaused=true variant is valid and preserved in props', () {
      const p = ProducerEntity(
        id: tProducerId,
        kind: MediaKind.audio,
        isPaused: true,
        isScreenShare: false,
      );
      expect(p.isPaused, isTrue);
      expect(p.props, [tProducerId, MediaKind.audio, true, false]);
    });

    test('ENT-02a: isScreenShare=true → different from camera producer (not equal)', () {
      const camera = ProducerEntity(id: tProducerId, kind: MediaKind.video, isPaused: false, isScreenShare: false);
      const screen = ProducerEntity(id: tProducerId, kind: MediaKind.video, isPaused: false, isScreenShare: true);
      expect(camera, isNot(equals(screen)));
    });

    test('ENT-02b: isScreenShare=true props reflected correctly', () {
      const p = ProducerEntity(id: tProducerId, kind: MediaKind.video, isPaused: false, isScreenShare: true);
      expect(p.isScreenShare, isTrue);
      expect(p.props.contains(true), isTrue);
    });

    test('ENT-02c: paused screen-share producer is valid entity state', () {
      const p = ProducerEntity(id: tProducerId, kind: MediaKind.video, isPaused: true, isScreenShare: true);
      expect(p.isPaused, isTrue);
      expect(p.isScreenShare, isTrue);
    });
  });

  // ─── ENT-03/04: ConsumerEntity boundary states ────────────────────────────
  group('ConsumerEntity boundary states', () {
    test('ENT-03: audio-kind consumer is valid (separate from video consumer)', () {
      final audio = ConsumerEntity(id: tConsumerId, producerId: tRemoteProducerId, peerId: tPeerId, kind: MediaKind.audio, isPaused: false, rtpParameters: tRtpParameters);
      final video = ConsumerEntity(id: tConsumerId, producerId: tRemoteProducerId, peerId: tPeerId, kind: MediaKind.video, isPaused: false, rtpParameters: tRtpParameters);
      expect(audio.kind, MediaKind.audio);
      expect(audio, isNot(equals(video)));
    });

    test('ENT-04: isPaused=true is preserved in props', () {
      final c = ConsumerEntity(
        id: tConsumerId,
        producerId: tRemoteProducerId,
        peerId: tPeerId,
        kind: MediaKind.video,
        isPaused: true,
        rtpParameters: tRtpParameters,
      );
      expect(c.isPaused, isTrue);
      expect(c.props.contains(true), isTrue);
    });

    test('ENT-04b: paused consumer ≠ unpaused consumer (same id, different state)', () {
      final active = ConsumerEntity(id: tConsumerId, producerId: tRemoteProducerId, peerId: tPeerId, kind: MediaKind.video, isPaused: false, rtpParameters: tRtpParameters);
      final paused = ConsumerEntity(id: tConsumerId, producerId: tRemoteProducerId, peerId: tPeerId, kind: MediaKind.video, isPaused: true, rtpParameters: tRtpParameters);
      expect(active, isNot(equals(paused)));
    });
  });

  // ─── ENT-05: PeerEntity boolean flag combinations ─────────────────────────
  group('PeerEntity boundary states', () {
    test('ENT-05a: fully muted and camera-off peer is valid entity state', () {
      const peer = PeerEntity(
        id: tPeerId,
        displayName: tGuestDisplayName,
        producers: [],
        consumers: [],
        isAudioMuted: true,
        isCameraOff: true,
        isScreenSharing: false,
      );
      expect(peer.isAudioMuted, isTrue);
      expect(peer.isCameraOff, isTrue);
      expect(peer.isScreenSharing, isFalse);
    });

    test('ENT-05b: screen-sharing peer — isScreenSharing=true is preserved in props', () {
      const peer = PeerEntity(
        id: tPeerId,
        displayName: tGuestDisplayName,
        producers: [],
        consumers: [],
        isAudioMuted: false,
        isCameraOff: false,
        isScreenSharing: true,
      );
      expect(peer.isScreenSharing, isTrue);
      expect(peer.props.contains(true), isTrue);
    });

    test('ENT-05c: muted+camera-off peer ≠ unmuted peer (same id)', () {
      const active = PeerEntity(id: tPeerId, displayName: tGuestDisplayName, producers: [], consumers: [], isAudioMuted: false, isCameraOff: false, isScreenSharing: false);
      const muted = PeerEntity(id: tPeerId, displayName: tGuestDisplayName, producers: [], consumers: [], isAudioMuted: true, isCameraOff: true, isScreenSharing: false);
      expect(active, isNot(equals(muted)));
    });

    test('ENT-05d: peer with multiple producers and consumers has correct counts', () {
      const peer = PeerEntity(
        id: tHostPeerId,
        displayName: tDisplayName,
        producers: [tAudioProducer, tVideoProducer],
        consumers: [],
        isAudioMuted: false,
        isCameraOff: false,
        isScreenSharing: false,
      );
      expect(peer.producers.length, 2);
      expect(peer.consumers, isEmpty);
    });
  });

  // ─── ENT-06: RoomEntity — isActive: false ─────────────────────────────────
  group('RoomEntity boundary states', () {
    test('ENT-06a: isActive=false (closed room) is a valid domain state', () {
      final closed = RoomEntity(
        id: tRoomId,
        hostPeerId: tHostPeerId,
        peers: const [],
        createdAt: DateTime(2026, 4, 14),
        isActive: false,
      );
      expect(closed.isActive, isFalse);
    });

    test('ENT-06b: active room ≠ closed room (same id)', () {
      final active = RoomEntity(id: tRoomId, hostPeerId: tHostPeerId, peers: const [], createdAt: DateTime(2026, 4, 14), isActive: true);
      final closed = RoomEntity(id: tRoomId, hostPeerId: tHostPeerId, peers: const [], createdAt: DateTime(2026, 4, 14), isActive: false);
      expect(active, isNot(equals(closed)));
    });

    test('ENT-06c: room with multiple peers — peer count preserved in props', () {
      expect(tRoomWithGuest.peers.length, 2);
      expect(tRoomWithGuest.props.contains(tRoomWithGuest.peers), isTrue);
    });
  });

  // ─── ENT-07: TransportEntity — non-null sctpParameters ───────────────────
  group('TransportEntity boundary states', () {
    test('ENT-07a: non-null sctpParameters are preserved in entity', () {
      final sctp = <String, dynamic>{'maxMessageSize': 262144};
      final t = TransportEntity(
        id: 'transport-001',
        iceParameters: tIceParameters,
        iceCandidates: tIceCandidates,
        dtlsParameters: tDtlsParameters,
        sctpParameters: sctp,
      );
      expect(t.sctpParameters, equals(sctp));
      expect(t.sctpParameters, isNotNull);
    });

    test('ENT-07b: transport with sctp ≠ transport without sctp (same id)', () {
      final withSctp = TransportEntity(id: 'transport-001', iceParameters: tIceParameters, iceCandidates: tIceCandidates, dtlsParameters: tDtlsParameters, sctpParameters: {'max': 256});
      final noSctp = TransportEntity(id: 'transport-001', iceParameters: tIceParameters, iceCandidates: tIceCandidates, dtlsParameters: tDtlsParameters, sctpParameters: null);
      expect(withSctp, isNot(equals(noSctp)));
    });

    test('ENT-07c: multiple ice candidates are preserved', () {
      final candidates = [
        <String, dynamic>{'ip': '10.0.0.1', 'port': 3478},
        <String, dynamic>{'ip': '10.0.0.2', 'port': 3479},
      ];
      final t = TransportEntity(id: 'transport-001', iceParameters: tIceParameters, iceCandidates: candidates, dtlsParameters: tDtlsParameters);
      expect(t.iceCandidates.length, 2);
    });
  });

  // ─── LocalMediaEntity additional boundary states ──────────────────────────
  group('LocalMediaEntity boundary states', () {
    test('mic disabled + camera disabled: valid state (pre-permission or background)', () {
      final entity = LocalMediaEntity(
        localStream: null,
        isMicEnabled: false,
        isCameraEnabled: false,
        isFrontCamera: true,
        availableDevices: const [],
      );
      expect(entity.isMicEnabled, isFalse);
      expect(entity.isCameraEnabled, isFalse);
    });

    test('rear camera state (isFrontCamera=false) preserved in props', () {
      final entity = LocalMediaEntity(
        localStream: null,
        isMicEnabled: true,
        isCameraEnabled: true,
        isFrontCamera: false,
        availableDevices: const [],
      );
      expect(entity.isFrontCamera, isFalse);
      expect(entity.props.contains(false), isTrue);
    });

    test('entity with mic-on and camera-off ≠ entity with mic-on and camera-on', () {
      final cameraOff = LocalMediaEntity(localStream: null, isMicEnabled: true, isCameraEnabled: false, isFrontCamera: true, availableDevices: const []);
      final cameraOn = LocalMediaEntity(localStream: null, isMicEnabled: true, isCameraEnabled: true, isFrontCamera: true, availableDevices: const []);
      expect(cameraOff, isNot(equals(cameraOn)));
    });
  });
}
