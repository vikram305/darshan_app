import 'package:bloc_test/bloc_test.dart';
import 'package:darshan_app/core/error/failure.dart';
import 'package:darshan_app/core/fetcher/fetcher_event.dart';
import 'package:darshan_app/core/fetcher/fetcher_state.dart';
import 'package:darshan_app/core/usecase/success.dart';
import 'package:darshan_app/features/call/domain/entities/room_entity.dart';
import 'package:darshan_app/features/call/domain/usecases/create_room_usecase.dart';
import 'package:darshan_app/features/call/domain/usecases/join_room_usecase.dart';
import 'package:darshan_app/features/call/presentation/bloc/call_fetcher_bloc.dart';
import 'package:darshan_app/features/call/presentation/bloc/call_fetcher_filter.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:fpdart/fpdart.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';

import '../utils/call_test_constants.dart';

import 'call_fetcher_bloc_test.mocks.dart';

@GenerateMocks([CreateRoomUsecase, JoinRoomUsecase])
void main() {
  late CallFetcherBloc bloc;
  late MockCreateRoomUsecase mockCreateRoom;
  late MockJoinRoomUsecase mockJoinRoom;

  setUp(() {
    provideDummy<Either<Failure, Success<RoomEntity>>>(Right(Success(tRoom)));
    mockCreateRoom = MockCreateRoomUsecase();
    mockJoinRoom = MockJoinRoomUsecase();

    bloc = CallFetcherBloc(
      createRoomUsecase: mockCreateRoom,
      joinRoomUsecase: mockJoinRoom,
    );
  });

  group('CallFetcherBloc', () {
    test('initial state should be FetcherInitial', () {
      expect(bloc.state, equals(const FetcherInitial<RoomEntity>()));
    });

    blocTest<CallFetcherBloc, FetcherState<RoomEntity>>(
      'Scenario 3.5 #1: should emit [Loading, Success] when joinRoom succeeds',
      build: () {
        when(mockJoinRoom(any)).thenAnswer((_) async => Right(Success(tRoomWithGuest)));
        return bloc;
      },
      act: (bloc) => bloc.add(const FetchData(
        filter: JoinRoomFilter(roomId: tRoomId, displayName: tGuestDisplayName),
      )),
      expect: () => [
        isA<FetcherLoading<RoomEntity>>(),
        isA<FetcherSuccess<RoomEntity>>().having((s) => s.data, 'room', tRoomWithGuest),
      ],
      verify: (_) {
        verify(mockJoinRoom(const JoinRoomParams(roomId: tRoomId, displayName: tGuestDisplayName)));
      },
    );

    blocTest<CallFetcherBloc, FetcherState<RoomEntity>>(
      'Scenario 3.5 #2: should emit [Loading, Success] when createRoom succeeds',
      build: () {
        when(mockCreateRoom(any)).thenAnswer((_) async => Right(Success(tRoom)));
        return bloc;
      },
      act: (bloc) => bloc.add(const FetchData(
        filter: CreateRoomFilter(displayName: tDisplayName),
      )),
      expect: () => [
        isA<FetcherLoading<RoomEntity>>(),
        isA<FetcherSuccess<RoomEntity>>().having((s) => s.data, 'room', tRoom),
      ],
    );

    blocTest<CallFetcherBloc, FetcherState<RoomEntity>>(
      'Scenario 3.5 #3: should emit [Loading, Failure] when repository fails',
      build: () {
        when(mockJoinRoom(any)).thenAnswer((_) async => const Left(tRoomNotFoundFailure));
        return bloc;
      },
      act: (bloc) => bloc.add(const FetchData(
        filter: JoinRoomFilter(roomId: 'bad-id', displayName: tDisplayName),
      )),
      expect: () => [
        isA<FetcherLoading<RoomEntity>>(),
        const FetcherFailure<RoomEntity>(tRoomNotFoundMessage),
      ],
    );

    blocTest<CallFetcherBloc, FetcherState<RoomEntity>>(
      'Scenario 3.5 #4: should emit [Loading, Failure] for unknown filter',
      build: () => bloc,
      act: (bloc) => bloc.add(const FetchData(filter: null)),
      expect: () => [
        isA<FetcherLoading<RoomEntity>>(),
        const FetcherFailure<RoomEntity>('Invalid filter for CallFetcher'),
      ],
    );
  });
}
