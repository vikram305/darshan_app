import 'package:darshan_app/core/error/failure.dart';
import 'package:darshan_app/core/fetcher/base_fetcher_bloc.dart';
import 'package:darshan_app/core/usecase/filter.dart';
import 'package:darshan_app/core/usecase/success.dart';
import 'package:darshan_app/features/call/domain/entities/room_entity.dart';
import 'package:darshan_app/features/call/domain/usecases/create_room_usecase.dart';
import 'package:darshan_app/features/call/domain/usecases/join_room_usecase.dart';
import 'package:darshan_app/features/call/presentation/bloc/call_fetcher_filter.dart';
import 'package:fpdart/fpdart.dart';

class CallFetcherBloc extends BaseFetcherBloc<RoomEntity> {
  final CreateRoomUsecase _createRoomUsecase;
  final JoinRoomUsecase _joinRoomUsecase;

  CallFetcherBloc({
    required CreateRoomUsecase createRoomUsecase,
    required JoinRoomUsecase joinRoomUsecase,
  })  : _createRoomUsecase = createRoomUsecase,
        _joinRoomUsecase = joinRoomUsecase;

  @override
  Future<Either<Failure, Success<RoomEntity>>> operation({
    required Filter filter,
  }) async {
    if (filter is CreateRoomFilter) {
      return await _createRoomUsecase(CreateRoomParams(
        displayName: filter.displayName,
      ));
    } else if (filter is JoinRoomFilter) {
      return await _joinRoomUsecase(JoinRoomParams(
        roomId: filter.roomId,
        displayName: filter.displayName,
      ));
    } else {
      return const Left(BadFilterFailure('Invalid filter for CallFetcher'));
    }
  }
}
