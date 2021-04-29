///Not Implemented Exception
class NotImplementedException  implements Exception {
  NotImplementedException ([this.message, this.erroCode=400]);
  final String? message;
  final int erroCode;

  @override
  String toString() {
    if (message == null) return 'NotImplementedException';
    return 'NotImplementedException: $message | ErroCode: $erroCode';
  }
}
