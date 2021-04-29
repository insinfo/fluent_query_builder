/// Error thrown for invalid operations in [Filter].
class FilterError {
  final String message;
  FilterError(this.message);
}

/// Condition for [Filter].
class Condition {
  static const String EQ = '=';
  static const String NE = '<>';
  static const String GT = '>';
  static const String GTE = '>=';
  static const String LT = '<';
  static const String LTE = '<=';
  static const String IN = 'IN';
  static const String BETWEEN = 'BETWEEN';
  static const String LIKE = 'LIKE';
  static const String MATCHES = 'MATCHES';

  String key;
  dynamic value;
  String predicate;

  Condition(this.key, this.value, this.predicate) {
    /*if (key == null) {
      throw NullPointerException('Key of Condition is Null');
    }

    if (value == null) {
      throw NullPointerException('Value of Condition is Null');
    }

    if (predicate == null) {
      throw NullPointerException('Predicate of Condition is Null');
    }*/
  }

  @override
  String toString() => 'Condition($key $predicate $value)';
}

/// Criteria provides a way to filter entities fetched from [Repository] based
/// on certain conditions. Used in `findOne`, `find` and `count` methods of
/// [Repository] interface.
class Filter<T> {
  final List<Condition> conditions = <Condition>[];
  int? skip;
  int? take;

  /// Default constructor.
  Filter();

  /// Creates new criteria as a copy of [other].
  factory Filter.from(Filter<T> other) {
    return Filter<T>()
      ..conditions.addAll(other.conditions)
      ..skip = other.skip
      ..take = other.take;
  }
}
