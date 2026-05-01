/// App-level exceptions for the data layer.
class AppException implements Exception {
  final String message;
  final String? code;

  const AppException({required this.message, this.code});

  @override
  String toString() => 'AppException(message: $message, code: $code)';
}

class ServerException extends AppException {
  const ServerException({required super.message, super.code});
}

class AuthException extends AppException {
  const AuthException({required super.message, super.code});
}

class CacheException extends AppException {
  const CacheException({
    super.message = 'Cache operation failed',
    super.code,
  });
}

class NetworkException extends AppException {
  const NetworkException({
    super.message = 'No internet connection',
    super.code = 'network-error',
  });
}
