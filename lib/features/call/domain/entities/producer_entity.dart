import 'package:equatable/equatable.dart';
import 'media_kind.dart';

/// Represents a single outbound media track (microphone or camera) owned by the local peer.
/// A producer is identified by Mediasoup's server-assigned [id] and may be paused
/// without being fully closed, preserving server state.
class ProducerEntity extends Equatable {
  /// Mediasoup server-assigned producer ID.
  final String id;

  /// Whether this producer carries audio or video.
  final MediaKind kind;

  /// True when the track is paused (muted/frozen) but the server-side producer is still alive.
  final bool isPaused;

  /// Differentiates a screen-share video producer from a regular camera producer.
  final bool isScreenShare;

  const ProducerEntity({
    required this.id,
    required this.kind,
    required this.isPaused,
    required this.isScreenShare,
  });

  @override
  List<Object?> get props => [id, kind, isPaused, isScreenShare];
}
