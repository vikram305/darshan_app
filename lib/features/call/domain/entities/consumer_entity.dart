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

  const ConsumerEntity({
    required this.id,
    required this.producerId,
    required this.peerId,
    required this.kind,
    required this.isPaused,
    required this.rtpParameters,
  });

  @override
  List<Object?> get props => [id, producerId, peerId, kind, isPaused, rtpParameters];
}
