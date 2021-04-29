///param null or empty exception
class IllegalArgumentException implements Exception {
  IllegalArgumentException([this.message, this.erroCode=400]);
  final String? message;
  final int erroCode;

  @override
  String toString() {
    if (message == null) return 'IllegalArgumentException';
    return 'IllegalArgumentException: $message | ErroCode: $erroCode';
  }
}
