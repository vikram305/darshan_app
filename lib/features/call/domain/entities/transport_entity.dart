import 'package:equatable/equatable.dart';

/// Wraps the Mediasoup WebRTC transport parameters returned by the server.
/// Used verbatim when calling `device.createSendTransport()` or `device.createRecvTransport()`.
/// This entity is intentionally thin — the Mediasoup SDK owns the transport lifecycle.
class TransportEntity extends Equatable {
  /// Mediasoup server-assigned transport ID.
  final String id;

  /// ICE credentials (ufrag + password).
  final Map<String, dynamic> iceParameters;

  /// STUN/TURN candidates for ICE negotiation.
  final List<Map<String, dynamic>> iceCandidates;

  /// DTLS fingerprint used for SRTP key exchange.
  final Map<String, dynamic> dtlsParameters;

  /// Optional SCTP parameters; present only when data channels are enabled on the server.
  final Map<String, dynamic>? sctpParameters;

  const TransportEntity({
    required this.id,
    required this.iceParameters,
    required this.iceCandidates,
    required this.dtlsParameters,
    this.sctpParameters,
  });

  @override
  List<Object?> get props => [id, iceParameters, iceCandidates, dtlsParameters, sctpParameters];
}
