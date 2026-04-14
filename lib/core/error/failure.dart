import 'package:equatable/equatable.dart';

abstract class Failure extends Equatable {
  final String message;
  const Failure(this.message);

  @override
  List<Object?> get props => [message];
}

class ServerFailure extends Failure {
  const ServerFailure(super.message);
}

class InternetFailure extends Failure {
  const InternetFailure(super.message);
}

class BadFilterFailure extends Failure {
  const BadFilterFailure(super.message);
}

/// Thrown when the server signals the requested room ID does not exist.
class RoomNotFoundFailure extends Failure {
  const RoomNotFoundFailure(super.message);
}

/// Thrown when the server rejects a join request because the room has reached its peer limit.
class RoomFullFailure extends Failure {
  const RoomFullFailure(super.message);
}

/// Thrown when the OS denies mic or camera permission before media capture begins.
class MediaPermissionFailure extends Failure {
  const MediaPermissionFailure(super.message);
}

/// Thrown when WebRTC ICE/DTLS negotiation fails or a required transport is not initialized.
class TransportFailure extends Failure {
  const TransportFailure(super.message);
}
