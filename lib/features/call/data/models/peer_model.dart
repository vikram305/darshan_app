import '../../domain/entities/peer_entity.dart';
import 'producer_model.dart';
import 'consumer_model.dart';

class PeerModel extends PeerEntity {
  const PeerModel({
    required super.id,
    required super.displayName,
    required super.producers,
    required super.consumers,
    required super.isAudioMuted,
    required super.isCameraOff,
    required super.isScreenSharing,
  });

  factory PeerModel.fromJson(Map<String, dynamic> json) {
    return PeerModel(
      id: (json['id'] ?? '') as String,
      displayName: (json['name'] ?? json['displayName'] ?? 'Unknown') as String,
      producers: (json['producers'] as List? ?? [])
          .map((p) => ProducerModel.fromJson(p as Map<String, dynamic>))
          .toList(),
      consumers: (json['consumers'] as List? ?? [])
          .map((c) => ConsumerModel.fromJson(c as Map<String, dynamic>))
          .toList(),
      isAudioMuted: (json['isAudioMuted'] ?? false) as bool,
      isCameraOff: (json['isCameraOff'] ?? false) as bool,
      isScreenSharing: (json['isScreenSharing'] ?? false) as bool,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'displayName': displayName,
      'producers': producers.map((p) => (p as ProducerModel).toJson()).toList(),
      'consumers': consumers.map((c) => (c as ConsumerModel).toJson()).toList(),
      'isAudioMuted': isAudioMuted,
      'isCameraOff': isCameraOff,
      'isScreenSharing': isScreenSharing,
    };
  }
}
