// ignore_for_file: lines_longer_than_80_chars

import 'package:darshan_app/core/error/failure.dart';
import 'package:darshan_app/core/usecase/success.dart';
import 'package:darshan_app/features/call/domain/entities/room_entity.dart';
import 'package:darshan_app/features/call/domain/usecases/join_room_usecase.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:fpdart/fpdart.dart';
import 'package:mockito/mockito.dart';

import '../../utils/call_test_constants.dart';
import 'usecases_test.mocks.dart';

void main() {
  late MockCallRepository mockRepo;
  late JoinRoomUsecase usecase;

  setUp(() {
    mockRepo = MockCallRepository();
    usecase = JoinRoomUsecase(mockRepo);
    provideDummy<Either<Failure, Success<RoomEntity>>>(Right(tSuccessRoomWithGuest));
  });

  group('JoinRoomUsecase', () {
    // Scenario 3.4 #2 — correctly passes roomId and displayName.
    test(
      'SC-UC-04: passes roomId and displayName to repository correctly',
      () async {
        when(mockRepo.joinRoom(roomId: tRoomId, displayName: tGuestDisplayName))
            .thenAnswer((_) async => Right(tSuccessRoomWithGuest));

        final result = await usecase.call(tJoinRoomParams);

        expect(result, Right<Failure, Success<RoomEntity>>(tSuccessRoomWithGuest));
        verify(mockRepo.joinRoom(roomId: tRoomId, displayName: tGuestDisplayName)).called(1);
        verifyNoMoreInteractions(mockRepo);
      },
    );

    // Scenario 3.4 #7 — empty roomId is delegated to repo which returns Left(ServerFailure).
    test(
      'SC-UC-05: delegates empty roomId to repo which returns Left(ServerFailure)',
      () async {
        when(mockRepo.joinRoom(roomId: '', displayName: tGuestDisplayName))
            .thenAnswer((_) async => const Left(tServerFailure));

        final result = await usecase.call(tJoinRoomParamsEmptyId);

        expect(result, const Left<Failure, Success<RoomEntity>>(tServerFailure));
      },
    );

    // RoomNotFoundFailure passthrough.
    test(
      'SC-UC-06: passes through Left(RoomNotFoundFailure) from repository',
      () async {
        when(mockRepo.joinRoom(roomId: tRoomId, displayName: tGuestDisplayName))
            .thenAnswer((_) async => const Left(tRoomNotFoundFailure));

        final result = await usecase.call(tJoinRoomParams);

        expect(result, const Left<Failure, Success<RoomEntity>>(tRoomNotFoundFailure));
      },
    );

    // RoomFullFailure passthrough.
    test(
      'SC-UC-07: passes through Left(RoomFullFailure) from repository',
      () async {
        when(mockRepo.joinRoom(roomId: tRoomId, displayName: tGuestDisplayName))
            .thenAnswer((_) async => const Left(tRoomFullFailure));

        final result = await usecase.call(tJoinRoomParams);

        expect(result, const Left<Failure, Success<RoomEntity>>(tRoomFullFailure));
      },
    );

    // Scenario 3.4 #8 — offline scenario.
    test(
      'SC-UC-08: passes through Left(InternetFailure) when offline',
      () async {
        when(mockRepo.joinRoom(roomId: tRoomId, displayName: tGuestDisplayName))
            .thenAnswer((_) async => const Left(tInternetFailure));

        final result = await usecase.call(tJoinRoomParams);

        expect(result, const Left<Failure, Success<RoomEntity>>(tInternetFailure));
      },
    );
  });
}
