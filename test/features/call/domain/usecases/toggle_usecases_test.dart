// ignore_for_file: lines_longer_than_80_chars

import 'package:darshan_app/core/error/failure.dart';
import 'package:darshan_app/core/usecase/success.dart';
import 'package:darshan_app/features/call/domain/usecases/toggle_audio_usecase.dart';
import 'package:darshan_app/features/call/domain/usecases/toggle_camera_usecase.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:fpdart/fpdart.dart';
import 'package:mockito/mockito.dart';

import '../../utils/call_test_constants.dart';
import 'usecases_test.mocks.dart';

void main() {
  late MockCallRepository mockRepo;

  setUp(() {
    mockRepo = MockCallRepository();
    provideDummy<Either<Failure, Success<void>>>(Right(tSuccessVoid));
  });

  // ─── ToggleAudioUsecase ──────────────────────────────────────────────────
  group('ToggleAudioUsecase', () {
    late ToggleAudioUsecase usecase;

    setUp(() => usecase = ToggleAudioUsecase(mockRepo));

    // Scenario 3.4 #3 — pause:true calls repo with correct producerId.
    test(
      'SC-UC-18: pause=true → calls repository with correct producerId',
      () async {
        when(mockRepo.toggleAudio(producerId: tProducerId, pause: true))
            .thenAnswer((_) async => Right(tSuccessVoid));

        final result = await usecase.call(tToggleAudioParamsPause);

        expect(result, Right<Failure, Success<void>>(tSuccessVoid));
        verify(mockRepo.toggleAudio(producerId: tProducerId, pause: true)).called(1);
        verifyNoMoreInteractions(mockRepo);
      },
    );

    test(
      'SC-UC-19: passes through Left(ServerFailure) from repository',
      () async {
        when(mockRepo.toggleAudio(producerId: tProducerId, pause: true))
            .thenAnswer((_) async => const Left(tServerFailure));

        final result = await usecase.call(tToggleAudioParamsPause);

        expect(result, const Left<Failure, Success<void>>(tServerFailure));
      },
    );
  });

  // ─── ToggleCameraUsecase ─────────────────────────────────────────────────
  group('ToggleCameraUsecase', () {
    late ToggleCameraUsecase usecase;

    setUp(() => usecase = ToggleCameraUsecase(mockRepo));

    test(
      'SC-UC-20: pause=true → calls repository with correct producerId',
      () async {
        when(mockRepo.toggleCamera(producerId: tProducerId, pause: true))
            .thenAnswer((_) async => Right(tSuccessVoid));

        final result = await usecase.call(tToggleCameraParamsPause);

        expect(result, Right<Failure, Success<void>>(tSuccessVoid));
        verify(mockRepo.toggleCamera(producerId: tProducerId, pause: true)).called(1);
        verifyNoMoreInteractions(mockRepo);
      },
    );

    test(
      'SC-UC-21: passes through Left(ServerFailure) from repository',
      () async {
        when(mockRepo.toggleCamera(producerId: tProducerId, pause: true))
            .thenAnswer((_) async => const Left(tServerFailure));

        final result = await usecase.call(tToggleCameraParamsPause);

        expect(result, const Left<Failure, Success<void>>(tServerFailure));
      },
    );
  });
}
