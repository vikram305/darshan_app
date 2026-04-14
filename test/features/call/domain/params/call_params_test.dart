// ignore_for_file: lines_longer_than_80_chars

import 'package:darshan_app/features/call/domain/usecases/consume_media_usecase.dart';
import 'package:darshan_app/features/call/domain/usecases/create_room_usecase.dart';
import 'package:darshan_app/features/call/domain/usecases/init_local_media_usecase.dart';
import 'package:darshan_app/features/call/domain/usecases/join_room_usecase.dart';
import 'package:darshan_app/features/call/domain/usecases/params/room_peer_params.dart';
import 'package:darshan_app/features/call/domain/usecases/switch_camera_usecase.dart';
import 'package:darshan_app/features/call/domain/usecases/toggle_audio_usecase.dart';
import 'package:darshan_app/features/call/domain/usecases/toggle_camera_usecase.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../utils/call_test_constants.dart';

void main() {
  // ─── PRM-01 CreateRoomParams ───────────────────────────────────────────────
  group('CreateRoomParams', () {
    test('PRM-01a: equal instances with same displayName are equal', () {
      const a = CreateRoomParams(displayName: tDisplayName);
      const b = CreateRoomParams(displayName: tDisplayName);
      expect(a, equals(b));
    });

    test('PRM-01b: different displayName → not equal', () {
      const a = CreateRoomParams(displayName: tDisplayName);
      const b = CreateRoomParams(displayName: 'Charlie');
      expect(a, isNot(equals(b)));
    });

    test('PRM-01c: props contains displayName', () {
      const p = CreateRoomParams(displayName: tDisplayName);
      expect(p.props, [tDisplayName]);
    });
  });

  // ─── PRM-02 JoinRoomParams ─────────────────────────────────────────────────
  group('JoinRoomParams', () {
    test('PRM-02a: equal instances with same roomId + displayName are equal', () {
      const a = JoinRoomParams(roomId: tRoomId, displayName: tGuestDisplayName);
      const b = JoinRoomParams(roomId: tRoomId, displayName: tGuestDisplayName);
      expect(a, equals(b));
    });

    test('PRM-02b: different roomId → not equal', () {
      const a = JoinRoomParams(roomId: 'room-1', displayName: tGuestDisplayName);
      const b = JoinRoomParams(roomId: 'room-2', displayName: tGuestDisplayName);
      expect(a, isNot(equals(b)));
    });

    test('PRM-02c: different displayName → not equal', () {
      const a = JoinRoomParams(roomId: tRoomId, displayName: 'Alice');
      const b = JoinRoomParams(roomId: tRoomId, displayName: 'Bob');
      expect(a, isNot(equals(b)));
    });

    test('PRM-02d: props contains roomId and displayName', () {
      const p = JoinRoomParams(roomId: tRoomId, displayName: tGuestDisplayName);
      expect(p.props, [tRoomId, tGuestDisplayName]);
    });

    test('PRM-02e: empty roomId is a valid (though semantically wrong) param', () {
      // Domain does not validate — it delegates to repo. Params must accept it.
      expect(() => const JoinRoomParams(roomId: '', displayName: tGuestDisplayName), returnsNormally);
    });
  });

  // ─── PRM-03 RoomPeerParams ─────────────────────────────────────────────────
  group('RoomPeerParams', () {
    test('PRM-03a: equal instances with same roomId + peerId are equal', () {
      const a = RoomPeerParams(roomId: tRoomId, peerId: tHostPeerId);
      const b = RoomPeerParams(roomId: tRoomId, peerId: tHostPeerId);
      expect(a, equals(b));
    });

    test('PRM-03b: different peerId → not equal', () {
      const a = RoomPeerParams(roomId: tRoomId, peerId: 'peer-1');
      const b = RoomPeerParams(roomId: tRoomId, peerId: 'peer-2');
      expect(a, isNot(equals(b)));
    });

    test('PRM-03c: props contains roomId and peerId', () {
      const p = RoomPeerParams(roomId: tRoomId, peerId: tHostPeerId);
      expect(p.props, [tRoomId, tHostPeerId]);
    });
  });

  // ─── PRM-04 ConsumeMediaParams ─────────────────────────────────────────────
  group('ConsumeMediaParams', () {
    test('PRM-04a: equal instances are equal', () {
      const a = ConsumeMediaParams(roomId: tRoomId, producerId: tRemoteProducerId, peerId: tPeerId);
      const b = ConsumeMediaParams(roomId: tRoomId, producerId: tRemoteProducerId, peerId: tPeerId);
      expect(a, equals(b));
    });

    test('PRM-04b: different producerId → not equal', () {
      const a = ConsumeMediaParams(roomId: tRoomId, producerId: 'prod-1', peerId: tPeerId);
      const b = ConsumeMediaParams(roomId: tRoomId, producerId: 'prod-2', peerId: tPeerId);
      expect(a, isNot(equals(b)));
    });

    test('PRM-04c: different peerId → not equal', () {
      const a = ConsumeMediaParams(roomId: tRoomId, producerId: tRemoteProducerId, peerId: 'p-1');
      const b = ConsumeMediaParams(roomId: tRoomId, producerId: tRemoteProducerId, peerId: 'p-2');
      expect(a, isNot(equals(b)));
    });

    test('PRM-04d: props contains all three ids', () {
      const p = ConsumeMediaParams(roomId: tRoomId, producerId: tRemoteProducerId, peerId: tPeerId);
      expect(p.props, [tRoomId, tRemoteProducerId, tPeerId]);
    });
  });

  // ─── PRM-05 ToggleAudioParams ──────────────────────────────────────────────
  group('ToggleAudioParams', () {
    test('PRM-05a: same producerId + same pause flag → equal', () {
      const a = ToggleAudioParams(producerId: tProducerId, pause: true);
      const b = ToggleAudioParams(producerId: tProducerId, pause: true);
      expect(a, equals(b));
    });

    test('PRM-05b: same producerId but different pause flags → not equal', () {
      const a = ToggleAudioParams(producerId: tProducerId, pause: true);
      const b = ToggleAudioParams(producerId: tProducerId, pause: false);
      expect(a, isNot(equals(b)));
    });

    test('PRM-05c: props contains producerId and pause', () {
      const p = ToggleAudioParams(producerId: tProducerId, pause: true);
      expect(p.props, [tProducerId, true]);
    });
  });

  // ─── PRM-06 ToggleCameraParams ────────────────────────────────────────────
  group('ToggleCameraParams', () {
    test('PRM-06a: same producerId + same pause flag → equal', () {
      const a = ToggleCameraParams(producerId: tProducerId, pause: false);
      const b = ToggleCameraParams(producerId: tProducerId, pause: false);
      expect(a, equals(b));
    });

    test('PRM-06b: different pause flag → not equal', () {
      const a = ToggleCameraParams(producerId: tProducerId, pause: true);
      const b = ToggleCameraParams(producerId: tProducerId, pause: false);
      expect(a, isNot(equals(b)));
    });

    test('PRM-06c: props contains producerId and pause', () {
      const p = ToggleCameraParams(producerId: tProducerId, pause: false);
      expect(p.props, [tProducerId, false]);
    });
  });

  // ─── PRM-07 SwitchCameraParams ────────────────────────────────────────────
  group('SwitchCameraParams', () {
    test('PRM-07a: any two instances are always equal (empty props)', () {
      const a = SwitchCameraParams();
      const b = SwitchCameraParams();
      expect(a, equals(b));
    });

    test('PRM-07b: props is empty list', () {
      const p = SwitchCameraParams();
      expect(p.props, isEmpty);
    });
  });

  // ─── PRM-08 InitLocalMediaParams ──────────────────────────────────────────
  group('InitLocalMediaParams', () {
    test('PRM-08a: same flags → equal', () {
      const a = InitLocalMediaParams(enableAudio: true, enableVideo: true);
      const b = InitLocalMediaParams(enableAudio: true, enableVideo: true);
      expect(a, equals(b));
    });

    test('PRM-08b: different enableAudio → not equal', () {
      const a = InitLocalMediaParams(enableAudio: true, enableVideo: true);
      const b = InitLocalMediaParams(enableAudio: false, enableVideo: true);
      expect(a, isNot(equals(b)));
    });

    test('PRM-08c: different enableVideo → not equal', () {
      const a = InitLocalMediaParams(enableAudio: true, enableVideo: true);
      const b = InitLocalMediaParams(enableAudio: true, enableVideo: false);
      expect(a, isNot(equals(b)));
    });

    test('PRM-08d: props contains both flags', () {
      const p = InitLocalMediaParams(enableAudio: false, enableVideo: true);
      expect(p.props, [false, true]);
    });

    test('PRM-08e: both-false params is constructable (semantics handled by repo)', () {
      // Params must not throw — validation lives in the repo layer.
      expect(() => const InitLocalMediaParams(enableAudio: false, enableVideo: false), returnsNormally);
    });
  });
}
