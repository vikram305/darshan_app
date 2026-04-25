import '../../domain/entities/room_entity.dart';
import 'peer_model.dart';

class RoomModel extends RoomEntity {
  const RoomModel({
    required super.id,
    required super.hostPeerId,
    required super.peers,
    required super.createdAt,
    required super.isActive,
    super.myPeerId,
  });

  factory RoomModel.fromJson(Map<String, dynamic> json, {String? myPeerId}) {
    return RoomModel(
      id: (json['code'] ?? json['id'] ?? '') as String,
      hostPeerId: (json['hostPeerId'] ?? '') as String,
      peers: (json['peers'] as List? ?? [])
          .map((p) => PeerModel.fromJson(p as Map<String, dynamic>))
          .toList(),
      createdAt: json['createdAt'] != null
          ? (json['createdAt'] is DateTime
              ? json['createdAt'] as DateTime
              : DateTime.tryParse(json['createdAt'] as String) ?? DateTime.now())
          : DateTime.now(),
      isActive: (json['isActive'] ?? true) as bool,
      myPeerId: myPeerId ?? json['myPeerId'] as String?,
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
