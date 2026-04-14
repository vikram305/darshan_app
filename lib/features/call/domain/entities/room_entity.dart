import 'package:equatable/equatable.dart';
import 'peer_entity.dart';

/// Represents the active Mediasoup room/session that a user creates or joins.
/// [peers] reflects the live participant list; it is mutable via cubit state diffs
/// as `new-peer` / `peer-left` socket events arrive.
class RoomEntity extends Equatable {
  /// Unique room identifier (UUID assigned by the server).
  final String id;

  /// Peer ID of the user who originally created the room.
  final String hostPeerId;

  /// All currently active participants, including the local peer.
  final List<PeerEntity> peers;

  /// Server-assigned creation timestamp.
  final DateTime createdAt;

  /// False once the last peer leaves or the host explicitly closes the room.
  final bool isActive;

  const RoomEntity({
    required this.id,
    required this.hostPeerId,
    required this.peers,
    required this.createdAt,
    required this.isActive,
  });

  @override
  List<Object?> get props => [id, hostPeerId, peers, createdAt, isActive];
}
