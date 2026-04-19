import 'package:equatable/equatable.dart';
import 'peer_entity.dart';
import 'media_kind.dart';

sealed class CallEvent extends Equatable {
  const CallEvent();
  @override
  List<Object?> get props => [];
}

class PeerJoinedEvent extends CallEvent {
  final PeerEntity peer;
  const PeerJoinedEvent(this.peer);
  @override
  List<Object?> get props => [peer];
}

class PeerLeftEvent extends CallEvent {
  final String peerId;
  const PeerLeftEvent(this.peerId);
  @override
  List<Object?> get props => [peerId];
}

class ProducerJoinedEvent extends CallEvent {
  final String peerId;
  final String producerId;
  final MediaKind kind;
  const ProducerJoinedEvent({
    required this.peerId,
    required this.producerId,
    required this.kind,
  });
  @override
  List<Object?> get props => [peerId, producerId, kind];
}

class ProducerClosedEvent extends CallEvent {
  final String peerId;
  final String producerId;
  const ProducerClosedEvent({
    required this.peerId,
    required this.producerId,
  });
  @override
  List<Object?> get props => [peerId, producerId];
}
