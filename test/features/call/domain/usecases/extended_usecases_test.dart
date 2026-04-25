// ignore_for_file: lines_longer_than_80_chars

// Extended use-case tests covering:
// Gap 5 — Toggle RESUME paths (pause=false, previously untested)
// Gap 6 — Missing failure variants per use case
// Gap 7 — Interaction isolation (verifyNoMoreInteractions beyond the happy path)

import 'package:darshan_app/core/error/failure.dart';
import 'package:darshan_app/core/usecase/success.dart';
import 'package:darshan_app/features/call/domain/entities/consumer_entity.dart';
import 'package:darshan_app/features/call/domain/entities/local_media_entity.dart';
import 'package:darshan_app/features/call/domain/entities/media_kind.dart';
import 'package:darshan_app/features/call/domain/entities/producer_entity.dart';
import 'package:darshan_app/features/call/domain/entities/room_entity.dart';
import 'package:darshan_app/features/call/domain/usecases/consume_media_usecase.dart';
import 'package:darshan_app/features/call/domain/usecases/create_room_usecase.dart';
import 'package:darshan_app/features/call/domain/usecases/init_local_media_usecase.dart';
import 'package:darshan_app/features/call/domain/usecases/join_room_usecase.dart';
import 'package:darshan_app/features/call/domain/usecases/produce_media_usecase.dart';
import 'package:darshan_app/features/call/domain/usecases/switch_camera_usecase.dart';
import 'package:darshan_app/features/call/domain/usecases/toggle_audio_usecase.dart';
import 'package:darshan_app/features/call/domain/usecases/toggle_camera_usecase.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_webrtc/flutter_webrtc.dart';
import 'package:fpdart/fpdart.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';

import '../../utils/call_test_constants.dart';
import 'usecases_test.mocks.dart';
import 'extended_usecases_test.mocks.dart';

