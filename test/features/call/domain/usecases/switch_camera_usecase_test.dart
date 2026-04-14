// ignore_for_file: lines_longer_than_80_chars

import 'package:darshan_app/core/error/failure.dart';
import 'package:darshan_app/core/usecase/success.dart';
import 'package:darshan_app/features/call/domain/entities/local_media_entity.dart';
import 'package:darshan_app/features/call/domain/usecases/switch_camera_usecase.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:fpdart/fpdart.dart';
import 'package:mockito/mockito.dart';

import '../../utils/call_test_constants.dart';
import 'usecases_test.mocks.dart';

void main() {
  late MockCallRepository mockRepo;
  late SwitchCameraUsecase usecase;

  setUp(() {
    mockRepo = MockCallRepository();
    usecase = SwitchCameraUsecase(mockRepo);
    provideDummy<Either<Failure, Success<LocalMediaEntity>>>(Right(tSuccessLocalMediaSwitched));
  });

  group('SwitchCameraUsecase', () {
    // Scenario 3.4 #4 — only touches WebRTC datasource, never socket.
    // At the domain level: ensure switchCamera() is called and repo.consume / createRoom etc.
    // are never invoked. At the implementation level, the repo impl enforces the datasource route.
    test(
      'SC-UC-22: calls repository.switchCamera() and returns Right(LocalMediaEntity) with flipped isFrontCamera',
      () async {
        when(mockRepo.switchCamera())
            .thenAnswer((_) async => Right(tSuccessLocalMediaSwitched));

        final result = await usecase.call(tSwitchCameraParams);

        expect(result, Right<Failure, Success<LocalMediaEntity>>(tSuccessLocalMediaSwitched));
        // Verify the isFrontCamera flag is flipped in the returned entity.
        final localMedia = (result as Right).value.data as LocalMediaEntity;
        expect(localMedia.isFrontCamera, isFalse);
        verify(mockRepo.switchCamera()).called(1);
        verifyNoMoreInteractions(mockRepo);
      },
    );

    // MediaPermissionFailure (no front camera on device).
    test(
      'SC-UC-23: no front camera → returns Left(MediaPermissionFailure)',
      () async {
        when(mockRepo.switchCamera())
            .thenAnswer((_) async => const Left(tMediaPermissionFailure));

        final result = await usecase.call(tSwitchCameraParams);

        expect(result, const Left<Failure, Success<LocalMediaEntity>>(tMediaPermissionFailure));
      },
    );
  });
}
