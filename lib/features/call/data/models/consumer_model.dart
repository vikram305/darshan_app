import '../../domain/entities/media_kind.dart';
import '../../domain/entities/consumer_entity.dart';

class ConsumerModel extends ConsumerEntity {
  const ConsumerModel({
    required super.id,
    required super.producerId,
    required super.peerId,
    required super.kind,
    required super.isPaused,
    required super.rtpParameters,
    super.stream,
  });


  factory ConsumerModel.fromJson(Map<String, dynamic> json) {
    return ConsumerModel(
      id: json['id'] as String,
      producerId: json['producerId'] as String,
      peerId: json['peerId'] as String,
      kind: json['kind'] == 'audio' ? MediaKind.audio : MediaKind.video,
      isPaused: json['isPaused'] as bool,
      rtpParameters: Map<String, dynamic>.from(json['rtpParameters'] as Map),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'producerId': producerId,
      'peerId': peerId,
      'kind': kind == MediaKind.audio ? 'audio' : 'video',
      'isPaused': isPaused,
      'rtpParameters': rtpParameters,
    };
  }
}
