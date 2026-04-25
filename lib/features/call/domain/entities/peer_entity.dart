import 'package:equatable/equatable.dart';
import 'consumer_entity.dart';
import 'producer_entity.dart';

/// Represents a single participant inside a room.
/// Each peer holds its own set of [producers] (outbound tracks) and
/// [consumers] (inbound tracks it is receiving from other peers).
class PeerEntity extends Equatable {
  /// Socket-assigned peer ID; unique within the room.
  final String id;

  /// Human-readable display name for UI rendering.
  final String displayName;

  /// Media tracks this peer is currently sending.
  final List<ProducerEntity> producers;

  /// Media tracks this peer is currently consuming from others.
  final List<ConsumerEntity> consumers;

  /// Whether this peer's microphone is muted (local or remote signaled state).
  final bool isAudioMuted;

  /// Whether this peer's camera is off.
  final bool isCameraOff;

  /// Whether this peer is broadcasting a screen-share track.
  final bool isScreenSharing;

  const PeerEntity({
    required this.id,
    required this.displayName,
    required this.producers,
    required this.consumers,
    required this.isAudioMuted,
    required this.isCameraOff,
    required this.isScreenSharing,
  });

  @override
  List<Object?> get props => [id, displayName, producers, consumers, isAudioMuted, isCameraOff, isScreenSharing];
  PeerEntity copyWith({
    String? id,
    String? displayName,
    List<ProducerEntity>? producers,
    List<ConsumerEntity>? consumers,
    bool? isAudioMuted,
    bool? isCameraOff,
    bool? isScreenSharing,
  }) {
    return PeerEntity(
      id: id ?? this.id,
      displayName: displayName ?? this.displayName,
      producers: producers ?? this.producers,
      consumers: consumers ?? this.consumers,
      isAudioMuted: isAudioMuted ?? this.isAudioMuted,
      isCameraOff: isCameraOff ?? this.isCameraOff,
      isScreenSharing: isScreenSharing ?? this.isScreenSharing,
    );
  }
}
