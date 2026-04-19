import '../../domain/entities/media_kind.dart';
import '../../domain/entities/producer_entity.dart';

class ProducerModel extends ProducerEntity {
  const ProducerModel({
    required super.id,
    required super.kind,
    required super.isPaused,
    required super.isScreenShare,
  });

  factory ProducerModel.fromJson(Map<String, dynamic> json) {
    return ProducerModel(
      id: json['id'] as String,
      kind: json['kind'] == 'audio' ? MediaKind.audio : MediaKind.video,
      isPaused: json['isPaused'] as bool,
      isScreenShare: json['isScreenShare'] as bool,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'kind': kind == MediaKind.audio ? 'audio' : 'video',
      'isPaused': isPaused,
      'isScreenShare': isScreenShare,
    };
  }
}
