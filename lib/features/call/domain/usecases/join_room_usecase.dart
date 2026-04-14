import 'package:equatable/equatable.dart';
import 'package:fpdart/fpdart.dart';
import '../../../../core/error/failure.dart';
import '../../../../core/usecase/success.dart';
import '../../../../core/usecase/usecase.dart';
import '../entities/room_entity.dart';
import '../repositories/call_repository.dart';

/// Joins an existing room and returns the full [RoomEntity] including all current peers.
/// Possible failures: [ServerFailure] (room not found / room full), [InternetFailure].
/// Callers should inspect the concrete [Failure] subtype to surface appropriate UI messages.
class JoinRoomUsecase extends UseCase<RoomEntity, JoinRoomParams> {
  final CallRepository repository;
  JoinRoomUsecase(this.repository);

  @override
  Future<Either<Failure, Success<RoomEntity>>> call(JoinRoomParams params) {
    return repository.joinRoom(
      roomId: params.roomId,
      displayName: params.displayName,
    );
  }
}

class JoinRoomParams extends Equatable {
  final String roomId;
  final String displayName;
  const JoinRoomParams({required this.roomId, required this.displayName});

  @override
  List<Object?> get props => [roomId, displayName];
}