@GenerateMocks([MediaStreamTrack, MediaStream])
void main() {
  late MockCallRepository mockRepo;
  late MockMediaStreamTrack mockTrack;
  late MockMediaStream mockStream;

  setUp(() {
    mockRepo = MockCallRepository();
    mockTrack = MockMediaStreamTrack();
    mockStream = MockMediaStream();
  });

  // ───────────────────────────────────────────────────────────────────────────
  // GAP 5 — Toggle RESUME paths (pause=false)
  // ───────────────────────────────────────────────────────────────────────────

  group('ToggleAudioUsecase — resume path (pause=false)', () {
    late ToggleAudioUsecase usecase;
    setUp(() {
      usecase = ToggleAudioUsecase(mockRepo);
      provideDummy<Either<Failure, Success<void>>>(Right(tSuccessVoid));
    });

    // UC-EXT-01
    test(
      'UC-EXT-01: pause=false (resume) → calls repo with pause=false, returns Right',
      () async {
        when(mockRepo.toggleAudio(producerId: tProducerId, pause: false))
            .thenAnswer((_) async => Right(tSuccessVoid));

        const params = ToggleAudioParams(producerId: tProducerId, pause: false);
        final result = await usecase.call(params);

        expect(result, Right<Failure, Success<void>>(tSuccessVoid));
        verify(mockRepo.toggleAudio(producerId: tProducerId, pause: false)).called(1);
        verifyNoMoreInteractions(mockRepo);
      },
    );

    test(
      'UC-EXT-01b: pause=false passes through Left(ServerFailure)',
      () async {
        when(mockRepo.toggleAudio(producerId: tProducerId, pause: false))
            .thenAnswer((_) async => const Left(tServerFailure));

        const params = ToggleAudioParams(producerId: tProducerId, pause: false);
        final result = await usecase.call(params);

        expect(result, const Left<Failure, Success<void>>(tServerFailure));
      },
    );
  });

  group('ToggleCameraUsecase — resume path (pause=false)', () {
    late ToggleCameraUsecase usecase;
    setUp(() {
      usecase = ToggleCameraUsecase(mockRepo);
      provideDummy<Either<Failure, Success<void>>>(Right(tSuccessVoid));
    });

    // UC-EXT-02
    test(
      'UC-EXT-02: pause=false (resume) → calls repo with pause=false, returns Right',
      () async {
        when(mockRepo.toggleCamera(producerId: tProducerId, pause: false))
            .thenAnswer((_) async => Right(tSuccessVoid));

        const params = ToggleCameraParams(producerId: tProducerId, pause: false);
        final result = await usecase.call(params);

        expect(result, Right<Failure, Success<void>>(tSuccessVoid));
        verify(mockRepo.toggleCamera(producerId: tProducerId, pause: false)).called(1);
        verifyNoMoreInteractions(mockRepo);
      },
    );

    test(
      'UC-EXT-02b: pause=false passes through Left(ServerFailure)',
      () async {
        when(mockRepo.toggleCamera(producerId: tProducerId, pause: false))
            .thenAnswer((_) async => const Left(tServerFailure));

        const params = ToggleCameraParams(producerId: tProducerId, pause: false);
        final result = await usecase.call(params);

        expect(result, const Left<Failure, Success<void>>(tServerFailure));
      },
    );
  });

  // ───────────────────────────────────────────────────────────────────────────
  // GAP 6 — Missing failure variants per use case
  // ───────────────────────────────────────────────────────────────────────────

  group('ProduceMediaUsecase — MediaPermissionFailure', () {
    late ProduceMediaUsecase usecase;

    setUp(() {
      usecase = ProduceMediaUsecase(mockRepo);
      provideDummy<Either<Failure, Success<ProducerEntity>>>(Right(tSuccessProducer));
    });

    // UC-EXT-03
    test(
      'UC-EXT-03: audio produce → OS denies permission → Left(MediaPermissionFailure)',
      () async {
        when(mockRepo.produce(
          roomId: anyNamed('roomId'),
          kind: anyNamed('kind'),
          track: anyNamed('track'),
          stream: anyNamed('stream'),
        )).thenAnswer((_) async => const Left(tMediaPermissionFailure));

        final params = ProduceMediaParams(
          roomId: tRoomId,
          kind: MediaKind.audio,
          track: mockTrack,
          stream: mockStream,
        );
        final result = await usecase.call(params);

        expect(result, const Left<Failure, Success<ProducerEntity>>(tMediaPermissionFailure));
      },
    );
  });

  group('ConsumeMediaUsecase — explicit InternetFailure', () {
    late ConsumeMediaUsecase usecase;
    setUp(() {
      usecase = ConsumeMediaUsecase(mockRepo);
      provideDummy<Either<Failure, Success<ConsumerEntity>>>(Right(tSuccessConsumer));
    });

    // UC-EXT-04
    test(
      'UC-EXT-04: offline → consume call → Left(InternetFailure) passes through',
      () async {
        when(mockRepo.consume(
          roomId: tRoomId,
          producerId: tRemoteProducerId,
          peerId: tPeerId,
        )).thenAnswer((_) async => const Left(tInternetFailure));

        const params = ConsumeMediaParams(roomId: tRoomId, producerId: tRemoteProducerId, peerId: tPeerId);
        final result = await usecase.call(params);

        expect(result, const Left<Failure, Success<ConsumerEntity>>(tInternetFailure));
        verify(mockRepo.consume(roomId: tRoomId, producerId: tRemoteProducerId, peerId: tPeerId)).called(1);
      },
    );
  });

  group('SwitchCameraUsecase — unexpected ServerFailure', () {
    late SwitchCameraUsecase usecase;
    setUp(() {
      usecase = SwitchCameraUsecase(mockRepo);
      provideDummy<Either<Failure, Success<LocalMediaEntity>>>(Right(tSuccessLocalMedia));
    });

    // UC-EXT-05
    test(
      'UC-EXT-05: unexpected repo error → Left(ServerFailure) passes through',
      () async {
        when(mockRepo.switchCamera())
            .thenAnswer((_) async => const Left(tServerFailure));

        final result = await usecase.call(tSwitchCameraParams);

        expect(result, const Left<Failure, Success<LocalMediaEntity>>(tServerFailure));
      },
    );
  });

  group('InitLocalMediaUsecase — audio-only MediaPermissionFailure', () {
    late InitLocalMediaUsecase usecase;
    setUp(() {
      usecase = InitLocalMediaUsecase(mockRepo);
      provideDummy<Either<Failure, Success<LocalMediaEntity>>>(Right(tSuccessLocalMedia));
    });

    // UC-EXT-06
    test(
      'UC-EXT-06: audio-only params denied by OS → Left(MediaPermissionFailure)',
      () async {
        when(mockRepo.initLocalMedia(enableAudio: true, enableVideo: false))
            .thenAnswer((_) async => const Left(tMediaPermissionFailure));

        final result = await usecase.call(tInitMediaParamsAudioOnly);

        expect(result, const Left<Failure, Success<LocalMediaEntity>>(tMediaPermissionFailure));
      },
    );
  });

  // ───────────────────────────────────────────────────────────────────────────
  // GAP 7 — Interaction Isolation
  // ───────────────────────────────────────────────────────────────────────────

  group('CreateRoomUsecase — interaction isolation', () {
    late CreateRoomUsecase usecase;
    setUp(() {
      usecase = CreateRoomUsecase(mockRepo);
      provideDummy<Either<Failure, Success<RoomEntity>>>(Right(tSuccessRoom));
    });

    // ISO-01
    test(
      'ISO-01: createRoom called → joinRoom, leaveRoom, produce etc. never invoked',
      () async {
        when(mockRepo.createRoom(displayName: tDisplayName))
            .thenAnswer((_) async => Right(tSuccessRoom));

        await usecase.call(tCreateRoomParams);

        verify(mockRepo.createRoom(displayName: tDisplayName)).called(1);
        verifyNoMoreInteractions(mockRepo); // all other repo methods untouched
      },
    );
  });

  group('JoinRoomUsecase — interaction isolation', () {
    late JoinRoomUsecase usecase;
    setUp(() {
      usecase = JoinRoomUsecase(mockRepo);
      provideDummy<Either<Failure, Success<RoomEntity>>>(Right(tSuccessRoom));
    });

    // ISO-02
    test(
      'ISO-02: joinRoom called → createRoom and all other methods never invoked',
      () async {
        when(mockRepo.joinRoom(roomId: tRoomId, displayName: tGuestDisplayName))
            .thenAnswer((_) async => Right(tSuccessRoom));

        await usecase.call(tJoinRoomParams);

        verify(mockRepo.joinRoom(roomId: tRoomId, displayName: tGuestDisplayName)).called(1);
        verifyNoMoreInteractions(mockRepo);
      },
    );
  });

  group('SwitchCameraUsecase — socket isolation (ISO-03 critical)', () {
    late SwitchCameraUsecase usecase;
    setUp(() {
      usecase = SwitchCameraUsecase(mockRepo);
      provideDummy<Either<Failure, Success<LocalMediaEntity>>>(Right(tSuccessLocalMediaSwitched));
    });

    // ISO-03 — most critical: SwitchCamera MUST NOT touch socket layer
    test(
      'ISO-03: switchCamera triggers ONLY repo.switchCamera() — no produce, consume, join, create called',
      () async {
        when(mockRepo.switchCamera())
            .thenAnswer((_) async => Right(tSuccessLocalMediaSwitched));

        await usecase.call(tSwitchCameraParams);

        verify(mockRepo.switchCamera()).called(1);
        // verifyNoMoreInteractions ensures produce/consume/join/create were never called
        verifyNoMoreInteractions(mockRepo);
      },
    );
  });

  // ───────────────────────────────────────────────────────────────────────────
  // Additional: Use case call() is always async (no sync throw)
  // ───────────────────────────────────────────────────────────────────────────

  group('UseCase never throws (always returns Either)', () {
    test(
      'InitLocalMediaUsecase: repository error surfaces as Left, never throws',
      () async {
        final usecase = InitLocalMediaUsecase(mockRepo);
        provideDummy<Either<Failure, Success<LocalMediaEntity>>>(Right(tSuccessLocalMedia));
        when(mockRepo.initLocalMedia(enableAudio: true, enableVideo: true))
            .thenAnswer((_) async => const Left(tServerFailure));

        // Must complete without throwing — Either wraps the error
        expect(
          usecase.call(tInitMediaParams),
          completion(isA<Left<Failure, Success<LocalMediaEntity>>>()),
        );
      },
    );

    test(
      'SwitchCameraUsecase: repository error surfaces as Left, never throws',
      () async {
        final usecase = SwitchCameraUsecase(mockRepo);
        provideDummy<Either<Failure, Success<LocalMediaEntity>>>(Right(tSuccessLocalMedia));
        when(mockRepo.switchCamera())
            .thenAnswer((_) async => const Left(tMediaPermissionFailure));

        expect(
          usecase.call(tSwitchCameraParams),
          completion(isA<Left<Failure, Success<LocalMediaEntity>>>()),
        );
      },
    );
  });
}
