class NotFoundException implements Exception {
  String _cause;
  NotFoundException(this._cause);
}