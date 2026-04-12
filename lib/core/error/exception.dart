class ServerException implements Exception {
  final String message;
  ServerException(this.message);
}

class BadFilterException implements Exception {
  final String message;
  BadFilterException(this.message);
}
