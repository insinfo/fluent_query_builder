class NotFoundException implements Exception {
  final message;

  NotFoundException([this.message]);

  @override
  String toString() {
    if (message == null) return 'NotFoundException';
    return 'NotFoundException: $message';
  }
}
