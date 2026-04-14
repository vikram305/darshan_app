// ignore_for_file: lines_longer_than_80_chars

import 'package:darshan_app/core/error/failure.dart';
import 'package:darshan_app/core/usecase/success.dart';
import 'package:darshan_app/features/call/domain/entities/room_entity.dart';
import 'package:darshan_app/features/call/domain/usecases/create_room_usecase.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:fpdart/fpdart.dart';
import 'package:mockito/mockito.dart';

import '../../utils/call_test_constants.dart';
import 'usecases_test.mocks.dart';

void main() {
  late MockCallRepository mockRepo;
  late CreateRoomUsecase usecase;

  setUp(() {
    mockRepo = MockCallRepository();
    usecase = CreateRoomUsecase(mockRepo);
    // Provide a dummy for Either to avoid LateInitializationError in Mockito.
    provideDummy<Either<Failure, Success<RoomEntity>>>(Right(tSuccessRoom));
  });

  group('CreateRoomUsecase', () {
    // Scenario 3.4 #1 — happy path: delegates call() to repo and returns Either unchanged.
    test(
      'SC-UC-01: delegates to repository and returns Right(Success<RoomEntity>) unchanged',
      () async {
        when(mockRepo.createRoom(displayName: tDisplayName))
            .thenAnswer((_) async => Right(tSuccessRoom));

        final result = await usecase.call(tCreateRoomParams);

        expect(result, Right<Failure, Success<RoomEntity>>(tSuccessRoom));
        verify(mockRepo.createRoom(displayName: tDisplayName)).called(1);
        verifyNoMoreInteractions(mockRepo);
      },
    );

    // Scenario 3.4 #8 (offline variant for create): repo returns Left(InternetFailure).
    test(
      'SC-UC-02: passes through Left(InternetFailure) from repository when offline',
      () async {
        when(mockRepo.createRoom(displayName: tDisplayName))
            .thenAnswer((_) async => const Left(tInternetFailure));

        final result = await usecase.call(tCreateRoomParams);

        expect(result, const Left<Failure, Success<RoomEntity>>(tInternetFailure));
      },
    );

    // ServerFailure passthrough
    test(
      'SC-UC-03: passes through Left(ServerFailure) from repository',
      () async {
        when(mockRepo.createRoom(displayName: tDisplayName))
            .thenAnswer((_) async => const Left(tServerFailure));

        final result = await usecase.call(tCreateRoomParams);

        expect(result, const Left<Failure, Success<RoomEntity>>(tServerFailure));
      },
    );
  });
}
