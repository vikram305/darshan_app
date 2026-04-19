import '../../domain/entities/transport_entity.dart';

class TransportModel extends TransportEntity {
  const TransportModel({
    required super.id,
    required super.iceParameters,
    required super.iceCandidates,
    required super.dtlsParameters,
    super.sctpParameters,
  });

  factory TransportModel.fromJson(Map<String, dynamic> json) {
    return TransportModel(
      id: json['id'] as String,
      iceParameters: Map<String, dynamic>.from(json['iceParameters'] as Map),
      iceCandidates: (json['iceCandidates'] as List)
          .map((c) => Map<String, dynamic>.from(c as Map))
          .toList(),
      dtlsParameters: Map<String, dynamic>.from(json['dtlsParameters'] as Map),
      sctpParameters: json['sctpParameters'] != null
          ? Map<String, dynamic>.from(json['sctpParameters'] as Map)
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'iceParameters': iceParameters,
      'iceCandidates': iceCandidates,
      'dtlsParameters': dtlsParameters,
      'sctpParameters': sctpParameters,
    };
  }
}
