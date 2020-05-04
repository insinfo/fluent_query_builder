class NullPointerException implements Exception {
  final message;

  NullPointerException([this.message]);

  @override
  String toString() {
    if (message == null) return 'NullPointerException';
    return 'NullPointerException: $message';
  }
}
