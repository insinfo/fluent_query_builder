/// Helper utilities.

class Util {
  Util();

  static bool isEmpty(String? str) {
    return str == null || str.isEmpty;
  }

  static String join(String separator, Iterable<String?> values) {
    final sb = StringBuffer();
    for (var value in values) {
      if (sb.length > 0) {
        sb.write(separator);
      }
      sb.write(value);
    }
    return sb.toString();
  }

  static String joinNonEmpty(String separator, Iterable<String?> values) {
    final sb = StringBuffer();
    for (var value in values) {
      if (!isEmpty(value)) {
        if (sb.length > 0) {
          sb.write(separator);
        }
        sb.write(value);
      }
    }
    return sb.toString();
  }
}
