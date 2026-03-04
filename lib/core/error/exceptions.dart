class ServerException implements Exception {
  final String message;
  final int? statusCode;
  final dynamic response;

  ServerException({
    required this.message,
    this.statusCode,
    this.response,
  });

  @override
  String toString() => 'ServerException: $message (status: $statusCode)';
}

class NetworkException implements Exception {
  final String message;

  NetworkException({required this.message});

  @override
  String toString() => 'NetworkException: $message';
}
