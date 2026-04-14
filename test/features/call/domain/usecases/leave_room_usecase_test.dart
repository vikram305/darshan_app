// ignore_for_file: lines_longer_than_80_chars

import 'package:darshan_app/core/error/failure.dart';
import 'package:darshan_app/core/usecase/success.dart';
import 'package:darshan_app/features/call/domain/usecases/leave_room_usecase.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:fpdart/fpdart.dart';
import 'package:mockito/mockito.dart';

import '../../utils/call_test_constants.dart';
import 'usecases_test.mocks.dart';

void main() {
  late MockCallRepository mockRepo;
  late LeaveRoomUsecase usecase;

  setUp(() {
    mockRepo = MockCallRepository();
    usecase = LeaveRoomUsecase(mockRepo);
    provideDummy<Either<Failure, Success<void>>>(Right(tSuccessVoid));
  });

  group('LeaveRoomUsecase', () {
    // Scenario 3.4 #5 — online, success.
    test(
      'SC-UC-09: online → returns Right(Success<void>) on clean leave',
      () async {
        when(mockRepo.leaveRoom(roomId: tRoomId, peerId: tHostPeerId))
            .thenAnswer((_) async => Right(tSuccessVoid));

        final result = await usecase.call(tLeaveRoomParams);

        expect(result, Right<Failure, Success<void>>(tSuccessVoid));
        verify(mockRepo.leaveRoom(roomId: tRoomId, peerId: tHostPeerId)).called(1);
        verifyNoMoreInteractions(mockRepo);
      },
    );

    // Mid-cleanup error — repo still returns Left(ServerFailure), no unhandled exception.
    test(
      'SC-UC-10: repo throws mid-cleanup → returns Left(ServerFailure), no unhandled exception',
      () async {
        when(mockRepo.leaveRoom(roomId: tRoomId, peerId: tHostPeerId))
            .thenAnswer((_) async => const Left(tServerFailure));

        final result = await usecase.call(tLeaveRoomParams);

        expect(result, const Left<Failure, Success<void>>(tServerFailure));
      },
    );

    // Offline scenario.
    test(
      'SC-UC-11: passes through Left(InternetFailure) when offline',
      () async {
        when(mockRepo.leaveRoom(roomId: tRoomId, peerId: tHostPeerId))
            .thenAnswer((_) async => const Left(tInternetFailure));

        final result = await usecase.call(tLeaveRoomParams);

        expect(result, const Left<Failure, Success<void>>(tInternetFailure));
      },
    );
  });
}
