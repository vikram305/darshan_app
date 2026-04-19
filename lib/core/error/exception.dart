class ServerException implements Exception {
  final String message;
  ServerException(this.message);
}

class BadFilterException implements Exception {
  final String message;
  BadFilterException(this.message);
}

class RoomNotFoundException implements Exception {
  final String message;
  RoomNotFoundException(this.message);
}

class RoomFullException implements Exception {
  final String message;
  RoomFullException(this.message);
}

class MediaPermissionException implements Exception {
  final String message;
  MediaPermissionException(this.message);
}

class TransportException implements Exception {
  final String message;
  TransportException(this.message);
}

