import 'package:fpdart/fpdart.dart';
import '../../../../core/error/failure.dart';
import '../../../../core/usecase/success.dart';
import '../../../../core/usecase/usecase.dart';
import '../repositories/call_repository.dart';
import 'params/room_peer_params.dart';

/// Signals a clean disconnect from the server.
/// Must be called even when no media was produced (e.g. joined but never enabled camera).
/// Possible failures: [ServerFailure], [InternetFailure].
class LeaveRoomUsecase extends UseCase<void, RoomPeerParams> {
  final CallRepository repository;
  LeaveRoomUsecase(this.repository);

  @override
  Future<Either<Failure, Success<void>>> call(RoomPeerParams params) {
    return repository.leaveRoom(roomId: params.roomId, peerId: params.peerId);
  }
}
