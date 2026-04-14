import 'package:equatable/equatable.dart';
import 'package:fpdart/fpdart.dart';
import '../../../../core/error/failure.dart';
import '../../../../core/usecase/success.dart';
import '../../../../core/usecase/usecase.dart';
import '../entities/room_entity.dart';
import '../repositories/call_repository.dart';

/// Creates a new Mediasoup room on the server.
/// On success returns the freshly created [RoomEntity] with the host peer pre-populated.
/// Possible failures: [ServerFailure], [InternetFailure].
class CreateRoomUsecase extends UseCase<RoomEntity, CreateRoomParams> {
  final CallRepository repository;
  CreateRoomUsecase(this.repository);

  @override
  Future<Either<Failure, Success<RoomEntity>>> call(CreateRoomParams params) {
    return repository.createRoom(displayName: params.displayName);
  }
}

class CreateRoomParams extends Equatable {
  final String displayName;
  const CreateRoomParams({required this.displayName});

  @override
  List<Object?> get props => [displayName];
}
