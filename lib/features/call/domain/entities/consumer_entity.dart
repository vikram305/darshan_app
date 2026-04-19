import 'package:flutter_webrtc/flutter_webrtc.dart';
import 'package:equatable/equatable.dart';
import 'media_kind.dart';

/// Represents an inbound media track that the local peer receives from a remote [ProducerEntity].
/// The [rtpParameters] map is passed verbatim to the Mediasoup Device to set up decoding.
/// Consumers are read-only from the domain perspective — they are created server-side on demand.
class ConsumerEntity extends Equatable {
  /// Mediasoup server-assigned consumer ID.
  final String id;

  /// The remote producer this consumer is linked to.
  final String producerId;

  /// The remote peer whose media is being consumed.
  final String peerId;

  /// Whether this consumer carries audio or video.
  final MediaKind kind;

  /// True when the remote producer is paused, propagated down to the consumer.
  final bool isPaused;

  /// Raw RTP parameters returned by the server; must be forwarded to the Mediasoup Device unchanged.
  final Map<String, dynamic> rtpParameters;

  /// The actual media stream for rendering. Received from Mediasoup Transport.
  final MediaStream? stream;

  const ConsumerEntity({
    required this.id,
    required this.producerId,
    required this.peerId,
    required this.kind,
    required this.isPaused,
    required this.rtpParameters,
    this.stream,
  });

  @override
  List<Object?> get props => [id, producerId, peerId, kind, isPaused, rtpParameters, stream];

  ConsumerEntity copyWith({
    String? id,
    String? producerId,
    String? peerId,
    MediaKind? kind,
    bool? isPaused,
    Map<String, dynamic>? rtpParameters,
    MediaStream? stream,
  }) {
    return ConsumerEntity(
      id: id ?? this.id,
      producerId: producerId ?? this.producerId,
      peerId: peerId ?? this.peerId,
      kind: kind ?? this.kind,
      isPaused: isPaused ?? this.isPaused,
      rtpParameters: rtpParameters ?? this.rtpParameters,
      stream: stream ?? this.stream,
    );
  }
}

