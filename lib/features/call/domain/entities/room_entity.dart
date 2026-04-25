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

  /// The local user's Peer ID in this room.
  final String? myPeerId;

  const RoomEntity({
    required this.id,
    required this.hostPeerId,
    required this.peers,
    required this.createdAt,
    required this.isActive,
    this.myPeerId,
  });

  @override
  List<Object?> get props => [id, hostPeerId, peers, createdAt, isActive, myPeerId];

  RoomEntity copyWith({
    String? id,
    String? hostPeerId,
    List<PeerEntity>? peers,
    DateTime? createdAt,
    bool? isActive,
    String? myPeerId,
  }) {
    return RoomEntity(
      id: id ?? this.id,
      hostPeerId: hostPeerId ?? this.hostPeerId,
      peers: peers ?? this.peers,
      createdAt: createdAt ?? this.createdAt,
      isActive: isActive ?? this.isActive,
      myPeerId: myPeerId ?? this.myPeerId,
    );
  }
}
