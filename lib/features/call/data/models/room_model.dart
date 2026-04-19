import '../../domain/entities/room_entity.dart';
import 'peer_model.dart';

class RoomModel extends RoomEntity {
  const RoomModel({
    required super.id,
    required super.hostPeerId,
    required super.peers,
    required super.createdAt,
    required super.isActive,
  });

  factory RoomModel.fromJson(Map<String, dynamic> json) {
    return RoomModel(
      id: json['id'] as String,
      hostPeerId: json['hostPeerId'] as String,
      peers: (json['peers'] as List)
          .map((p) => PeerModel.fromJson(p as Map<String, dynamic>))
          .toList(),
      createdAt: json['createdAt'] is DateTime
          ? json['createdAt'] as DateTime
          : DateTime.parse(json['createdAt'] as String),
      isActive: json['isActive'] as bool,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'hostPeerId': hostPeerId,
      'peers': peers.map((p) => (p as PeerModel).toJson()).toList(),
      'createdAt': createdAt.toIso8601String(),
      'isActive': isActive,
    };
  }
}
