import 'package:equatable/equatable.dart';

/// Shared param used by use cases that require both a room and a peer identifier.
/// Extracted here because [LeaveRoomUsecase] and [ConsumeMediaUsecase] share this shape.
class RoomPeerParams extends Equatable {
  final String roomId;
  final String peerId;

  const RoomPeerParams({required this.roomId, required this.peerId});

  @override
  List<Object?> get props => [roomId, peerId];
}
