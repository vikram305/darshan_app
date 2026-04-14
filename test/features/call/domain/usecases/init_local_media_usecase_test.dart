// ignore_for_file: lines_longer_than_80_chars

import 'package:darshan_app/core/error/failure.dart';
import 'package:darshan_app/core/usecase/success.dart';
import 'package:darshan_app/features/call/domain/entities/local_media_entity.dart';
import 'package:darshan_app/features/call/domain/usecases/init_local_media_usecase.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:fpdart/fpdart.dart';
import 'package:mockito/mockito.dart';

import '../../utils/call_test_constants.dart';
import 'usecases_test.mocks.dart';

void main() {
  late MockCallRepository mockRepo;
  late InitLocalMediaUsecase usecase;

  setUp(() {
    mockRepo = MockCallRepository();
    usecase = InitLocalMediaUsecase(mockRepo);
    provideDummy<Either<Failure, Success<LocalMediaEntity>>>(Right(tSuccessLocalMedia));
  });

  group('InitLocalMediaUsecase', () {
    // Happy path: audio + video enabled.
    test(
      'SC-UC-24: audio+video enabled → returns Right(Success<LocalMediaEntity>)',
      () async {
        when(mockRepo.initLocalMedia(enableAudio: true, enableVideo: true))
            .thenAnswer((_) async => Right(tSuccessLocalMedia));

        final result = await usecase.call(tInitMediaParams);

        expect(result, Right<Failure, Success<LocalMediaEntity>>(tSuccessLocalMedia));
        verify(mockRepo.initLocalMedia(enableAudio: true, enableVideo: true)).called(1);
        verifyNoMoreInteractions(mockRepo);
      },
    );

    // Audio only variant.
    test(
      'SC-UC-25: enableVideo=false → delegates to repo with correct flags',
      () async {
        when(mockRepo.initLocalMedia(enableAudio: true, enableVideo: false))
            .thenAnswer((_) async => Right(tSuccessLocalMedia));

        final result = await usecase.call(tInitMediaParamsAudioOnly);

        expect(result, Right<Failure, Success<LocalMediaEntity>>(tSuccessLocalMedia));
        verify(mockRepo.initLocalMedia(enableAudio: true, enableVideo: false)).called(1);
      },
    );

    // Scenario 3.4 #10 — both disabled → MediaPermissionFailure.
    test(
      'SC-UC-26: both enableAudio=false & enableVideo=false → returns Left(MediaPermissionFailure)',
      () async {
        when(mockRepo.initLocalMedia(enableAudio: false, enableVideo: false))
            .thenAnswer((_) async => const Left(tMediaPermissionFailure));

        final result = await usecase.call(tInitMediaParamsBothOff);

        expect(result, const Left<Failure, Success<LocalMediaEntity>>(tMediaPermissionFailure));
      },
    );

    // OS permission denied.
    test(
      'SC-UC-27: OS denies mic/camera permission → Left(MediaPermissionFailure)',
      () async {
        when(mockRepo.initLocalMedia(enableAudio: true, enableVideo: true))
            .thenAnswer((_) async => const Left(tMediaPermissionFailure));

        final result = await usecase.call(tInitMediaParams);

        expect(result, const Left<Failure, Success<LocalMediaEntity>>(tMediaPermissionFailure));
      },
    );

    // Device enumeration error.
    test(
      'SC-UC-28: device enumeration error → Left(ServerFailure)',
      () async {
        when(mockRepo.initLocalMedia(enableAudio: true, enableVideo: true))
            .thenAnswer((_) async => const Left(tServerFailure));

        final result = await usecase.call(tInitMediaParams);

        expect(result, const Left<Failure, Success<LocalMediaEntity>>(tServerFailure));
      },
    );
  });
}
